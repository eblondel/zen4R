#' ZenodoManager
#' @docType class
#' @export
#' @keywords zenodo manager
#' @return Object of \code{\link{R6Class}} for modelling an ZenodoManager
#' @format \code{\link{R6Class}} object.
#' @section Methods:
#' \describe{
#'  \item{\code{new()}}{
#'    This method is used to instantiate an ZenodoManager
#'  }
#' }
#' @note Main user class to be used with \pkg{zen4R}
#' 
#' @author Emmanuel Blondel <emmanuel.blondel1@@gmail.com>
#' 
ZenodoManager <-  R6Class("ZenodoManager",
  inherit = zen4RLogger,
  private = list(
    url = "https://zenodo.org/api",
    access_token = NULL
  ),
  public = list(
    #logger
    verbose.info = FALSE,
    verbose.debug = FALSE,
    loggerType = NULL,
    logger = function(type, text){
      if(self$verbose.info){
        cat(sprintf("[zen4R][%s] %s - %s \n", type, self$getClassName(), text))
      }
    },
    INFO = function(text){self$logger("INFO", text)},
    WARN = function(text){self$logger("WARN", text)},
    ERROR = function(text){self$logger("ERROR", text)},
    
    initialize = function(url = "https://zenodo.org/api", access_token, logger = NULL){
      super$initialize(logger = logger)
      private$url = url
      private$access_token <- access_token
    },
    
    #getDepositions
    getDepositions = function(){
      zenReq <- ZenodoRequest$new(private$url, "GET", "deposit/depositions", 
                                  private$access_token, logger = self$loggerType)
      zenReq$execute()
      return(zenReq)
    }
  )
)