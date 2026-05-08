#' Calculate difference in slopes between two linear models
#'
#' @param x1 Numeric vector for x of group 1.
#' @param y1 Numeric vector for y of group 1.
#' @param x2 Numeric vector for x of group 2.
#' @param y2 Numeric vector for y of group 2.
#' @param permutations Integer, number of permutations.
#' @param ic Logical, whether to calculate intercept difference.
#' @param resc.x Logical, rescale x.
#' @param resc.y Logical, rescale y.
#' @param trace Logical, print trace.
#' @param ... Additional arguments.
#'
#' @return An S3 object of class `dsl` or `dsl2`.
#' @export
diffslope <- function(x1, y1, x2, y2, permutations = 1000, ic = FALSE, resc.x = FALSE, resc.y = TRUE, trace = FALSE, ...) {
  if (resc.x) {
    maxS <- max(mean(x1), mean(x2))
    x1 <- x1 + (maxS - mean(x1))
    x2 <- x2 + (maxS - mean(x2))
  }
  if (resc.y) {
    maxD <- max(mean(y1), mean(y2))
    y1 <- y1 + (maxD - mean(y1))
    y2 <- y2 + (maxD - mean(y2))
  }

  m1 <- data.frame(y = as.numeric(y1), x = as.numeric(x1))
  m2 <- data.frame(y = as.numeric(y2), x = as.numeric(x2))

  m1.lm <- stats::lm(y ~ x, data = m1)
  m2.lm <- stats::lm(y ~ x, data = m2)
  ds0 <- as.numeric(m1.lm$coefficients[2] - m2.lm$coefficients[2])

  if (ic) {
    m12.lmcoeff <- matrix(data = NA, nrow = permutations, ncol = 2)
    m21.lmcoeff <- matrix(data = NA, nrow = permutations, ncol = 2)
    dic <- as.numeric(m1.lm$coefficients[1] - m2.lm$coefficients[1])

    if (trace) cat(permutations, "perms: ")
    for (i in 1:permutations) {
      tmp1 <- sample(nrow(m1), nrow(m1) / 2)
      tmp2 <- sample(nrow(m2), nrow(m2) / 2)
      m12 <- rbind(m1[tmp1, ], m2[tmp2, ])
      m21 <- rbind(m1[-tmp1, ], m2[-tmp2, ])
      m12.lmcoeff[i, ] <- as.numeric(stats::lm(y ~ x, data = m12)$coefficients)
      m21.lmcoeff[i, ] <- as.numeric(stats::lm(y ~ x, data = m21)$coefficients)
      if (trace) cat(paste(i, ""))
    }

    perms <- m12.lmcoeff - m21.lmcoeff
    signif <- if (ds0 >= 0) length(perms[perms[, 2] >= ds0, 2]) / permutations else length(perms[perms[, 2] <= ds0, 2]) / permutations
    signific <- if (dic >= 0) length(perms[perms[, 1] >= ds0, 1]) / permutations else length(perms[perms[, 1] <= ds0, 1]) / permutations

    if (signif == 0) signif <- 1 / permutations
    if (signific == 0) signific <- 1 / permutations
  } else {
    perms <- vector("numeric", permutations)
    if (trace) cat(permutations, "perms: ")
    for (i in 1:permutations) {
      tmp1 <- sample(nrow(m1), nrow(m1) / 2)
      tmp2 <- sample(nrow(m2), nrow(m2) / 2)
      m12 <- rbind(m1[tmp1, ], m2[tmp2, ])
      m21 <- rbind(m1[-tmp1, ], m2[-tmp2, ])
      perms[i] <- as.numeric(stats::lm(y ~ x, data = m12)$coefficients[2] - stats::lm(y ~ x, data = m21)$coefficients[2])
      if (trace) cat(paste(i, ""))
    }
    signif <- if (ds0 >= 0) length(perms[perms >= ds0]) / permutations else length(perms[perms <= ds0]) / permutations
    if (signif == 0) signif <- 1 / permutations
    perms <- cbind(perms, perms)
  }

  res <- c(call = match.call())
  res$slope.diff <- as.numeric(ds0)
  res$signif <- signif
  res$permutations <- permutations
  res$perms <- perms[, 2]
  class(res) <- "dsl"

  if (ic) {
    res$intercept <- as.numeric(dic)
    res$signific <- as.numeric(signific)
    res$permsic <- as.numeric(perms[, 1])
    class(res) <- "dsl2"
  }
  return(res)
}

