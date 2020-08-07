#' @name get_versions
#' @aliases get_versions
#' @title get_versions
#' @description \code{get_versions} allows to execute a workflow
#'
#' @usage get_versions("10.5281/zenodo.2547036")
#'                 
#' @param doi a Zenodo DOI or concept DOI
#' @param logger a logger to print messages. The logger can be either NULL, 
#' "INFO" (with minimum logs), or "DEBUG" (for complete curl http calls logs)
#' @return an object of class \code{data.frame} giving the record versions
#' including date, version number and version-specific DOI. 
#' 
#' @export
#' 
get_versions = function(doi, logger = NULL){
  
  zenodo <- ZenodoManager$new(logger = logger)
  rec <- zenodo$getRecordByDOI(doi)
  if(is.null(rec)){
    #try to get it as concept DOI
    rec <- zenodo$getRecordByConceptDOI(doi)
    if(is.null(rec)){
      stop("The DOI specified doesn't match any existing Zenodo DOI or concept DOI")
    }
  }
  #versions
  versions <- rec$getVersions()
  return(versions)
}