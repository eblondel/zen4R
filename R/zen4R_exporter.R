#' @name export_zenodo
#' @aliases export_zenodo
#' @title export_zenodo
#' @description \code{export_zenodo} allows to export a Zenodo record, identified by its 
#' DOI or concept DOI, using one of the export formats supported by Zenodo.
#'
#' @examples 
#' \dontrun{
#'  export_zenodo("10.5281/zenodo.2547036", filename = "test", format = "BibTeX", append_format = F)
#' }
#'                 
#' @param doi a Zenodo DOI or concept DOI
#' @param filename a base file name (without file extension) to export to.
#' @param format a valid Zenodo export format among the following: BibTeX, CSL, DataCite, DublinCore, 
#' DCAT, JSON, JSON-LD, GeoJSON, MARCXML.
#' @param append_format wether format name has to be appended to the filename. Default is \code{TRUE} (for
#' backward compatibility reasons). Set it to \code{FALSE} if you want to use only the \code{filename}.
#' @param logger a logger to print Zenodo API-related messages. The logger can be either NULL, 
#' "INFO" (with minimum logs), or "DEBUG" (for complete curl http calls logs)
#' @return the exported file name (with extension)
#' @export
#' 
export_zenodo = function(doi, filename, format, append_format = TRUE, logger = NULL){
  
  zenodo <- suppressWarnings(ZenodoManager$new(logger = logger))
  rec <- zenodo$getRecordByDOI(doi)
  if(is.null(rec)){
    #try to get it as concept DOI
    rec <- zenodo$getRecordByConceptDOI(doi)
    if(is.null(rec)){
      stop("The DOI specified doesn't match any existing Zenodo DOI or concept DOI")
    }
  }
  #download
  rec$exportAs(filename = filename, format = format, append_format = append_format)
}