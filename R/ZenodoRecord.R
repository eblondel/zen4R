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
    allowed_upload_types = c("publication","poster","presentation", "dataset","image","video","software", "lesson", "physicalobject", "other"),
    allowed_publication_types = c("annotationcollection", "book","section","conferencepaper","datamanagementplan", "article","patent","preprint",
                                  "deliverable", "milestone", "proposal", "report","softwaredocumentation", "taxonomictreatment", "technicalnote",
                                  "thesis","workingpaper","other"),
    allowed_image_types = c("figure","plot","drawing","diagram","photo","other"),
    allowed_relations = c("isCitedBy", "cites", "isSupplementTo", "isSupplementedBy", "isContinuedBy", "continues", 
                  "isDescribedBy", "describes", "hasMetadata", "isMetadataFor", "isNewVersionOf", "isPreviousVersionOf", 
                  "isPartOf", "hasPart", "isReferencedBy", "references", "isDocumentedBy", "documents", "isCompiledBy", 
                  "compiles", "isVariantFormOf", "isOriginalFormof", "isIdenticalTo", "isAlternateIdentifier", 
                  "isReviewedBy", "reviews", "isDerivedFrom", "isSourceOf", "requires", "isRequiredBy", 
                  "isObsoletedBy", "obsoletes"),
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
      self$conceptdoi = obj$conceptdoi
      self$conceptrecid = obj$conceptrecid
      self$created = obj$created
      self$doi = obj$doi
      self$doi_url = obj$doi_url
      self$files = obj$files
      self$id = obj$id
      self$links = obj$links
      self$metadata = obj$metadata
      self$modified = obj$modified
      self$owner = obj$owner
      self$record_id = obj$record_id
      self$state = obj$state
      self$submitted = obj$submitted
      self$title = obj$title
      self$version = obj$version
    }
  ),
  public = list(
    #' @field conceptdoi record Concept DOI (common to all record versions)
    conceptdoi = NULL,
    #' @field conceptrecid record concept id
    conceptrecid = NULL,
    #' @field created record creation date
    created = NULL,
    #' @field doi record doi
    doi = NULL,
    #' @field doi_url record doi URL
    doi_url = NULL,
    #' @field files list of files associated to the record
    files = list(),
    #' @field id record id
    id = NULL,
    #' @field links list of links associated to the record
    links = list(),
    #' @field metadata metadata elements associated to the record
    metadata = list(),
    #' @field modified record modification date
    modified = NULL,
    #' @field owner record owner
    owner = NULL,
    #' @field record_id record_id
    record_id = NULL,
    #' @field state record state
    state = NULL,
    #' @field submitted record submission status
    submitted = FALSE,
    #' @field title record title
    title = NULL,
    #' @field version record version
    version = NULL,
    
    #' @description method is used to instantiate a \code{\link{ZenodoRecord}}
    #' @param obj an optional list object to create the record
    #' @param logger a logger to print log messages. It can be either NULL, "INFO" (with minimum logs), 
    #' or "DEBUG" (for complete curl http calls logs)
    initialize = function(obj = NULL, logger = "INFO"){
      super$initialize(logger = logger)
      self$prereserveDOI(TRUE)
      if(!is.null(obj)) private$fromList(obj)
    },
    
    #' @description Set prereserve_doi if \code{TRUE}, \code{FALSE} otherwise to create a record without
    #'    prereserved DOI by Zenodo. By default, this method will be called to prereserve a DOI assuming 
    #'    the record created doesn't yet handle a DOI. To avoid prereserving a DOI call \code{$prereserveDOI(FALSE)} 
    #'    on your record.
    #' @param prereserve whether a DOI has to be pre-reserved by Zenodo
    prereserveDOI = function(prereserve){
      if(!is(prereserve,"logical")){
        stop("The argument should be 'logical' (TRUE/FALSE)")
      }
      self$metadata$prereserve_doi <- prereserve
    },
 
    #' @description Set the DOI. This method can be used if a DOI has been already assigned outside Zenodo.
    #'    This method will call the method \code{$prereserveDOI(FALSE)}.
    #' @param doi DOI to set for the record
    setDOI = function(doi){
      self$metadata$doi <- doi
      self$prereserveDOI(FALSE)
    },
    
    #' @description Get the concept (generic) DOI. The concept DOI is a generic DOI common to all versions
    #'    of a Zenodo record. When a deposit is unsubmitted, this concept DOI is inherited based
    #'    on the prereserved DOI of the first record version.
    #' @return the concept DOI, object of class \code{character}
    getConceptDOI = function(){
      conceptdoi <- self$conceptdoi
      if(is.null(conceptdoi)){
        doi <- self$metadata$prereserve_doi
        if(!is.null(doi)) {
          doi_parts <- unlist(strsplit(doi$doi, "zenodo."))
          conceptdoi <- paste0(doi_parts[1], "zenodo.", self$conceptrecid)
        }
      }
      return(conceptdoi)
    },
    
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
      
      record_type <- if(self$state == "done") "record" else if(self$state == "unsubmitted") "deposit"
      ref_link <- if(record_type == "record") "latest_html" else if(record_type == "deposit") "latest_draft_html"
      zenodo_url <- paste0(unlist(strsplit(self$links[[ref_link]], paste0("/", record_type)))[1],"/api")
      zenodo <- ZenodoManager$new(url = zenodo_url)
      
      records <- zenodo$getRecords(q = sprintf("conceptrecid:%s", self$conceptrecid), all_versions = T)
      
      versions <- data.frame(
        created = character(0),
        date = character(0),
        version = character(0),
        doi = character(0),
        stringsAsFactors = FALSE
      )
      if(length(records)>0){
        versions = do.call("rbind", lapply(records, function(version){
          return(data.frame(
            created = as.POSIXct(version$created, format = "%Y-%m-%dT%H:%M:%OS"),
            date = as.Date(version$metadata$publication_date),
            version = if(!is.null(version$metadata$version)) version$metadata$version else NA,
            doi = version$doi,
            stringsAsFactors = FALSE
          ))
        }))
        versions <- versions[order(versions$created),]
        row.names(versions) <- 1:nrow(versions)
        if(all(is.na(versions$version))) versions$version <- 1:nrow(versions)
      }
      
      return(versions)
    },
    
    #' @description Set the upload type (mandatory). 
    #' @param uploadType record upload type among the following values: 'publication', 'poster', 
    #'  'presentation', 'dataset', 'image', 'video', 'software', 'lesson', 'physicalobject', 'other'
    setUploadType = function(uploadType){
      if(!(uploadType %in% private$allowed_upload_types)){
        errorMsg <- sprintf("The upload type should be among the values [%s]",
                            paste(private$allowed_upload_types, collapse=","))
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      
      self$metadata$upload_type <- uploadType
    },
    
    #' @description Set the publication type (mandatory if upload type is 'publication').
    #' @param publicationType record publication type among the following values: 'annotationcollection', 'book', 
    #'   'section', 'conferencepaper', 'datamanagementplan', 'article', 'patent', 'preprint', 'deliverable', 'milestone', 
    #'   'proposal', 'report', 'softwaredocumentation', 'taxonomictreatment', 'technicalnote', 'thesis', 'workingpaper', 
    #'   'other'
    setPublicationType = function(publicationType){
      if(!(publicationType %in% private$allowed_publication_types)){
        errorMsg <- sprintf("The publication type should be among the values [%s]",
                            paste(private$allowed_publication_types, collapse=","))
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      self$setUploadType("publication")
      self$metadata$publication_type <- publicationType
    },
    
    #' @description Set the image type (mandatory if image type is 'image').
    #' @param imageType record publication type among the following values: 'figure','plot',
    #' 'drawing','diagram','photo', or 'other'
    setImageType = function(imageType){
      if(!(imageType %in% private$allowed_image_types)){
        errorMsg <- sprintf("The image type should be among the values [%s",
                            paste(private$allowed_image_types, collapse=","))
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      self$setUploadType("image")
      self$metadata$image_type <- imageType
    },
    
    #' @description Set the publication date.
    #' @param publicationDate object of class \code{Date}
    setPublicationDate = function(publicationDate){
      if(!is(publicationDate,"Date")){
        stop("The publication date should be a 'Date' object")
      }
      self$metadata$publication_date <- as(publicationDate, "character")
    },
    
    #' @description Set the embargo date.
    #' @param embargoDate object of class \code{Date}
    setEmbargoDate = function(embargoDate){
      if(!is(embargoDate,"Date")){
        stop("The embargo date should be a 'Date' object")
      }
      self$metadata$embargo_date <- as(embargoDate, "character")
    },
    
    #' @description Set the record title.
    #' @param title object of class \code{character}
    setTitle = function(title){
      self$metadata$title <- title
    },
    
    #' @description Set the record description
    #' @param description object of class \code{character}
    setDescription = function(description){
      self$metadata$description <- description
    },
    
    #' @description Set the access right. 
    #' @param accessRight record access right among the following values: 'open','embargoed', 'restricted','closed'
    setAccessRight = function(accessRight){
      accessRightValues <- c("open","embargoed","restricted","closed")
      if(!(accessRight %in% accessRightValues)){
        errorMsg <- sprintf("The access right should be among the values [%s",
                            paste(accessRightValues, collapse=","))
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      self$metadata$access_right <- accessRight
    },
    
    #' @description set the access conditions.
    #' @param accessConditions object of class \code{character}
    setAccessConditions = function(accessConditions){
      self$metadata$access_conditions <- accessConditions
    },
    
    #' @description Add a creator for the record. One approach is to use the \code{firstname} and
    #'    \code{lastname} arguments, that by default will be concatenated for Zenodo as
    #'    \code{lastname, firstname}. For more flexibility over this, the \code{name}
    #'    argument can be directly used.
    #' @param firstname creator first name
    #' @param lastname creator last name
    #' @param name creator name
    #' @param affiliation creator affiliation (optional)
    #' @param orcid creator ORCID (optional)
    #' @param gnd creator GND (optional)
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addCreator = function(firstname, lastname, name = paste(lastname, firstname, sep = ", "),
                          affiliation = NULL, orcid = NULL, gnd = NULL){
      creator <- list(name = name)
      if(!is.null(affiliation)) creator <- c(creator, affiliation = affiliation)
      if(!is.null(orcid)) creator <- c(creator, orcid = orcid)
      if(!is.null(gnd)) creator <- c(creator, gnd = gnd)
      if(is.null(self$metadata$creators)) self$metadata$creators <- list()
      self$metadata$creators[[length(self$metadata$creators)+1]] <- creator
    },
    
    #' @description Removes a creator by a property. The \code{by} parameter should be the name
    #'    of the creator property ('name' - in the form 'lastname, firstname', 'affiliation',
    #'    'orcid' or 'gnd').
    #' @param by property used as criterion to remove the creator
    #' @param property property value used to remove the creator
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreator = function(by,property){
      removed <- FALSE
      for(i in 1:length(self$metadata$creators)){
        creator <- self$metadata$creators[[i]]
        if(creator[[by]]==property){
          self$metadata$creators[[i]] <- NULL
          removed <- TRUE 
        }
      }
      return(removed)
    },
    
    #' @description Removes a creator by name.
    #' @param name creator name
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByName = function(name){
      return(self$removeCreator(by = "name", name))
    },

    #' @description Removes a creator by affiliation.
    #' @param affiliation creator affiliation
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByAffiliation = function(affiliation){
      return(self$removeCreator(by = "affiliation", affiliation))
    },
    
    #' @description Removes a creator by ORCID.
    #' @param orcid creator ORCID
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByORCID = function(orcid){
      return(self$removeCreator(by = "orcid", orcid))
    },
    
    #' @description Removes a creator by GND.
    #' @param gnd creator GND
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeCreatorByGND = function(gnd){
      return(self$removeCreator(by = "gnd", gnd))
    },
    
    #' @description  Add a contributor for the record. One approach is to use the \code{firstname} and
    #'    \code{lastname} arguments, that by default will be concatenated for Zenodo as
    #'    \code{lastname, firstname}. For more flexibility over this, the \code{name}
    #'    argument can be directly used.
    #' @param firstname contributor first name
    #' @param lastname contributor last name
    #' @param name contributor name
    #' @param type contributor type, among values: ContactPerson, 
    #'    DataCollector, DataCurator, DataManager, Distributor, Editor, Funder, HostingInstitution, 
    #'    Producer, ProjectLeader, ProjectManager, ProjectMember, RegistrationAgency, RegistrationAuthority,
    #'    RelatedPerson, Researcher, ResearchGroup, RightsHolder, Supervisor, Sponsor, WorkPackageLeader, Other.
    #' @param affiliation contributor affiliation (optional)
    #' @param orcid contributor orcid (optional)
    #' @param gnd contributor gnd (optional)
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addContributor = function(firstname, lastname, name = paste(lastname, firstname, sep = ", "),
                              type, affiliation = NULL, orcid = NULL, gnd = NULL){
      allowedTypes <- c("ContactPerson", "DataCollector", "DataCurator", "DataManager","Distributor",
                        "Editor", "Funder", "HostingInstitution", "Producer", "ProjectLeader", "ProjectManager",
                        "ProjectMember", "RegistrationAgency", "RegistrationAuthority", "RelatedPerson",
                        "Researcher", "ResearchGroup", "RightsHolder","Supervisor", "Sponsor", "WorkPackageLeader", "Other")
      if(!(type %in% allowedTypes)){
        stop(sprintf("The contributor type should be one value among values [%s]",
                      paste(allowedTypes, collapse=",")))
      }
      contributor <- list(name = name, type = type)
      if(!is.null(affiliation)) contributor <- c(contributor, affiliation = affiliation)
      if(!is.null(orcid)) contributor <- c(contributor, orcid = orcid)
      if(!is.null(gnd)) contributor <- c(contributor, gnd = gnd)
      if(is.null(self$metadata$contributors)) self$metadata$contributors <- list()
      self$metadata$contributors[[length(self$metadata$contributors)+1]] <- contributor
    },
    
    #' @description Removes a contributor by a property. The \code{by} parameter should be the name
    #'    of the contributor property ('name' - in the form 'lastname, firstname', 'affiliation',
    #'    'orcid' or 'gnd').
    #'    \code{FALSE} otherwise.
    #' @param by property used as criterion to remove the contributor
    #' @param property property value used to remove the contributor
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributor = function(by,property){
      removed <- FALSE
      for(i in 1:length(self$metadata$contributors)){
        contributor <- self$metadata$contributors[[i]]
        if(contributor[[by]]==property){
          self$metadata$contributors[[i]] <- NULL
          removed <- TRUE 
        }
      }
      return(removed)
    },
    
    #' @description Removes a contributor by name.
    #' @param name contributor name
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByName = function(name){
      return(self$removeContributor(by = "name", name))
    },
    
    #' @description Removes a contributor by affiliation.
    #' @param affiliation contributor affiliation
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByAffiliation = function(affiliation){
      return(self$removeContributor(by = "affiliation", affiliation))
    },
    
    #' @description Removes a contributor by ORCID.
    #' @param orcid contributor ORCID
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByORCID = function(orcid){
      return(self$removeContributor(by = "orcid", orcid))
    },
    
    #' @description Removes a contributor by GND.
    #' @param gnd contributor GND
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeContributorByGND = function(gnd){
      return(self$removeContributor(by = "gnd", gnd))
    },
    
    #' @description Set license. The license should be set with the Zenodo id of the license. If not
    #'    recognized by Zenodo, the function will return an error. The list of licenses can
    #'    fetched with the \code{ZenodoManager} and the function \code{$getLicenses()}.
    #' @param licenseId a license Id
    #' @param sandbox Use the Zenodo sandbox infrastructure as basis to control available licenses. Default is \code{FALSE}
    setLicense = function(licenseId, sandbox = FALSE){
      zen <- ZenodoManager$new(sandbox = sandbox)
      zen_license <- zen$getLicenseById(licenseId)
      if(!is.null(zen_license$status)){
        errorMsg <- sprintf("License with id '%s' doesn't exist in Zenodo", licenseId)
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      self$metadata$license <- licenseId
    },
    
    #' @description Set record version.
    #' @param version the record version to set
    setVersion = function(version){
      self$metadata$version <- version
    },
    
    #' @description  Set the language.
    #' @param language ISO 639-2 or 639-3 code
    setLanguage = function(language){
      self$metadata$language <- language
    },
    
    #' @description Adds a related identifier with a given relation.
    #' @param relation relation type among following values: isCitedBy, cites, isSupplementTo, isSupplementedBy, 
    #'  isContinuedBy, continues, isDescribedBy, describes, hasMetadata, isMetadataFor, isNewVersionOf, 
    #'  isPreviousVersionOf, isPartOf, hasPart, isReferencedBy, references, isDocumentedBy, documents, 
    #'  isCompiledBy, compiles, isVariantFormOf, isOriginalFormof, isIdenticalTo, isAlternateIdentifier, 
    #'  isReviewedBy, reviews, isDerivedFrom, isSourceOf, requires, isRequiredBy, isObsoletedBy, obsoletes
    #' @param identifier resource identifier
    #' @param resource_type optional resource type, value among possible publication types, image types, or upload 
    #'  types (except 'publication' and 'image' for which a publication/image has to be specified). Default is \code{NULL}
    addRelatedIdentifier = function(relation, identifier, resource_type = NULL){
      if(!(relation %in% private$allowed_relations)){
        stop(sprintf("Relation '%s' incorrect. Use a value among the following [%s]", 
                    relation, paste(private$allowed_relations, collapse=",")))
      }
      added <- FALSE
      if(is.null(self$metadata$related_identifiers)) self$metadata$related_identifiers <- list()
      ids_df <- data.frame(relation = character(0), identifier = character(0), stringsAsFactors = FALSE)
      if(length(self$metadata$related_identifiers)>0){
        ids_df <- do.call("rbind", lapply(self$metadata$related_identifiers, function(x){
          data.frame(relation = x$relation, identifier = x$identifier, stringsAsFactors = FALSE)
        }))
      }
      if(nrow(ids_df[ids_df$relation == relation & ids_df$identifier == identifier,])==0){
        new_rel <- list(relation = relation, identifier = identifier)
        if(!is.null(resource_type)) {
          allowed_resource_types <- c(private$allowed_upload_types, private$allowed_publication_types, private$allowed_image_types)
          allowed_resource_types <- allowed_resource_types[!(allowed_resource_types %in% c("publication", "image"))]
          if(!(resource_type %in% allowed_resource_types)){
            stop(sprintf("Relation resource type '%s' incorrect. Use a value among the following [%s]", 
                         relation, paste(allowed_resource_types, collapse=",")))
          }
          resource_type_prefix <- ""
          if(resource_type %in% private$allowed_publication_types)resource_type_prefix = "publication-"
          if(resource_type %in% private$allowed_image_types)resource_type_prefix = "image-"
          
          new_rel$resource_type <- paste0(resource_type_prefix, resource_type)
        } 
        self$metadata$related_identifiers[[length(self$metadata$related_identifiers)+1]] <- new_rel
        added <- TRUE
      }
      return(added)
    },
    
    #' @description Removes a related identifier with a given relation.
    #' @param relation relation type among following values: isCitedBy, cites, isSupplementTo, isSupplementedBy, 
    #'  isContinuedBy, continues, isDescribedBy, describes, hasMetadata, isMetadataFor, isNewVersionOf, 
    #'  isPreviousVersionOf, isPartOf, hasPart, isReferencedBy, references, isDocumentedBy, documents, 
    #'  isCompiledBy, compiles, isVariantFormOf, isOriginalFormof, isIdenticalTo, isAlternateIdentifier, 
    #'  isReviewedBy, reviews, isDerivedFrom, isSourceOf, requires, isRequiredBy, isObsoletedBy, obsoletes
    #' @param identifier resource identifier
    removeRelatedIdentifier = function(relation, identifier){
      if(!(relation %in% private$allowed_relations)){
        stop(sprintf("Relation '%s' incorrect. Use a value among the following [%s]", 
                     relation, paste(private$allowed_relations, collapse=",")))
      }
      removed <- FALSE
      if(!is.null(self$metadata$related_identifiers)){
        for(i in 1:length(self$metadata$related_identifiers)){
          related_id <- self$metadata$related_identifiers[[i]]
          if(related_id$relation == relation & related_id$identifier == identifier){
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
      if(!(reference %in% self$metadata$references)){
        self$metadata$references[[length(self$metadata$references)+1]] <- reference
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
          if(ref == reference){
            self$metadata$references[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #' @description Set keywords
    #' @param keywords a vector or list of keywords to set for the record
    setKeywords = function(keywords){
      if(is.null(self$metadata$keywords)) self$metadata$keywords <- list()
      for(keyword in keywords){
        self$addKeyword(keyword)
      }
    },
    
    #' @description Add a keyword
    #' @param keyword the keyword to add
    #' @return \code{TRUE} if added, \code{FALSE} otherwise
    addKeyword = function(keyword){
      added <- FALSE
      if(is.null(self$metadata$keywords)) self$metadata$keywords <- list()
      if(!(keyword %in% self$metadata$keywords)){
        self$metadata$keywords[[length(self$metadata$keywords)+1]] <- keyword
        added <- TRUE
      }
      return(added)
    },
    
    #' @description Remove a keyword
    #' @param keyword the keyword to remove
    #' @return \code{TRUE} if removed, \code{FALSE} otherwise
    removeKeyword = function(keyword){
      removed <- FALSE
      if(!is.null(self$metadata$keywords)){
        for(i in 1:length(self$metadata$keywords)){
          kwd <- self$metadata$keywords[[i]]
          if(kwd == keyword){
            self$metadata$keywords[[i]] <- NULL
            removed <- TRUE
            break;
          }
        }
      }
      return(removed)
    },
    
    #' @description Adds a subject given a term and identifier
    #' @param term subject term
    #' @param identifier subject identifier
    addSubject = function(term, identifier){
      subject <- list(term = term, identifier = identifier)
      if(is.null(self$metadata$subjects)) self$metadata$subjects <- list()
      self$metadata$subjects[[length(self$metadata$subjects)+1]] <- subject
    },
    
    #' @description Removes subject(s) by a property. The \code{by} parameter should be the name
    #'    of the subject property ('term' or 'identifier').
    #' @param by property used as criterion to remove subjects
    #' @param property property value used to remove subjects
    #' @return \code{TRUE} if at least one subject is removed, \code{FALSE} otherwise.
    removeSubject = function(by, property){
      removed <- FALSE
      for(i in 1:length(self$metadata$subjects)){
        subject <- self$metadata$subjects[[i]]
        if(subject[[by]]==property){
          self$metadata$subjects[[i]] <- NULL
          removed <- TRUE 
        }
      }
      return(removed)
    },
    
    #' @description Removes subject(s) by term.
    #' @param term the term to use to remove subject(s)
    #' @return \code{TRUE} if at least one subject is removed, \code{FALSE} otherwise. 
    removeSubjectByTerm = function(term){
      return(self$removeSubject(by = "term", property = term))
    },
    
    #' @description Removes subject(s) by identifier
    #' @param identifier the identifier to use to remove subject(s)
    #' @return \code{TRUE} if at least one subject is removed, \code{FALSE} otherwise. 
    removeSubjectByIdentifier = function(identifier){
      return(self$removeSubject(by = "identifier", property = identifier))
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
      if(is.null(zenodo_url)) zenodo_url <- self$links$latest_html
      if(is.null(zenodo_url)){
        stop("Ups, this record seems a draft, can't export metadata until it is published!")
      }
      metadata_export_url <- switch(format,
        "BibTeX" = paste0(zenodo_url,"/export/hx"),
        "CSL" =  paste0(zenodo_url,"/export/csl"),
        "DataCite" =  paste0(zenodo_url,"/export/dcite4"),
        "DublinCore" =  paste0(zenodo_url,"/export/xd"),
        "DCAT" =  paste0(zenodo_url,"/export/dcat"),
        "JSON" =  paste0(zenodo_url,"/export/json"),
        "JSON-LD" =  paste0(zenodo_url,"/export/schemaorg_jsonld"),
        "GeoJSON" =  paste0(zenodo_url,"/export/geojson"),
        "MARCXML" =  paste0(zenodo_url,"/export/xm"),
        NULL
      )
      if(is.null(metadata_export_url)){
        stop(sprintf("Unknown Zenodo metadata export format '%s'. Supported export formats are [%s]", format, paste(private$export_formats, collapse=",")))
      }
      
      fileext <- private$getExportFormatExtension(format)
      
      html <- xml2::read_html(metadata_export_url)
      reference <- xml2::xml_find_all(html, ".//pre")
      reference <- reference[1]
      reference <- gsub("<pre.*\">","",reference)
      reference <- gsub("</pre>","",reference)
      if(fileext %in% c("xml", "rdf")){
        reference <- gsub("&lt;", "<", reference)
        reference <- gsub("&gt;", ">", reference)
      }
    
      destfile <- paste(paste0(filename, ifelse(append_format,paste0("_", format),"")), fileext, sep = ".")
      writeChar(reference, destfile, eos = NULL)
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
            id = x$id,
            checksum = x$checksum,
            filename = x$filename,
            download = x$links$download,
            self = x$links$self,
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
        self$WARN(sprintf("No files to download for record '%s' (doi: '%s')",
                          self$id, self$doi))
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
                            self$id, self$doi, paste0(files, collapse=","))
          self$ERROR(errMsg)
          stop(errMsg)
        }
        for(file in files){
          if(!file %in% sapply(files.list, function(x){x$filename})){
            self$WARN(sprintf("No files available in record '%s' (doi: '%s') for file name '%s': ",
                              self$id, self$doi, file))
          }
        }

        files_summary <- sprintf("Will download %s file%s from record '%s' (doi: '%s') - total size: %s",
                                length(files.list), ifelse(length(files.list)>1,"s",""), self$id, self$doi, 
                                human_filesize(sum(sapply(files.list, function(x){x$filesize}))))
        
        #download_file util
        download_file <- function(file){
          file$filename <- substring(file$filename, regexpr("/", file$filename)+1, nchar(file$filename))
          if (!quiet) cat(sprintf("[zen4R][INFO] Downloading file '%s' - size: %s\n", 
                            file$filename, human_filesize(file$filesize)))
          target_file <- file.path(path, file$filename)
          timeout_cache <- getOption("timeout")
          options(timeout = timeout)
          download.file(url = file$links$download, destfile = target_file, 
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
            if (!quiet) cat(sprintf("[zen4R][INFO] File '%s': integrity verified (md5sum: %s)\n",
                        file$filename, file$checksum))
          }else{
            warnMsg <- sprintf("[zen4R][WARN] Download issue: md5sum (%s) of file '%s' does not match Zenodo archive md5sum (%s)\n", 
                               target_file_md5sum, tools::file_path_as_absolute(target_file), file$checksum)
            cat(warnMsg)
            warning(warnMsg)
          }
        }
        
        if(parallel){
          if (!quiet) self$INFO("Download in parallel mode")
          if (is.null(parallel_handler)) {
            errMsg <- "No 'parallel_handler' specified"
            self$ERROR(errMsg)
            stop(errMsg)
          }
          if(!is.null(parallel_handler)){
            if(!is.null(cl)){
              if (!requireNamespace("parallel", quietly = TRUE)) {
                errMsg <- "Package \"parallel\" needed for cluster-based parallel handler. Please install it."
                self$ERROR(errMsg)
                stop(errMsg)
              }
              if (!quiet) self$INFO("Using cluster-based parallel handler (cluster 'cl' argument specified)")
              if (!quiet) self$INFO(files_summary)
              invisible(parallel_handler(cl, files.list, download_file, ...))
              try(parallel::stopCluster(cl))
            }else{
              if (!quiet) self$INFO("Using non cluster-based (no cluster 'cl' argument specified)")
              if (!quiet) self$INFO(files_summary)
              invisible(parallel_handler(files.list, download_file, ...))
            }
          }
        }else{
          if (!quiet) self$INFO("Download in sequential mode")
          if (!quiet) self$INFO(files_summary) 
          invisible(lapply(files.list, download_file))
        }
        if (!quiet) cat(sprintf("[zen4R][INFO] File%s downloaded at '%s'.\n",
                                ifelse(length(files.list)>1,"s",""), tools::file_path_as_absolute(path)))
        if (!quiet) self$INFO("Verifying file integrity...")
        invisible(lapply(files.list, check_integrity))
        if (!quiet) self$INFO("End of download")
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
          self$WARN(sprintf("Can't print record as '%s' format: record is not published! Use 'internal' printing format ...", format))
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
    }
    
  )
)
