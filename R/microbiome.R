# CRAN check Note
utils::globalVariables(c("."))

#' Permutational Multivariate Analysis of Variance Using Distance Matrices
#'
#' @param formula Model formula.
#' @param data Data frame.
#' @param permutations Number of permutations (default 999).
#' @param method Distance method.
#' @param sqrt.dist Logical, whether to take the square root of distances.
#' @param add Logical or character, whether to add a constant to distances.
#' @param by Character, margin or terms.
#' @param parallel Number of parallel cores.
#' @param na.action Function for handling NAs.
#' @param strata Permutation strata.
#' @param ... Additional arguments.
#'
#' @return An ANOVA table.
#' @export
#'
#' @importFrom stats model.frame delete.response terms update anova nobs na.fail
#' @importFrom vegan vegdist
adonis3 <- function(formula, data, permutations = 999, method = "bray",
                    sqrt.dist = FALSE, add = FALSE, by = "terms",
                    parallel = getOption("mc.cores"), na.action = stats::na.fail,
                    strata = NULL, ...) {
  ## handle missing data
  if (missing(data)) {
    data <- stats::model.frame(stats::delete.response(stats::terms(formula)),
                               na.action = na.action)
  }

  ## we accept only by = "terms", "margin" or NULL
  if (!is.null(by)) by <- match.arg(by, c("terms", "margin", "onedf"))

  ## evaluate lhs
  YVAR <- formula[[2]]
  lhs <- eval(YVAR, environment(formula), globalenv())
  environment(formula) <- environment()

  ## Take care that input lhs are dissimilarities
  if ((is.matrix(lhs) || is.data.frame(lhs)) && isSymmetric(unname(as.matrix(lhs)))) {
    lhs <- stats::as.dist(lhs)
  }
  if (!inherits(lhs, "dist")) {
    lhs <- vegan::vegdist(as.matrix(lhs), method = method, ...)
  }

  ## adjust distances if requested
  if (sqrt.dist) lhs <- sqrt(lhs)

  if (is.logical(add) && isTRUE(add)) add <- "lingoes"
  if (is.character(add)) {
    add <- match.arg(add, c("lingoes", "cailliez"))
    if (add == "lingoes") {
      ac <- addLingoes(as.matrix(lhs))
      lhs <- sqrt(lhs^2 + 2 * ac)
    } else if (add == "cailliez") {
      ac <- addCailliez(as.matrix(lhs))
      lhs <- lhs + ac
    }
  }

  ## adonis0 & anova.cca should see only dissimilarities (lhs)
  if (!missing(data)) formula <- stats::terms(formula, data = data)

  if (is.null(attr(data, "terms"))) {
    data <- stats::model.frame(stats::delete.response(stats::terms(formula)), data,
                               na.action = na.action)
  }

  formula <- stats::update(formula, lhs ~ .)
  sol <- adonis0(formula, data = data, method = method)

  ## handle permutations
  perm <- getPermuteMatrix(permutations, NROW(data), strata = strata)
  out <- stats::anova(sol, permutations = perm, by = by, parallel = parallel)

  ## attributes will be lost when adding a new column
  att <- attributes(out)

  ## add traditional adonis output on R2
  out <- rbind(out, "Total" = c(stats::nobs(sol) - 1, sol$tot.chi, NA, NA))
  out <- cbind(out[, 1:2], "R2" = out[, 2] / sol$tot.chi, out[, 3:4])

  ## Fix output header to show the adonis2() call instead of adonis0()
  att$heading[2] <- deparse(match.call(), width.cutoff = 500L)
  att$names <- names(out)
  att$row.names <- rownames(out)
  attributes(out) <- att

  return(out)
}

# adonis0
#' @importFrom stats terms formula model.matrix na.action
adonis0 <- function(formula, data = NULL, method = "bray") {
  Trms <- stats::terms(data)
  sol <- list(call = match.call(),
              method = "adonis",
              terms = Trms,
              terminfo = list(terms = Trms))
  sol$call$formula <- stats::formula(Trms)
  TOL <- 1e-7
  lhs <- formula[[2]]
  lhs <- eval(lhs, environment(formula))
  formula[[2]] <- NULL

  rhs <- stats::model.matrix(formula, data)
  assign <- attr(rhs, "assign")
  sol$terminfo$assign <- assign[assign > 0]
  rhs <- rhs[, -1, drop = FALSE]
  rhs <- scale(rhs, scale = FALSE, center = TRUE)
  qrhs <- qr(rhs)

  if (!inherits(lhs, "dist")) stop("internal error: contact developers")
  if (any(lhs < -TOL)) stop("dissimilarities must be non-negative")

  if (!is.null(nas <- stats::na.action(data))) {
    lhs <- as.matrix(lhs)[-nas, -nas, drop = FALSE]
    n <- nrow(lhs)
  } else {
    n <- attr(lhs, "Size")
  }

  G <- initDBRDA(lhs)
  Gfit <- qr.fitted(qrhs, G)
  Gres <- qr.resid(qrhs, G)

  if (!is.null(qrhs$rank) && qrhs$rank > 0) {
    CCA <- list(rank = qrhs$rank, qrank = qrhs$rank, tot.chi = sum(diag(Gfit)), QR = qrhs)
  } else {
    CCA <- NULL
  }

  CA <- list(rank = n - max(qrhs$rank, 0) - 1, u = matrix(0, nrow = n), tot.chi = sum(diag(Gres)))

  sol$tot.chi <- sum(diag(G))
  sol$adjust <- 1
  sol$Ybar <- G
  sol$CCA <- CCA
  sol$CA <- CA
  class(sol) <- c("adonis2", "dbrda", "rda", "cca")

  return(sol)
}

