#' zenodo_pat
#' @description Get Zenodo personal access token, looking in env var `ZENODO_PAT`
#' @param quiet Hide log message, default is \code{TRUE}
zenodo_pat <- function(quiet = TRUE) {
  pat <- Sys.getenv("ZENODO_PAT")
  
  if (nzchar(pat)) {
    if (!quiet) {
      message("Using Zenodo personal access token (PAT) from environment variable 'ZENODO_PAT'\n")
    }
    return(pat) 
  }
  NULL
}