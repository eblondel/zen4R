#' @name get_citation
#' @aliases get_citation
#' @title get_citation
#' @description \code{get_citation} allows to get the styled citation for Zenodo record, identified by 
#' its DOI or concept DOI, and the style name
#'
#' @examples 
#' \dontrun{
#'  get_citation(doi = "10.5281/zenodo.2547036", style = "ieee")
#' }
#'  
#' @param doi a Zenodo DOI or concept DOI
#' @param sandbox Use the sandbox infrastructure. Default is \code{FALSE}
#' @param style the style character string among. Possible values "havard-cite-them-right", "apa",
#' "modern-language-association","vancouver","chicago-fullnote-bibliography", "ieee", or "bibtex".
#' @param logger a logger to print messages. The logger can be either NULL, 
#' "INFO" (with minimum logs), or "DEBUG" (for complete curl http calls logs)
#' @return an object of class \code{data.frame} giving the record versions
#' including date, version number and version-specific DOI.
#' @return the record citation
#' 
#' @export
#' 
get_citation = function(doi, sandbox = FALSE, 
                        style = c("havard-cite-them-right", "apa",
                                  "modern-language-association", "vancouver",
                                  "chicago-fullnote-bibliography", "ieee"), 
                        logger = NULL){
  cit = NULL
  zenodo <- get_zenodo(doi = doi, sandbox = sandbox , logger = logger)
  if(!is.null(zenodo)) cit = zenodo$getCitation(style = style)
  return(cit)
}