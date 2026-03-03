#' ZenodoException
#'
#' @docType class
#' @export
#' @keywords Zenodo Exception
#' @return Object of \code{\link[R6]{R6Class}} for modelling a generic Zenodo service exception
#' @format \code{\link[R6]{R6Class}} object.
#' 
#' @note Abstract class used internally by \pkg{zen4R}
#' 
#' @author Emmanuel Blondel <emmanuel.blondel1@@gmail.com>
#'
ZenodoException <- R6Class("ZenodoException",
   inherit = zen4RLogger,                    
   public = list(
     
     #'@field message message
     message = NA,
     #'@field status status
     status = NA,
     
     #' @description Initializes a \code{ZenodoException}
     #' @param message message
     #' @param status status
     #' @param logger the logger type
     initialize = function(message, status, logger = NULL){
       super$initialize(logger = logger)
       self$message = message
       self$status = status
     }
   )
)
  