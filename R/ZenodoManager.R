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
      if(sandbox) url = "https://zenodo-rdm-qa.web.cern.ch/api"
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
            cli::cli_alert_danger(errMsg)
            self$ERROR(errMsg)
            stop(errMsg)
          }
        }else{
          infoMsg = "Successfully connected to Zenodo with user token"
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }
      }else{
        infoMsg = "Successfully connected to Zenodo as anonymous user"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
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
    
    #Vocabulary/Languages
    #------------------------------------------------------------------------------------------    
    
    #' @description Get Languages supported by Zenodo.
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of languages as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of languages
    #' @return list of languages as \code{data.frame} or \code{list}
    getLanguages = function(pretty = TRUE){
      zenReq <- ZenodoRequest$new(private$url, "GET", "vocabularies/languages?q=&size=1000",
                                  accept = "application/json",
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
              revision_id = x$revision_id,
              created = x$created,
              updated = x$updated
            )
            return(rec)
          }))
        }
        infoMsg = "Successfully fetched list of languages"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching languages: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Get language by Id.
    #' @param id license id
    #' @return the license
    getLanguageById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("vocabularies/languages/%s",id),
                                  accept = "application/json",
                                  token= self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        infoMsg = sprintf("Successfully fetched language '%s'",id)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching language '%s': %s", id, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        out <- NULL
      }
      return(out)
    },
    
    #Vocabulary/Licenses
    #------------------------------------------------------------------------------------------

    #' @description Get Licenses supported by Zenodo.
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of licenses as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of licenses.
    #' @return list of licenses as \code{data.frame} or \code{list}
    getLicenses = function(pretty = TRUE){
      zenReq <- ZenodoRequest$new(private$url, "GET", "vocabularies/licenses?q=&size=1000",
                                  accept = "application/json",
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
        infoMsg = "Successfully fetched list of licenses"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching licenses: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Get license by Id.
    #' @param id license id
    #' @return the license
    getLicenseById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("vocabularies/licenses/%s",id),
                                  accept = "application/json",
                                  token= self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        infoMsg = sprintf("Successfully fetched license '%s'",id)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching license '%s': %s", id, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        out <- NULL
      }
      return(out)
    },
    
    #Vocabulary/resourcetypes
    #------------------------------------------------------------------------------------------    
    
    #' @description Get Resource types supported by Zenodo.
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of resource types as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of resource types
    #' @return list of resource types as \code{data.frame} or \code{list}
    getResourceTypes = function(pretty = TRUE){
      zenReq <- ZenodoRequest$new(private$url, "GET", "vocabularies/resourcetypes?q=&size=1000",
                                  accept = "application/json",
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
              revision_id = x$revision_id,
              created = x$created,
              updated = x$updated
            )
            return(rec)
          }))
        }
        infoMsg = "Successfully fetched list of resource types"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching resource types: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Get resource type by Id.
    #' @param id resource type id
    #' @return the resource type
    getResourceTypeById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("vocabularies/resourcetypes/%s",id),
                                  accept = "application/json",
                                  token= self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        infoMsg = sprintf("Successfully fetched resourcetype '%s'",id)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching resourcetype '%s': %s", id, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        out <- NULL
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
    #'  not all communities can be listed from Zenodo, a query has to be specified.
    #' @param size number of communities to be returned. By default equal to 500
    #' @return list of communities as \code{data.frame} or \code{list}
    getCommunities = function(pretty = TRUE, q = "", size = 500){
      page <- 1
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("communities?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                  accept = "application/json",
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        communities <- resp$hits$hits
        total <- resp$hits$total
        if(total > 10000){
          warnMsg = sprintf("Total of %s records found: the Zenodo API limits to a maximum of 10,000 records!", total)
          cli::cli_alert_warning(warnMsg)
          self$WARN(warnMsg) 
        }
        total_remaining <- total
        hasCommunities <- length(communities)>0
        while(hasCommunities){
          out <- c(out, communities)
          infoMsg = sprintf("Successfully fetched list of communities - page %s", page)
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
          total_remaining <- total_remaining-length(communities)
          if(total_remaining <= size) size = total_remaining
          if(total_remaining == 0){
            break
          }
          
          #next page
          page <- page+1
          zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("communities?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                      accept = "application/json",
                                      token = self$getToken(),
                                      logger = self$loggerType)
          zenReq$execute()
          if(zenReq$getStatus() == 200){
            resp <- zenReq$getResponse()
            communities <- resp$hits$hits
            hasCommunities <- length(communities)>0
          }else{
            warnMsg = sprintf("Maximum allowed size for list of communities at page %s", page)
            cli::cli_alert_warning(warnMsg)
            self$WARN(warnMsg)
            break
          }
        }
        infoMsg = "Successfully fetched list of communities!"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while fetching communities: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
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
                                  accept = "application/json",
                                  token= self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        infoMsg = sprintf("Successfully fetched community '%s'",id)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching community '%s': %s", id, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        out <- NULL
      }
      return(out)
    },
    
    #Special vocabulary/Awards (former Grants)
    #------------------------------------------------------------------------------------------
    
    #' @description Get Grants supported by Zenodo. DEPRECATED: replaced by \code{getAwards}
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of grants as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of grants
    #' @param q an ElasticSearch compliant query, object of class \code{character}. Default is emtpy.
    #'  Note that the Zenodo API restrains a maximum number of 10,000 records to be retrieved. Consequently,
    #'  not all grants can be listed from Zenodo, a query has to be specified.
    #' @param size number of grants to be returned. By default equal to 500.
    #' @return list of grants as \code{data.frame} or \code{list}
    getGrants = function(q = "", pretty = TRUE, size = 500){
      warnMsg = "Method 'getGrants' is deprecated, please use 'getAwards' instead!"
      cli::cli_alert_warning(warnMsg)
      self$WARN(warnMsg)
      return(self$getAwards(q = q, pretty = pretty, size = size)) 
    },
    
    #' @description Get Awards supported by Zenodo.
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of awards as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of awards
    #' @param q an ElasticSearch compliant query, object of class \code{character}. Default is emtpy.
    #'  Note that the Zenodo API restrains a maximum number of 10,000 records to be retrieved. Consequently,
    #'  not all awards can be listed from Zenodo, a query has to be specified.
    #' @param size number of awards to be returned. By default equal to 500.
    #' @return list of awards as \code{data.frame} or \code{list}
    getAwards = function(q = "", pretty = TRUE, size = 500){
      page <- 1
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("awards?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                  accept = "application/json",
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        awards <- resp$hits$hits
        total <- resp$hits$total
        if(total > 10000){
          warnMsg = sprintf("Total of %s records found: the Zenodo API limits to a maximum of 10,000 records!", total)
          cli::cli_alert_warning(warnMsg)
          self$WARN(warnMsg) 
        }
        total_remaining <- total
        hasAwards <- length(awards)>0
        while(hasAwards){
          out <- c(out, awards)
          total_remaining <- total_remaining-length(awards)
          if(total_remaining <= size) size = total_remaining
          if(total_remaining == 0){
            break
          }
          
          #next page
          page = page+1
          zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("awards?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                      accept = "application/json",
                                      token = self$getToken(),
                                      logger = self$loggerType)
          zenReq$execute()
          if(zenReq$getStatus() == 200){
            resp <- zenReq$getResponse()
            awards <- resp$hits$hits
            hasAwards <- length(awards)>0
          }else{
            warnMsg = sprintf("Maximum allowed size for list of awards at page %s", page)
            cli::cli_alert_warning(warnMsg)
            self$WARN(warnMsg)
            break
          }
        }
        infoMsg = "Successfully fetched list of awards!"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while fetching awards: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
        }
      }
      
      if(pretty){
        out = do.call("rbind", lapply(out,function(x){
          rec = data.frame(
            id = x$id,
            number = x$number,
            title = x$title[[1]],
            created = x$created,
            updated = x$updated,
            funder_id = x$funder$id,
            funder_name = x$funder$name,
            program = if(!is.null(x$program)) x$program else NA,
            stringsAsFactors = FALSE
          )
          return(rec)
        }))
      }
      return(out)
    },
    
    #' @description Get grants by name. DEPRECATED: replaced by \code{getAwardByName} 
    #' @param name name
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of grants as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of grants
    #' @return list of grants as \code{data.frame} or \code{list}
    getGrantsByName = function(name, pretty = TRUE){
      warnMsg = "Method 'getGrantsByName' is deprecated, please use 'getAwardsByName' instead!"
      cli::cli_alert_warning(warnMsg)
      self$WARN(warnMsg)
      return(self$getAwardsByName(name = name, pretty = pretty))
    },
    
    #' @description Get awards by name.
    #' @param name name
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of awards as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of awards
    #' @return list of awards as \code{data.frame} or \code{list}
    getAwardsByName = function(name, pretty = TRUE){
      query = sprintf("title.en:%s", URLencode(paste0("\"",name,"\"")))
      self$getAwards(q = query, pretty = pretty)
    },
    
    #' @description Get grant by Id.DEPRECATED: replaced by \code{getAwardById} 
    #' @param id grant id
    #' @return the grant
    getGrantById = function(id){
      warnMsg = "Method 'getGrantById' is deprecated, please use 'getAwardById' instead!"
      cli::cli_alert_warning(warnMsg)
      self$WARN(warnMsg)
      return(self$getAwardById(id))
    },
    
    #' @description Get award by Id. 
    #' @param id award id
    #' @return the award
    getAwardById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("awards/%s",id),
                                  accept = "application/json",
                                  token= self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        infoMsg = sprintf("Successfully fetched award '%s'",id)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching award '%s': %s", id, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        out <- NULL
      }
      return(out)
    },
    
    #Special vocabulary/Affiliations 
    #------------------------------------------------------------------------------------------
    
    #' @description Get Affiliations supported by Zenodo.
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of affiliations as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of affiliations
    #' @param q an ElasticSearch compliant query, object of class \code{character}. Default is emtpy.
    #'  Note that the Zenodo API restrains a maximum number of 10,000 records to be retrieved. Consequently,
    #'  not all affiliations can be listed from Zenodo, a query has to be specified.
    #' @param size number of affiliations to be returned. By default equal to 500.
    #' @return list of affiliations as \code{data.frame} or \code{list}
    getAffiliations = function(q = "", pretty = TRUE, size = 500){
      page <- 1
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("affiliations?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                  accept = "application/json",
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        affiliations <- resp$hits$hits
        total <- resp$hits$total
        if(total > 10000){
          warnMsg = sprintf("Total of %s records found: the Zenodo API limits to a maximum of 10,000 records!", total)
          cli::cli_alert_warning(warnMsg)
          self$WARN(warnMsg) 
        }
        total_remaining <- total
        hasAwards <- length(affiliations)>0
        while(hasAwards){
          out <- c(out, affiliations)
          total_remaining <- total_remaining-length(affiliations)
          if(total_remaining <= size) size = total_remaining
          if(total_remaining == 0){
            break
          }
          
          #next page
          page = page+1
          zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("affiliations?q=%s&size=%s&page=%s", URLencode(q), size, page), 
                                      accept = "application/json",
                                      token = self$getToken(),
                                      logger = self$loggerType)
          zenReq$execute()
          if(zenReq$getStatus() == 200){
            resp <- zenReq$getResponse()
            affiliations <- resp$hits$hits
            hasAwards <- length(affiliations)>0
          }else{
            warnMsg = sprintf("Maximum allowed size for list of affiliations at page %s", page)
            cli::cli_alert_warning(warnMsg)
            self$WARN(warnMsg)
            break
          }
        }
        infoMsg = "Successfully fetched list of affiliations!"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while fetching affiliations: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
        }
      }
      
      if(pretty){
        out = do.call("rbind", lapply(out,function(x){
          rec = data.frame(
            id = x$id,
            acronym = if(!is.null(x$acronym)) x$acronym else NA,
            name = if(!is.null(x$name)) x$name else NA,
            title = x$title[[1]],
            created = x$created,
            updated = x$updated,
            stringsAsFactors = FALSE
          )
          return(rec)
        }))
      }
      return(out)
    },
    
    #' @description Get affiliations by name.
    #' @param name name
    #' @param pretty Prettify the output. By default the argument \code{pretty} is set to 
    #'    \code{TRUE} which will returns the list of affiliations as \code{data.frame}.
    #'    Set \code{pretty = FALSE} to get the raw list of affiliations
    #' @return list of affiliations as \code{data.frame} or \code{list}
    getAffiliationByName = function(name, pretty = TRUE){
      query = sprintf("title.en:%s", URLencode(paste0("\"",name,"\"")))
      self$getAffiliations(q = query, pretty = pretty)
    },
    
    #' @description Get affiliation by Id. 
    #' @param id affiliation id
    #' @return the affiliation
    getAffiliationById = function(id){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("affiliations/%s",id),
                                  accept = "application/json",
                                  token= self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        infoMsg = sprintf("Successfully fetched affiliation '%s'",id)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching affiliation '%s': %s", id, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
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
                                  accept = "application/json",
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        funders <- resp$hits$hits
        total <- resp$hits$total
        if(total > 10000){
          warnMsg = sprintf("Total of %s records found: the Zenodo API limits to a maximum of 10,000 records!", total)
          cli::cli_alert_warning(warnMsg)
          self$WARN(warnMsg) 
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
                                      accept = "application/json",
                                      token = self$getToken(),
                                      logger = self$loggerType)
          zenReq$execute()
          if(zenReq$getStatus() == 200){
            resp <- zenReq$getResponse()
            funders <- resp$hits$hits
            hasFunders <- length(funders)>0
          }else{
            warnMsg = sprintf("Maximum allowed size for list of communities reached at page %s", page)
            cli::cli_alert_warning(warnMsg)
            self$WARN(warnMsg)
            break
          }
        }
        infoMsg = "Successfully fetched list of funders!"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while fetching funders: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
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
                                  accept = "application/json",
                                  token= self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        infoMsg = sprintf("Successfully fetched funder '%s'",id)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching funder '%s': %s", id, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        out <- NULL
      }
      return(out)
    },
    
    #Depositions
    #------------------------------------------------------------------------------------------
    
    #' @description Get the list of Zenodo records deposited in your Zenodo workspace (user records). By default
    #'    the list of depositions will be returned by page with a size of 10 results per page (default size of 
    #'    the Zenodo API). The parameter \code{q} allows to specify an ElasticSearch-compliant query to filter 
    #'    depositions (default query is empty to retrieve all records). The argument \code{all_versions}, if set 
    #'    to TRUE allows to get all versions of records as part of the depositions list. The argument \code{exact}
    #'    specifies that an exact matching is wished, in which case paginated search will be disabled (only the first 
    #'    search page will be returned).
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
      baseUrl <- "user/records"
      
      #set in #72, now re-deactivated through #76 (due to Zenodo server-side changes)
      #if(!private$sandbox) baseUrl <- paste0(baseUrl, "/")
      
      req <- sprintf("%s?q=%s&size=%s&page=%s", baseUrl, URLencode(q), size, page)
      if(all_versions) req <- paste0(req, "&allversions=1")
      zenReq <- ZenodoRequest$new(private$url, "GET", req, 
                                  token = self$getToken(),
                                  logger = if(quiet) NULL else self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        records <- resp$hits$hits
        total <- resp$hits$total
        if(total > 10000){
          warnMsg = sprintf("Total of %s records found: the Zenodo API limits to a maximum of 10,000 records!", total)
          cli::cli_alert_warning(warnMsg)
          self$WARN(warnMsg) 
        }
        total_remaining <- total
        hasRecords <- length(records)>0
        while(hasRecords){
          out <- c(out, lapply(records, ZenodoRecord$new))
          if(!quiet){
            infoMsg = sprintf("Successfully fetched list of depositions (user records) - page %s", page)
            cli::cli_alert_success(infoMsg)
            self$INFO(infoMsg)
          }
          total_remaining <- total_remaining-length(records)
          if(total_remaining <= size) size = total_remaining
          if(total_remaining == 0){
            break
          }
          
          if(exact){
            hasRecords <- FALSE
          }else{
            #next
            page <- page+1
            nextreq <- sprintf("%s?q=%s&size=%s&page=%s", baseUrl, q, size, page)
            if(all_versions) nextreq <- paste0(nextreq, "&allversions=1")
            zenReq <- ZenodoRequest$new(private$url, "GET", nextreq, 
                                        token = self$getToken(),
                                        logger = if(quiet) NULL else self$loggerType)
            zenReq$execute()
            resp <- zenReq$getResponse()
            if(zenReq$getStatus() == 200){
              resp <- zenReq$getResponse()
              records <- resp$hits$hits
              hasRecords <- length(records)>0
            }else{
              if(!quiet){
                warnMsg = sprintf("Maximum allowed size for list of depositions (user records) at page %s", page)
                cli::cli_alert_warning(warnMsg)
                self$WARN(warnMsg)
              }
              break
            }
          }
        }
        if(!quiet){
          infoMsg = "Successfully fetched list of depositions (user records)!"
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }
      }else{
        out <- zenReq$getResponse()
        if(!quiet){
          errMsg = sprintf("Error while fetching depositions (user records): %s", out$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
          for(error in out$errors){
            errMsg = sprintf("Error: %s - %s", error$field, error$message)
            cli::cli_alert_danger(errMsg)
            self$ERROR(errMsg)
          }
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
          infoMsg = sprintf("Successfully fetched record for concept DOI '%s'!", conceptdoi)
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }
      }else{
        result <- NULL
      }
      if(is.null(result)){
        warnMsg = sprintf("No record for concept DOI '%s'!", conceptdoi)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
      }
      if(is.null(result)){
        #try to get record by id
        if( regexpr("zenodo", conceptdoi)>0){
          conceptrecid <- unlist(strsplit(conceptdoi, "zenodo."))[2]
          infoMsg = sprintf("Try to get deposition by Zenodo specific record id '%s'", conceptrecid)
          cli::cli_alert_info(infoMsg)
          self$INFO(infoMsg)
          conceptrec <- self$getDepositionByConceptId(conceptrecid)
          result = conceptrec
          # last_doi <- tail(conceptrec$getVersions(),1L)$doi
          # if(length(last_doi)==0) {
          #   if(nzchar(conceptrec$metadata$doi)){
          #      last_doi = conceptrec$metadata$doi
          #   }else{
          #     last_doi = conceptrec$metadata$prereserve_doi$doi
          #   }
          # }
          # result <- self$getDepositionByDOI(last_doi)
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
        if(result$getDOI() == doi){
          infoMsg = sprintf("Successfully fetched record for DOI '%s'!",doi)
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)){
        warnMsg = sprintf("No record for DOI '%s'!",doi)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
      }
      if(is.null(result)){
        #try to get record by id
        if( regexpr("zenodo", doi)>0){
          recid <- unlist(strsplit(doi, "zenodo."))[2]
          infoMsg = sprintf("Try to get deposition by Zenodo specific record id '%s'", recid)
          cli::cli_alert_info(infoMsg)
          self$INFO(infoMsg)
          result <- self$getDepositionById(recid)
        }
      }
      return(result)
    },
    
    #' @description Get a Zenodo deposition record by ID.
    #' @param recid the record ID, object of class \code{character}
    #' @return an object of class \code{ZenodoRecord} if record does exist, NULL otherwise
    getDepositionById = function(recid){
      request = sprintf("records/%s/draft", recid)
      zenReq <- ZenodoRequest$new(private$url, "GET", request,
                                  token = self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      result <- NULL
      if(zenReq$getStatus() == 200){
        result = ZenodoRecord$new(obj = zenReq$getResponse())
        infoMsg = sprintf("Successfuly fetched record ford id %s", recid)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while fetching record: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
        }
      }
      
      if(is.null(result)){
        warnMsg = sprintf("No record for id '%s'!",recid)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
      }
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
        if(result$getConceptId() == conceptrecid){
          infoMsg = sprintf("Successfully fetched record for concept id '%s'!",conceptrecid)
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)){
        warnMsg = sprintf("No record for concept id '%s'!",conceptrecid)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
      }
      return(result)
    },
    
    #' @description Deposits a record on Zenodo.
    #' @param record the record to deposit, object of class \code{ZenodoRecord}
    #' @param reserveDOI reserve DOI. By default \code{TRUE}
    #' @param publish object of class \code{logical} indicating if record has to be published (default \code{FALSE}). 
    #'   Can be set to \code{TRUE} (to use CAUTIOUSLY, only if you want to publish your record)
    #' @return object of class \code{ZenodoRecord}
    depositRecord = function(record, reserveDOI = TRUE, publish = FALSE){
      data <- record
      type <- ifelse(is.null(record$id), "POST", "PUT")
      request <- ifelse(is.null(record$id), "records", 
                        sprintf("records/%s/draft", record$id))
      zenReq <- ZenodoRequest$new(private$url, type, request, data = data,
                                  token = self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() %in% c(200,201)){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        infoMsg = "Successful record deposition"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
        
        if(reserveDOI){
          if(is.null(record$pids$doi)){
            out <- self$reserveDOI(out)
          }else{
            warnMsg = sprintf("Existing DOI (%s) for record %s. Aborting DOI reservation!", record$pids$doi$identifier, out$id)
            cli::cli_alert_warning(warnMsg)
            self$WARN(warnMsg)
          }
          
        }
        
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while depositing record: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
        }
      }
      
      if(publish){
        out <- self$publishRecord(record$id)
      }
      
      return(out)
    },
    
    #'@description Reserves a DOI for a deposition (draft record)
    #' @param record the record to deposit, object of class \code{ZenodoRecord}
    #'@return object of class \code{ZenodoRecord}
    reserveDOI = function(record){
      request <- sprintf("records/%s/draft/pids/doi", record$id)
      zenReq <- ZenodoRequest$new(private$url, "POST", request, data = NULL,
                                  token = self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 201){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        infoMsg = sprintf("Successful reserved DOI for record %s", record$id)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while reserving DOI for record %s: %s", record$id, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
        }
      }
      return(out)
    },
    
    #'@description Reserves a DOI for a deposition (draft record)
    #' @param record the record for which DOI has to be deleted, object of class \code{ZenodoRecord}
    #'@return object of class \code{ZenodoRecord}
    deleteDOI = function(record){
      request <- sprintf("records/%s/draft/pids/doi", record$id)
      zenReq <- ZenodoRequest$new(private$url, "DELETE", request, data = NULL,
                                  token = self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        infoMsg = sprintf("Successful deleted DOI for record %s", record$id)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while deleting DOI for record %s: %s", record$id, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
        }
      }
      return(out)
    },
    
    #' @description Deposits a record version on Zenodo.
    #' @param record the record version to deposit, object of class \code{ZenodoRecord}
    #' @param delete_latest_files object of class \code{logical} indicating if latest files have to be deleted. Default is \code{TRUE}
    #' @param files a list of files to be uploaded with the new record version
    #' @param publish object of class \code{logical} indicating if record has to be published (default \code{FALSE})
    #' @return \code{TRUE} if deposited (and eventually published), \code{FALSE} otherwise
    depositRecordVersion = function(record, delete_latest_files = TRUE, files = list(), publish = FALSE){
      type <- "POST"
      if(is.null(record$getConceptId())){
        errMsg = "The record concept id cannot be null for creating a new version"
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        stop(errMsg)
      }
      if(is.null(record$getConceptDOI())){
        errMsg = "Concept DOI is null: a new version can only be added to a published record"
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        stop(errMsg)
      }
      
      #id of the last record
      record_id <- record$id
      
      infoMsg = sprintf("Creating new version for record '%s' (concept DOI: '%s')", record_id, record$getConceptDOI())
      cli::cli_alert_info(infoMsg)
      self$INFO(infoMsg)
      request <- sprintf("records/%s/versions", record_id)
      zenReq <- ZenodoRequest$new(private$url, type, request, data = NULL,
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      out_id <- NULL
      if(zenReq$getStatus() == 201){
        out <- ZenodoRecord$new(obj =zenReq$getResponse())
        out <-  self$getDepositionById(out$id)
        infoMsg = sprintf("Successful new version record created for concept DOI '%s'", record$getConceptDOI())
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
        record$id <- out$id
        record$metadata$doi <- NULL
        record$pids = list()
        out <- self$depositRecord(record)
        
        if(delete_latest_files){
          infoMsg = "Deleting files copied from latest record"
          cli::cli_alert_info(infoMsg)
          self$INFO(infoMsg)
          invisible(lapply(out$files, function(x){ 
            self$deleteFile(out$id, x$id)
            Sys.sleep(0.6)
          }))
        }
        if(length(files)>0){
          infoMsg = "Upload files to new version"
          cli::cli_alert_info(infoMsg)
          self$INFO(infoMsg)
          for(f in files){
            infoMsg = sprintf("Upload file '%s' to new version", f)
            cli::cli_alert_info(infoMsg)
            self$INFO(infoMsg)
            self$uploadFile(f, record = out)
          }
        }
        
        if(publish){
          out <- self$publishRecord(record$id)
        }
        
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while creating new version: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
        }
      }
      
      return(out)
    },
    
    #' @description Deletes a record given its ID
    #' @param recordId the ID of the record to be deleted
    #' @return \code{TRUE} if deleted, \code{FALSE} otherwise
    deleteRecord = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "DELETE", sprintf("records/%s/draft", recordId), 
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 204){
        out <- TRUE
        infoMsg = sprintf("Successful deleted record '%s'", recordId)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        resp <- zenReq$getResponse()
        errMsg = sprintf("Error while deleting record '%s': %s", recordId, resp$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Deletes a record by DOI
    #' @param doi the DOI of the record to be deleted
    #' @return \code{TRUE} if deleted, \code{FALSE} otherwise
    deleteRecordByDOI = function(doi){
      infoMsg =sprintf("Deleting record with DOI '%s'", doi)
      cli::cli_alert_info(infoMsg)
      self$INFO(infoMsg)
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
      records <- records[sapply(records, function(x){x$status == "draft"})]
      hasDraftRecords <- length(records)>0
      if(length(records)>0){
        record_ids <- sapply(records, function(x){x$id})
        deleted.all <- sapply(record_ids, self$deleteRecord)
        deleted.all <- deleted.all[is.na(deleted.all)]
        deleted <- all(deleted.all)
        if(!deleted){
          errMsg = "Error while deleting records"
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
        }
      }
      infoMsg = "Successful deleted records"
      cli::cli_alert_success(infoMsg)
      self$INFO(infoMsg)
    },
    
    #' @description Creates an empty record in the Zenodo deposit. Returns the record
    #'    newly created in Zenodo, as an object of class \code{ZenodoRecord} with an 
    #'    assigned identifier.
    #' @param reserveDOI reserve DOI. By default \code{TRUE}
    #' @return an object of class \code{ZenodoRecord}
    createEmptyRecord = function(reserveDOI = TRUE){
      return(self$depositRecord(NULL, reserveDOI = reserveDOI))
    },
    
    #' @description Unlocks a record already submitted. Required to edit metadata of a Zenodo record already published.
    #' @param recordId the ID of the record to unlock and set in editing mode.
    #' @return an object of class \code{ZenodoRecord}
    editRecord = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("records/%s/draft", recordId),
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 201){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        infoMsg = sprintf("Successful unlocked record '%s' for edition", recordId)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while unlocking record '%s' for edition: %s", recordId, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Discards changes on a Zenodo record. Deleting a draft for an unpublished 
    #' record will remove the draft and associated files from the system. Deleting a draft for 
    #' a published record will remove the draft but not the published record.
    #' @param recordId the ID of the record for which changes have to be discarded.
    #' @return an object of class \code{ZenodoRecord}
    discardChanges = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "DELETE", sprintf("records/%s/draft", recordId),
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 204){
        out <- TRUE
        infoMsg = sprintf("Successful discarded changes for record '%s' for edition", recordId)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while discarding record '%s' changes", recordId)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Publishes a Zenodo record.
    #' @param recordId the ID of the record to be published.
    #' @return an object of class \code{ZenodoRecord}
    publishRecord = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("records/%s/draft/actions/publish",recordId),
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 202){
        out <- ZenodoRecord$new(obj = zenReq$getResponse())
        infoMsg = sprintf("Successful published record '%s'", recordId)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while publishing record '%s': %s", recordId, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #File management
    #------------------------------------------------------------------------------------------
    
    #' @description Get list of files attached to a Zenodo record.
    #' @param recordId the ID of the record.
    #' @return list of files
    getFiles = function(recordId){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("records/%s/draft/files", recordId),
                                  accept = "application/json",
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        out <- resp$entries
        infoMsg = sprintf("Successful fetched file(s) for record '%s'", recordId)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while fetching file(s) for record '%s': %s", recordId, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Get a file record metadata.
    #' @param recordId the ID of the record.
    #' @param filename filename
    #' @return the file metadata
    getFile = function(recordId, filename){
      zenReq <- ZenodoRequest$new(private$url, "GET", sprintf("records/%s/draft/files/%s", recordId, filename),
                                  accept = "application/json",
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- zenReq$getResponse()
      if(zenReq$getStatus() == 200){
        infoMsg = sprintf("Successful fetched file metadata for record '%s' - filename '%s'", recordId, filename)
        cli::cli_alert_success(infoMSg)
        self$INFO(infoMsg)
      }else{
        errMsg = sprintf("Error while fetching file(s) for record '%s': %s", recordId, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Start a file upload. The method will create a key for the file to be uploaded
    #' This method is essentially for internal purpose, and is called directly in \code{uploadFile}
    #' for user convenience and for backward compatibility with the legacy Zenodo API.
    #' @param path Local path of the file
    #' @param recordId ID of the record
    startFileUpload = function(path, recordId){
      self$INFO(sprintf("Start upload procedure for file '%s'", path))
      fileparts <- unlist(strsplit(path,"/"))
      filename <- fileparts[length(fileparts)]
    
      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("records/%s/draft/files", recordId),
                                  data = list(list(key = filename)),
                                  token = self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 201){
        infoMsg = sprintf("Successfully started upload procedure for file '%s'", path)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
        out <- TRUE
      }else{
        errMsg = sprintf("Error while starting upload procedure for file '%s' in record %s: %s", 
                         path, recordId, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Completes a file upload. The method will complete a file upload through a commit operation
    #' This method is essentially for internal purpose, and is called directly in \code{uploadFile}
    #' for user convenience and for backward compatibility with the legacy Zenodo API.
    #' @param path Local path of the file
    #' @param recordId ID of the record
    completeFileUpload = function(path, recordId){
      infoMsg = sprintf("Complete upload procedure for file '%s'", path)
      cli::cli_alert_info(infoMsg)
      self$INFO(infoMsg)
      fileparts <- unlist(strsplit(path,"/"))
      filename <- fileparts[length(fileparts)]

      zenReq <- ZenodoRequest$new(private$url, "POST", sprintf("records/%s/draft/files/%s/commit", recordId, filename),
                                  token = self$getToken(), 
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 200){
        infoMsg = sprintf("Successfully completed upload procedure for file '%s'", path)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
        out <- TRUE
      }else{
        errMsg = sprintf("Error while completing upload procedure for file '%s' in record %s: %s", 
                         path, recordId, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      return(out)
    },
    
    #' @description Uploads a file to a Zenodo record. With the new Zenodo Invenio RDM API, this method
    #' internally calls \code{startFileUpload} to create a file record (with a filename key) at start, followed
    #' by the actual file content upload. At this stage, the file upload is in "pending" status. At the end,
    #' the function calls \code{completeFileUpload} to commit the file which status becomes "completed".
    #' @param path Local path of the file
    #' @param recordId ID of the record. Deprecated, use \code{record} instead to take advantage of the new Zenodo bucket upload API.
    #' @param record object of class \code{ZenodoRecord}
    uploadFile = function(path, recordId = NULL, record = NULL){
      newapi = TRUE
      if(!is.null(recordId)){
        warnMsg = "'recordId' argument is deprecated, please consider using 'record' argument giving an object of class 'ZenodoRecord'"
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
        warnMsg = "'recordId' is used, cannot determine new API record bucket, switch to old upload API..."
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
        newapi <- FALSE
      }
      if(!is.null(record)) recordId <- record$id
      fileparts <- unlist(strsplit(path,"/"))
      filename <- fileparts[length(fileparts)]
      if(!"bucket" %in% names(record$links)){
        warnMsg = sprintf("No bucket link for record id = %s. Revert to old file upload API", recordId)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
        newapi <- FALSE
      }
      
      #start upload (needed with new Invenio RDM API)
      if(newapi){
        started = self$startFileUpload(path = path, recordId = recordId)
        if(!started){
          return(NULL)
        }
      }
        
      #proceed with upload
      method <- if(newapi) "PUT"  else "POST"
      if(newapi){
        infoMsg = "Using new file upload API with bucket"
        cli::cli_alert_info(infoMsg)
        self$INFO(infoMsg)
      }
      method_url <- if(newapi) sprintf("records/%s/draft/files/%s/content", recordId, URLencode(filename)) else sprintf("deposit/depositions/%s/files", recordId)
      print(method_url)
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
        infoMsg = sprintf("Successful uploaded file to record '%s'", recordId)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
        rec_files = self$getFiles(recordId = recordId)
        out = rec_files$entries[sapply(rec_files$entries, function(x){x$key == filename})][[1]]
        return(out)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while uploading file to record '%s': %s", recordId, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
      }
      
      #complete upload (needed with new Invenio RDM API)
      if(newapi){
        completed = self$completeFileUpload(path = path, recordId = recordId)
        if(!completed){
          warnMsg = "File upload procedure completion failed, file is uploaded but remains in 'pending' status!"
          cli::cli_alert_warning(warnMsg)
          self$WARN(warnMsg)
        }else{
          out$status = "completed"
        }
      }

      return(out)
    },
    
    #' @description Deletes a file for a record. With the new Zenodo Invenio RDM API, if a file is
    #' deleted although its status was pending, only the upload content is deleted, and the file upload
    #' record (identified by a filename key) is kept. If the status was completed (with a file commit),
    #' the file record is deleted. 
    #' @param recordId ID of the record
    #' @param filename name of the file to be deleted
    deleteFile = function(recordId, filename){
      zenReq <- ZenodoRequest$new(private$url, "DELETE", sprintf("records/%s/draft/files", recordId), 
                                  data = filename, token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- FALSE
      if(zenReq$getStatus() == 204){
        out <- TRUE
        infoMsg = sprintf("Successful deleted file from record '%s'", recordId)
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while deleting file from record '%s': %s", recordId, out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
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
    getRecords = function(q = "", size = 10, all_versions = FALSE, exact = TRUE){
      page <- 1
      req <- sprintf("records?q=%s&size=10page=%s", URLencode(q), page)
      if(all_versions) req <- paste0(req, "&allversions=1")
      zenReq <- ZenodoRequest$new(private$url, "GET", req, 
                                  token = self$getToken(),
                                  logger = NULL)
      zenReq$execute()
      total = 0
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        total <- resp$hits$total
        if(total > 10000){
          warnMsg = sprintf("Total of %s records found: the Zenodo API limits to a maximum of 10,000 records!", total)
          cli::cli_alert_warning(warnMsg)
          self$WARN(warnMSg) 
        }
      }
      
      req <- sprintf("records?q=%s&size=%s&page=%s", URLencode(q), size, page)
      if(all_versions) req <- paste0(req, "&allversions=1")
      zenReq <- ZenodoRequest$new(private$url, "GET_WITH_CURL", req, 
                                  token = self$getToken(),
                                  logger = self$loggerType)
      zenReq$execute()
      out <- NULL
      if(zenReq$getStatus() == 200){
        resp <- zenReq$getResponse()
        total_remaining <- total
        records = resp
        hasRecords <- length(records)>0
        while(hasRecords){
          out <- c(out, lapply(records, ZenodoRecord$new))
          infoMsg = sprintf("Successfully fetched list of published records - page %s", page)
          cli::cli_alert_info(infoMsg)
          self$INFO(infoMsg)
          total_remaining <- total_remaining-length(records)
          if(total_remaining <= size) size = total_remaining
          if(total_remaining == 0){
            break
          }
          
          if(exact){
            hasRecords <- FALSE
          }else{
            #next
            page <- page+1
            nextreq <- sprintf("records?q=%s&size=%s&page=%s", URLencode(q), size, page)
            if(all_versions) nextreq <- paste0(nextreq, "&allversions=1")
            zenReq <- ZenodoRequest$new(private$url, "GET_WITH_CURL", nextreq, 
                                        token = self$getToken(),
                                        logger = self$loggerType)
            zenReq$execute()
            if(zenReq$getStatus() == 200){
              resp <- zenReq$getResponse()
              records <- resp$hits$hits
              hasRecords <- length(records)>0
            }else{
              warnMsg = sprintf("Maximum allowed size for list of published records at page %s", page)
              cli::cli_alert_warning(warnMsg)
              self$WARN(warnMsg)
              break
            }
          }
        }
        infoMsg = "Successfully fetched list of published records!"
        cli::cli_alert_success(infoMsg)
        self$INFO(infoMsg)
      }else{
        out <- zenReq$getResponse()
        errMsg = sprintf("Error while fetching published records: %s", out$message)
        cli::cli_alert_danger(errMsg)
        self$ERROR(errMsg)
        for(error in out$errors){
          errMsg = sprintf("Error: %s - %s", error$field, error$message)
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
        }
      }
      return(out)
    },
    
    #' @description Get Record by concept DOI
    #' @param conceptdoi the concept DOI
    #' @return a object of class \code{ZenodoRecord}
    getRecordByConceptDOI = function(conceptdoi){
      if(regexpr("zenodo", conceptdoi) < 0){
        errMsg = sprintf("DOI '%s' doesn not seem to be a Zenodo DOI", conceptdoi)
        cli::cli_alert_danger(errMsg)
        stop(errMsg)
      }
      query <- sprintf("conceptdoi:\"%s\"", conceptdoi)
      result <- self$getRecords(q = query, all_versions = TRUE, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$getConceptDOI() == conceptdoi){
          infoMsg = sprintf("Successfully fetched published record for concept DOI '%s'!", conceptdoi)
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)){
        warnMsg = sprintf("No published record for concept DOI '%s'!", conceptdoi)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
      }
      if(is.null(result)){
        #try to get record by id
        if( regexpr("zenodo", conceptdoi)>0){
          conceptrecid <- unlist(strsplit(conceptdoi, "zenodo."))[2]
          infoMsg = sprintf("Try to get published record by Zenodo concept record id '%s'", conceptrecid)
          cli::cli_alert_info(infoMsg)
          self$INFO(infoMsg)
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
        errMsg = sprintf("DOI '%s' doesn not seem to be a Zenodo DOI", doi)
        cli::cli_alert_danger(errMsg)
        stop(errMsg)
      }
      query <- sprintf("doi:\"%s\"", doi)
      result <- self$getRecords(q = query, all_versions = TRUE, exact = TRUE)
      if(length(result)>0){
        result <- result[[1]]
        if(result$getDOI() == doi){
          infoMsg = sprintf("Successfully fetched record for DOI '%s'!",doi)
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)){
        warnMsg = sprintf("No record for DOI '%s'!",doi)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
      }
      if(is.null(result)){
        #try to get record by id
        if( regexpr("zenodo", doi)>0){
          recid <- unlist(strsplit(doi, "zenodo."))[2]
          infoMsg = sprintf("Try to get deposition by Zenodo specific record id '%s'", recid)
          cli::cli_alert_info(infoMsg)
          self$INFO(infoMsg)
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
          infoMsg = sprintf("Successfully fetched record for id '%s'!",recid)
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)){
        warnMsg = sprintf("No record for id '%s'!",recid)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
      }
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
        if(result$getConceptId() == conceptrecid){
          infoMSg = sprintf("Successfully fetched record for concept id '%s'!",conceptrecid)
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }else{
          result <- NULL
        }
      }else{
        result <- NULL
      }
      if(is.null(result)){
        warnMsg = sprintf("No record for concept id '%s'!",conceptrecid)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
      }
      return(result)
    }
    
  )
)
