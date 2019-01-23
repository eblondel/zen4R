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
#'  \item{\code{getLicenses(pretty)}}{
#'    Get the list of licenses. By default the argument \code{pretty} is set to 
#'    \code{TRUE} which will returns the list of licenses as \code{data.frame}.
#'    Set \code{pretty = FALSE} to get the raw list of licenses.
#'  }
#'  \item{\code{getLicenseById(id)}}{
#'    Get license by Id
#'  }
#'  \item{\code{getCommunities()}}{
#'    Get the list of communities.
#'  }
#'  \item{\code{getDepositions()}}{
#'    Get the list of Zenodo records deposited in your Zenodo workspace
#'  }
#'  \item{\code{depositRecord(record, publish)}}{
#'    A method to deposit/update a Zenodo record. The record should be an object
#'    of class \code{ZenodoRecord}. The method returns the deposited record
#'    of class \code{ZenodoRecord}. The parameter \code{publish} (default value
#'    is \code{FALSE}) can be set to \code{TRUE} (to use CAUTIOUSLY, only if you
#'    want to publish your record)
#'  }
#'  \item{\code{deleteRecord(recordId)}}{
#'    Deletes a Zenodo record based on its identifier.
#'  }
#'  \item{\code{createEmptyRecord()}}{
#'    Creates an empty record in the Zenodo deposit. Returns the record
#'    newly created in Zenodo, as an object of class \code{ZenodoRecord}
#'    with an assigned identifier.
#'  }
#'  \item{\code{publishRecord(recordId)}}{
#'    Publishes a deposited record online.
#'  }
#'  \item{\code{getFiles(recordId)}}{
#'    Get the list of uploaded files for a deposited record
#'  }
#'  \item{\code{uploadFile(path, recordId)}}{
#'    Uploads a file for a given Zenodo deposited record
#'  }
#'  \item{\code{deleteFile(recordId, fileId)}}{
#'    Deletes a file for a given Zenodo deposited record
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
    
    initialize = function(url = "https://zenodo.org/api", access_token = NULL, logger = NULL){
      super$initialize(logger = logger)
      private$url = url
      private$access_token <- access_token
    },
    
    #Licenses
    #------------------------------------------------------------------------------------------

    #getLicenses
    getLicenses = function(pretty = TRUE){
      zenReq <- ZenodoRequest$new(private$url, "GET", "licenses?q=&size=1000",
                                  access_token= private$access_token, logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        out <- out$hits$hits
        if(pretty){
          out = do.call("rbind", lapply(out,function(x){
            rec = x$metadata
            rec$`$schema` <- NULL
            rec$is_generic <- NULL
            rec$suggest <- NULL
            rec <- as.data.frame(rec)
            rec <- rec[,c("id", "title", "url", "domain_content", "domain_data", "domain_software", "family", 
                          "maintainer", "od_conformance", "osd_conformance", "status")]
            return(rec)
          }))
        }
        self$INFO("Successfuly fetched list of licenses")
      }else{
        self$ERROR(sprintf("Error while fetching licenses: %s", out$message))
      }
      return(out)
    },
    
    #getLicenseById
    getLicenseById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("licenses/%s",id),
                                  access_token= private$access_token, logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        self$INFO(sprintf("Successfuly fetched license '%s'",id))
      }else{
        self$ERROR(sprintf("Error while fetching license '%s': %s", id, out$message))
      }
      return(out)
    },
    
    #Communities
    #------------------------------------------------------------------------------------------
    
    #getCommunities
    getCommunities = function(pretty = TRUE){
      zenReq <- ZenodoRequest$new(private$url, "GET", "communities?q=&size=1000",
                                  access_token= private$access_token, logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        out <- out$hits$hits
        self$INFO("Successfuly fetched list of communities")
      }else{
        self$ERROR(sprintf("Error while fetching communities: %s", out$message))
      }
      return(out)
    },
    
    #Depositions
    #------------------------------------------------------------------------------------------
    
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
    depositRecord = function(record, publish = FALSE){
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
      
      if(publish){
        out <- self$publishRecord(record$id)
      }
      
      return(out)
    },
    
    #deleteRecord
    deleteRecord = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "DELETE", "deposit/depositions", 
                                  data = recordId, access_token = private$access_token,
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 204){
        out <- TRUE
        self$INFO(sprintf("Successful deleted file from record '%s'", recordId))
      }else{
        self$ERROR(sprintf("Error while deleting file from record '%s': %s", recordId, out$message))
      }
      return(out)
    },
    
    #createRecord
    createEmptyRecord = function(){
      return(self$depositRecord(NULL))
    },
    
    #publisRecord
    publishRecord = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("deposit/depositions/%s/actions/publish",recordId),
                                  access_token = private$access_token,
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 202){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        self$INFO(sprintf("Successful published record '%s'", recordId))
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while publishing record '%s': %s", recordId, out$message))
      }
      return(out)
    },
    
    #getFiles
    getFiles = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("deposit/depositions/%s/files", recordId), 
                                  access_token = private$access_token,
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 201){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        self$INFO(sprintf("Successful fetched file(s) for record '%s'", recordId))
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while fetching file(s) for record '%s': %s", recordId, out$message))
      }
      return(out)
    },
    
    #uploadFile
    uploadFile = function(path, recordId){
      fileparts <- strsplit(path,"/")
      filename <- fileparts[[length(fileparts)]]
      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("deposit/depositions/%s/files", recordId), 
                                  data = filename, file = upload_file(path),
                                  access_token = private$access_token,
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 201){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        self$INFO(sprintf("Successful uploaded file to record '%s'", recordId))
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while uploading file to record '%s': %s", recordId, out$message))
      }
      return(out)
    },
    
    #deleteFile
    deleteFile = function(recordId, fileId){
      zenReq <- ZenodoRequest$new(private$url, "DELETE", sprintf("deposit/depositions/%s/files", recordId), 
                                  data = fileId, access_token = private$access_token,
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 204){
        out <- TRUE
        self$INFO(sprintf("Successful deleted file from record '%s'", recordId))
      }else{
        self$ERROR(sprintf("Error while deleting file from record '%s': %s", recordId, out$message))
      }
      return(out)
    }
  )
)