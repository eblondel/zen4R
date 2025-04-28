#' zen4RLogger
#'
#' @docType class
#' @export
#' @keywords logger
#' @return Object of \code{\link[R6]{R6Class}} for modelling a simple logger
#' @format \code{\link[R6]{R6Class}} object.
#' 
#' @note Logger class used internally by zen4R
#'
zen4RLogger <-  R6Class("zen4RLogger",
  public = list(
    #' @field verbose.info logger info status
    verbose.info = FALSE,
    #' @field verbose.debug logger debug status
    verbose.debug = FALSE,
    #' @field loggerType Logger type, either "INFO", "DEBUG" or NULL (if no logger)
    loggerType = NULL,
    
    #' @description internal logger function for the Zenodo manager
    #' @param type logger message type, "INFO", "WARN", or "ERROR"
    #' @param text log message
    logger = function(type, text){
      if(self$verbose.info){
        cat(sprintf("[zen4R][%s] %s - %s \n", type, self$getClassName(), text))
      }
    },
    
    #' @description internal INFO logger function
    #' @param text log message
    INFO = function(text){self$logger("INFO", text)},
    
    #' @description internal WARN logger function
    #' @param text log message
    WARN = function(text){self$logger("WARN", text)},
    
    #' @description internal ERROR logger function
    #' @param text log message
    ERROR = function(text){self$logger("ERROR", text)},
    
    #' @description initialize the Zenodo logger
    #' @param logger logger type NULL, 'INFO', or 'DEBUG'
    initialize = function(logger = NULL){
      
      #logger
      if(!missing(logger)){
        if(!is.null(logger)){
          self$loggerType <- toupper(logger)
          if(!(self$loggerType %in% c("INFO","DEBUG"))){
            stop(sprintf("Unknown logger type '%s", logger))
          }
          if(self$loggerType == "INFO"){
            self$verbose.info = TRUE
          }else if(self$loggerType == "DEBUG"){
            self$verbose.info = TRUE
            self$verbose.debug = TRUE
          }
        }
      }
    },
    
    #'@description Get object class name
    #'@return the class name, object of class \code{character}
    getClassName = function(){
      return(class(self)[1])
    },
    
    #'@description Get object class
    #'@return the class, object of class \code{R6}
    getClass = function(){
      class <- eval(parse(text=self$getClassName()))
      return(class)
    }
    
  )
)