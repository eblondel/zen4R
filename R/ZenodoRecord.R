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
#'  \item{\code{setLicense(licenseId)}}{
#'    Set license. The license should be set with the Zenodo id of the license. If not
#'    recognized by Zenodo, the function will return an error. The list of licenses can
#'    fetched with the \code{ZenodoManager} and the function \code{$getLicenses()}.
#'  }
#'  \item{\code{setDOI(doi)}}{
#'    Set the DOI. This method can be used if a DOI has been already assigned outside Zenodo.
#'    This method will call the method \code{$prereserveDOI(FALSE)}.
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
      self$metadata$doi
      self$prereserveDOI(FALSE)
    },
    
    #setUploadType
    setUploadType = function(uploadType){
      uploadTypeValues <- c("publication","poster","presentation",
                            "dataset","image","video","software")
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
    addCreator = function(firstname, lastname, affiliation, orcid = NULL, gnd = NULL){
      creator <- list(name = paste(lastname, firstname, sep=", "),
                      affiliation = affiliation)
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
      return(self$removeCreator(by = "Name", name))
    },

    #removeCreatorByAffiliation
    removeCreatorByAffiliation = function(affiliation){
      return(self$removeCreator(by = "affiliation", affiliation))
    },
    
    #removeCreatorByORCID
    removeCreatorByORCID = function(orcid){
      return(self$removeCreator(by = "orcid", orcid))
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
        if(!is.null(zen_community$status)){
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
    }
    
    #TODO missing metadata setter methods
    
  )
)