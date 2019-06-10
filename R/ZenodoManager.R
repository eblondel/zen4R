#' ZenodoManager
#' @docType class
#' @export
#' @keywords zenodo manager
#' @return Object of \code{\link{R6Class}} for modelling an ZenodoManager
#' @format \code{\link{R6Class}} object.
#' @section Methods:
#' \describe{
#'  \item{\code{new(url, token, logger)}}{
#'    This method is used to instantiate an ZenodoManager. By default,
#'    the url is set to "https://zenodo.org/api". The token is
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
#'  \item{\code{getCommunities(pretty)}}{
#'    Get the list of communities. By default the argument \code{pretty} is set to 
#'    \code{TRUE} which will returns the list of communities as \code{data.frame}.
#'    Set \code{pretty = FALSE} to get the raw list of communities.
#'  }
#'  \item{\code{getCommunityById(id)}}{
#'    Get community by Id
#'  }
#'  \item{\code{getDepositions(size)}}{
#'    Get the list of Zenodo records deposited in your Zenodo workspace. By defaut
#'    the list of depositions will be returned by page with a size of 10 results per
#'    page (default size of the Zenodo API).
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
#'  \item{\code{deleteRecords()}}{
#'    Deletes all Zenodo deposited (unpublished) records.
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
#' 
#' @examples
#' \dontrun{
#'   ZENODO <- ZenodoManager$new(
#'      url = "https://sandbox.zenodo.org/api",
#'      token = "<your_token>",
#'      logger = "INFO"
#'   )
#'   
#'   #create (deposit) an empty record
#'   newRec <- ZENODO$createEmptyRecord()
#'   
#'   #create and fill a local (not yet deposited) record
#'   myrec <- ZenodoRecord$new()
#'   myrec$setTitle("my R package")
#'   myrec$setDescription("A description of my R package")
#'   myrec$setUploadType("software")
#'   myrec$addCreator(
#'     firstname = "John", lastname = "Doe",
#'     affiliation = "Independent", orcid = "0000-0000-0000-0000"
#'    )
#'   myrec$setLicense("mit")
#'   myrec$setAccessRight("open")
#'   myrec$setDOI("mydoi") #use this method if your DOI has been assigned elsewhere, outside Zenodo
#'   myrec$addCommunity("ecfunded")
#'   
#'   #deposit the record 
#'   myrec <- ZENODO$depositRecord(myrec)
#'   
#'   #publish a record (with caution!!)
#'   #this method will PUBLISH the deposition done earlier
#'   ZENODO$publishRecord(myrec$id)
#'   #With even more caution the publication can be done with a shortcut argument at deposit time
#'   ZENODO$depositRecord(myrec, publish = TRUE)
#'   
#'   #delete a record (by id)
#'   #this methods only works for unpublished deposits 
#'   #(if a record is published, it cannot be deleted anymore!)
#'   ZENODO$deleteRecord(myrec$id)
#'   
#'   #HOW TO UPLOAD FILES to a deposit
#'   
#'   #upload a file
#'   ZENODO$uploadFile("path/to/your/file", myrec$id)
#'   
#'   #list files
#'   zen_files <- ZENODO$getFiles(myrec$id)
#'   
#'   #delete a file?
#'   ZENODO$deleteFile(myrec$id, zen_files[[1]]$id)
#' }
#' 
#' @note Main user class to be used with \pkg{zen4R}
#' 
#' @author Emmanuel Blondel <emmanuel.blondel1@@gmail.com>
#' 
ZenodoManager <-  R6Class("ZenodoManager",
  inherit = zen4RLogger,
  private = list(
    url = "https://zenodo.org/api",
    token = NULL
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
    
    initialize = function(url = "https://zenodo.org/api", token = NULL, logger = NULL){
      super$initialize(logger = logger)
      private$url = url
      private$token <- token
    },
    
    #Licenses
    #------------------------------------------------------------------------------------------

    #getLicenses
    getLicenses = function(pretty = TRUE){
      zenReq <- ZenodoRequest$new(private$url, "GET", "licenses?q=&size=1000",
                                  token= private$token, logger = self$loggerType)
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
                                  token= private$token, logger = self$loggerType)
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
      zenReq <- ZenodoRequest$new(private$url, "GET", "communities?q=&size=10000",
                                  token= private$token, logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        out <- out$hits$hits
        if(pretty){
          out = do.call("rbind", lapply(out,function(x){
            rec = data.frame(
              id = x$id,
              title = x$title,
              description = x$description,
              curation_policy = x$curation_policy,
              url = x$links$html,
              created = x$created,
              updated = x$updated,
              stringsAsFactors = FALSE
            )
            return(rec)
          }))
        }
        self$INFO("Successfuly fetched list of communities")
      }else{
        self$ERROR(sprintf("Error while fetching communities: %s", out$message))
      }
      return(out)
    },
    
    #getCommunityById
    getCommunityById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("communities/%s",id),
                                  token= private$token, logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        self$INFO(sprintf("Successfuly fetched community '%s'",id))
      }else{
        self$ERROR(sprintf("Error while fetching community '%s': %s", id, out$message))
      }
      return(out)
    },
    
    #Depositions
    #------------------------------------------------------------------------------------------
    
    #getDepositions
    getDepositions = function(size = 10){
      page <- 1
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("deposit/depositions?size=%s&page=%s", size, page), 
                                  token = private$token, logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        hasRecords <- length(resp)>0
        while(hasRecords){
          out <- c(out, lapply(resp, ZenodoRecord$new))
          self$INFO("Successfuly fetched list of depositions - page %s")
          #next
          page <- page+1
          zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("deposit/depositions?size=%s&page=%s", size, page), 
                                      token = private$token, logger = self$loggerType)
          zenReq$execute()
          resp <- zenReq$getResponse()
          hasRecords <- length(resp)>0
        }
        self$INFO("Successfuly fetched list of depositions!")
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
                                  token = private$token, 
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
                                  data = recordId, token = private$token,
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 204){
        out <- TRUE
        self$INFO(sprintf("Successful deleted record '%s'", recordId))
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while deleting record '%s': %s", recordId, out$message))
      }
      return(out)
    },
    
    #deleteRecords
    deleteRecords = function(){
      records <- self$getDepositions()
      records <- records[sapply(records, function(x){!x$submitted})]
      hasDraftRecords <- length(records)>0
      while(hasDraftRecords){
        record_ids <- sapply(records, function(x){x$id})
        deleted.all <- sapply(record_ids, self$deleteRecord)
        deleted.all <- deleted.all[is.na(deleted.all)]
        deleted <- all(deleted.all)
        if(!deleted){
          self$ERROR("Error while deleting records")
        }
        records <- records[sapply(self$getDepositions(), function(x){!x$submitted})]
        hasDraftRecords <- length(records) > 0
      }
      self$INFO("Successful deleted records")
    },
    
    #createRecord
    createEmptyRecord = function(){
      return(self$depositRecord(NULL))
    },
    
    #publisRecord
    publishRecord = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("deposit/depositions/%s/actions/publish",recordId),
                                  token = private$token,
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
                                  token = private$token,
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
                                  token = private$token,
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
                                  data = fileId, token = private$token,
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 204){
        out <- TRUE
        self$INFO(sprintf("Successful deleted file from record '%s'", recordId))
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while deleting file from record '%s': %s", recordId, out$message))
      }
      return(out)
    }
  )
)
