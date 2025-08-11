#' @name zen4R
#' @aliases zen4R-package
#' @aliases zen4R
#'
#' @importFrom R6 R6Class
#' @import cli
#' @import methods
#' @import httr
#' @import jsonlite
#' @import xml2
#' @import XML
#' @import keyring
#' @importFrom tools file_path_as_absolute
#' @importFrom tools md5sum
#' @importFrom utf8 utf8_encode
#' @importFrom plyr rbind.fill
#' 
#' @title Interface to 'Zenodo' REST API
#' @description Provides an Interface to 'Zenodo' (<https://zenodo.org>) REST API, 
#'   including management of depositions, attribution of DOIs by 'Zenodo', 
#'   upload and download of files.
#'  
#'@author Emmanuel Blondel \email{emmanuel.blondel1@@gmail.com}
#'
"_PACKAGE"