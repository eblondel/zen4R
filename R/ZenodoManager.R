#' ZenodoManager
#' @docType class
#' @export
#' @keywords zenodo manager
#' @return Object of \code{\link{R6Class}} for modelling an ZenodoManager
#' @format \code{\link{R6Class}} object.
#' @section Methods:
#' \describe{
#'  \item{\code{new(url, token, logger, keyring_backend)}}{
#'    This method is used to instantiate the \code{ZenodoManager}. By default,
#'    the url is set to "https://zenodo.org/api". For tests, the Zenodo sandbox API 
#'    URL can be used: https://sandbox.zenodo.org/api .
#'    
#'    The token is mandatory in order to use Zenodo API deposit actions. By default, 
#'    \pkg{zen4R} will first try to get it from environment variable 'ZENODO_PAT'.
#'    
#'    The \code{keyring_backend} can be set to use a different backend for storing 
#'    the Zenodo token with \pkg{keyring} (Default value is 'env').
#'    
#'    The logger can be either NULL, "INFO" (with minimum logs), or "DEBUG" 
#'    (for complete curl http calls logs)
#'  }
#'  \item{\code{getToken()}}{
#'    Get Zenodo user token.
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
#'  \item{\code{getGrants(pretty)}}{
#'    Get the list of grants. By default the argument \code{pretty} is set to 
#'    \code{TRUE} which will returns the list of grants as \code{data.frame}.
#'    Set \code{pretty = FALSE} to get the raw list of grants.
#'  }
#'  \item{\code{getGrantById(id)}}{
#'    Get grant by Id
#'  }
#'  \item{\code{getFunders(pretty)}}{
#'    Get the list of funders. By default the argument \code{pretty} is set to 
#'    \code{TRUE} which will returns the list of funders as \code{data.frame}.
#'    Set \code{pretty = FALSE} to get the raw list of funders.
#'  }
#'  \item{\code{getFunderById(id)}}{
#'    Get funder by Id
#'  }
#'  \item{\code{getDepositions(q, size, all_versions, exact, quiet)}}{
#'    Get the list of Zenodo records deposited in your Zenodo workspace. By defaut
#'    the list of depositions will be returned by page with a size of 10 results per
#'    page (default size of the Zenodo API). The parameter \code{q} allows to specify
#'    an ElasticSearch-compliant query to filter depositions (default query is empty 
#'    to retrieve all records). The argument \code{all_versions}, if set to TRUE allows
#'    to get all versions of records as part of the depositions list. The argument \code{exact}
#'    specifies that an exact matching is wished, in which case paginated search will be
#'    disabled (only the first search page will be returned).
#'    Examples of ElasticSearch queries for Zenodo can be found at \href{https://help.zenodo.org/guides/search/}{https://help.zenodo.org/guides/search/}.
#'  }
#'  \item{\code{getDepositionByConceptDOI(conceptdoi)}}{
#'    Get a Zenodo deposition record by concept DOI (generic DOI common to all deposition record versions)
#'  }
#'  \item{\code{getDepositionByDOI(doi)}}{
#'    Get a Zenodo deposition record by DOI.
#'  }
#'  \item{\code{getDepositionById(recid)}}{
#'    Get a Zenodo deposition record by its Zenodo specific record id.
#'  }
#'  \item{\code{getDepositionByConceptId(conceptrecid)}}{
#'    Get a Zenodo deposition record by its Zenodo concept id.
#'  }
#'  \item{\code{depositRecord(record, publish)}}{
#'    A method to deposit/update a Zenodo record. The record should be an object
#'    of class \code{ZenodoRecord}. The method returns the deposited record
#'    of class \code{ZenodoRecord}. The parameter \code{publish} (default value
#'    is \code{FALSE}) can be set to \code{TRUE} (to use CAUTIOUSLY, only if you
#'    want to publish your record)
#'  }
#'  \item{\code{depositRecordVersion(record, publish)}}{
#'    A method to deposit a new version for a published record. For details about
#'    the behavior of this function, see \href{https://developers.zenodo.org/#new-version}{https://developers.zenodo.org/#new-version}
#'  }
#'  \item{\code{deleteRecord(recordId)}}{
#'    Deletes a Zenodo record based on its identifier.
#'  }
#'  \item{\code{deleteRecordByDOI(doi)}}{
#'    Deletes a Zenodo record based on its DOI. This DOI is necessarily a pre-reserved DOI corresponding to a draft record,
#'     and not a published DOI, as Zenodo does not allow to delete a record already published.
#'  }
#'  \item{\code{deleteRecords(q)}}{
#'    Deletes all Zenodo deposited (unpublished) records. The parameter \code{q} allows 
#'    to specify an ElasticSearch-compliant query to filter depositions (default query 
#'    is empty to retrieve all records). Examples of ElasticSearch queries for Zenodo 
#'    can be found at \href{https://help.zenodo.org/guides/search/}{https://help.zenodo.org/guides/search/}. 
#'  }
#'  \item{\code{createEmptyRecord()}}{
#'    Creates an empty record in the Zenodo deposit. Returns the record
#'    newly created in Zenodo, as an object of class \code{ZenodoRecord}
#'    with an assigned identifier.
#'  }
#'  \item{\code{editRecord(recordId)}}{
#'    Unlocks a record already submitted. This is required to edit metadata of a Zenodo
#'    record already published.
#'  }
#'  \item{\code{discardChanges(recordId)}}{
#'    Discards changes operated on a record.
#'  }
#'  \item{\code{publishRecord(recordId)}}{
#'    Publishes a deposited record online.
#'  }
#'  \item{\code{getFiles(recordId)}}{
#'    Get the list of uploaded files for a deposited record
#'  }
#'  \item{\code{uploadFile(path, record, recordId)}}{
#'    Uploads a file for a given Zenodo deposited record
#'  }
#'  \item{\code{deleteFile(recordId, fileId)}}{
#'    Deletes a file for a given Zenodo deposited record
#'  }
#'  \item{\code{getRecords(q, size, all_versions, exact)}}{
#'    Get the list of Zenodo records. By defaut the list of records will be returned by
#'     page with a size of 10 results per page (default size of the Zenodo API). The parameter 
#'     \code{q} allows to specify an ElasticSearch-compliant query to filter depositions 
#'     (default query is empty to retrieve all records). The argument \code{all_versions}, 
#'     if set to TRUE allows to get all versions of records as part of the depositions list. 
#'     The argument \code{exact} specifies that an exact matching is wished, in which case 
#'     paginated search will be disabled (only the first search page will be returned).
#'     Examples of 
#'    ElasticSearch queries for Zenodo can be found at \href{https://help.zenodo.org/guides/search/}{https://help.zenodo.org/guides/search/}.
#'  }
#'  \item{\code{getRecordByConceptDOI(conceptdoi)}}{
#'    Get a Zenodo published record by concept DOI (generic DOI common to all record versions)
#'  }
#'  \item{\code{getRecordByDOI(doi)}}{
#'    Get a Zenodo published record by DOI.
#'  }
#'  \item{\code{getRecordById(recid)}}{
#'    Get a Zenodo published record by its Zenodo specific record id.
#'  }
#'  \item{\code{getRecordByConceptId(conceptrecid)}}{
#'    Get a Zenodo published record by its Zenodo concept id.
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
#'   ZENODO$uploadFile("path/to/your/file", record = myrec)
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
    keyring_backend = NULL,
    keyring_service = NULL,
    url = "https://zenodo.org/api"
  ),
  public = list(
    #logger
    anonymous = FALSE,
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
    
    initialize = function(url = "https://zenodo.org/api", token = zenodo_pat(), logger = NULL,
                          keyring_backend = 'env'){
      super$initialize(logger = logger)
      private$url = url
      if(!is.null(token)) if(nzchar(token)){
        if(!keyring_backend %in% names(keyring:::known_backends)){
          errMsg <- sprintf("Backend '%s' is not a known keyring backend!", keyring_backend)
          self$ERROR(errMsg)
          stop(errMsg)
        }
        private$keyring_backend <- keyring:::known_backends[[keyring_backend]]$new()
        private$keyring_service = paste0("zen4R@", url)
        private$keyring_backend$set_with_value(private$keyring_service, username = "zen4R", password = token)
        deps <- self$getDepositions(size = 1, quiet = TRUE)
        if(!is.null(deps$status)) {
          if(deps$status == 401){
            errMsg <- "Cannot connect to your Zenodo deposit: Invalid token"
            self$ERROR(errMsg)
            stop(errMsg)
          }
        }else{
          self$INFO("Successfully connected to Zenodo with user token")
        }
      }else{
        self$INFO("Successfully connected to Zenodo as anonymous user")
        self$anonymous <- TRUE
      }
    },
    
    #getToken
    getToken = function(){
      token <- NULL
      if(!is.null(private$keyring_service)){
        token <- suppressWarnings(private$keyring_backend$get(private$keyring_service, username = "zen4R"))
      }
      return(token)
    },
    
    #Licenses
    #------------------------------------------------------------------------------------------

    #getLicenses
    getLicenses = function(pretty = TRUE){
      zenReq <- ZenodoRequest$new(private$url, "GET", "licenses?q=&size=1000",
                                  token= self$getToken(), 
                                  logger = self$loggerType)
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
        self$INFO("Successfully fetched list of licenses")
      }else{
        self$ERROR(sprintf("Error while fetching licenses: %s", out$message))
      }
      return(out)
    },
    
    #getLicenseById
    getLicenseById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("licenses/%s",id),
                                  token= self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        self$INFO(sprintf("Successfully fetched license '%s'",id))
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
                                  token= self$getToken(),
                                  logger = self$loggerType)
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
        self$INFO("Successfully fetched list of communities")
      }else{
        self$ERROR(sprintf("Error while fetching communities: %s", out$message))
      }
      return(out)
    },
    
    #getCommunityById
    getCommunityById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("communities/%s",id),
                                  token= self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        self$INFO(sprintf("Successfully fetched community '%s'",id))
      }else{
        self$ERROR(sprintf("Error while fetching community '%s': %s", id, out$message))
        out <- NULL
      }
      return(out)
    },
    
    #Grants
    #------------------------------------------------------------------------------------------
    
    #getGrants
    getGrants = function(pretty = TRUE, size = 1000){
      
      page <- 1
      lastPage <- FALSE
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("grants?size=%s&page=%s", size, page), 
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        grants <- resp$hits$hits
        hasGrants <- length(grants)>0
        while(hasGrants){
          out <- c(out, grants)
          if(!is.null(grants)){
            self$INFO(sprintf("Successfully fetched list of grants - page %s", page))
            page <- page+1  #next
          }else{
            lastPage <- TRUE
          }
          zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("grants?size=%s&page=%s", size, page), 
                                      token = self$getToken(),
                                      logger = self$loggerType)
          zenReq$execute()
          if(zenReq$getStatus() == 200){
            resp <- zenReq$getResponse()
            grants <- resp$hits$hits
            hasGrants <- length(grants)>0
          }else{
            self$WARN("Maximum allowed size for list of grants - page %s - attempt to decrease size")
            size <- size-1
            hasGrants <- TRUE
            grants <- NULL
          }
          if(lastPage) break;
        }
        self$INFO("Successfully fetched list of grants!")
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while fetching grants: %s", out$message))
        for(error in out$errors){
          self$ERROR(sprintf("Error: %s - %s", error$field, error$message))
        }
      }
      
      if(pretty){
        out = do.call("rbind", lapply(out,function(x){
          rec = data.frame(
            id = x$metadata$internal_id,
            code = x$metadata$code,
            title = x$metadata$title,
            startdate = x$metadata$startdate,
            enddate = x$metadata$enddate,
            url = x$metadata$url,
            created = x$created,
            updated = x$updated,
            funder_country = x$metadata$funder$country,
            funder_doi = x$metadata$funder$doi,
            funder_name = x$metadata$funder$name,
            funder_type = x$metadata$funder$type,
            funder_subtype = x$metadata$funder$subtype,
            funder_parent_country = x$metadata$funder$parent$country,
            funder_parent_doi = x$metadata$funder$parent$doi,
            funder_parent_name = x$metadata$funder$parent$name,
            funder_parent_type = x$metadata$funder$parent$type,
            funder_parent_subtype = x$metadata$funder$parent$subtype,
            stringsAsFactors = FALSE
          )
          return(rec)
        }))
      }
      return(out)
    },
    
    #getGrantById
    getGrantById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("grants/%s",id),
                                  token= self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        self$INFO(sprintf("Successfully fetched grant '%s'",id))
      }else{
        self$ERROR(sprintf("Error while fetching grant '%s': %s", id, out$message))
        out <- NULL
      }
      return(out)
    },
    
    #Funders
    #------------------------------------------------------------------------------------------
    
    #getFunders
    getFunders = function(pretty = TRUE, size = 1000){
      
      page <- 1
      lastPage <- FALSE
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("funders?size=%s&page=%s", size, page), 
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        funders <- resp$hits$hits
        hasFunders <- length(funders)>0
        while(hasFunders){
          out <- c(out, funders)
          if(!is.null(funders)){
            self$INFO(sprintf("Successfully fetched list of funders - page %s", page))
            page <- page+1  #next
          }else{
            lastPage <- TRUE
          }
          zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("funders?size=%s&page=%s", size, page), 
                                      token = self$getToken(),
                                      logger = self$loggerType)
          zenReq$execute()
          if(zenReq$getStatus() == 200){
            resp <- zenReq$getResponse()
            funders <- resp$hits$hits
            hasFunders <- length(funders)>0
          }else{
            self$WARN("Maximum allowed size for list of funders - page %s - attempt to decrease size")
            size <- size-1
            hasFunders <- TRUE
            funders <- NULL
          }
          if(lastPage) break;
        }
        self$INFO("Successfully fetched list of funders!")
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while fetching funders: %s", out$message))
        for(error in out$errors){
          self$ERROR(sprintf("Error: %s - %s", error$field, error$message))
        }
      }
      
      if(pretty){
        out = do.call("rbind", lapply(out,function(x){
          rec = data.frame(
            id = x$metadata$doi,
            doi = x$metadata$doi,
            country = x$metadata$country,
            name = x$metadata$name,
            type = x$metadata$type,
            subtype = x$metadata$subtype,
            created = x$created,
            updated = x$updated,
            stringsAsFactors = FALSE
          )
          return(rec)
        }))
      }
      return(out)
    },
    
    #getFunderById
    getFunderById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("funders/%s",id),
                                  token= self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        self$INFO(sprintf("Successfully fetched funder '%s'",id))
      }else{
        self$ERROR(sprintf("Error while fetching funder '%s': %s", id, out$message))
        out <- NULL
      }
      return(out)
    },
    
    #Depositions
    #------------------------------------------------------------------------------------------
    
    #getDepositions
    getDepositions = function(q = "", size = 10, all_versions = FALSE, exact = TRUE,
                              quiet = FALSE){
      page <- 1
      req <- sprintf("deposit/depositions?q=%s&size=%s&page=%s", q, size, page)
      if(all_versions) req <- paste0(req, "&all_versions=1")
      zenReq <- ZenodoRequest$new(private$url, "GET", req, 
                                  token = self$getToken(),
                                  logger = if(quiet) NULL else self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        hasRecords <- length(resp)>0
        while(hasRecords){
          out <- c(out, lapply(resp, ZenodoRecord$new))
          if(!quiet) self$INFO(sprintf("Successfully fetched list of depositions - page %s", page))
          
          if(exact){
            hasRecords <- FALSE
          }else{
            #next
            page <- page+1
            nextreq <- sprintf("deposit/depositions?q=%s&size=%s&page=%s", q, size, page)
            if(all_versions) nextreq <- paste0(nextreq, "&all_versions=1")
            zenReq <- ZenodoRequest$new(private$url, "GET", nextreq, 
                                        token = self$getToken(),
                                        logger = if(quiet) NULL else self$loggerType)
            zenReq$execute()
            resp <- zenReq$getResponse()
            hasRecords <- length(resp)>0
          }
        }
        if(!quiet) self$INFO("Successfully fetched list of depositions!")
      }else{
        out <- zenReq$getResponse()
        if(!quiet) self$ERROR(sprintf("Error while fetching depositions: %s", out$message))
        for(error in out$errors){
          self$ERROR(sprintf("Error: %s - %s", error$field, error$message))
        }
      }
      return(out)
    },
    
    #getDepositionByConceptDOI
    getDepositionByConceptDOI = function(conceptdoi){
      query <- sprintf("conceptdoi:%s", gsub("/", "//", conceptdoi))
      result <- self$getDepositions(q = query, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$conceptdoi == conceptdoi){
          self$INFO(sprintf("Successfully fetched record for concept DOI '%s'!", conceptdoi))
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)) self$WARN(sprintf("No record for concept DOI '%s'!", conceptdoi))
      if(is.null(result)){
        #try to get record by id
        if( regexpr("zenodo", conceptdoi)>0){
          conceptrecid <- unlist(strsplit(conceptdoi, "zenodo."))[2]
          self$INFO(sprintf("Try to get deposition by Zenodo specific record id '%s'", conceptrecid))
          conceptrec <- self$getDepositionByConceptId(conceptrecid)
          last_doi <- tail(conceptrec$getVersions(),1L)$doi
          result <- self$getDepositionByDOI(last_doi)
        }
      }
      return(result)
    },
    
    #getDepositionByDOI
    getDepositionByDOI = function(doi){
      query <- sprintf("doi:%s", gsub("/", "//", doi))
      result <- self$getDepositions(q = query, all_versions = TRUE, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$doi == doi){
          self$INFO(sprintf("Successfully fetched record for DOI '%s'!",doi))
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)) self$WARN(sprintf("No record for DOI '%s'!",doi))
      if(is.null(result)){
        #try to get record by id
        if( regexpr("zenodo", doi)>0){
          recid <- unlist(strsplit(doi, "zenodo."))[2]
          self$INFO(sprintf("Try to get deposition by Zenodo specific record id '%s'", recid))
          result <- self$getDepositionById(recid)
        }
      }
      return(result)
    },
    
    #getDepositionbyId
    getDepositionById = function(recid){
      query <- sprintf("recid:%s", recid)
      result <- self$getDepositions(q = query, all_versions = TRUE, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$id == recid){
          self$INFO(sprintf("Successfully fetched record for id '%s'!",recid))
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)) self$WARN(sprintf("No record for id '%s'!",recid))
      return(result)
    },
    
    #getDepositionbyConceptId
    getDepositionByConceptId = function(conceptrecid){
      query <- sprintf("conceptrecid:%s", conceptrecid)
      result <- self$getDepositions(q = query, all_versions = TRUE, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$conceptrecid == conceptrecid){
          self$INFO(sprintf("Successfully fetched record for concept id '%s'!",conceptrecid))
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)) self$WARN(sprintf("No record for concept id '%s'!",conceptrecid))
      return(result)
    },
    
    #depositRecord
    depositRecord = function(record, publish = FALSE){
      data <- record
      type <- ifelse(is.null(record$id), "POST", "PUT")
      request <- ifelse(is.null(record$id), "deposit/depositions", 
                        sprintf("deposit/depositions/%s", record$id))
      zenReq <- ZenodoRequest$new(private$url, type, request, data = data,
                                  token = self$getToken(), 
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
    
    #depositRecordVersion
    depositRecordVersion = function(record, delete_latest_files = TRUE, files = list(), publish = FALSE){
      type <- "POST"
      if(is.null(record$conceptrecid)){
        stop("The record concept id cannot be null for creating a new version")
      }
      if(is.null(record$conceptdoi)){
        stop("Concept DOI is null: a new version can only be added to a published record")
      }
      
      #id of the last record
      record_id <- unlist(strsplit(record$links$latest,"records/"))[[2]] 
      
      self$INFO(sprintf("Creating new version for record '%s' (concept DOI: '%s')", record_id, record$getConceptDOI()))
      request <- sprintf("deposit/depositions/%s/actions/newversion", record_id)
      zenReq <- ZenodoRequest$new(private$url, type, request, data = NULL,
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      out_id <- NULL
      if(zenReq$getStatus() %in% c(200,201)){
        out <- zenReq$getResponse()
        out_id <- unlist(strsplit(out$links$latest_draft,"depositions/"))[[2]]
        out <-  ZENODO$getDepositionById(out_id)
        self$INFO(sprintf("Successful new version record created for concept DOI '%s'", record$getConceptDOI()))
        record$id <- out$id
        record$metadata$doi <- NULL
        record$doi <- NULL
        record$prereserveDOI(TRUE)
        out <- self$depositRecord(record)
        
        if(delete_latest_files){
          self$INFO("Deleting files copied from latest record")
          invisible(lapply(out$files, function(x){ self$deleteFile(out$id, x$id)}))
        }
        if(length(files)>0){
          self$INFO("Upload files to new version")
          for(f in files){
            self$INFO(sprintf("Upload file '%s' to new version", f))
            self$uploadFile(f, record = out)
          }
        }
        
        if(publish){
          out <- self$publishRecord(record$id)
        }
        
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while creating new version: %s", out$message))
        for(error in out$errors){
          self$ERROR(sprintf("Error: %s - %s", error$field, error$message))
        }
      }
      
      return(out)
    },
    
    #deleteRecord
    deleteRecord = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "DELETE", "deposit/depositions", 
                                  data = recordId, token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 204){
        out <- TRUE
        self$INFO(sprintf("Successful deleted record '%s'", recordId))
      }else{
        resp <- zenReq$getResponse()
        self$ERROR(sprintf("Error while deleting record '%s': %s", recordId, resp$message))
      }
      return(out)
    },
    
    #deleteRecordByDOI
    deleteRecordByDOI = function(doi){
      self$INFO(sprintf("Deleting record with DOI '%s'", doi))
      deleted <- FALSE
      rec <- self$getDepositionByDOI(doi)
      if(!is.null(rec)){
        deleted <- self$deleteRecord(rec$id)
      }
      return(deleted)
    },
    
    #deleteRecords
    deleteRecords = function(q = "", size = 10){
      records <- self$getDepositions(q = q, size = size)
      records <- records[sapply(records, function(x){!x$submitted})]
      hasDraftRecords <- length(records)>0
      if(length(records)>0){
        record_ids <- sapply(records, function(x){x$id})
        deleted.all <- sapply(record_ids, self$deleteRecord)
        deleted.all <- deleted.all[is.na(deleted.all)]
        deleted <- all(deleted.all)
        if(!deleted){
          self$ERROR("Error while deleting records")
        }
      }
      self$INFO("Successful deleted records")
    },
    
    #createRecord
    createEmptyRecord = function(){
      return(self$depositRecord(NULL))
    },
    
    #editRecord
    editRecord = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("deposit/depositions/%s/actions/edit", recordId),
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 201){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        self$INFO(sprintf("Successful unlocked record '%s' for edition", recordId))
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while unlocking record '%s' for edition: %s", recordId, out$message))
      }
      return(out)
    },
    
    #discardChanges
    discardChanges = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("deposit/depositions/%s/actions/discard", recordId),
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 201){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        self$INFO(sprintf("Successful discarded changes for record '%s' for edition", recordId))
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while discarding record '%s' changes: %s", recordId, out$message))
      }
      return(out)
    },
    
    #publisRecord
    publishRecord = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("deposit/depositions/%s/actions/publish",recordId),
                                  token = self$getToken(),
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
                                  token = self$getToken(),
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
    uploadFile = function(path, record = NULL, recordId = NULL){
      newapi = TRUE
      if(!is.null(recordId)){
        self$WARN("'recordId' argument is deprecated, please consider using 'record' argument giving an object of class 'ZenodoRecord'")
        self$WARN("'recordId' is used, cannot determine new API record bucket, switch to old upload API...")
        newapi <- FALSE
      }
      if(!is.null(record)) recordId <- record$id
      fileparts <- strsplit(path,"/")
      filename <- unlist(fileparts)[length(fileparts)]
      method <- ifelse(newapi, "PUT", "POST")
      if(!"bucket" %in% names(record$links)){
        self$WARN(sprintf("No bucket link for record id = %s. Revert to old file upload API", recordId))
        newapi <- FALSE
      }
      if(newapi) self$INFO(sprintf("Using new file upload API with bucket: %s", record$links$bucket))
      method_url <- ifelse(newapi, sprintf("%s/%s", unlist(strsplit(record$links$bucket, "api/"))[2], filename), sprintf("deposit/depositions/%s/files", recordId))
      zenReq <- ZenodoRequest$new(private$url, method, method_url, 
                                  data = filename, file = upload_file(path),
                                  token = self$getToken(),
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
                                  data = fileId, token = self$getToken(),
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
    },
    
    
    #Records
    #------------------------------------------------------------------------------------------
    
    #getRecords
    getRecords = function(q = "", size = 10, all_versions = FALSE, exact = FALSE){
      page <- 1
      req <- sprintf("records?q=%s&size=%s&page=%s", q, size, page)
      if(all_versions) req <- paste0(req, "&all_versions=1")
      zenReq <- ZenodoRequest$new(private$url, "GET", req, 
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        hasRecords <- length(resp)>0
        while(hasRecords){
          out <- c(out, lapply(resp, ZenodoRecord$new))
          self$INFO(sprintf("Successfully fetched list of published records - page %s", page))
          
          if(exact){
            hasRecords <- FALSE
          }else{
            #next
            page <- page+1
            nextreq <- sprintf("records?q=%s&size=%s&page=%s", q, size, page)
            if(all_versions) nextreq <- paste0(nextreq, "&all_versions=1")
            zenReq <- ZenodoRequest$new(private$url, "GET", nextreq, 
                                        token = self$getToken(),
                                        logger = self$loggerType)
            zenReq$execute()
            resp <- zenReq$getResponse()
            hasRecords <- length(resp)>0
          }
        }
        self$INFO("Successfully fetched list of published records!")
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while fetching published records: %s", out$message))
        for(error in out$errors){
          self$ERROR(sprintf("Error: %s - %s", error$field, error$message))
        }
      }
      return(out)
    },
    
    #getRecordByConceptDOI
    getRecordByConceptDOI = function(conceptdoi){
      if(regexpr("zenodo", conceptdoi) < 0){
        stop(sprintf("DOI '%s' doesn not seem to be a Zenodo DOI", conceptdoi))
      }
      query <- sprintf("conceptdoi:%s", gsub("/", "//", conceptdoi))
      result <- self$getRecords(q = query, all_versions = TRUE, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$conceptdoi == conceptdoi){
          self$INFO(sprintf("Successfully fetched published record for concept DOI '%s'!", conceptdoi))
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)) self$WARN(sprintf("No published record for concept DOI '%s'!", conceptdoi))
      if(is.null(result)){
        #try to get record by id
        if( regexpr("zenodo", conceptdoi)>0){
          conceptrecid <- unlist(strsplit(conceptdoi, "zenodo."))[2]
          self$INFO(sprintf("Try to get published record by Zenodo concept record id '%s'", conceptrecid))
          conceptrec <- self$getRecordByConceptId(conceptrecid)
          last_doi <- tail(conceptrec$getVersions(),1L)$doi
          result <- self$getRecordByDOI(last_doi)
        }
      }
      return(result)
    },
    
    #getRecordByDOI
    getRecordByDOI = function(doi){
      if(regexpr("zenodo", doi) < 0){
        stop(sprintf("DOI '%s' doesn not seem to be a Zenodo DOI", doi))
      }
      query <- sprintf("doi:%s", gsub("/", "//", doi))
      result <- self$getRecords(q = query, all_versions = TRUE, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$doi == doi){
          self$INFO(sprintf("Successfully fetched record for DOI '%s'!",doi))
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)) self$WARN(sprintf("No record for DOI '%s'!",doi))
      if(is.null(result)){
        #try to get record by id
        if( regexpr("zenodo", doi)>0){
          recid <- unlist(strsplit(doi, "zenodo."))[2]
          self$INFO(sprintf("Try to get deposition by Zenodo specific record id '%s'", recid))
          result <- self$getRecordById(recid)
        }
      }
      return(result)
    },
    
    #getRecordById
    getRecordById = function(recid){
      query <- sprintf("recid:%s", recid)
      result <- self$getRecords(q = query, all_versions = TRUE, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$id == recid){
          self$INFO(sprintf("Successfully fetched record for id '%s'!",recid))
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)) self$WARN(sprintf("No record for id '%s'!",recid))
      return(result)
    },
    
    #getRecordByConceptId
    getRecordByConceptId = function(conceptrecid){
      query <- sprintf("conceptrecid:%s", conceptrecid)
      result <- self$getRecords(q = query, all_versions = TRUE, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$conceptrecid == conceptrecid){
          self$INFO(sprintf("Successfully fetched record for concept id '%s'!",conceptrecid))
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)) self$WARN(sprintf("No record for concept id '%s'!",conceptrecid))
      return(result)
    }
    
  )
)
