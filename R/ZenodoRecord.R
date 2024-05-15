#' ZenodoRecord
#' @docType class
#' @export
#' @keywords zenodo record
#' @return Object of \code{\link{R6Class}} for modelling an ZenodoRecord
#' @format \code{\link{R6Class}} object.
#' 
#' @author Emmanuel Blondel <emmanuel.blondel1@@gmail.com>
#' 
ZenodoRecord <-  R6Class("ZenodoRecord",
  inherit = zen4RLogger,
  private = list(
    allowed_additional_title_types = c("alternative-title", "subtitle", "translated-title", "other"),
    allowed_additional_description_types = c("abstract", "methods", "series-information", "table-of-contents", "technical-info", "other"),
    allowed_role_types = c("contactperson", "datacollector", "datacurator", "datamanager", 
                           "distributor", "editor", "funder", "hostinginstitution", "producer", 
                           "projectleader", "projectmanager", "projectmember", "registrationagency", 
                           "registrationauthority", "relatedperson", "researcher", "researchgroup", 
                           "rightsholder", "supervisor", "sponsor", "workpackageleader", 
                           "other"),
    allowed_date_types = c("accepted", "available", "collected", "copyrighted", "created", "issued", 
                           "other", "submitted", "updated", "valid", "withdrawn"),
    allowed_identifier_schemes = c("ark", "arxiv", "bibcode", "doi", "ean13", "eissn", "handle", "igsn", "isbn",
                                   "issn", "istc", "lissn", "lsid", "pubmed id", "purl", "upc", "url", "urn", "w3id"),
    allowed_relation_types = c("iscitedby", "cites", "issupplementto", "issupplementedby", 
                          "iscontinuedby", "continues", "isdescribedby", "describes", "hasmetadata", 
                          "ismetadatafor", "isnewversionof", "ispreviousversionof", "ispartof", 
                          "haspart", "isreferencedby", "references", "isdocumentedby", 
                          "documents", "iscompiledby", "compiles", "isvariantformof", "isoriginalformof", 
                          "isidenticalto", "isalternateidentifier", "isreviewedby", "reviews", 
                          "isderivedfrom", "issourceof", "requires", "isrequiredby", "isobsoletedby", 
                          "obsoletes"),
    export_formats = c("BibTeX","CSL","DataCite","DublinCore","DCAT","JSON","JSON-LD","GeoJSON","MARCXML"),
    getExportFormatExtension = function(format){
      switch(format,
         "BibTeX" = "bib",
         "CSL" = "json",
         "DataCite" ="xml",
         "DublinCore" = "xml",
         "DCAT" = "rdf",
         "JSON" = "json",
         "JSON-LD" = "json",
         "GeoJSON" = "json",
         "MARCXML" = "xml"           
      )
    },
    fromList = function(obj){
      self$created = obj$created
      self$updated = obj$updated
      self$revision_id = obj$revision_id
      self$status = obj$status
      self$is_draft = obj$is_draft
      self$is_published = obj$is_published
      self$versions = obj$versions
      
      #invenio model
      self$access = obj$access
      self$links = obj$links
      self$files = lapply(obj$files$entries, function(file){
        list(
          filename = if(!is.null(file$filename)) file$filename else file$key,
          filesize = if(!is.null(file$filesize)) file$filesize else file$size,
          checksum = if(!startsWith(file$checksum, "md5:")) file$checksum else unlist(strsplit(file$checksum, "md5:"))[2],
          download = if(!is.null(file$links$download)) file$links$download else file.path(self$links$self, sprintf("files/%s/content", file$key))
        )
      })
      self$id = obj$id
      self$metadata = obj$metadata
      resource_type = self$metadata$resource_type
      if(!is.null(resource_type)){
        resource_type_id = resource_type$id
        self$metadata$resource_type = list(id = resource_type_id)
      }
      self$pids = obj$pids
      self$parent = obj$parent
      
      #zen4R specific fields
      if(!is.null(obj$stats)) self$stats = data.frame(obj$stats)
    }
  ),
  public = list(
    
    #' @field created record creation date
    created = NULL,
    #' @field updated record update date
    updated = NULL,
    #' @field revision_id revision id
    revision_id = NULL,
    #' @field is_draft is draft
    is_draft = NULL,
    #' @field is_published is published
    is_published = NULL,
    #' @field status record status
    status = NULL,
    #' @field versions versions
    versions = NULL,
    
    #' @field access access policies
    access = list(
      record = "public", 
      files = "public"
    ),
    
    #' @field files list of files associated to the record
    files = list(),
    #' @field id record id
    id = NULL,
    #' @field links list of links associated to the record
    links = list(),
    #' @field metadata metadata elements associated to the record
    metadata = list(),
    #' @field parent parent record
    parent = NULL,
    #' @field pids pids
    pids = list(),
    
    #zen4R specific fields
    
    #' @field stats stats
    stats = NULL,
    
    #' @description method is used to instantiate a \code{\link{ZenodoRecord}}
    #' @param obj an optional list object to create the record
    #' @param logger a logger to print log messages. It can be either NULL, "INFO" (with minimum logs), 
    #' or "DEBUG" (for complete curl http calls logs)
    initialize = function(obj = NULL, logger = "INFO"){
      super$initialize(logger = logger)
      if(!is.null(obj)) private$fromList(obj)
    },
    
    #zen4R specific methods
    #---------------------------------------------------------------------------
    
    #' @description Get record statistics
    #' @return statistics as \code{data.frame}
    getStats = function(){
      return(self$stats)
    },
    
    #Invenio RDM API new methods
    #---------------------------------------------------------------------------
    #ID methods
    #---------------------------------------------------------------------------
    
    #'@description Get the record Id
    #'@return the Id, object of class \code{character}
    getId = function(){
      return(self$id)
    },
    
    #'@description Get the parent record Id
    #'@return the parent Id, object of class \code{character}
    getParentId = function(){
      return(self$parent$id)
    },
    
    #'@description Get the concept record Id
    #'@return the concept Id, object of class \code{character}
    getConceptId = function(){
      self$getParentId()
    },
    
    #DOI methods
    #---------------------------------------------------------------------------
    
    #' @description Set the DOI. This method can be used if a DOI has been already assigned outside Zenodo.
    #' @param doi DOI to set for the record
    #' @param provider DOI provider
    #' @param client DOI client
    setDOI = function(doi, provider = NULL, client = NULL){
      self$pids = list(doi = list(identifier = doi, provider = provider, client = client))
    },
    
    #'@description Get the record DOI.
    #'@return the DOI, object of class \code{character}
    getDOI = function(){
      return(self$pids$doi$identifier)
    },
    
    #' @description Get the concept (generic) DOI. The concept DOI is a generic DOI 
    #' common to all versions of a Zenodo record.
    #' @return the concept DOI, object of class \code{character}
    getConceptDOI = function(){
      conceptdoi = NULL
      doi <- self$pids$doi$identifier
      if(!is.null(doi)) if(regexpr("zenodo", doi)>0){
        doi_parts <- unlist(strsplit(doi, "zenodo."))
        conceptdoi <- paste0(doi_parts[1], "zenodo.", self$getConceptId())
      }
      return(conceptdoi)
    },
    
    #Access methods
    #---------------------------------------------------------------------------
    
    #'@description Set the access policy for record, among values "public" (default) or "restricted"
    #'@param access access policy ('public' or 'restricted')
    setAccessPolicyRecord = function(access = c("public","resticted")){
      self$access$record = access
    },
    
    #'@description Set the access policy for files, among values "public" (default) or "restricted"
    #'@param access access policy ('public' or 'restricted')
    setAccessPolicyFiles = function(access = c("public","resticted")){
      self$access$files = access
    },
    
    #'@description Set access policy embargo options
    #'@param active whether embargo is active or not. Default is \code{FALSE}
    #'@param until embargo date, object of class \code{Date}. Default is \code{NULL}. Must be provided if embargo is active
    #'@param reason embargo reason, object of class \code{character}. Default is an empty string
    setAccessPolicyEmbargo = function(active = FALSE, until = NULL, reason = ""){
      if(!is.null(until)) if(!is(until, "Date")) stop("Argument 'until' should be of class 'Date'")
      self$access$embargo = list(active = active, until = until, reason = reason)
    },
    
    #Resource type methods
    #---------------------------------------------------------------------------
    
    #' @description Set the resource type (mandatory). 
    #' @param resourceType record resource type
    setResourceType = function(resourceType){
      zenodo = ZenodoManager$new()
      zen_resourcetype <- zenodo$getResourceTypeById(resourceType)
      if(is.null(zen_resourcetype)){
        errorMsg <- sprintf("Resource type with id '%s' doesn't exist in Zenodo", resourceType)
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      self$metadata$resource_type <- list(id = zen_resourcetype$id)
    },
    
    #' @description Set the upload type (mandatory). Deprecated since zen4R 1.0
    #' @param uploadType record upload type among the following values: 'publication', 'poster', 
    #'  'presentation', 'dataset', 'image', 'video', 'software', 'lesson', 'physicalobject', 'other'
    setUploadType = function(uploadType){
      warnMsg = "Method 'setUploadType' is deprecated, please use 'setResourceType'"
      self$WARN(warnMsg)
    },
    
    #' @description Set the publication type (mandatory if upload type is 'publication'). Deprecated since zen4R 1.0
    #' @param publicationType record publication type among the following values: 'annotationcollection', 'book', 
    #'   'section', 'conferencepaper', 'datamanagementplan', 'article', 'patent', 'preprint', 'deliverable', 'milestone', 
    #'   'proposal', 'report', 'softwaredocumentation', 'taxonomictreatment', 'technicalnote', 'thesis', 'workingpaper', 
    #'   'other'
    setPublicationType = function(publicationType){
      warnMsg = "Method 'setPublicationType' is deprecated, please use 'setResourceType'"
      self$WARN(warnMsg)
    },
    
    #' @description Set the image type (mandatory if image type is 'image'). Deprecated since zen4R 1.0
    #' @param imageType record publication type among the following values: 'figure','plot',
    #' 'drawing','diagram','photo', or 'other'
    setImageType = function(imageType){
      warnMsg = "Method 'setImageType' is deprecated, please use 'setImageType'"
      self$WARN(warnMsg)
    },
    
    #Publication-related methods
    #---------------------------------------------------------------------------
    
    #' @description Set the publisher
    #' @param publisher publisher object of class \code{character}
    setPublisher = function(publisher){
      self$metadata$publisher = publisher  
    },
    
    #' @description Set the publication date. For more information on the accepted format,
    #' please check https://inveniordm.docs.cern.ch/reference/metadata/#publication-date-1
    #' @param publicationDate object of class \code{character}
    setPublicationDate = function(publicationDate){
      self$metadata$publication_date <- publicationDate
    },
    
    #' @description Add date
    #' @param date date
    #' @param type type of date, among following values: 'accepted', 'available', 'collected', 'copyrighted', 
    #' 'created', 'issued', 'other', 'submitted', 'updated', 'valid', 'withdrawn'
    #' @param description free text, specific information about the date
    addDate = function(date, type, description = NULL){
      if(!type %in% private$allowed_date_types){
        errMsg = sprintf("Date type should be among following possible values: %s",
                         paste0(private$allowed_date_types, collapse=", "))
        self$ERROR(errMsg)
        stop(errMsg)
      }
      if(is.null(self$metadata$dates)) self$metadata$dates = list()
      self$metadata$dates[[length(self$metadata$dates)+1]] = list(
        date = date, 
        type = list(id = type), 
        description = description
      )
    },
    
    #' @description Remove a date
    #' @param date the date to remove
    #' @param type the date type of the date to be removed
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeDate = function(date, type){
      removed <- FALSE
      if(!is.null(self$metadata$dates)){
        for(i in 1:length(self$metadata$dates)){
          dat <- self$metadata$dates[[i]]
          if(dat$date == date & dat$type$id == type){
            self$metadata$dates[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #Description methods
    #---------------------------------------------------------------------------
    
    #' @description Set the record title.
    #' @param title object of class \code{character}
    setTitle = function(title){
      self$metadata$title <- title
    },
    
    #' @description Add additional record title
    #' @param title title free text
    #' @param type type of title, among following values: alternative-title, subtitle, translated-title, other
    #' @param lang language id
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addAdditionalTitle = function(title, type, lang = "eng"){
      added = FALSE
      if(!(type %in% private$allowed_additional_title_types)){
        errMsg = sprintf("Additional title type '%s' incorrect. Possible values are: %s",
                         type, paste0(private$allowed_additional_title_types, collapse=","))
        self$ERROR(errMsg)
        stop(errMsg)
      }
      
      if(is.null(self$metadata$additional_titles)) self$metadata$additional_titles = list()
      ids_df <- data.frame(
        title = character(0),
        type = character(0),
        lang = character(0),
        stringsAsFactors = FALSE
      )
      if(length(self$metadata$additional_titles)>0){
        ids_df <- do.call("rbind", lapply(self$metadata$additional_titles, function(x){
          data.frame(
            title = x$title,
            type = x$type$id,
            lang = x$lang$id,
            stringsAsFactors = FALSE
          )
        }))
      }
      if(nrow(ids_df[ids_df$title == title & 
                     ids_df$type == type &
                     ids_df$lang == lang,])==0){
        new_title = list(
          title = title,
          type = list(id = type),
          lang = list(id = lang)
        )
        self$metadata$additional_titles[[length(self$metadata$additional_titles)+1]] <- new_title
        added = TRUE
      }
      return(added)
    },
    
    #' @description Removes additional record title.
    #' @param title title free text
    #' @param type type of title, among following values: abstract, methods, 
    #' series-information, table-of-contents, technical-info, other
    #' @param lang language id
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeAdditionalTitle = function(title, type, lang = "eng"){
      removed <- FALSE
      if(!is.null(self$metadata$additional_titles)){
        for(i in 1:length(self$metadata$additional_titles)){
          desc <- self$metadata$additional_titles[[i]]
          if(desc$title == title &&
             desc$type$id == type &&
             desc$lang$id == lang){
            self$metadata$additional_titles[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #' @description Set the record description
    #' @param description object of class \code{character}
    setDescription = function(description){
      self$metadata$description <- description
    },
    
    #' @description Add additional record description
    #' @param description description free text
    #' @param type type of description, among following values: abstract, methods, 
    #' series-information, table-of-contents, technical-info, other
    #' @param lang language id
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addAdditionalDescription = function(description, type, lang = "eng"){
      added = FALSE
      if(!(type %in% private$allowed_additional_description_types)){
        errMsg = sprintf("Additional description type '%s' incorrect. Possible values are: %s",
                         type, paste0(private$allowed_additional_description_types, collapse=","))
        self$ERROR(errMsg)
        stop(errMsg)
      }
      
      if(is.null(self$metadata$additional_descriptions)) self$metadata$additional_descriptions = list()
      ids_df <- data.frame(
        description = character(0),
        type = character(0),
        lang = character(0),
        stringsAsFactors = FALSE
      )
      if(length(self$metadata$additional_descriptions)>0){
        ids_df <- do.call("rbind", lapply(self$metadata$additional_descriptions, function(x){
          data.frame(
            description = x$description,
            type = x$type$id,
            lang = x$lang$id,
            stringsAsFactors = FALSE
          )
        }))
      }
      if(nrow(ids_df[ids_df$description == description & 
                     ids_df$type == type &
                     ids_df$lang == lang,])==0){
        new_desc = list(
          description = description,
          type = list(id = type),
          lang = list(id = lang)
        )
        self$metadata$additional_descriptions[[length(self$metadata$additional_descriptions)+1]] <- new_desc
        added = TRUE
      }
      return(added)
    },
    
    #' @description Removes additional record description
    #' @param description description free text
    #' @param type type of description, among following values: abstract, methods, 
    #' series-information, table-of-contents, technical-info, other
    #' @param lang language id
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeAdditionalDescription = function(description, type, lang = "eng"){
      removed <- FALSE
      if(!is.null(self$metadata$additional_descriptions)){
        for(i in 1:length(self$metadata$additional_descriptions)){
          desc <- self$metadata$additional_descriptions[[i]]
          if(desc$description == description &&
             desc$type$id == type &&
             desc$lang$id == lang){
            self$metadata$additional_descriptions[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    # PERSON OR ORG
    #---------------------------------------------------------------------------
    
    #' @description Add a person or organization for the record. For persons, the approach is to use the \code{firstname} and
    #'    \code{lastname} arguments, that by default will be concatenated for Zenodo as \code{lastname, firstname}.
    #'    For organizations, use the \code{name} argument.
    #' @param firstname person first name
    #' @param lastname person last name
    #' @param name organization name
    #' @param orcid person or organization ORCID (optional)
    #' @param gnd person or organization GND (optional)
    #' @param isni person or organization ISNI (optional)
    #' @param ror person or organization ROR (optional)
    #' @param role role, values among: contactperson, datacollector, datacurator, datamanager, distributor, editor, funder, 
    #' hostinginstitution, producer, projectleader, projectmanager, projectmember, registrationagency, registrationauthority, 
    #' relatedperson, researcher, researchgroup, rightsholder, supervisor, sponsor, workpackageleader, other
    #' @param affiliations person or organization affiliations (optional)
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available affiliations. Default is \code{FALSE}
    #' @param type type of person or org (creators/contributors)
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    #' 
    #' @note Internal method. Prefer using \code{addCreator} or \code{addContributor}
    #' 
    addPersonOrOrg = function(firstname = NULL, lastname = NULL, name = paste(lastname, firstname, sep = ", "),
                          orcid = NULL, gnd = NULL, isni = NULL, ror = NULL, role = NULL, affiliations = NULL, sandbox = FALSE,
                          type){
      personOrOrg <- list(
        person_or_org = list(
          type = if(!is.null(firstname)&&!is.null(lastname)) "personal" else "organizational",
          given_name = firstname,
          family_name = lastname,
          name = name,
          identifiers = list()
        ),
        role = NULL,
        affiliations = list()
      )
      #identifiers
      if(!is.null(orcid)) personOrOrg$person_or_org$identifiers[[length(personOrOrg$person_or_org$identifiers)+1]] = list(scheme = "orcid", identifier = orcid)
      if(!is.null(gnd)) personOrOrg$person_or_org$identifiers[[length(personOrOrg$person_or_org$identifiers)+1]] = list(scheme = "gnd", identifier = gnd)
      if(!is.null(isni)) personOrOrg$person_or_org$identifiers[[length(personOrOrg$person_or_org$identifiers)+1]] = list(scheme = "isni", identifier = isni)
      if(!is.null(ror)) personOrOrg$person_or_org$identifiers[[length(personOrOrg$person_or_org$identifiers)+1]] = list(scheme = "ror", identifier = ror)
      
      #role
      if(!is.null(role)){
        if(!(role %in% private$allowed_role_types)){
          stop(sprintf("The role type should be one value among values [%s]",
                       paste(private$allowed_role_types, collapse=",")))
        }
        personOrOrg$role = list(id = role)
      }
        
      #affiliations
      if(!is.null(affiliations)) if(personOrOrg$person_or_org$type == "personal"){
        zen = ZenodoManager$new(sandbox = sandbox)
        affs = lapply(affiliations, function(affiliation){
          zen_affiliation <- zen$getAffiliationById(affiliation)
          if(is.null(zen_affiliation)){
            warnMsg <- sprintf("Affiliation with id '%s' doesn't exist in Zenodo", affiliation)
            self$WARN(errorMsg)
            return(NULL)
          }
          return(list(id = zen_affiliation$id))
        })
        affs = affs[!sapply(affs,is.null)]
        personOrOrg$affiliations = affs
      }
      
      if(is.null(self$metadata[[type]])) self$metadata[[type]] <- list()
      self$metadata[[type]][[length(self$metadata[[type]])+1]] <- personOrOrg
    },
    
    #' @description Removes a person or organization by a property. The \code{by} parameter should be the name
    #'    of the person or organization property ('name', 'affiliation','orcid','gnd','isni','ror').
    #' @param by property used as criterion to remove the person or organization
    #' @param property property value used to remove the person or organization
    #' @param type type of person or org (creators / contributors)
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    #' 
    #' @note Internal method. Prefer using \code{removeCreator} or \code{removeContributor}
    #'
    removePersonOrOrg = function(by, property, type){
      removed <- FALSE
      for(i in 1:length(self$metadata[[type]])){
        personOrOrg <- self$metadata[[type]][[i]]
        personOrOrg_map = personOrOrg$person_or_org[names(personOrOrg$person_or_org)!="identifiers"]
        if(!is.null(personOrOrg$person_or_org$identifiers)) for(identifier in personOrOrg$person_or_org$identifiers){
          personOrOrg_map = c(personOrOrg_map, scheme = identifier$identifier)
          names(personOrOrg_map)[names(personOrOrg_map)=="scheme"] = identifier$scheme
        }
        if(personOrOrg_map[[by]]==property){
          self$metadata[[type]][[i]] <- NULL
          removed <- TRUE 
        }
      }
      return(removed)
    },
    
    # CREATORS
    #---------------------------------------------------------------------------
    
    #' @description Add a creator for the record. For persons, the approach is to use the \code{firstname} and
    #'    \code{lastname} arguments, that by default will be concatenated for Zenodo as \code{lastname, firstname}.
    #'    For organizations, use the \code{name} argument.
    #' @param firstname person first name
    #' @param lastname person last name
    #' @param name organization name
    #' @param orcid creator ORCID (optional)
    #' @param gnd creator GND (optional)
    #' @param isni creator ISNI (optional)
    #' @param ror creator ROR (optional)
    #' @param role role, values among: contactperson, datacollector, datacurator, datamanager, distributor, editor, funder, 
    #' hostinginstitution, producer, projectleader, projectmanager, projectmember, registrationagency, registrationauthority, 
    #' relatedperson, researcher, researchgroup, rightsholder, supervisor, sponsor, workpackageleader, other
    #' @param affiliations creator affiliations (optional)
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available affiliations. Default is \code{FALSE}
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addCreator = function(firstname = NULL, lastname = NULL, name = paste(lastname, firstname, sep = ", "),
                              orcid = NULL, gnd = NULL, isni = NULL, ror = NULL, role = NULL, affiliations = NULL, sandbox = FALSE){
      self$addPersonOrOrg(firstname = firstname, lastname = lastname, name = name, 
                          orcid = orcid, gnd = gnd, isni = isni, ror = ror, role = role, affiliations = affiliations, sandbox = sandbox,
                          type = "creators")
    },
    
    #' @description Removes a creator by name.
    #' @param name creator name
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByName = function(name){
      return(self$removePersonOrOrg(by = "name", name, type = "creators"))
    },

    #' @description Removes a creator by affiliation.
    #' @param affiliation creator affiliation
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByAffiliation = function(affiliation){
      return(self$removePersonOrOrg(by = "affiliation", affiliation, type = "creators"))
    },
    
    #' @description Removes a creator by ORCID.
    #' @param orcid creator ORCID
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByORCID = function(orcid){
      return(self$removePersonOrOrg(by = "orcid", orcid, type = "creators"))
    },
    
    #' @description Removes a creator by GND.
    #' @param gnd creator GND
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByGND = function(gnd){
      return(self$removePersonOrOrg(by = "gnd", gnd, type = "creators"))
    },
    
    #' @description Removes a creator by ISNI.
    #' @param isni creator ISNI
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByISNI = function(isni){
      return(self$removePersonOrOrg(by = "isni", isni, type = "creators"))
    },
    
    #' @description Removes a creator by ROR.
    #' @param ror creator ROR
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByROR = function(ror){
      return(self$removePersonOrOrg(by = "ror", ror, type = "creators"))
    },
    
    # CONTRIBUTORS
    #---------------------------------------------------------------------------
    
    #' @description Add a contributor for the record. For persons, the approach is to use the \code{firstname} and
    #'    \code{lastname} arguments, that by default will be concatenated for Zenodo as \code{lastname, firstname}.
    #'    For organizations, use the \code{name} argument.
    #' @param firstname person first name
    #' @param lastname person last name
    #' @param name organization name
    #' @param orcid contributor ORCID (optional)
    #' @param gnd contributor GND (optional)
    #' @param isni contributor ISNI (optional)
    #' @param ror contributor ROR (optional)
    #' @param role role, values among: contactperson, datacollector, datacurator, datamanager, distributor, editor, funder, 
    #' hostinginstitution, producer, projectleader, projectmanager, projectmember, registrationagency, registrationauthority, 
    #' relatedperson, researcher, researchgroup, rightsholder, supervisor, sponsor, workpackageleader, other
    #' @param affiliations contributor affiliations (optional)
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available affiliations. Default is \code{FALSE}
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addContributor = function(firstname = NULL, lastname = NULL, name = paste(lastname, firstname, sep = ", "),
                          orcid = NULL, gnd = NULL, isni = NULL, ror = NULL, role = NULL, affiliations = NULL, sandbox = FALSE){
      self$addPersonOrOrg(firstname = firstname, lastname = lastname, name = name, 
                          orcid = orcid, gnd = gnd, isni = isni, ror = ror, role = role, affiliations = affiliations, sandbox = sandbox,
                          type = "contributors")
    },
    
    #' @description Removes a contributor by name.
    #' @param name contributor name
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByName = function(name){
      return(self$removePersonOrOrg(by = "name", name, type = "contributors"))
    },
    
    #' @description Removes a contributor by affiliation.
    #' @param affiliation contributor affiliation
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByAffiliation = function(affiliation){
      return(self$removePersonOrOrg(by = "affiliation", affiliation, type = "contributors"))
    },
    
    #' @description Removes a contributor by ORCID.
    #' @param orcid contributor ORCID
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByORCID = function(orcid){
      return(self$removePersonOrOrg(by = "orcid", orcid, type = "contributors"))
    },
    
    #' @description Removes a contributor by GND.
    #' @param gnd contributor GND
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByGND = function(gnd){
      return(self$removePersonOrOrg(by = "gnd", gnd, type = "contributors"))
    },
    
    #' @description Removes a contributor by ISNI.
    #' @param isni contributor ISNI
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByISNI = function(isni){
      return(self$removePersonOrOrg(by = "isni", isni, type = "contributors"))
    },
    
    #' @description Removes a contributor by ROR.
    #' @param ror contributor ROR
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByROR = function(ror){
      return(self$removePersonOrOrg(by = "ror", ror, type = "contributors"))
    },
    
    #'@description Add right/license. Please see https://inveniordm.docs.cern.ch/reference/metadata/#rights-licenses-0-n
    #'@param id license id
    #'@param title license title
    #'@param description a multi-lingual list
    #'@param link license link
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available licenses. Default is \code{FALSE}
    addRight = function(id = NULL, title = NULL, description = NULL, link = NULL,
                        sandbox = FALSE){
      added = FALSE
      if(is.null(self$metadata$rights)) self$metadata$rights = list()
      zen <- ZenodoManager$new(sandbox = sandbox)
      if(!is.null(id)){
        zen_license <- zen$getLicenseById(id)
        if(is.null(zen_license)){
          errorMsg <- sprintf("License with id '%s' doesn't exist in Zenodo", id)
          self$ERROR(errorMsg)
          stop(errorMsg)
        }
        right = list(id = zen_license$id)
        self$metadata$rights[[length(self$metadata$rights)+1]] = right
        added = TRUE
      }else{
        if(is.null(title)){
          errMsg <- "At least an 'id' or 'title' must be provided"
          self$ERROR(errorMsg)
          stop(errorMsg)
        }else{
          right = list(title = title)
          if(!is.null(description)) right$description = description
          if(!is.null(link)) right$link = link
          self$metadata$rights[[length(self$metadata$rights)+1]] = right
          added = TRUE
        }
      }
      return(added)
    },
    
    #' @description Set license. The license should be set with the Zenodo id of the license. If not
    #'    recognized by Zenodo, the function will return an error. The list of licenses can
    #'    fetched with the \code{ZenodoManager} and the function \code{$getLicenses()}.
    #' @param licenseId a license Id
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available licenses. Default is \code{FALSE}
    setLicense = function(licenseId, sandbox = FALSE){
      self$addRight(id = licenseId)
    },
    
    #' @description Set record version.
    #' @param version the record version to set
    setVersion = function(version){
      self$metadata$version <- version
    },
    
    #' @description  Adds a language.
    #' @param language ISO 639-2 or 639-3 code
    addLanguage = function(language){
      zenodo = ZenodoManager$new()
      zen_language = zenodo$getLanguageById(language)
      if(is.null(zen_language)){
        errorMsg <- sprintf("Language with id '%s' doesn't exist in Zenodo", language)
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      self$metadata$languages[[length(self$metadata$languages)+1]] <- list(id = language)
    },
    
    #' @description Set the language
    #' @param language ISO 639-2 or 639-3 code
    setLanguage = function(language){
      warnMsg = "Method 'setLanguage' is deprecated, please use 'addLanguage'"
      self$WARN(warnMsg)
      self$addLanguage(language)
    },
    
    #' @description Adds a related identifier with a given scheme and relation type.
    #' @param identifier identifier
    #' @param scheme scheme among following values: ark, arxiv, bibcode, doi, ean13, eissn, handle, igsn, isbn, issn, istc, lissn, 
    #' lsid, pubmed id, purl, upc, url, urn, w3id
    #' @param relation_type relation type among following values: iscitedby, cites, issupplementto, issupplementedby, iscontinuedby, 
    #' continues, isdescribedby, describes, hasmetadata, ismetadatafor, isnewversionof, ispreviousversionof, ispartof, haspart, 
    #' isreferencedby, references, isdocumentedby, documents, iscompiledby, compiles, isvariantformof, isoriginalformof, isidenticalto, 
    #' isalternateidentifier, isreviewedby, reviews, isderivedfrom, issourceof, requires, isrequiredby, isobsoletedby, obsoletes
    #' @param resource_type optional resource type
    #'@return \code{TRUE} if added, \code{FALSE} otherwise
    addRelatedIdentifier = function(identifier, scheme, relation_type, resource_type = NULL){
      if(!(scheme %in% private$allowed_identifier_schemes)){
        stop(sprintf("Identifier scheme '%s%' incorrect. Use a value among the following [%s]",
                     scheme, paste0(private$allowed_identifier_schemes, collapse=",")))
      }
      if(!(relation_type %in% private$allowed_relation_types)){
        stop(sprintf("Relation type '%s' incorrect. Use a value among the following [%s]", 
                    relation_type, paste(private$allowed_relation_types, collapse=",")))
      }
      added <- FALSE
      if(is.null(self$metadata$related_identifiers)) self$metadata$related_identifiers <- list()
      ids_df <- data.frame(
        identifier = character(0),
        scheme = character(0),
        relation_type = character(0),
        resource_type = character(0),
        stringsAsFactors = FALSE
      )
      if(length(self$metadata$related_identifiers)>0){
        ids_df <- do.call("rbind", lapply(self$metadata$related_identifiers, function(x){
          data.frame(
            identifier = x$identifier,
            scheme = x$scheme,
            relation_type = x$relation_type$id,
            resource_type = if(!is.null(x$resource_type$id)) x$resource_type$id else NA,
            stringsAsFactors = FALSE
          )
        }))
      }
      if(nrow(ids_df[ids_df$relation == relation_type & ids_df$identifier == identifier,])==0){
        new_rel <- list(
          identifier = identifier,
          scheme = scheme,
          relation_type = list(id = relation_type)
        )
        if(!is.null(resource_type)) {
          zenodo = ZenodoManager$new()
          res = ZENODO$getResourceTypeById(resource_type)
          if(!is.null(res)){
            new_rel$resource_type = list(id = resource_type)
          }
        } 
        self$metadata$related_identifiers[[length(self$metadata$related_identifiers)+1]] <- new_rel
        added <- TRUE
      }
      return(added)
    },
    
    #' @description Removes a related identifier with a given scheme/relation_type
    #' @param identifier identifier
    #' @param scheme scheme among following values: ark, arxiv, bibcode, doi, ean13, eissn, handle, igsn, isbn, issn, istc, lissn, 
    #' lsid, pubmed id, purl, upc, url, urn, w3id
    #' @param relation_type relation type among following values: iscitedby, cites, issupplementto, issupplementedby, iscontinuedby, 
    #' continues, isdescribedby, describes, hasmetadata, ismetadatafor, isnewversionof, ispreviousversionof, ispartof, haspart, 
    #' isreferencedby, references, isdocumentedby, documents, iscompiledby, compiles, isvariantformof, isoriginalformof, isidenticalto, 
    #' isalternateidentifier, isreviewedby, reviews, isderivedfrom, issourceof, requires, isrequiredby, isobsoletedby, obsoletes
    #'@return \code{TRUE} if removed, \code{FALSE} otherwise
    removeRelatedIdentifier = function(identifier, scheme, relation_type){
      if(!(scheme %in% private$allowed_identifier_schemes)){
        stop(sprintf("Identifier scheme '%s%' incorrect. Use a value among the following [%s]",
                     scheme, paste0(private$allowed_identifier_schemes, collapse=",")))
      }
      if(!(relation_type %in% private$allowed_relation_types)){
        stop(sprintf("Relation '%s' incorrect. Use a value among the following [%s]", 
                     relation_type, paste(private$allowed_relation_types, collapse=",")))
      }
      removed <- FALSE
      if(!is.null(self$metadata$related_identifiers)){
        for(i in 1:length(self$metadata$related_identifiers)){
          related_id <- self$metadata$related_identifiers[[i]]
          if(related_id$identifier == identifier &
             related_id$scheme == scheme &
             related_id$relation_type$id == relation_type){
            self$metadata$related_identifiers[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #' @description Set references
    #' @param references a vector or list of references to set for the record
    setReferences = function(references){
      if(is.null(self$metadata$references)) self$metadata$references <- list()
      for(reference in references){
        self$addReference(reference)
      }
    },
    
    #' @description Add a reference
    #' @param reference the reference to add
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addReference = function(reference){
      added <- FALSE
      if(is.null(self$metadata$references)) self$metadata$references <- list()
      if(!(reference %in% sapply(self$metadata$references, function(x){x$reference}))){
        self$metadata$references[[length(self$metadata$references)+1]] <- list(reference = reference)
        added <- TRUE
      }
      return(added)
    },
    
    #' @description Remove a reference
    #' @param reference the reference to remove
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeReference = function(reference){
      removed <- FALSE
      if(!is.null(self$metadata$references)){
        for(i in 1:length(self$metadata$references)){
          ref <- self$metadata$references[[i]]
          if(ref$reference == reference){
            self$metadata$references[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #' @description Set subjects
    #' @param subjects a vector or list of subjects to set for the record
    setSubjects = function(subjects){
      if(is.null(self$metadata$subjects)) self$metadata$subjects <- list()
      for(subject in subjects){
        self$addSubject(subject)
      }
    },
    
    #' @description Set keywords
    #' @param keywords a vector or list of keywords to set for the record
    setKeywords = function(keywords){
      warnMsg = "Method 'setKeywords' is deprecated, please use 'setSubjects'"
      self$WARN(warnMsg)
      self$setSubjects(keywords)
    },
    
    #' @description Add a subject
    #' @param subject the subject to add
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addSubject = function(subject){
      added <- FALSE
      if(is.null(self$metadata$subjects)) self$metadata$subjects <- list()
      if(!(subject %in% self$metadata$subjects)){
        self$metadata$subjects[[length(self$metadata$subjects)+1]] <- list(subject = subject)
        added <- TRUE
      }
      return(added)
    },
    
    #' @description Add a keyword
    #' @param keyword the keyword to add
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addKeyword = function(keyword){
      warnMsg = "Method 'addKeyword' is deprecated, please use 'addSubject'"
      self$WARN(warnMsg)
      self$addSubject(keyword)
    },
    
    #' @description Remove a subject
    #' @param subject the subject to remove
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeSubject = function(subject){
      removed <- FALSE
      if(!is.null(self$metadata$subjects)){
        for(i in 1:length(self$metadata$subjects)){
          sbj <- self$metadata$subjects[[i]]
          if(sbj$subject == subject){
            self$metadata$subjects[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #' @description Remove a keyword
    #' @param keyword the keyword to remove
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeKeyword = function(keyword){
      warnMsg = "Method 'removeKeyword' is deprecated, please use 'removeSubject'"
      self$WARN(warnMsg)
      self$removeSubject(keyword)
    },
    
    #' @description Set notes. HTML is not allowed
    #' @param notes object of class \code{character}
    setNotes = function(notes){
      self$metadata$notes <- notes
    },
    
    #' @description Set a vector of character strings identifying communities
    #' @param communities a vector or list of communities. Values should among known communities. The list of communities can
    #'    fetched with the \code{ZenodoManager} and the function \code{$getCommunities()}. Each community should be set with 
    #'    the Zenodo id of the community. If not recognized by Zenodo, the function will return an error.
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available communities. Default is \code{FALSE}
    setCommunities = function(communities, sandbox = FALSE){
      if(is.null(self$metadata$communities)) self$metadata$communities <- list()
      for(community in communities){
        self$addCommunity(community, sandbox = sandbox)
      }
    },
    
    #' @description Adds a community to the record metadata. 
    #' @param community community to add. The community should be set with the Zenodo id of the community. 
    #'   If not recognized by Zenodo, the function will return an error. The list of communities can fetched 
    #'   with the \code{ZenodoManager} and the function \code{$getCommunities()}.
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available communities. Default is \code{FALSE}
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addCommunity = function(community, sandbox = FALSE){
      added <- FALSE
      zen <- ZenodoManager$new(sandbox = sandbox)
      if(is.null(self$metadata$communities)) self$metadata$communities <- list()
      if(!(community %in% sapply(self$metadata$communities, function(x){x$identifier}))){
        zen_community <- zen$getCommunityById(community)
        if(is.null(zen_community)){
          errorMsg <- sprintf("Community with id '%s' doesn't exist in Zenodo", community)
          self$ERROR(errorMsg)
          stop(errorMsg)
        }
        self$metadata$communities[[length(self$metadata$communities)+1]] <- list(identifier = community)
        added <- TRUE
      }
      return(added)
    },
    
    #' @description Removes a community from the record metadata. 
    #' @param community community to remove. The community should be set with the Zenodo id of the community.
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCommunity = function(community){
      removed <- FALSE
      if(!is.null(self$metadata$communities)){
        for(i in 1:length(self$metadata$communities)){
          com <- self$metadata$communities[[i]]
          if(com == community){
            self$metadata$communities[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #' @description Set a vector of character strings identifying grants
    #' @param grants a vector or list of grants Values should among known grants The list of grants can
    #'    fetched with the \code{ZenodoManager} and the function \code{$getGrants()}. Each grant should be set with 
    #'    the Zenodo id of the grant If not recognized by Zenodo, the function will raise a warning only.
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available grants. Default is \code{FALSE}
    setGrants = function(grants, sandbox = FALSE){
      if(is.null(self$metadata$grants)) self$metadata$grants <- list()
      for(grant in grants){
        self$addGrant(grant, sandbox = sandbox)
      }
    },
    
    #' @description Adds a grant to the record metadata.
    #' @param grant grant to add. The grant should be set with the id of the grant. If not
    #'    recognized by Zenodo, the function will return an warning only. The list of grants can
    #'    fetched with the \code{ZenodoManager} and the function \code{$getGrants()}.
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available grants. Default is \code{FALSE}
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addGrant = function(grant, sandbox = FALSE){
      added <- FALSE
      zen <- ZenodoManager$new(sandbox = sandbox)
      if(is.null(self$metadata$grants)) self$metadata$grants <- list()
      if(!(grant %in% self$metadata$grants)){
        if(regexpr("::", grant)>0){
          zen_grant <- zen$getGrantById(grant)
          if(is.null(zen_grant)){
            warnMsg <- sprintf("Grant with id '%s' doesn't exist in Zenodo", grant)
            self$WARN(warnMsg)
          }
        }
        self$metadata$grants[[length(self$metadata$grants)+1]] <- list(id = grant)
        added <- TRUE
      }
      return(added)
    },
    
    #' @description Removes a grant from the record metadata. 
    #' @param grant grant to remove. The grant should be set with the Zenodo id of the grant
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeGrant = function(grant){
      removed <- FALSE
      if(!is.null(self$metadata$grants)){
        for(i in 1:length(self$metadata$grants)){
          grt <- self$metadata$grants[[i]]
          if(grt == grant){
            self$metadata$grants[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #' @description Set Journal title to the record metadata
    #' @param title a title, object of class \code{character}
    setJournalTitle = function(title){
      self$metadata$journal_title <- title
    },
    
    #' @description Set Journal volume to the record metadata
    #' @param volume a volume
    setJournalVolume = function(volume){
      self$metadata$journal_volume <- volume
    },
    
    #' @description Set Journal issue to the record metadata
    #' @param issue an issue
    setJournalIssue = function(issue){
      self$metadata$journal_issue <- issue
    },
    
    #' @description Set Journal pages to the record metadata
    #' @param pages number of pages
    setJournalPages = function(pages){
      self$metadata$journal_pages <- pages
    },
    
    #' @description Set conference title to the record metadata
    #' @param title conference title, object of class \code{character}
    setConferenceTitle = function(title){
      self$metadata$conference_title <- title
    },
    
    #' @description Set conference acronym to the record metadata
    #' @param acronym conference acronym, object of class \code{character}
    setConferenceAcronym = function(acronym){
      self$metadata$conference_acronym <- acronym
    },
    
    #' @description Set conference dates to the record metadata
    #' @param dates conference dates, object of class \code{character}
    setConferenceDates = function(dates){
      self$metadata$conference_dates <- dates
    },
    
    #' @description Set conference place to the record metadata
    #' @param place conference place, object of class \code{character}
    setConferencePlace = function(place){
      self$metadata$conference_place <- place
    },
    
    #' @description Set conference url to the record metadata
    #' @param url conference url, object of class \code{character}
    setConferenceUrl = function(url){
      self$metadata$conference_url <- url
    },
    
    #' @description Set conference session to the record metadata
    #' @param session conference session, object of class \code{character}
    setConferenceSession = function(session){
      self$metadata$conference_session <- session
    },
    
    #' @description Set conference session part to the record metadata
    #' @param part conference session part, object of class \code{character}
    setConferenceSessionPart = function(part){
      self$metadata$conference_session_part <- part
    },
    
    #' @description Set imprint publisher to the record metadata
    #' @param publisher the publisher, object of class \code{character}
    setImprintPublisher = function(publisher){
      self$metadata$imprint_publisher <- publisher
    },
    
    #' @description Set imprint ISBN to the record metadata
    #' @param isbn the ISBN, object of class \code{character}
    setImprintISBN = function(isbn){
      self$metadata$imprint_isbn <- isbn
    },
    
    #' @description Set imprint place to the record metadata
    #' @param place the place, object of class \code{character}
    setImprintPlace = function(place){
      self$metadata$imprint_place <- place
    },
    
    #' @description Set title to which record is part of
    #' @param title the title, object of class \code{character}
    setPartofTitle = function(title){
      self$metadata$partof_title <- title
    },
    
    #' @description Set pages to which record is part of
    #' @param pages the pages, object of class \code{character}
    setPartofPages = function(pages){
      self$metadata$partof_pages <- pages
    },
    
    #' @description Set thesis university
    #' @param university the university, object of class \code{character}
    setThesisUniversity = function(university){
      self$metadata_thesis_university <- university
    },
    
    #' @description Adds thesis supervisor
    #' @param firstname supervisor first name
    #' @param lastname supervisor last name
    #' @param affiliation supervisor affiliation (optional)
    #' @param orcid supervisor ORCID (optional)
    #' @param gnd supervisor GND (optional)
    addThesisSupervisor = function(firstname, lastname, affiliation = NULL, orcid = NULL, gnd = NULL){
      supervisor <- list(name = paste(lastname, firstname, sep=", "))
      if(!is.null(affiliation)) supervisor <- c(supervisor, affiliation = affiliation)
      if(!is.null(orcid)) supervisor <- c(supervisor, orcid = orcid)
      if(!is.null(gnd)) supervisor <- c(supervisor, gnd = gnd)
      if(is.null(self$metadata$thesis_supervisors)) self$metadata$thesis_supervisors <- list()
      self$metadata$thesis_supervisors[[length(self$metadata$thesis_supervisors)+1]] <- supervisor
    },
    
    #' @description Removes a thesis supervisor by a property. The \code{by} parameter should be the name
    #'    of the thesis supervisor property ('name' - in the form 'lastname, firstname', 'affiliation',
    #'    'orcid' or 'gnd').
    #' @param by property used as criterion to remove the thesis supervisor
    #' @param property property value used to remove the thesis supervisor
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeThesisSupervisor = function(by,property){
      removed <- FALSE
      for(i in 1:length(self$metadata$thesis_supervisors)){
        supervisor <- self$metadata$thesis_supervisors[[i]]
        if(supervisor[[by]]==property){
          self$metadata$thesis_supervisors[[i]] <- NULL
          removed <- TRUE 
        }
      }
      return(removed)
    },
    
    #' @description Removes a thesis supervisor by name.
    #' @param name thesis supervisor name
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeThesisSupervisorByName = function(name){
      return(self$removeThesisSupervisor(by = "name", name))
    },
    
    #' @description Removes a thesis supervisor by affiliation
    #' @param affiliation thesis supervisor affiliation
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeThesisSupervisorByAffiliation = function(affiliation){
      return(self$removeThesisSupervisor(by = "affiliation", affiliation))
    },
    
    #' @description Removes a thesis supervisor by ORCID
    #' @param orcid thesis supervisor ORCID
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeThesisSupervisorByORCID = function(orcid){
      return(self$removeThesisSupervisor(by = "orcid", orcid))
    },
    
    #' @description Removes a thesis supervisor by GND
    #' @param gnd thesis supervisor GND
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeThesisSupervisorByGND = function(gnd){
      return(self$removeThesisSupervisor(by = "gnd", gnd))
    },
    
    #' @description Adds a location to the record metadata.
    #' @param place place (required)
    #' @param description description
    #' @param lat latitude
    #' @param lon longitude
    addLocation = function(place, description = NULL, lat = NULL, lon = NULL){
      if(is.null(self$metadata$locations)) self$metadata$locations <- list()
      self$metadata$locations[[length(self$metadata$locations)+1]] <- list(place = place, description = description, lat = lat, lon = lon)
    },
    
    #' @description Removes a grant from the record metadata. 
    #' @param place place (required)
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeLocation = function(place){
      removed <- FALSE
      if(!is.null(self$metadata$locations)){
        for(i in 1:length(self$metadata$locations)){
          loc <- self$metadata$locations[[i]]
          if(loc$place == place){
            self$metadata$locations[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #' @description Exports record to a file by format.
    #' @param format the export format to use. Possibles values are: BibTeX, CSL, DataCite, DublinCore, DCAT, 
    #'   JSON, JSON-LD, GeoJSON, MARCXML
    #' @param filename the target filename (without extension)
    #' @param append_format wether format name has to be appended to the filename. Default is \code{TRUE} (for
    #' backward compatibility reasons). Set it to \code{FALSE} if you want to use only the \code{filename}.
    #' @return the writen file name (with extension)
    exportAs = function(format, filename, append_format = TRUE){
      zenodo_url <- self$links$record_html
      if(is.null(zenodo_url)) zenodo_url <- self$links$self_html
      if(is.null(zenodo_url)){
        stop("Ups, this record seems a draft, can't export metadata until it is published!")
      }
      metadata_export_url <- switch(format,
        "BibTeX" = paste0(zenodo_url,"/export/bibtex"),
        "CSL" =  paste0(zenodo_url,"/export/csl"),
        "DataCite" =  paste0(zenodo_url,"/export/datacite-xml"),
        "DublinCore" =  paste0(zenodo_url,"/export/dublincore"),
        "DCAT" =  paste0(zenodo_url,"/export/dcat-ap"),
        "JSON" =  paste0(zenodo_url,"/export/json"),
        "JSON-LD" =  paste0(zenodo_url,"/export/json-ld"),
        "GeoJSON" =  paste0(zenodo_url,"/export/geojson"),
        "MARCXML" =  paste0(zenodo_url,"/export/xm"),
        NULL
      )
      if(is.null(metadata_export_url)){
        stop(sprintf("Unknown Zenodo metadata export format '%s'. Supported export formats are [%s]", format, paste(private$export_formats, collapse=",")))
      }
      
      fileext <- private$getExportFormatExtension(format)
      destfile <- paste(paste0(filename, ifelse(append_format,paste0("_", format),"")), fileext, sep = ".")
      
      req <- httr::GET(
        url = metadata_export_url,
        httr::write_disk(path = destfile, overwrite = TRUE)
      )
      return(destfile)
    },
    
    #' @description Exports record as BibTeX
    #' @param filename the target filename (without extension)
    #' @return the writen file name (with extension)
    exportAsBibTeX = function(filename){
      self$exportAs("BibTeX", filename)
    },
    
    #' @description Exports record as CSL
    #' @param filename the target filename (without extension)
    #' @return the writen file name (with extension)
    exportAsCSL = function(filename){
      self$exportAs("CSL", filename)
    },
    
    #' @description Exports record as DataCite
    #' @param filename the target filename (without extension)
    #' @return the writen file name (with extension)
    exportAsDataCite = function(filename){
      self$exportAs("DataCite", filename)
    },
    
    #' @description Exports record as DublinCore
    #' @param filename the target filename (without extension)
    #' @return the writen file name (with extension)
    exportAsDublinCore = function(filename){
      self$exportAs("DublinCore", filename)
    },
    
    #' @description Exports record as DCAT
    #' @param filename the target filename (without extension)
    #' @return the writen file name (with extension)
    exportAsDCAT = function(filename){
      self$exportAs("DCAT", filename)
    },
    
    #' @description Exports record as JSON
    #' @param filename the target filename (without extension)
    #' @return the writen file name (with extension)
    exportAsJSON = function(filename){
      self$exportAs("JSON", filename)
    },
    
    #' @description Exports record as JSONLD
    #' @param filename the target filename (without extension)
    exportAsJSONLD = function(filename){
      self$exportAs("JSON-LD", filename)
    },
    
    #' @description Exports record as GeoJSON
    #' @param filename the target filename (without extension)
    #' @return the writen file name (with extension)
    exportAsGeoJSON = function(filename){
      self$exportAs("GeoJSON", filename)
    },
    
    #' @description Exports record as MARCXML
    #' @param filename the target filename (without extension)
    #' @return the writen file name (with extension)
    exportAsMARCXML = function(filename){
      self$exportAs("MARCXML", filename)
    },
    
    #' @description Exports record in all Zenodo record export formats. This function will
    #'    create one file per Zenodo metadata formats.
    #' @param filename the target filename (without extension)
    exportAsAllFormats = function(filename){
      invisible(lapply(private$export_formats, self$exportAs, filename))
    },
    
    #' @description list files attached to the record
    #' @param pretty whether a pretty output (\code{data.frame}) should be returned (default \code{TRUE}), otherwise
    #'   the raw list of files is returned.
    #' @return the files, as \code{data.frame} or \code{list}
    listFiles = function(pretty = TRUE){
      if(!pretty) return(self$files)
      outdf <- do.call("rbind", lapply(self$files, function(x){
        return(
          data.frame(
            filename = x$filename,
            filesize = x$filesize,
            checksum = x$checksum,
            download = x$download,
            stringsAsFactors = FALSE
          )
        )
      }))
      return(outdf)
    },
    
    #' @description Downloads files attached to the record
    #' @param path target download path (by default it will be the current working directory)
    #' @param files (list of) file(s) to download. If not specified, by default all files will be downloaded.
    #' @param parallel whether download has to be done in parallel using the chosen \code{parallel_handler}. Default is \code{FALSE}
    #' @param parallel_handler The parallel handler to use eg. \code{mclapply}. To use a different parallel handler (such as eg 
    #'   \code{parLapply} or \code{parSapply}), specify its function in \code{parallel_handler} argument. For cluster-based parallel 
    #'   download, this is the way to proceed. In that case, the cluster should be created earlier by the user with  \code{makeCluster}
    #'   and passed as \code{cl} argument. After downloading all files, the cluster will be stopped automatically.
    #' @param cl an optional cluster for cluster-based parallel handlers
    #' @param quiet (default is \code{FALSE}) can be set to suppress informative messages (not warnings).
    #' @param overwrite (default is \code{TRUE}) can be set to FALSE to avoid re-downloading existing files.
    #' @param timeout (default is 60s) see \code{download.file}.
    #' @param ... arguments inherited from \code{parallel::mclapply} or the custom \code{parallel_handler}
    #'   can be added (eg. \code{mc.cores} for \code{mclapply})
    #' 
    #' @note See examples in \code{\link{download_zenodo}} utility function.
    #' 
    downloadFiles = function(path = ".", files = list(),
                             parallel = FALSE, parallel_handler = NULL, cl = NULL, quiet = FALSE, overwrite=TRUE, timeout=60, ...){
      if(length(self$files)==0){
        warnMsg = sprintf("No files to download for record '%s' (doi: '%s')", self$id, self$pids$doi$identifier)
        cli::cli_alert_warning(warnMsg)
        self$WARN(warnMsg)
      }else{
        files.list <- self$files

        if(!overwrite){
          files.list <- files.list[
            which(sapply(files.list, function(x){
            !file.exists(file.path(path, x$filename))}))
          ]
        }

        if(length(files)>0) files.list <- files.list[sapply(files.list, function(x){x$filename %in% files})]
        if(length(files.list)==0){
          errMsg <- sprintf("No files available in record '%s' (doi: '%s') for file names [%s]",
                            self$id, self$pids$doi$identifier, paste0(files, collapse=","))
          cli::cli_alert_danger(errMsg)
          self$ERROR(errMsg)
          stop(errMsg)
        }
        for(file in files){
          if(!file %in% sapply(files.list, function(x){x$filename})){
            warnMsg = sprintf("No files available in record '%s' (doi: '%s') for file name '%s': ",
                              self$id, self$pids$doi$identifier, file)
            cli::cli_alert_warning(warnMsg)
            self$WARN(warnMSg)
          }
        }

        files_summary <- sprintf("Will download %s file%s from record '%s' (doi: '%s') - total size: %s",
                                length(files.list), ifelse(length(files.list)>1,"s",""), self$id, self$pids$doi$identifier, 
                                human_filesize(sum(sapply(files.list, function(x){x$filesize}))))
        
        #download_file util
        download_file <- function(file){
          file$filename <- substring(file$filename, regexpr("/", file$filename)+1, nchar(file$filename))
          if (!quiet){
            infoMsg = sprintf("Downloading file '%s' - size: %s\n", 
                              file$filename, human_filesize(file$filesize))
            cli::cli_alert_info(infoMsg)
            cat(paste("[zen4R][INFO]", infoMsg))
          }
          target_file <- file.path(path, file$filename)
          timeout_cache <- getOption("timeout")
          options(timeout = timeout)
          download.file(url = file$download, destfile = target_file, 
                        quiet = quiet, mode = "wb")
          options(timeout = timeout_cache)
        }
        #check_integrity util
        check_integrity <- function(file){
          file$filename <- substring(file$filename, regexpr("/", file$filename)+1, nchar(file$filename))
          target_file <-file.path(path, file$filename)
          #check md5sum
          target_file_md5sum <- tools::md5sum(target_file)
          if(target_file_md5sum==file$checksum){
            if (!quiet){
              infoMsg = sprintf("File '%s': integrity verified (md5sum: %s)\n",
                                file$filename, file$checksum)
              cli::cli_alert_info(infoMsg)
              cat(paste("[zen4R][INFO]", infoMsg))
            }
          }else{
            warnMsg <- sprintf("Download issue: md5sum (%s) of file '%s' does not match Zenodo archive md5sum (%s)\n", 
                               target_file_md5sum, tools::file_path_as_absolute(target_file), file$checksum)
            cli::cli_alert_warning(warnMsg)
            cat(paste("[zen4R][WARN]", warnMsg))
            warning(warnMsg)
          }
        }
        
        if(parallel){
          if (!quiet){
            infoMsg = "Download in parallel mode"
            cli::cli_alert_info(infoMsg)
            self$INFO(infoMsg)
          }
          if (is.null(parallel_handler)) {
            errMsg <- "No 'parallel_handler' specified"
            cli::cli_alert_danger(errMsg)
            self$ERROR(errMsg)
            stop(errMsg)
          }
          if(!is.null(parallel_handler)){
            if(!is.null(cl)){
              if (!requireNamespace("parallel", quietly = TRUE)) {
                errMsg <- "Package \"parallel\" needed for cluster-based parallel handler. Please install it."
                cli::cli_alert_danger(errMsg)
                self$ERROR(errMsg)
                stop(errMsg)
              }
              if (!quiet){
                infoMsg = "Using cluster-based parallel handler (cluster 'cl' argument specified)"
                cli::cli_alert_info(infoMsg)
                self$INFO(infoMsg)
                cli::cli_alert_info(files_summary)
                self$INFO(files_summary)
              }
              invisible(parallel_handler(cl, files.list, download_file, ...))
              try(parallel::stopCluster(cl))
            }else{
              if (!quiet){
                infoMsg = "Using non cluster-based (no cluster 'cl' argument specified)"
                cli::cli_alert_info(infoMsg)
                self$INFO(infoMsg)
                cli::cli_alert_info(files_summary)
                self$INFO(files_summary)
              }
              invisible(parallel_handler(files.list, download_file, ...))
            }
          }
        }else{
          if (!quiet){
            infoMsg = "Download in sequential mode"
            cli::cli_alert_info(infoMsg)
            self$INFO(infoMsg)
            cli::cli_alert_info(files_summary)
            self$INFO(files_summary)
          }
          invisible(lapply(files.list, download_file))
        }
        if (!quiet){
          infoMsg = sprintf("File%s downloaded at '%s'.\n",
                            ifelse(length(files.list)>1,"s",""), tools::file_path_as_absolute(path))
          cli::cli_alert_info(infoMsg)
          cat(paste("[zen4R][INFO]", infoMsg))
        }
        if (!quiet){
          infoMsg = "Verifying file integrity..."
          cli::cli_alert_info(infoMsg)
          self$INFO(infoMsg)
        }
        invisible(lapply(files.list, check_integrity))
        if (!quiet){
          infoMsg = "End of download"
          cli::cli_alert_success(infoMsg)
          self$INFO(infoMsg)
        }
      }
    },
    
    #'@description Prints a \link{ZenodoRecord} 
    #'@param ... any other parameter. Not used
    #'@param format format to use for printing. By default, \code{internal} uses an \pkg{zen4R} internal
    #' printing method. Other methods available are those supported by Zenodo for record export, and can be used 
    #' only if the record has already been published (with a DOI). Attemps to print using a Zenodo export format
    #' for a record will raise a warning message and revert to "internal" format
    #'@param depth an internal depth parameter for indentation of print statements, in case of listing or recursive use of print
    print = function(..., format = "internal", depth = 1){
      
      if(format != "internal"){
        zenodo_url <- self$links$record_html
        if(is.null(zenodo_url)) zenodo_url <- self$links$latest_html
        if(is.null(zenodo_url)){
          warnMsg = sprintf("Can't print record as '%s' format: record is not published! Use 'internal' printing format ...", format)
          self$WARN(warnMsg)
          method <- "internal"
        }
      }
      
      switch(format,
        "internal" = {
          cat(sprintf("<%s>", self$getClassName()))
          fields <- rev(names(self))
          fields <- fields[!sapply(fields, function(x){
            (class(self[[x]])[1] %in% c("environment", "function")) ||
              (x %in% c("verbose.info", "verbose.debug", "loggerType"))
          })]
          
          for(field in fields){
            fieldObj <- self[[field]]
            shift <- "...."
            if(is(fieldObj, "list")){
              if(length(fieldObj)>0){
                cat(paste0("\n", paste(rep(shift, depth), collapse=""),"|-- ", field, ": "))
                
                if(!is.null(names(fieldObj))){
                  #named list
                  for(fieldObjProp in names(fieldObj)){
                    item = fieldObj[[fieldObjProp]]
                    if(is(item, "list")){
                      if(length(item)>0){
                        cat(paste0("\n", paste(rep(shift, depth+1), collapse=""),"|-- ", fieldObjProp, ": "))
                        for(itemObj in names(item)){
                          cat(paste0("\n",paste(rep(shift, depth+2), collapse=""),"|-- ", itemObj, ": ", item[[itemObj]]))
                        }
                      }else{
                        item <- "<NULL>"
                        cat(paste0("\n",paste(rep(shift, depth+1), collapse=""),"|-- ", fieldObjProp, ": ", item))
                      }
                    }else{
                      cat(paste0("\n", paste(rep(shift, depth+1), collapse=""),"|-- ", fieldObjProp, ": ", item))
                    }
                    
                  }
                }else{
                  #unamed lists (eg. files)
                  for(i in 1:length(fieldObj)){
                    item = fieldObj[[i]]
                    cat(paste0("\n", paste(rep(shift, depth+1), collapse=""), i,"."))
                    for(itemObj in names(item)){
                      cat(paste0("\n", paste(rep(shift, depth+1), collapse=""),"|-- ", itemObj, ": ", item[[itemObj]]))
                    }
                  }
                }
              }else{
                fieldObj <- "<NULL>"
                cat(paste0("\n",paste(rep(shift, depth), collapse=""),"|-- ", field, ": ", fieldObj))
              }
            }else if(is(fieldObj, "data.frame")){
              if(field == "stats"){
                cat(paste0("\n",paste(rep(shift, depth), collapse=""),"|-- ", field, ":"))
                download_cols = colnames(fieldObj)[regexpr("downloads", colnames(fieldObj))>0]
                view_cols = colnames(fieldObj)[regexpr("views", colnames(fieldObj))>0]
                volume_cols = colnames(fieldObj)[regexpr("volume", colnames(fieldObj))>0]
                cols = c(download_cols, view_cols, volume_cols)
                for(col in cols){
                  symbol = ""
                  if(regexpr("views", col)>0) symbol = "\U0001f441"
                  if(regexpr("downloads", col)>0) symbol = "\U2193"
                  if(regexpr("volume", col)>0) symbol = "\U25A0"
                  cat(paste0("\n",paste(rep(" ", depth), collapse=""),"   ", utf8::utf8_encode(symbol)," ", col, " = ", fieldObj[,col]))
                }
              }
            }else{
              if(is.null(fieldObj)) fieldObj <- "<NULL>"
              cat(paste0("\n",paste(rep(shift, depth), collapse=""),"|-- ", field, ": ", fieldObj))
            }
          }
        },
        {
          tmp <- tempfile()
          export = self$exportAs(format = format, filename = tmp)
          cat(suppressWarnings(paste(readLines(export),collapse="\n")))
          unlink(tmp)
          unlink(export)
          
        }
      )
      invisible(self)
    },
    
    #'@description Maps to an \pkg{atom4R} \link{DCEntry}. Note: applies only to published records.
    #'@return an object of class \code{DCEntry}
    toDCEntry = function(){
      tmp <- tempfile()
      dcfile <- self$exportAsDublinCore(filename = tmp)
      return(atom4R::DCEntry$new(xml = XML::xmlParse(dcfile)))
    },
    
    #DOI versioning
    #----------------------------------------------------------------------------
    
    #' @description Get DOI of the first record version.
    #' @return the first DOI, object of class \code{character}
    getFirstDOI = function(){
      versions <- self$getVersions()
      return(versions[1,"doi"])
    },
    
    #' @description Get DOI of the latest record version.
    #' @return the last DOI, object of class \code{character}
    getLastDOI = function(){
      versions <- self$getVersions()
      return(versions[nrow(versions),"doi"])
    },
    
    #' @description Get record versions with creation/publication date, 
    #'   version (ordering number) and DOI.
    #' @return a \code{data.frame} with the record versions
    getVersions = function(){
      zenodo <- ZenodoManager$new(url = paste0(unlist(strsplit(self$links$self, "/api"))[1], "/api"))
      records <- zenodo$getRecords(q = sprintf("conceptrecid:%s", self$getConceptId()), all_versions = T, size = 1000)
      
      versions <- data.frame(
        created = character(0),
        updated = character(0),
        date = character(0),
        version = character(0),
        doi = character(0),
        stringsAsFactors = FALSE
      )
      if(length(records)>0){
        versions = do.call("rbind", lapply(records, function(version){
          return(data.frame(
            created = as.POSIXct(version$created, format = "%Y-%m-%dT%H:%M:%OS"),
            updated = as.POSIXct(version$updated, format = "%Y-%m-%dT%H:%M:%OS"),
            date = as.Date(version$metadata$publication_date),
            version = if(!is.null(version$metadata$version)) version$metadata$version else NA,
            doi = version$pids$doi$identifier,
            stringsAsFactors = FALSE
          ))
        }))
        versions <- versions[order(versions$created),]
        row.names(versions) <- 1:nrow(versions)
        if(all(is.na(versions$version))) versions$version <- 1:nrow(versions)
      }
      
      return(versions)
    }
    
  )
)
