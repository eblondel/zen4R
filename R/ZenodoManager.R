#' ZenodoManager
#' @docType class
#' @export
#' @keywords zenodo manager
#' @return Object of \code{\link{R6Class}} for modelling an ZenodoManager
#' @format \code{\link{R6Class}} object.
#' @section Methods:
#' \describe{
#'  \item{\code{new(url, access_token, logger)}}{
#'    This method is used to instantiate an ZenodoManager. By default,
#'    the url is set to "https://zenodo.org/api". The access_token is
#'    mandatory in order to use Zenodo API. The logger can be either
#'    NULL, "INFO" (with minimum logs), or "DEBUG" (for complete curl 
#'    http calls logs)
#'  }
#'  \item{\code{getDepositions()}}{
#'    Get the list of Zenodo records deposited in your Zenodo workspace
#'  }
#'  \item{\code{depositRecord(record)}}{
#'    A method to deposit a Zenodo record. The record should be an object
#'    of class \code{ZenodoRecord}. The method returns the deposited record
#'    of class \code{ZenodoRecord}.
#'  }
#'  \item{\code{createEmptyRecord()}}{
#'    Creates an empty record in the Zenodo deposit. Returns the record
#'    newly created in Zenodo, as an object of class \code{ZenodoRecord}
#'    with an assigned identifier.
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
      records <- lapply(zenReq$getResponse(), ZenodoRecord$new)
      return(records)
    },
    
    #depositRecord
    depositRecord = function(record){
      zenReq <- ZenodoRequest$new(private$url, "POST", "deposit/depositions",
                                  private$access_token, data = record,
                                  logger = self$loggerType)
      zenReq$execute()
      record <- ZenodoRecord$new(obj = zenReq$getResponse())
      return(record)
    },
    
    #createRecord
    createEmptyRecord = function(){
      return(self$depositRecord(ZenodoRecord$new()))
    }
  )
)