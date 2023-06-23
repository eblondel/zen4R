#' @name get_zenodo
#' @aliases get_zenodo
#' @title get_zenodo
#' @description \code{get_zenodo} allows to get a Zenodo record, identified by 
#' its DOI or concept DOI.
#'
#' @examples 
#' \dontrun{
#'  get_zenodo("10.5281/zenodo.2547036")
#' }
#'                 
#' @param doi a Zenodo DOI or concept DOI
#' @param logger a logger to print messages. The logger can be either NULL, 
#' "INFO" (with minimum logs), or "DEBUG" (for complete curl http calls logs)
#' @return an object of class \code{data.frame} giving the record versions
#' including date, version number and version-specific DOI.
#' @return object of class \code{ZenodoRecord}
#' 
#' @export
#' 
get_zenodo = function(doi, logger = NULL){
  zenodo <- suppressWarnings(ZenodoManager$new(logger = logger))
  rec <- zenodo$getRecordByDOI(doi)
  if(is.null(rec)){
    #try to get it as concept DOI
    rec <- zenodo$getRecordByConceptDOI(doi)
    if(is.null(rec)){
      stop("The DOI specified doesn't match any existing Zenodo DOI or concept DOI")
    }
  }
  return(rec)
}