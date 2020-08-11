#' @name download_zenodo
#' @aliases download_zenodo
#' @title download_zenodo
#' @description \code{download_zenodo} allows to download archives attached to a Zenodo
#' record, identified by its DOI or concept DOI.
#'
#' @examples 
#' \dontrun{
#' download_zenodo("10.5281/zenodo.2547036")
#' }
#'                 
#' @param doi a Zenodo DOI or concept DOI
#' @param path the target directory where to download files
#' @param logger a logger to print messages. The logger can be either NULL, 
#' "INFO" (with minimum logs), or "DEBUG" (for complete curl http calls logs)
#' @param ... any other arguments for parallel downloading (more information at
#'\link{ZenodoRecord}, \code{downloadFiles()} documentation)
#' 
#' @export
#' 
download_zenodo = function(doi, path = ".", logger = NULL, ...){
  
  zenodo <- ZenodoManager$new(logger = logger)
  rec <- zenodo$getRecordByDOI(doi)
  if(is.null(rec)){
    #try to get it as concept DOI
    rec <- zenodo$getRecordByConceptDOI(doi)
    if(is.null(rec)){
      stop("The DOI specified doesn't match any existing Zenodo DOI or concept DOI")
    }
  }
  #download
  rec$downloadFiles(path = path, ...)
}