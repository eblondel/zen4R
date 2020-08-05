#' Retrieve Zenodo personal access token.
#'
#' A zenodo personal access token
#' Looks in env var `ZENODO_PAT`
#'
#' @keywords internal
#' @noRd
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