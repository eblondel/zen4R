#' @name get_licenses
#' @aliases get_licenses
#' @title get_licenses
#' @description \code{get_licenses} allows to list all licenses supported by Zenodo.
#'
#' @examples 
#' \dontrun{
#'  get_licenses(pretty = TRUE)
#' }
#'                 
#' @param pretty output delivered as \code{data.frame}
#' @return the licenses as \code{list} or \code{data.frame}
#' @export
#'
get_licenses <- function(pretty = TRUE){
  zenodo = ZenodoManager$new()
  return(zenodo$getLicenses(pretty = pretty))
}