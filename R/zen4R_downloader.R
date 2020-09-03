#' @name download_zenodo
#' @aliases download_zenodo
#' @title download_zenodo
#' @description \code{download_zenodo} allows to download archives attached to a Zenodo
#' record, identified by its DOI or concept DOI.
#'
#' @examples 
#' \dontrun{
#'  #simple download (sequential)   
#'  download_zenodo("10.5281/zenodo.2547036")
#'  
#'  library(parallel)
#'  #download files as parallel using a cluster approach (for both Unix/Win systems)
#'  download_zenodo("10.5281/zenodo.2547036", 
#'    parallel = TRUE, parallel_handler = parLapply, cl = makeCluster(2))
#'  
#'  #download files as parallel using mclapply (for Unix systems)
#'  download_zenodo("10.5281/zenodo.2547036",
#'    parallel = TRUE, parallel_handler = mclapply, mc.cores = 2)
#' }
#'                 
#' @param doi a Zenodo DOI or concept DOI
#' @param path the target directory where to download files
#' @param logger a logger to print Zenodo API-related messages. The logger can be either NULL, 
#' "INFO" (with minimum logs), or "DEBUG" (for complete curl http calls logs)
#' @param quiet Logical (\code{FALSE} by default).
#' Do you want to suppress informative messages (not warnings)?
#' @param ... any other arguments for parallel downloading (more information at
#'\link{ZenodoRecord}, \code{downloadFiles()} documentation)
#' 
#' @export
#' 
download_zenodo = function(doi, path = ".", logger = NULL, quiet = FALSE, ...){
  
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
  rec$downloadFiles(path = path, quiet = quiet, ...)
}

#' Human-readable binary file size
#'
#' Takes an integer (referring to number of bytes) and returns an optimally
#' human-readable
#' \href{https://en.wikipedia.org/wiki/Binary_prefix}{binary-prefixed}
#' byte size (KiB, MiB, GiB, TiB, PiB, EiB).
#' The function is vectorised.
#'
#' @author Floris Vanderhaeghe, \email{floris.vanderhaeghe@@inbo.be}
#'
#' @param x A positive integer, i.e. the number of bytes (B).
#' Can be a vector of file sizes.
#'
#' @return
#' A character vector.
#' 
#' @keywords internal
#'
human_filesize <- function(x) {
  magnitude <- pmin(floor(log(x, base = 1024)), 8)
  unit <- factor(magnitude,
                 levels = 0:8,
                 labels = c(
                   "B",
                   "KiB",
                   "MiB",
                   "GiB",
                   "TiB",
                   "PiB",
                   "EiB",
                   "ZiB",
                   "YiB")
  )
  size <- round(x / 1024^magnitude, 1)
  return(paste(size, unit))
}