#' Calculate comprehensive model metrics
#'
#' @param truth Numeric vector of true values.
#' @param response Numeric vector of predicted values.
#'
#' @return A matrix with MAE, MSE, RMSE, Rho, and R2.
#' @export
calculate_metrics <- function(truth, response) {
  residuals <- response - truth
  mae <- mean(abs(residuals))
  mse <- mean(residuals^2)
  rmse <- sqrt(mse)
  rho <- stats::cor(truth, response)
  sst <- sum((truth - mean(truth))^2)
  ssr <- sum(residuals^2)
  r2 <- 1 - (ssr / sst)

  matrix(c(mae, mse, rmse, rho, r2), nrow = 1,
         dimnames = list(NULL, c("MAE", "MSE", "RMSE", "Rho", "R2")))
}

#' Calculate R-squared
#'
#' @param actual Numeric vector of true values.
#' @param predicted Numeric vector of predicted values.
#' @export
metric_rsquared <- function(actual, predicted) {
  1 - (sum((actual - predicted)^2) / sum((actual - mean(actual))^2))
}

#' Calculate Mean Squared Error (MSE)
#'
#' @param actual Numeric vector of true values.
#' @param predicted Numeric vector of predicted values.
#' @export
metric_mse <- function(actual, predicted) {
  mean((actual - predicted)^2)
}

#' Calculate Root Mean Squared Error (RMSE)
#'
#' @param actual Numeric vector of true values.
#' @param predicted Numeric vector of predicted values.
#' @export
metric_rmse <- function(actual, predicted) {
  sqrt(mean((actual - predicted)^2))
}

#' Calculate correlation between microbiome and metabolites
#'
#' @param microbiome Dataframe of microbiome abundance.
#' @param metabolites Dataframe of metabolites abundance.
#' @param name Character vector of length 2 for column names.
#' @param method Character, correlation method ("spearman", "pearson").
#'
#' @return A list containing association data, correlations, q-values, and p-values.
#' @export
cor_spearman <- function(microbiome, metabolites, name, method = "spearman") {
  common_rows <- intersect(row.names(microbiome), row.names(metabolites))
  microbiome <- microbiome[common_rows, , drop = FALSE]
  metabolites <- metabolites[common_rows, , drop = FALSE]

  pvals <- matrix(NA, ncol = ncol(microbiome), nrow = ncol(metabolites))
  cors <- matrix(NA, ncol = ncol(microbiome), nrow = ncol(metabolites))

  for (i in 1:ncol(microbiome)) {
    for (j in 1:ncol(metabolites)) {
      valid_idx <- !is.na(microbiome[, i]) & !is.na(metabolites[, j])
      a <- microbiome[valid_idx, i]
      b <- metabolites[valid_idx, j]

      if (length(a) > 2 && length(b) > 2) {
        cor_res <- stats::cor.test(a, b, method = method)
        pvals[j, i] <- cor_res$p.value
        cors[j, i] <- cor_res$estimate
      }
    }
  }

  qvals <- matrix(stats::p.adjust(pvals, method = "BH"), ncol = ncol(pvals))
  colnames(qvals) <- colnames(microbiome)
  rownames(qvals) <- colnames(metabolites)
  colnames(cors) <- colnames(microbiome)
  rownames(cors) <- colnames(metabolites)

  ind <- which(pvals <= 1, arr.ind = TRUE)
  association <- data.frame(
    metabolites = colnames(metabolites)[ind[, 1]],
    microbiome = colnames(microbiome)[ind[, 2]],
    Cor = cors[ind],
    Pval = pvals[ind],
    Qval = qvals[ind],
    stringsAsFactors = FALSE
  )

  association$name <- paste(association$metabolites, association$microbiome, sep = "_with_")
  colnames(association)[1:2] <- name[c(2, 1)]

  qvals[is.na(qvals)] <- 1
  cors <- cors[row.names(qvals), colnames(qvals)]

  pvals[pvals < 0.05] <- "."
  pvals[qvals < 0.05] <- "*"
  pvals[pvals > 0.05] <- NA
  qvals[qvals < 0.05] <- "*"
  qvals[qvals > 0.05] <- NA

  return(list(association, cors, qvals, pvals))
}
