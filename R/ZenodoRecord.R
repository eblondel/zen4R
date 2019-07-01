#' ZenodoRecord
#' @docType class
#' @export
#' @keywords zenodo record
#' @return Object of \code{\link{R6Class}} for modelling an ZenodoRecord
#' @format \code{\link{R6Class}} object.
#' @section Methods:
#' \describe{
#'  \item{\code{new()}}{
#'    This method is used to instantiate a Zenodo Record
#'  }
#'  \item{\code{prereserveDOI(prereserve)}}{
#'    Set prereserve_doi if \code{TRUE}, \code{FALSE} otherwise to create a record without
#'    prereserved DOI by Zenodo. By default, this method will be called to prereserve a DOI
#'    assuming the record created doesn't yet handle a DOI. To avoid prereserving a DOI 
#'    call \code{$prereserveDOI(FALSE)} on your record.
#'  }
#'  \item{\code{setUploadType(uploadType)}}{
#'    Set the upload type (mandatory). Value should be among the following: 'publication',
#'    'poster','presentation','dataset','image','video', or 'software'
#'  }
#'  \item{\code{setPublicationType(publicationType)}}{
#'    Set the publication type (mandatory if upload type is 'publication'). Value should be
#'    among the following: 'book','section','conferencepaper','article','patent','preprint',
#'    'report','softwaredocumentation','thesis','technicalnote','workingpaper', or 'other'
#'  }
#'  \item{\code{setImageType(imageType)}}{
#'    Set the image type (mandatory if image type is 'image'). Value should be among the 
#'    following: 'figure','plot','drawing','diagram','photo', or 'other'
#'  }
#'  \item{\code{setPublicationDate(publicationDate)}}{
#'    Set the publication date, as object of class \code{Date}
#'  }
#'  \item{\code{setEmbargoDate(embargoDate)}}{
#'    Set the embargo date, as object of class \code{Date}
#'  }
#'  \item{\code{setTitle(title)}}{
#'    Set title
#'  }
#'  \item{\code{setDescription(description)}}{
#'    Set description
#'  }
#'  \item{\code{setAccessRight(accessRight)}}{
#'    Set the access right. Value should be among the following: 'open','embargoed',
#'    'restricted','closed'
#'  }
#'  \item{\code{setAccessConditions(accessConditions)}}{
#'    Set access conditions.
#'  }
#'  \item{\code{addCreator(firsname, lastname, affiliation, orcid, gnd)}}{
#'    Add a creator for the record.
#'  }
#'  \item{\code{removeCreator(by,property)}}{
#'    Removes a creator by a property. The \code{by} parameter should be the name
#'    of the creator property ('name' - in the form 'lastname, firstname', 'affiliation',
#'    'orcid' or 'gnd'). Returns \code{TRUE} if some creator was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeCreatorByName(name)}}{
#'    Removes a creator by name. Returns \code{TRUE} if some creator was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeCreatorByAffiliation(affiliation)}}{
#'    Removes a creator by affiliation. Returns \code{TRUE} if some creator was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeCreatorByORCID(orcid)}}{
#'    Removes a creator by ORCID. Returns \code{TRUE} if some creator was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeCreatorByGND(gnd)}}{
#'    Removes a creator by GND. Returns \code{TRUE} if some creator was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{addContributor(firsname, lastname, type, affiliation, orcid, gnd)}}{
#'    Add a contributor for the record. Firstname, lastname, and type are mandatory.
#'    The type should be an object of class \code{character} among values: ContactPerson, 
#'    DataCollector, DataCurator, DataManager, Distributor, Editor, Funder, HostingInstitution, 
#'    Producer, ProjectLeader, ProjectManager, ProjectMember, RegistrationAgency, RegistrationAuthority,
#'    RelatedPerson, Researcher, ResearchGroup, RightsHolder, Supervisor, Sponsor, WorkPackageLeader, Other. 
#'  }
#'  \item{\code{removeContributor(by,property)}}{
#'    Removes a contributor by a property. The \code{by} parameter should be the name
#'    of the contributor property ('name' - in the form 'lastname, firstname', 'affiliation',
#'    'orcid' or 'gnd'). Returns \code{TRUE} if some contributor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeContributorByName(name)}}{
#'    Removes a contributor by name. Returns \code{TRUE} if some contributor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeContributorByAffiliation(affiliation)}}{
#'    Removes a contributor by affiliation. Returns \code{TRUE} if some contributor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeContributorByORCID(orcid)}}{
#'    Removes a contributor by ORCID. Returns \code{TRUE} if some contributor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeContributorByGND(gnd)}}{
#'    Removes a contributor by GND. Returns \code{TRUE} if some contributor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{setLicense(licenseId)}}{
#'    Set license. The license should be set with the Zenodo id of the license. If not
#'    recognized by Zenodo, the function will return an error. The list of licenses can
#'    fetched with the \code{ZenodoManager} and the function \code{$getLicenses()}.
#'  }
#'  \item{\code{setDOI(doi)}}{
#'    Set the DOI. This method can be used if a DOI has been already assigned outside Zenodo.
#'    This method will call the method \code{$prereserveDOI(FALSE)}.
#'  }
#'  \item{\code{getConceptDOI()}}{
#'    Get the concept (generic) DOI. The concept DOI is a generic DOI common to all versions
#'    of a Zenodo record. When a deposit is unsubmitted, this concept DOI is inherited based
#'    on the prereserved DOI of the first record version.
#'  }
#'  \item{\code{setVersion(version)}}{
#'    Set the version.
#'  }
#'  \item{\code{setLanguage(language)}}{
#'    Set the language ISO 639-2 or 639-3 code.
#'  }
#'  \item{\code{addRelatedIdentifier(relation, identifier)}}{
#'    Adds a related identifier with a given relation. Relation can be one of among
#'    following values: isCitedBy, cites, isSupplementTo, isSupplementedBy, isNewVersionOf,
#'    isPreviousVersionOf, isPartOf, hasPart, compiles, isCompiledBy, isIdenticalTo, 
#'    isAlternateIdentifier
#'  }
#'  \item{code{removeRelatedIdentifier(relation, identifier)}}{
#'    Remove a related identifier
#'  }
#'  \item{\code{setReferences(references)}}{
#'    Set a vector of character strings as references
#'  }
#'  \item{\code{addReference(reference)}}{
#'    Adds a reference to the record metadata. Return \code{TRUE} if added, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removedReference(reference)}}{
#'    Removes a reference from the record metadata. Return \code{TRUE} if removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{setKeywords(keywords)}}{
#'    Set a vector of character strings as keywords
#'  }
#'  \item{\code{addKeyword(keyword)}}{
#'    Adds a keyword to the record metadata. Return \code{TRUE} if added, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removedKeyword(keyword)}}{
#'    Removes a keyword from the record metadata. Return \code{TRUE} if removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{addSubject(term, identifier)}}{
#'    Add a Subject for the record.
#'  }
#'  \item{\code{removeSubject(by,property)}}{
#'    Removes a subject by a property. The \code{by} parameter should be the name
#'    of the subject property ('term' or 'identifier'). Returns \code{TRUE} if some 
#'    subject was removed, \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeSubjectByTerm(term)}}{
#'    Removes a subject by term. Returns \code{TRUE} if some subject was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeSubjectByIdentifier(identifier)}}{
#'    Removes a subject by identifier. Returns \code{TRUE} if some subject was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{setNotes(notes)}}{
#'    Set notes. HTML is not allowed
#'  }
#'  \item{\code{setCommunities(communities)}}{
#'    Set a vector of character strings identifying communities
#'  }
#'  \item{\code{addCommunity(community)}}{
#'    Adds a community to the record metadata. Return \code{TRUE} if added, 
#'    \code{FALSE} otherwise. The community should be set with the Zenodo id of the community. If not
#'    recognized by Zenodo, the function will return an error. The list of communities can
#'    fetched with the \code{ZenodoManager} and the function \code{$getCommunities()}.
#'  }
#'  \item{\code{removedCommunity(community)}}{
#'    Removes a community from the record metadata. Return \code{TRUE} if removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{setGrants(grants)}}{
#'    Set a vector of character strings identifying grants
#'  }
#'  \item{\code{addGrant(grant)}}{
#'    Adds a grant to the record metadata. Return \code{TRUE} if added, 
#'    \code{FALSE} otherwise. The grant should be set with the id of the grant. If not
#'    recognized by Zenodo, the function will return an warning only. The list of grants can
#'    fetched with the \code{ZenodoManager} and the function \code{$getGrants()}.
#'  }
#'  \item{\code{removeGrant(grant)}}{
#'    Removes a grant from the record metadata. Return \code{TRUE} if removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{setJournalTitle(title)}}{
#'    Set Journal title, object of class \code{\link{character}}, if deposition is a published article.
#'  }
#'  \item{\code{setJournalVolume(volume)}}{
#'    Set Journal volume, object of class \code{\link{character}}, if deposition is a published article.
#'  }
#'  \item{\code{setJournalIssue(issue)}}{
#'    Set Journal issue, object of class \code{\link{character}}, if deposition is a published article.
#'  }
#'  \item{\code{setJournalPages(pages)}}{
#'    Set Journal pages, object of class \code{\link{character}}, if deposition is a published article.
#'  }
#'  \item{\code{setConferenceTitle(title)}}{
#'   Set Conference title, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setConferenceAcronym(acronym)}}{
#'    Set conference acronym, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setConferenceDates(dates)}}{
#'    Set conference dates, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setConferencePlace(place)}}{
#'    Set conference place, object of class \code{\link{character}}, in the format city, country 
#'    (e.g. Kingston, Jamaica). Conference title or acronym must also be specified if this field 
#'    is specified.
#'  }
#'  \item{\code{setConferenceUrl(url)}}{
#'    Set conference url, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setConferenceSession(session)}}{
#'    Set conference session, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setConferenceSessionPart(part)}}{
#'    Set conference session part, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setImprintPublisher(publisher)}}{
#'    Set imprint publisher, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setImprintISBN(isbn)}}{
#'    Set imprint ISBN, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setImprintPlace(place)}}{
#'    Set imprint place, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setPartofTitle(title)}}{
#'    Set the book title in case of a chapter, object of class \code{\link{character}}.
#'  }
#'  \item{\code{setPartofPages(pages)}}{
#'    Set the page numbers of book, object of class \code{\link{character}}.
#'  }
#' }
#' 
#' @author Emmanuel Blondel <emmanuel.blondel1@@gmail.com>
#' 
ZenodoRecord <-  R6Class("ZenodoRecord",
  inherit = zen4RLogger,
  private = list(
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
    }
  ),
  public = list(
    conceptdoi = NULL,
    conceptrecid = NULL,
    created = NULL,
    doi = NULL,
    doi_url = NULL,
    files = list(),
    id = NULL,
    links = list(),
    metadata = list(),
    modified = NULL,
    owner = NULL,
    record_id = NULL,
    state = NULL,
    submitted = FALSE,
    title = NULL,
    
    initialize = function(obj = NULL, logger = "INFO"){
      super$initialize(logger = logger)
      self$prereserveDOI(TRUE)
      if(!is.null(obj)) private$fromList(obj)
    },
    
    #setPrereserveDOI
    prereserveDOI = function(prereserve){
      if(!is(prereserve,"logical")){
        stop("The argument should be 'logical' (TRUE/FALSE)")
      }
      self$metadata$prereserve_doi <- prereserve
    },
 
    #setDOI
    setDOI = function(doi){
      self$metadata$doi <- doi
      self$prereserveDOI(FALSE)
    },
    
    #getConceptDOI
    getConceptDOI = function(){
      conceptdoi <- self$conceptdoi
      if(is.null(conceptdoi)){
        doi <- self$metadata$prereserve_doi
        if(!is.null(doi)) {
          doi_parts <- unlist(strsplit(doi$doi, "zenodo."))
          conceptdoi <- paste0(doi_parts[1], "zenodo.", as.integer(doi_parts[2])-1)
        }
      }
      return(conceptdoi)
    },
    
    #setUploadType
    setUploadType = function(uploadType){
      uploadTypeValues <- c("publication","poster","presentation",
                            "dataset","image","video","software","other")
      if(!(uploadType %in% uploadTypeValues)){
        errorMsg <- sprintf("The upload type should be among the values [%s]",
                            paste(uploadTypeValues, collapse=","))
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      
      self$metadata$upload_type <- uploadType
    },
    
    #setPublicationType
    setPublicationType = function(publicationType){
      publicationTypeValues <- c("book","section","conferencepaper","article",
                                 "patent","preprint","report","softwaredocumentation",
                                 "thesis","technicalnote","workingpaper","other")
      if(!(publicationType %in% publicationTypeValues)){
        errorMsg <- sprintf("The publication type should be among the values [%s]",
                            paste(publicationTypeValues, collapse=","))
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      self$setUploadType("publication")
      self$metadata$publication_type <- publicationType
    },
    
    #setImageType
    setImageType = function(imageType){
      imageTypeValues = c("figure","plot","drawing","diagram","photo","other")
      if(!(imageType %in% imageTypeValues)){
        errorMsg <- sprintf("The image type should be among the values [%s",
                            paste(imageTypeValues, collapse=","))
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      self$setUploadType("image")
      self$metadata$image_type <- imageType
    },
    
    #setPublicationDate
    setPublicationDate = function(publicationDate){
      if(!is(publicationDate,"Date")){
        stop("The publication date should be a 'Date' object")
      }
      self$metadata$publication_date <- as(publicationDate, "character")
    },
    
    #setEmbargoDate
    setEmbargoDate = function(embargoDate){
      if(!is(embargoDate,"Date")){
        stop("The embargo date should be a 'Date' object")
      }
      self$metadata$embargo_date <- as(publicationDate, "character")
    },
    
    #setTitle
    setTitle = function(title){
      self$metadata$title <- title
    },
    
    #setDescription
    setDescription = function(description){
      self$metadata$description <- description
    },
    
    #setAccessRight
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
    
    #setAccessConditions
    setAccessConditions = function(accessConditions){
      self$metadata$access_conditions <- accessConditions
    },
    
    #addCreator
    addCreator = function(firstname, lastname, affiliation = NULL, orcid = NULL, gnd = NULL){
      creator <- list(name = paste(lastname, firstname, sep=", "))
      if(!is.null(affiliation)) creator <- c(creator, affiliation = affiliation)
      if(!is.null(orcid)) creator <- c(creator, orcid = orcid)
      if(!is.null(gnd)) creator <- c(creator, gnd = gnd)
      if(is.null(self$metadata$creators)) self$metadata$creators <- list()
      self$metadata$creators[[length(self$metadata$creators)+1]] <- creator
    },
    
    #removeCreator
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
    
    #removeCreatorByName
    removeCreatorByName = function(name){
      return(self$removeCreator(by = "name", name))
    },

    #removeCreatorByAffiliation
    removeCreatorByAffiliation = function(affiliation){
      return(self$removeCreator(by = "affiliation", affiliation))
    },
    
    #removeCreatorByORCID
    removeCreatorByORCID = function(orcid){
      return(self$removeCreator(by = "orcid", orcid))
    },
    
    #removeCreatorByGND
    removeCreatorByGND = function(gnd){
      return(self$removeCreator(by = "gnd", gnd))
    },
    
    #addContributor
    addContributor = function(firstname, lastname, type, affiliation = NULL, orcid = NULL, gnd = NULL){
      allowedTypes <- c("ContactPerson", "DataCollector", "DataCurator", "DataManager","Distributor",
                        "Editor", "Funder", "HostingInstitution", "Producer", "ProjectLeader", "ProjectManager",
                        "ProjectMember", "RegistrationAgency", "RegistrationAuthority", "RelatedPerson",
                        "Researcher", "ResearchGroup", "RightsHolder","Supervisor", "Sponsor", "WorkPackageLeader", "Other")
      if(!(type %in% allowedTypes)){
        stop(sprintf("The contributor type should be one value among values [%s]",
                      paste(allowedTypes, collapse=",")))
      }
      contributor <- list(name = paste(lastname, firstname, sep=", "), type = type)
      if(!is.null(affiliation)) contributor <- c(contributor, affiliation = affiliation)
      if(!is.null(orcid)) contributor <- c(contributor, orcid = orcid)
      if(!is.null(gnd)) contributor <- c(contributor, gnd = gnd)
      if(is.null(self$metadata$contributors)) self$metadata$contributors <- list()
      self$metadata$contributors[[length(self$metadata$contributors)+1]] <- contributor
    },
    
    #removeContributor
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
    
    #removeContributorByName
    removeContributorByName = function(name){
      return(self$removeContributor(by = "name", name))
    },
    
    #removeContributorByAffiliation
    removeContributorByAffiliation = function(affiliation){
      return(self$removeContributor(by = "affiliation", affiliation))
    },
    
    #removeContributorByORCID
    removeContributorByORCID = function(orcid){
      return(self$removeContributor(by = "orcid", orcid))
    },
    
    #removeContributorByGND
    removeContributorByGND = function(gnd){
      return(self$removeContributor(by = "gnd", gnd))
    },
    
    #setLicense
    setLicense = function(licenseId){
      zen <- ZenodoManager$new()
      zen_license <- zen$getLicenseById(licenseId)
      if(!is.null(zen_license$status)){
        errorMsg <- sprintf("License with id '%s' doesn't exist in Zenodo", licenseId)
        self$ERROR(errorMsg)
        stop(errorMsg)
      }
      self$metadata$license <- licenseId
    },
    
    #setVersion
    setVersion = function(version){
      self$metadata$version <- version
    },
    
    #setLanguage
    setLanguage = function(language){
      self$metadata$language <- language
    },
    
    #addRelatedIdentifier
    addRelatedIdentifier = function(relation, identifier){
      allowedRelations <- c("isCitedBy", "cites", "isSupplementTo",
                            "isSupplementedBy", "isNewVersionOf", "isPreviousVersionOf", 
                            "isPartOf", "hasPart", "compiles", "isCompiledBy", "isIdenticalTo",
                            "isAlternateIdentifier")
      if(!(relation %in% allowedRelations)){
        stop(sprint("Relation '%s' incorrect. Use a value among the following [%s]", 
                    relation, paste(allowedRelations, collapse=",")))
      }
      added <- FALSE
      if(is.null(self$metadata$related_identifiers)) self$metadata$related_identifiers <- list()
      if(!(relation %in% sapply(self$metadata$related_identifiers, function(x){x$relation})) &
         !(identifier %in% sapply(self$metadata$related_identifiers, function(x){x$identifier}))){
        self$metadata$related_identifiers[[length(self$metadata$related_identifiers)+1]] <- list(
          relation = relation,
          identifier = identifier
        )
        added <- TRUE
      }
      return(added)
    },
    
    #removeRelatedIdentifier
    removeRelatedIdentifier = function(relation, identifier){
      allowedRelations <- c("isCitedBy", "cites", "isSupplementTo",
                            "isSupplementedBy", "isNewVersionOf", "isPreviousVersionOf", 
                            "isPartOf", "hasPart", "compiles", "isCompiledBy", "isIdenticalTo",
                            "isAlternateIdentifier")
      if(!(relation %in% allowedRelations)){
        stop(sprint("Relation '%s' incorrect. Use a value among the following [%s]", 
                    relation, paste(allowedRelations, collapse=",")))
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
    
    #setReferences
    setReferences = function(references){
      if(is.null(self$metadata$references)) self$metadata$references <- list()
      for(reference in references){
        self$addReference(reference)
      }
    },
    
    #addReference
    addReference = function(reference){
      added <- FALSE
      if(is.null(self$metadata$references)) self$metadata$references <- list()
      if(!(reference %in% self$metadata$references)){
        self$metadata$references[[length(self$metadata$references)+1]] <- reference
        added <- TRUE
      }
      return(added)
    },
    
    #removeReference
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
    
    #setKeywords
    setKeywords = function(keywords){
      if(is.null(self$metadata$keywords)) self$metadata$keywords <- list()
      for(keyword in keywords){
        self$addKeyword(keyword)
      }
    },
    
    #addKeyword
    addKeyword = function(keyword){
      added <- FALSE
      if(is.null(self$metadata$keywords)) self$metadata$keywords <- list()
      if(!(keyword %in% self$metadata$keywords)){
        self$metadata$keywords[[length(self$metadata$keywords)+1]] <- keyword
        added <- TRUE
      }
      return(added)
    },
    
    #removeKeyword
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
    
    #addSubject
    addSubject = function(term, identifier){
      subject <- list(term = term, identifier = identifier)
      if(is.null(self$metadata$subjects)) self$metadata$subjects <- list()
      self$metadata$subjects[[length(self$metadata$subjects)+1]] <- subject
    },
    
    #removeSubject
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
    
    #removeSubjectByTerm
    removeSubjectByTerm = function(term){
      return(self$removeSubject(by = "term", property = term))
    },
    
    #removeSubjectByIdentifier
    removeSubjectByIdentifier = function(identifier){
      return(self$removeSubject(by = "identifier", property = identifier))
    },
    
    #setNotes
    setNotes = function(notes){
      self$metadata$notes <- notes
    },
    
    #setCommunities
    setCommunities = function(communities){
      if(is.null(self$metadata$communities)) self$metadata$communities <- list()
      for(community in communities){
        self$addCommunity(community)
      }
    },
    
    #addCommunity
    addCommunity = function(community){
      added <- FALSE
      zen <- ZenodoManager$new()
      if(is.null(self$metadata$communities)) self$metadata$communities <- list()
      if(!(community %in% self$metadata$communities)){
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
    
    #removeCommunity
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
    
    #setGrants
    setGrants = function(grants){
      if(is.null(self$metadata$grants)) self$metadata$grants <- list()
      for(grant in grants){
        self$addGrant(grant)
      }
    },
    
    #addGrant
    addGrant = function(grant){
      added <- FALSE
      zen <- ZenodoManager$new()
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
    
    #removeGrant
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
    
    #setJournalTitle
    setJournalTitle = function(title){
      self$metadata$journal_title <- title
    },
    
    #setJournalVolume
    setJournalVolume = function(volume){
      self$metadata$journal_volume <- volume
    },
    
    #setJournalIssue
    setJournalIssue = function(issue){
      self$metadata$journal_issue <- issue
    },
    
    #setJournalPages
    setJournalPages = function(pages){
      self$metadata$journal_pages <- pages
    },
    
    #setConferenceTitle
    setConferenceTitle = function(title){
      self$metadata$conference_title <- title
    },
    
    #setConferenceAcronym
    setConferenceAcronym = function(acronym){
      self$metadata$conference_acronym <- acronym
    },
    
    #setConferenceDates
    setConferenceDates = function(dates){
      self$metadata$conference_dates <- dates
    },
    
    #setConferencePlace
    setConferencePlace = function(place){
      self$metadata$conference_place <- place
    },
    
    #setConferenceUrl
    setConferenceUrl = function(url){
      self$metadata$conference_url <- url
    },
    
    #setConferenceSession
    setConferenceSession = function(session){
      self$metadata$conference_session <- session
    },
    
    #setConferenceSessionPart
    setConferenceSessionPart = function(part){
      self$metadata$conference_session_part <- part
    },
    
    #setImprintPublisher
    setImprintPublisher = function(publisher){
      self$metadata$imprint_publisher <- publisher
    },
    
    #setImprintISBN
    setImprintISBN = function(isbn){
      self$metadata$imprint_isbn <- isbn
    },
    
    #setImprintPlace
    setImprintPlace = function(place){
      self$metadata$imprint_place <- place
    },
    
    #setPartofTitle
    setPartofTitle = function(title){
      self$metadata$partof_title <- title
    },
    
    #setPartofPages
    setPartofPages = function(pages){
      self$metadata$partof_pages <- pages
    }
    
  )
)