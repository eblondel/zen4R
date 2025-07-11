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
#' @param files subset of filenames to restrain to download. If ignored, all files will be downloaded.
#' @param sandbox Use the sandbox infrastructure. Default is \code{FALSE}
#' @param logger a logger to print Zenodo API-related messages. The logger can be either NULL, 
#' "INFO" (with minimum logs), or "DEBUG" (for complete curl http calls logs)
#' @param quiet Logical (\code{FALSE} by default).
#' Do you want to suppress informative messages (not warnings)?
#' @param ... any other arguments for downloading (more information at
#'\link{ZenodoRecord}, \code{downloadFiles()} documentation)
#' 
#' @export
#' 
download_zenodo = function(doi, path = ".", files = list(), sandbox = FALSE, logger = NULL, quiet = FALSE, ...){
  #rec
  rec = get_zenodo(doi = doi, sandbox = sandbox, logger = logger)
  #download
  rec$downloadFiles(path = path, files = files, quiet = quiet, ...)
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