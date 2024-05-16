#' @name get_versions
#' @aliases get_versions
#' @title get_versions
#' @description \code{get_versions} allows to execute a workflow
#'
#' @examples 
#' \dontrun{
#' get_versions("10.5281/zenodo.2547036")
#' }
#'                 
#' @param doi a Zenodo DOI or concept DOI
#' @param sandbox Use the sandbox infrastructure. Default is \code{FALSE}
#' @param logger a logger to print messages. The logger can be either NULL, 
#' "INFO" (with minimum logs), or "DEBUG" (for complete curl http calls logs)
#' @return an object of class \code{data.frame} giving the record versions
#' including date, version number and version-specific DOI. 
#' 
#' @export
#' 
get_versions = function(doi, sandbox = FALSE, logger = NULL){
  #get
  rec = get_zenodo(doi = doi, sandbox = sandbox, logger = logger)
  #versions
  versions <- rec$getVersions()
  return(versions)
}