.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    splitline()
  )
  packageStartupMessage(
    messageline("Welcome to My package !")
  )
  packageStartupMessage(
    messageline("Creted by Wang Jiaxuan")
  )
  packageStartupMessage(
    splitline()
  )
}
