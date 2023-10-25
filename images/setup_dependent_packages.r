#!/usr/bin/env Rscript

# NOTE: reference implementation is ~/src/cruise-control/scripts/setup_dependent_packages.r  

args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  req_pkgs <- c('Rcpp', 'knitr', 'roxygen2', 'lubridate', 'xts', 'devtools', 'ggplot2', 'dplyr', 'plyr', 'testthat', 'mvtnorm', 'rmarkdown', 'readr', 'DiagrammeR', 'ncdf4', 'udunits2')
} else {
  req_pkgs <- args
}

pkg_names <- installed.packages()[,'Package']
missing_pkgs <- req_pkgs[ !(req_pkgs %in% pkg_names) ]

cran_repos <- Sys.getenv("CRAN_REPOS")
cran_repos <- ifelse(cran_repos == "", 'http://cran.csiro.au', cran_repos)

if (length(missing_pkgs) > 0) {
  cat(paste("Installing: ", paste(missing_pkgs, collapse=', '), "\n"))
  if (Sys.info()['sysname'] == "Windows") {
    install.packages(missing_pkgs, lib=.libPaths()[1] , quiet=TRUE, type='win.binary', repos=cran_repos)
  } else {
    install.packages(missing_pkgs, lib=.libPaths()[1] , quiet=FALSE, type='source', repos=cran_repos)
  }
}
 # Check that all the required packages could be installed:
pkg_names <- installed.packages()[,'Package']
missing_pkgs <- req_pkgs[ !(req_pkgs %in% pkg_names) ]
quit(save = 'no', status = ifelse (length(missing_pkgs) > 0, 1, 0), runLast = FALSE) 
