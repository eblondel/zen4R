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
    }
    
    #TODO missing metadata setter methods
    
  )
)