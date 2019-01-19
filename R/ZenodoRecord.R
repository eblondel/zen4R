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
#' }
#' 
#' @author Emmanuel Blondel <emmanuel.blondel1@@gmail.com>
#' 
ZenodoRecord <-  R6Class("ZenodoRecord",
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
    
    initialize = function(obj = NULL){
      if(!is.null(obj)) private$fromList(obj)
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
    }
    
    #TODO missing metadata setter methods
    
  )
)