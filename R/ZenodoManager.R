#' ZenodoManager
#' @docType class
#' @export
#' @keywords zenodo manager
#' @return Object of \code{\link{R6Class}} for modelling an ZenodoManager
#' @format \code{\link{R6Class}} object.
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
    url = "https://zenodo.org/api",
    verbose.info = FALSE
  ),
  public = list(
    
    #' @field sandbox Zenodo manager sandbox status, \code{TRUE} if we interact with Sandbox infra
    sandbox = FALSE, 
    #' @field anonymous Zenodo manager anonymous status, \code{TRUE} when no token is specified
    anonymous = FALSE,
    
    #' @description initializes the Zenodo Manager
    #' @param url Zenodo API URL. By default, the url is set to "https://zenodo.org/api". For tests, 
    #'   the Zenodo sandbox API URL can be used: https://sandbox.zenodo.org/api 
    #' @param token the user token. By default an attempt will be made to retrieve token using \link{zenodo_pat}
    #' @param sandbox Indicates if the Zenodo sandbox platform should be used. Default is \code{FALSE}
    #' @param logger logger type. The logger can be either NULL, "INFO" (with minimum logs), or "DEBUG" 
    #'    (for complete curl http calls logs)
    #' @param keyring_backend The \pkg{keyring} backend used to store user token. The \code{keyring_backend} 
    #' can be set to use a different backend for storing the Zenodo token with \pkg{keyring} (Default value is 'env').
    initialize = function(url = "https://zenodo.org/api", token = zenodo_pat(), sandbox = FALSE, logger = NULL,
                          keyring_backend = 'env'){
      super$initialize(logger = logger)
      if(sandbox) url = "https://sandbox.zenodo.org/api"
      private$url = url
      if(url == "https://sandbox.zenodo.org/api") self$sandbox = TRUE
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
    
    #' @description Get user token
    #' @return the token, object of class \code{character}
    getToken = function(){
      token <- NULL
      if(!is.null(private$keyring_service)){
        token <- suppressWarnings(private$keyring_backend$get(private$keyring_service, username = "zen4R"))
      }
      return(token)
    },
    
    #Licenses
    #------------------------------------------------------------------------------------------

    #' @description Get Licenses supported by Zenodo.
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of licenses as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of licenses.
    #' @return list of licenses as \code{data.frame} or \code{list}
    getLicenses = function(pretty = TRUE){
      zenReq <- ZenodoRequest$new(private$url, "GET", "vocabularies/licenses?q=&size=1000",
                                  token= self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        out = out$hits$hits
        if(pretty){
          out = do.call("rbind", lapply(out,function(x){
            rec = data.frame(
              id = x$id,
              title = x$title[[1]],
              description = if(!is.null(x$description)) x$description[[1]] else NA,
              url = x$props$url,
              schema = x$props$scheme,
              osi_approved = x$props$osi_approved,
              revision_id = x$revision_id,
              created = x$created,
              updated = x$updated
            )
            return(rec)
          }))
        }
        self$INFO("Successfully fetched list of licenses")
      }else{
        self$ERROR(sprintf("Error while fetching licenses: %s", out$message))
      }
      return(out)
    },
    
    #' @description Get license by Id.
    #' @param id license id
    #' @return the license
    getLicenseById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("vocabularies/licenses/%s",id),
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
    
    #' @description Get Communities supported by Zenodo.
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of communities as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of communities
    #' @param q an ElasticSearch compliant query, object of class \code{character}. Default is emtpy.
    #'  Note that the Zenodo API restrains a maximum number of 10,000 records to be retrieved. Consequently,
    #'  not all grants can be listed from Zenodo, a query has to be specified.
    #' @param size number of grants to be returned. By default equal to 500
    #' @return list of grants as \code{data.frame} or \code{list}
    getCommunities = function(pretty = TRUE, q = "", size = 500){
      page <- 1
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("communities?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        communities <- resp$hits$hits
        total <- resp$hits$total
        if(total > 10000){
          self$WARN(sprintf("Total of %s records found: the Zenodo API limits to a maximum of 10,000 records!", total)) 
        }
        total_remaining <- total
        hasCommunities <- length(communities)>0
        while(hasCommunities){
          out <- c(out, communities)
          self$INFO(sprintf("Successfully fetched list of communities - page %s", page))
          total_remaining <- total_remaining-length(communities)
          if(total_remaining <= size) size = total_remaining
          if(total_remaining == 0){
            break
          }
          
          #next page
          page <- page+1
          zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("communities?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                      token = self$getToken(),
                                      logger = self$loggerType)
          zenReq$execute()
          if(zenReq$getStatus() == 200){
            resp <- zenReq$getResponse()
            communities <- resp$hits$hits
            hasCommunities <- length(communities)>0
          }else{
            self$WARN(sprintf("Maximum allowed size for list of communities at page %s", page))
            break
          }
        }
        self$INFO("Successfully fetched list of communities!")
      }else{
        out <- zenReq$getResponse()
        self$ERROR(sprintf("Error while fetching communities: %s", out$message))
        for(error in out$errors){
          self$ERROR(sprintf("Error: %s - %s", error$field, error$message))
        }
      }
      
      if(pretty){
        out = do.call("rbind", lapply(out,function(x){
          rec = data.frame(
            id = x$id,
            title = x$metadata$title,
            description = if(!is.null(x$metadata$description)) x$metadata$description else NA,
            website = if(!is.null(x$metadata$website)) x$metadata$website else NA,
            visibility = x$access$visibility,
            member_policy = x$access$member_policy,
            record_policy = x$access$record_policy,
            review_policy = x$access$review_policy,
            url = x$links$self_html,
            created = x$created,
            updated = x$updated,
            stringsAsFactors = FALSE
          )
          return(rec)
        }))
      }
      
      return(out)
    },
    
    #' @description Get community by Id.
    #' @param id community id
    #' @return the community
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
    
    #' @description Get Grants supported by Zenodo.
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of grants as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of grants
    #' @param q an ElasticSearch compliant query, object of class \code{character}. Default is emtpy.
    #'  Note that the Zenodo API restrains a maximum number of 10,000 records to be retrieved. Consequently,
    #'  not all grants can be listed from Zenodo, a query has to be specified.
    #' @param size number of grants to be returned. By default equal to 500.
    #' @return list of grants as \code{data.frame} or \code{list}
    getGrants = function(q = "", pretty = TRUE, size = 500){
      page <- 1
      lastPage <- FALSE
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("grants?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        grants <- resp$hits$hits
        total <- resp$hits$total
        if(total > 10000){
          self$WARN(sprintf("Total of %s records found: the Zenodo API limits to a maximum of 10,000 records!", total)) 
        }
        total_remaining <- total
        hasGrants <- length(grants)>0
        while(hasGrants){
          out <- c(out, grants)
          if(!is.null(grants)){
            self$INFO(sprintf("Successfully fetched list of grants - page %s", page))
            if(q!=""){
              page <- page+1  #next
              total_remaining <- total_remaining-length(grants)
            }else{
              break;
            }
          }else{
            lastPage <- TRUE
          }
          zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("grants/?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                      token = self$getToken(),
                                      logger = self$loggerType)
          zenReq$execute()
          if(zenReq$getStatus() == 200){
            resp <- zenReq$getResponse()
            grants <- resp$hits$hits
            hasGrants <- length(grants)>0
            if(lastPage) break;
          }else{
            self$WARN(sprintf("Maximum allowed size for list of grants - page %s - attempt to decrease size", page))
            size <- size-1
            hasGrants <- TRUE
            grants <- NULL
          }
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
            funder_parent_country = if(length(x$metadata$funder$parent)>0) x$metadata$funder$parent$country else NA,
            funder_parent_doi = if(length(x$metadata$funder$parent)>0) x$metadata$funder$parent$doi else NA,
            funder_parent_name = if(length(x$metadata$funder$parent)>0) x$metadata$funder$parent$name else NA,
            funder_parent_type = if(length(x$metadata$funder$parent)>0) x$metadata$funder$parent$type else NA,
            funder_parent_subtype = if(length(x$metadata$funder$parent)>0) x$metadata$funder$parent$subtype else NA,
            stringsAsFactors = FALSE
          )
          return(rec)
        }))
      }
      return(out)
    },
    
    #' @description Get grants by name.
    #' @param name name
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of grants as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of grants
    #' @return list of grants as \code{data.frame} or \code{list}
    getGrantsByName = function(name, pretty = TRUE){
      query = sprintf("title:%s", URLencode(paste0("\"",name,"\"")))
      self$getGrants(q = query, pretty = pretty)
    },
    
    #' @description Get grant by Id.
    #' @param id grant id
    #' @return the grant
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
    
    #' @description Get Funders supported by Zenodo based on a query.
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of funders as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of funders
    #' @param q an ElasticSearch compliant query, object of class \code{character}. Default is emtpy.
    #'  Note that the Zenodo API restrains a maximum number of 10,000 records to be retrieved. Consequently,
    #'  not all funders can be listed from Zenodo, a query has to be specified.
    #' @param size number of funders to be returned. By default equal to 500
    #' @return list of funders as \code{data.frame} or \code{list}
    getFunders = function(q = "", pretty = TRUE, size = 500){
      page <- 1
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("funders?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        funders <- resp$hits$hits
        total <- resp$hits$total
        if(total > 10000){
          self$WARN(sprintf("Total of %s records found: the Zenodo API limits to a maximum of 10,000 records!", total)) 
        }
        total_remaining <- total
        hasFunders <- length(funders)>0
        while(hasFunders){
          out <- c(out, funders)
          self$INFO(sprintf("Successfully fetched list of funders - page %s", page))
          total_remaining <- total_remaining-length(funders)
          if(total_remaining <= size) size = total_remaining
          if(total_remaining == 0){
            break
          }
          
          #next page
          page <- page+1
          zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("funders?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                      token = self$getToken(),
                                      logger = self$loggerType)
          zenReq$execute()
          if(zenReq$getStatus() == 200){
            resp <- zenReq$getResponse()
            funders <- resp$hits$hits
            hasFunders <- length(funders)>0
          }else{
            self$WARN(sprintf("Maximum allowed size for list of communities reached at page %s", page))
            break
          }
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
        out = do.call("rbind.fill", lapply(out,function(x){
          
          identifiers = do.call("cbind", lapply(x$identifiers, function(identifier){
            out_id = data.frame(scheme = identifier$identifier, stringsAsFactors = F)
            names(out_id) = identifier$scheme
            return(out_id)
          }))
          
          rec = data.frame(
            id = x$id,
            country = x$country,
            name = x$name,
            identifiers,
            created = x$created,
            updated = x$updated,
            stringsAsFactors = FALSE
          )
          return(rec)
        }))
      }
      return(out)
    },
    
    #' @description Get funders by name.
    #' @param name name
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of funders as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of funders
    #' @return list of funders as \code{data.frame} or \code{list}
    getFundersByName = function(name, pretty = TRUE){
      query = sprintf("name:%s", URLencode(paste0("\"",name,"\"")))
      self$getFunders(q = query, pretty = pretty)
    },
    
    #' @description Get funder by Id.
    #' @param id funder id
    #' @return the funder
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
    
    #' @description Get the list of Zenodo records deposited in your Zenodo workspace. By defaut
    #'    the list of depositions will be returned by page with a size of 10 results per
    #'    page (default size of the Zenodo API). The parameter \code{q} allows to specify
    #'    an ElasticSearch-compliant query to filter depositions (default query is empty 
    #'    to retrieve all records). The argument \code{all_versions}, if set to TRUE allows
    #'    to get all versions of records as part of the depositions list. The argument \code{exact}
    #'    specifies that an exact matching is wished, in which case paginated search will be
    #'    disabled (only the first search page will be returned).
    #'    Examples of ElasticSearch queries for Zenodo can be found at \href{https://help.zenodo.org/guides/search/}{https://help.zenodo.org/guides/search/}.
    #' @param q Elastic-Search-compliant query, as object of class \code{character}. Default is ""
    #' @param size number of depositions to be retrieved per request (paginated). Default is 10
    #' @param all_versions object of class \code{logical} indicating if all versions of deposits have to be retrieved. Default is \code{FALSE}
    #' @param exact object of class \code{logical} indicating if exact matching has to be applied. Default is \code{TRUE}
    #' @param quiet object of class \code{logical} indicating if logs have to skipped. Default is \code{FALSE}
    #' @return a list of \code{ZenodoRecord}
    getDepositions = function(q = "", size = 10, all_versions = FALSE, exact = TRUE,
                              quiet = FALSE){
      page <- 1
      baseUrl <- "deposit/depositions"
      
      #set in #72, now re-deactivated through #76 (due to Zenodo server-side changes)
      #if(!private$sandbox) baseUrl <- paste0(baseUrl, "/")
      
      req <- sprintf("%s?q=%s&size=%s&page=%s", baseUrl, URLencode(q), size, page)
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
            nextreq <- sprintf("%s?q=%s&size=%s&page=%s", baseUrl, q, size, page)
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
    
    #' @description Get a Zenodo deposition record by concept DOI (generic DOI common to all deposition record versions).
    #' @param conceptdoi the concept DOI, object of class \code{character}
    #' @return an object of class \code{ZenodoRecord} if record does exist, NULL otherwise
    getDepositionByConceptDOI = function(conceptdoi){
      query <- sprintf("conceptdoi:\"%s\"", conceptdoi)
      result <- self$getDepositions(q = query, exact = TRUE)
      if(length(result)>0){
        conceptdois <- vapply(result, function(i){
          i$getConceptDOI()
        }, character(1))
        if (!conceptdoi %in% conceptdois){
          result <- NULL
        }else{
          result <- result[[which(conceptdois == conceptdoi)[1]]]
          self$INFO(sprintf("Successfully fetched record for concept DOI '%s'!", conceptdoi))
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
          if(length(last_doi)==0) {
            if(nzchar(conceptrec$metadata$doi)){
               last_doi = conceptrec$metadata$doi
            }else{
              last_doi = conceptrec$metadata$prereserve_doi$doi
            }
          }
          result <- self$getDepositionByDOI(last_doi)
        }
      }
      return(result)
    },
    
    #' @description Get a Zenodo deposition record by DOI.
    #' @param doi the DOI, object of class \code{character}
    #' @return an object of class \code{ZenodoRecord} if record does exist, NULL otherwise
    getDepositionByDOI = function(doi){
      query <- sprintf("doi:\"%s\"", doi)
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
    
    #' @description Get a Zenodo deposition record by ID.
    #' @param recid the record ID, object of class \code{character}
    #' @return an object of class \code{ZenodoRecord} if record does exist, NULL otherwise
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
    
    #' @description Get a Zenodo deposition record by concept ID.
    #' @param conceptrecid the record concept ID, object of class \code{character}
    #' @return an object of class \code{ZenodoRecord} if record does exist, NULL otherwise
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
    
    #' @description Deposits a record on Zenodo.
    #' @param record the record to deposit, object of class \code{ZenodoRecord}
    #' @param publish object of class \code{logical} indicating if record has to be published (default \code{FALSE}). 
    #'   Can be set to \code{TRUE} (to use CAUTIOUSLY, only if you want to publish your record)
    #' @return \code{TRUE} if deposited (and eventually published), \code{FALSE} otherwise
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
    
    #' @description Deposits a record version on Zenodo. For details about the behavior of this function, 
    #'   see \href{https://developers.zenodo.org/#new-version}{https://developers.zenodo.org/#new-version}
    #' @param record the record version to deposit, object of class \code{ZenodoRecord}
    #' @param delete_latest_files object of class \code{logical} indicating if latest files have to be deleted. Default is \code{TRUE}
    #' @param files a list of files to be uploaded with the new record version
    #' @param publish object of class \code{logical} indicating if record has to be published (default \code{FALSE})
    #' @return \code{TRUE} if deposited (and eventually published), \code{FALSE} otherwise
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
        out <-  self$getDepositionById(out_id)
        self$INFO(sprintf("Successful new version record created for concept DOI '%s'", record$getConceptDOI()))
        record$id <- out$id
        record$metadata$doi <- NULL
        record$doi <- NULL
        record$prereserveDOI(TRUE)
        out <- self$depositRecord(record)
        
        if(delete_latest_files){
          self$INFO("Deleting files copied from latest record")
          invisible(lapply(out$files, function(x){ 
            self$deleteFile(out$id, x$id)
            Sys.sleep(0.6)
          }))
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
    
    #' @description Deletes a record given its ID
    #' @param recordId the ID of the record to be deleted
    #' @return \code{TRUE} if deleted, \code{FALSE} otherwise
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
    
    #' @description Deletes a record by DOI
    #' @param doi the DOI of the record to be deleted
    #' @return \code{TRUE} if deleted, \code{FALSE} otherwise
    deleteRecordByDOI = function(doi){
      self$INFO(sprintf("Deleting record with DOI '%s'", doi))
      deleted <- FALSE
      rec <- self$getDepositionByDOI(doi)
      if(!is.null(rec)){
        deleted <- self$deleteRecord(rec$id)
      }
      return(deleted)
    },
    
    #' @description Deletes all Zenodo deposited (unpublished) records. 
    #'   The parameter \code{q} allows to specify an ElasticSearch-compliant query to filter depositions (default query 
    #'    is empty to retrieve all records). Examples of ElasticSearch queries for Zenodo  can be found at 
    #'    \href{https://help.zenodo.org/guides/search/}{https://help.zenodo.org/guides/search/}. 
    #' @param q an ElasticSearch compliant query, object of class \code{character}
    #' @param size number of records to be passed to \code{$getDepositions} method
    #' @return \code{TRUE} if all records have been deleted, \code{FALSE} otherwise
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
    
    #' @description Creates an empty record in the Zenodo deposit. Returns the record
    #'    newly created in Zenodo, as an object of class \code{ZenodoRecord} with an 
    #'    assigned identifier.
    #' @return an object of class \code{ZenodoRecord}
    createEmptyRecord = function(){
      return(self$depositRecord(NULL))
    },
    
    #' @description Unlocks a record already submitted. Required to edit metadata of a Zenodo record already published.
    #' @param recordId the ID of the record to unlock and set in editing mode.
    #' @return an object of class \code{ZenodoRecord}
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
    
    #' @description Discards changes on a Zenodo record.
    #' @param recordId the ID of the record for which changes have to be discarded.
    #' @return an object of class \code{ZenodoRecord}
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
    
    #' @description Publishes a Zenodo record.
    #' @param recordId the ID of the record to be published.
    #' @return an object of class \code{ZenodoRecord}
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
    
    #' @description Get list of files attached to a Zenodo record.
    #' @param recordId the ID of the record.
    #' @return list of files
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
    
    #' @description Uploads a file to a Zenodo record
    #' @param path Local path of the file
    #' @param record object of class \code{ZenodoRecord}
    #' @param recordId ID of the record. Deprecated, use \code{record} instead to take advantage of the new Zenodo bucket upload API.
    uploadFile = function(path, record = NULL, recordId = NULL){
      newapi = TRUE
      if(!is.null(recordId)){
        self$WARN("'recordId' argument is deprecated, please consider using 'record' argument giving an object of class 'ZenodoRecord'")
        self$WARN("'recordId' is used, cannot determine new API record bucket, switch to old upload API...")
        newapi <- FALSE
      }
      if(!is.null(record)) recordId <- record$id
      fileparts <- unlist(strsplit(path,"/"))
      filename <- fileparts[length(fileparts)]
      if(!"bucket" %in% names(record$links)){
        self$WARN(sprintf("No bucket link for record id = %s. Revert to old file upload API", recordId))
        newapi <- FALSE
      }
      method <- if(newapi) "PUT"  else "POST"
      if(newapi) self$INFO(sprintf("Using new file upload API with bucket: %s", record$links$bucket))
      method_url <- if(newapi) sprintf("%s/%s", unlist(strsplit(record$links$bucket, "api/"))[2], URLencode(filename)) else sprintf("deposit/depositions/%s/files", recordId)
      zenReq <- if(newapi){
        ZenodoRequest$new(
          private$url, method, method_url, 
          data = upload_file(path),
          progress = TRUE,
          token = self$getToken(),
          logger = self$loggerType
        )
      }else{
        ZenodoRequest$new(
          private$url, method, method_url, 
          data = filename, file = upload_file(path),
          progress = TRUE,
          token = self$getToken(),
          logger = self$loggerType
        )
      }
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
    
    #' @description Deletes a file for a record
    #' @param recordId ID of the record
    #' @param fileId ID of the file to delete
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
    
    #' @description Get the list of Zenodo records. By defaut the list of records will be returned by
    #'     page with a size of 10 results per page (default size of the Zenodo API). The parameter 
    #'     \code{q} allows to specify an ElasticSearch-compliant query to filter depositions 
    #'     (default query is empty to retrieve all records). The argument \code{all_versions}, 
    #'     if set to TRUE allows to get all versions of records as part of the depositions list. 
    #'     The argument \code{exact} specifies that an exact matching is wished, in which case 
    #'     paginated search will be disabled (only the first search page will be returned).
    #'     Examples of ElasticSearch queries for Zenodo can be found at \href{https://help.zenodo.org/guides/search/}{https://help.zenodo.org/guides/search/}.
    #' @param q Elastic-Search-compliant query, as object of class \code{character}. Default is ""
    #' @param size number of records to be retrieved per request (paginated). Default is 10
    #' @param all_versions object of class \code{logical} indicating if all versions of records have to be retrieved. Default is \code{FALSE}
    #' @param exact object of class \code{logical} indicating if exact matching has to be applied. Default is \code{TRUE}
    #' @param quiet object of class \code{logical} indicating if logs have to skipped. Default is \code{FALSE}
    #' @return a list of \code{ZenodoRecord}
    getRecords = function(q = "", size = 10, all_versions = FALSE, exact = FALSE){
      page <- 1
      req <- sprintf("records/?q=%s&size=%s&page=%s", URLencode(q), size, page)
      if(all_versions) req <- paste0(req, "&all_versions=1")
      zenReq <- ZenodoRequest$new(private$url, "GET_WITH_CURL", req, 
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
            nextreq <- sprintf("records/?q=%s&size=%s&page=%s", URLencode(q), size, page)
            if(all_versions) nextreq <- paste0(nextreq, "&all_versions=1")
            zenReq <- ZenodoRequest$new(private$url, "GET_WITH_CURL", nextreq, 
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
    
    #' @description Get Record by concept DOI
    #' @param conceptdoi the concept DOI
    #' @return a object of class \code{ZenodoRecord}
    getRecordByConceptDOI = function(conceptdoi){
      if(regexpr("zenodo", conceptdoi) < 0){
        stop(sprintf("DOI '%s' doesn not seem to be a Zenodo DOI", conceptdoi))
      }
      query <- sprintf("conceptdoi:\"%s\"", conceptdoi)
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
    
    #' @description Get Record by DOI
    #' @param doi the DOI
    #' @return a object of class \code{ZenodoRecord}
    getRecordByDOI = function(doi){
      if(regexpr("zenodo", doi) < 0){
        stop(sprintf("DOI '%s' doesn not seem to be a Zenodo DOI", doi))
      }
      query <- sprintf("doi:\"%s\"", doi)
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
    
    #' @description Get Record by ID
    #' @param recid the record ID
    #' @return a object of class \code{ZenodoRecord}
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
    
    #' @description Get Record by concept ID
    #' @param conceptrecid the concept ID
    #' @return a object of class \code{ZenodoRecord}
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