# initDBRDA
initDBRDA <- function(Y) {
  Y <- as.matrix(Y)
  dims <- dim(Y)
  if (dims[1] != dims[2] || !isSymmetric(unname(Y))) {
    stop("input Y must be distances or a symmetric square matrix")
  }
  Y <- -0.5 * GowerDblcen(Y^2)
  attr(Y, "METHOD") <- "DISTBASED"
  return(Y)
}

GowerDblcen <- function(x, na.rm = TRUE) {
  cnt <- colMeans(x, na.rm = na.rm)
  x <- sweep(x, 2L, cnt, check.margin = FALSE)
  cnt <- rowMeans(x, na.rm = na.rm)
  sweep(x, 1L, cnt, check.margin = FALSE)
}

#' @importFrom permute how getBlocks setBlocks<- shuffleSet
getPermuteMatrix <- function(perm, N, strata = NULL) {
  if (length(perm) == 1) perm <- permute::how(nperm = perm)
  if (!missing(strata) && !is.null(strata)) {
    if (inherits(perm, "how") && is.null(permute::getBlocks(perm))) {
      permute::setBlocks(perm) <- strata
    }
  }
  if (inherits(perm, "how")) {
    perm <- permute::shuffleSet(N, control = perm)
  } else {
    if (!is.integer(perm) && !all(perm == round(perm))) {
      stop("permutation matrix must be strictly integers: use round()")
    }
  }
  if (is.null(attr(perm, "control"))) {
    attr(perm, "control") <- structure(list(within = list(type = "supplied matrix"), nperm = nrow(perm)), class = "how")
  }
  return(perm)
}

#' Calculate alpha diversity indices
#'
#' @param x Species abundance matrix.
#' @param tree Optional phylogenetic tree for PD calculation.
#'
#' @return A data frame containing multiple alpha diversity metrics.
#' @export
#'
#' @importFrom vegan estimateR diversity
alpha_diversity <- function(x, tree = NULL) {
  observed_species <- vegan::estimateR(x)[1, ]
  Chao1 <- vegan::estimateR(x)[2, ]
  ACE <- vegan::estimateR(x)[4, ]
  Shannon <- vegan::diversity(x, index = 'shannon', base = 2)
  Simpson <- vegan::diversity(x, index = 'simpson')
  goods_Coverage <- 1 - rowSums(x == 1) / rowSums(x)

  Shannon <- sprintf("%0.4f", Shannon)
  Simpson <- sprintf("%0.4f", Simpson)
  goods_Coverage <- sprintf("%0.4f", goods_Coverage)

  result <- data.frame(observed_species, ACE, Chao1, Shannon, Simpson, goods_Coverage, stringsAsFactors = FALSE)

  if (!is.null(tree)) {
    if (!requireNamespace("picante", quietly = TRUE)) stop("Package 'picante' is required for PD calculation.")
    PD_whole_tree <- picante::pd(x, tree, include.root = FALSE)[1]
    names(PD_whole_tree) <- 'PD_whole_tree'
    result <- cbind(result, PD_whole_tree)
    result <- data.frame(observed_species, ACE, Chao1, Shannon, Simpson, PD_whole_tree, goods_Coverage, stringsAsFactors = FALSE)
  }

  return(result)
}

#' Read and align microbiome abundance and metadata
#'
#' @param file_path Character, path to the excel file.
#' @param verbose Logical, print matching report or not.
#'
#' @return A list containing aligned `exp` and `meta` dataframes.
#' @export
#'
#' @importFrom readxl read_excel
#' @importFrom dplyr filter arrange %>%
read_mib <- function(file_path, verbose = FALSE) {
  exp_raw <- readxl::read_excel(file_path, sheet = "exp")
  meta_raw <- readxl::read_excel(file_path, sheet = "meta")

  exp_samples <- colnames(exp_raw)[-1]
  meta_samples <- as.character(meta_raw[[1]])
  common_ids <- intersect(exp_samples, meta_samples)

  if (verbose) {
    cat(sprintf("Exp样本数: %d\nMeta样本数: %d\n共有样本数: %d\n",
                length(exp_samples), length(meta_samples), length(common_ids)))

    only_in_exp <- setdiff(exp_samples, meta_samples)
    only_in_meta <- setdiff(meta_samples, exp_samples)
    if (length(only_in_exp) > 0) cat("Exp独有(Meta缺失):", paste(only_in_exp, collapse = ", "), "\n")
    if (length(only_in_meta) > 0) cat("Meta独有(Exp缺失):", paste(only_in_meta, collapse = ", "), "\n")
  }

  meta <- meta_raw %>%
    dplyr::filter(as.character(.[[1]]) %in% common_ids) %>%
    dplyr::arrange(match(as.character(.[[1]]), common_ids))

  exp <- exp_raw[, c(1, match(meta[[1]], colnames(exp_raw)[-1]) + 1)]

  stopifnot(all(colnames(exp)[-1] == as.character(meta[[1]])))
  return(list(exp = exp, meta = meta))
}

# Internal helper for Lingoes adjustment
addLingoes <- function(d) {
  d <- -GowerDblcen(d^2)/2
  e <- eigen(d, symmetric = TRUE, only.values = TRUE)$values
  max(0, -min(e))
}

# Internal helper for Cailliez adjustment
addCailliez <- function(d) {
  n <- nrow(d)
  q1 <- seq_len(n)
  q2 <- n + q1
  A <- matrix(0, 2 * n, 2 * n)
  A[q1, q2] <- -diag(n)
  A[q2, q1] <- -GowerDblcen(d^2)/2
  A[q2, q2] <- GowerDblcen(d)
  e <- eigen(A, symmetric = FALSE, only.values = TRUE)$values
  max(0, Re(e))
}
