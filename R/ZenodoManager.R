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
                                  access_token = private$access_token, logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        out <- lapply(zenReq$getResponse(), ZenodoRecord$new)
        self$INFO("Successfuly fetched list of depositions")
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while fetching depositions: %s", out$message))
        for(error in out$errors){
          self$ERROR(sprintf("Error: %s - %s", error$field, error$message))
        }
      }
      return(out)
    },
    
    #depositRecord
    depositRecord = function(record){
      data <- record
      type <- ifelse(is.null(record$id), "POST", "PUT")
      request <- ifelse(is.null(record$id), "deposit/depositions", 
                        sprintf("deposit/depositions/%s", record$id))
      zenReq <- ZenodoRequest$new(private$url, type, request, data = data,
                                  access_token = private$access_token,
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() %in% c(200,201)){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        self$INFO("Successful record deposition")
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while depositing record: %s", out$message))
        for(error in out$errors){
          self$ERROR(sprintf("Error: %s - %s", error$field, error$message))
        }
      }
      return(out)
    },
    
    #createRecord
    createEmptyRecord = function(){
      return(self$depositRecord(ZenodoRecord$new()))
    }
  )
)