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
#'  \item{\code{addCreator(firsname, lastname, name, affiliation, orcid, gnd)}}{
#'    Add a creator for the record. One approach is to use the \code{firstname} and
#'    \code{lastname} arguments, that by default will be concatenated for Zenodo as
#'    \code{lastname, firstname}. For more flexibility over this, the \code{name}
#'    argument can be directly used.
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
#'  \item{\code{getFirstDOI()}}{
#'    Get DOI of the first record version.
#'  }
#'  \item{\code{getLastDOI()}}{
#'    Get DOI of the latest record version.
#'  }
#'  \item{\code{getVersions()}}{
#'    Get a \code{data.frame} listing record versions with publication date and DOI.
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
#'  \item{\code{setThesisUniversity(university)}}{
#'    Set the thesis university, object of class \code{\link{character}}
#'  }
#'  \item{\code{addThesisSupervisor(firsname, lastname, affiliation, orcid, gnd)}}{
#'    Add a thesis supervisor for the record.
#'  }
#'  \item{\code{removeThesisSupervisor(by,property)}}{
#'    Removes a thesi supervisor by a property. The \code{by} parameter should be the name
#'    of the thesis supervisor property ('name' - in the form 'lastname, firstname', 'affiliation',
#'    'orcid' or 'gnd'). Returns \code{TRUE} if some thesis supervisor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeThesisSupervisorByName(name)}}{
#'    Removes a thesis supervisor by name. Returns \code{TRUE} if some thesis supervisor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeThesisSupervisorByAffiliation(affiliation)}}{
#'    Removes a thesis supervisor by affiliation. Returns \code{TRUE} if some thesis supervisor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeThesisSupervisorByORCID(orcid)}}{
#'    Removes a thesis supervisor by ORCID. Returns \code{TRUE} if some thesis supervisor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{removeThesisSupervisorByGND(gnd)}}{
#'    Removes a thesis supervisor by GND. Returns \code{TRUE} if some thesis supervisor was removed, 
#'    \code{FALSE} otherwise.
#'  }
#'  \item{\code{exportAs(format, filename)}}{
#'    Export metadata in a format supported by Zenodo. Supported formats are: BibTeX, CSL, DataCite, 
#'    DublinCore, DCAT, JSON, JSON-LD, GeoJSON, MARCXML. The exported will be named with the specified
#'    filename followed by the format name.
#'  }
#'  \item{\code{exportAsBibTeX(filename)}}{
#'    Export metadata as BibTeX (BIB) file
#'  }
#'  \item{\code{exportAsCSL(filename)}}{
#'    Export metadata as CSL (JSON) file
#'  }
#'  \item{\code{exportAsDataCite(filename)}}{
#'    Export metadata as DataCite (XML) file
#'  }
#'  \item{\code{exportAsDublinCore(filename)}}{
#'    Export metadata as Dublin Core file
#'  }
#'  \item{\code{exportAsDCAT(filename)}}{
#'    Export metadata as DCAT (RDF) file
#'  }
#'  \item{\code{exportAsJSON(filename)}}{
#'    Export metadata as JSON file
#'  }
#'  \item{\code{exportAsJSONLD(filename)}}{
#'    Export metadata as JSON-LD (JSON) file
#'  }
#'  \item{\code{exportAsGeoJSON(filename)}}{
#'    Export metadata as GeoJSON (JSON) file
#'  }
#'  \item{\code{exportAsMARCXML{filename}}}{
#'    Export metadata as MARCXML (XML) file
#'  }
#'  \item{\code{exportAsAllFormats(filename)}}{
#'    Export metadata as all Zenodo supported metadata formats. THis function will
#'    create one file per Zenodo metadata formats.
#'  }
#'  \item{\code{listFiles(pretty)}}{
#'    List files attached to the record. By default \code{pretty} is TRUE and the output
#'    will be a \code{data.frame}, otherwise a \code{list} will be returned.
#'  }
#'  \item{\code{downloadFiles(path, parallel, parallel_handler, cl, ...)}}{
#'    Download files attached to the record. The \code{path} can be specified as target
#'    download directory (by default it will be the current working directory).
#'    
#'    The argument \code{parallel} (default is \code{FALSE}) can be used to parallelize
#'    the files download. If set to \code{TRUE}, files will be downloaded in parallel
#'    using default \code{mclapply} interface from \pkg{parallel} package. To use a different
#'    parallel handler (such as eg \code{parLapply} or \code{parSapply}), specify its function
#'    in \code{parallel_handler} argument. For cluster-based parallel download, this is the 
#'    way to proceed. In that case, the cluster should be created earlier by the user with 
#'    \code{makeCluster} and passed as \code{cl} argument. After downloading all files, the cluster
#'    will be stopped automatically.
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
    
    #getFirstDOI
    getFirstDOI = function(){
      versions <- self$getVersions()
      return(versions[1,"doi"])
    },
    
    #getLastDOI
    getLastDOI = function(){
      versions <- self$getVersions()
      return(versions[nrow(versions),"doi"])
    },
    
    #getVersions
    getVersions = function(){
      locale <- Sys.getlocale("LC_TIME")
      Sys.setlocale("LC_TIME", "us_US")
      html <- xml2::read_html(self$links$latest_html)
      html_versions <- xml2::xml_find_all(html, ".//table")[3]
      versions <- data.frame(
        date = as.Date(sapply(xml2::xml_find_all(html_versions, ".//tr"), function(x){
          xml_version <- xml2::read_xml(as.character(x))
          html_date <- xml2::xml_text(xml2::xml_find_all(xml_version, ".//small")[2])
          date <- as.Date(strptime(html_date, format="%b %d, %Y"))
          return(date)
        }), origin = "1970-01-01"),
        version = sapply(xml2::xml_find_all(html_versions, ".//tr"), function(x){
          xml_version <- xml2::read_xml(as.character(x))
          v <- xml2::xml_text(xml2::xml_find_all(xml_version, "//a")[1])
          v <- substr(v, 9, nchar(v)-1)
          return(v)
        }),
        doi = sapply(xml2::xml_find_all(html_versions, ".//tr"), function(x){
          xml_version <- xml2::read_xml(as.character(x))
          xml2::xml_text(xml2::xml_find_all(xml_version, ".//small")[1])
        }),
        stringsAsFactors = FALSE
      )
      versions <- versions[rev(row.names(versions)),]
      row.names(versions) <- 1:nrow(versions)
      Sys.setlocale("LC_TIME", locale)
      return(versions)
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
    addCreator = function(firstname, lastname, name = paste(lastname, firstname, sep = ", "),
                          affiliation = NULL, orcid = NULL, gnd = NULL){
      creator <- list(name = name)
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
        stop(sprintf("Relation '%s' incorrect. Use a value among the following [%s]", 
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
    },
    
    #setThesisUniversity
    setThesisUniversity = function(university){
      self$metadata_thesis_university <- university
    },
    
    #addThesisSupervisor
    addThesisSupervisor = function(firstname, lastname, affiliation = NULL, orcid = NULL, gnd = NULL){
      supervisor <- list(name = paste(lastname, firstname, sep=", "))
      if(!is.null(affiliation)) supervisor <- c(supervisor, affiliation = affiliation)
      if(!is.null(orcid)) supervisor <- c(supervisor, orcid = orcid)
      if(!is.null(gnd)) supervisor <- c(supervisor, gnd = gnd)
      if(is.null(self$metadata$thesis_supervisors)) self$metadata$thesis_supervisors <- list()
      self$metadata$thesis_supervisors[[length(self$metadata$thesis_supervisors)+1]] <- supervisor
    },
    
    #removeThesisSupervisor
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
    
    #removeThesisSupervisorByName
    removeThesisSupervisorByName = function(name){
      return(self$removeThesisSupervisor(by = "name", name))
    },
    
    #removeThesisSupervisorByAffiliation
    removeThesisSupervisorByAffiliation = function(affiliation){
      return(self$removeThesisSupervisor(by = "affiliation", affiliation))
    },
    
    #removeThesisSupervisorByORCID
    removeThesisSupervisorByORCID = function(orcid){
      return(self$removeThesisSupervisor(by = "orcid", orcid))
    },
    
    #removeThesisSupervisorByGND
    removeThesisSupervisorByGND = function(gnd){
      return(self$removeThesisSupervisor(by = "gnd", gnd))
    },
    
    #exportAs
    exportAs = function(format, filename){
      formats <- c("BibTeX","CSL","DataCite","DublinCore","DCAT","JSON","JSON-LD","GeoJSON","MARCXML")
      zenodo_url <- self$links$record_html
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
        stop(sprintf("Unknown Zenodo metadata format '%s'. Supported formats are [%s]", format, paste(formats, collapse=",")))
      }
      
      fileext <- switch(format,
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
      
      html <- xml2::read_html(metadata_export_url)
      reference <- xml2::xml_find_all(html, ".//pre")
      reference <- reference[1]
      reference <- gsub("<pre.*\">","",reference)
      reference <- gsub("</pre>","",reference)
      if(fileext %in% c("xml", "rdf")){
        reference <- gsub("&lt;", "<", reference)
        reference <- gsub("&gt;", ">", reference)
      }
    
      destfile <- paste(paste0(filename, "_", format), fileext, sep = ".")
      writeChar(reference, destfile, eos = NULL)
    },
    
    #exportAsBibTeX
    exportAsBibTeX = function(filename){
      self$exportAs("BibTeX", filename)
    },
    
    #exportAsCSL
    exportAsCSL = function(filename){
      self$exportAs("CSL", filename)
    },
    
    #exportAsDataCite
    exportAsDataCite = function(filename){
      self$exportAs("DataCite", filename)
    },
    
    #exportAsDublinCore
    exportAsDublinCore = function(filename){
      self$exportAs("DublinCore", filename)
    },
    
    #exportAsDCAT
    exportAsDCAT = function(filename){
      self$exportAs("DCAT", filename)
    },
    
    #exportAsJSON
    exportAsJSON = function(filename){
      self$exportAs("JSON", filename)
    },
    
    #exportAsJSONLD
    exportAsJSONLD = function(filename){
      self$exportAs("JSON-LD", filename)
    },
    
    #exportAsGeoJSON
    exportAsGeoJSON = function(filename){
      self$exportAs("GeoJSON", filename)
    },
    
    #exportAsMARCXML
    exportAsMARCXML = function(filename){
      self$exportAs("MARCXML", filename)
    },
    
    #exportAsAllFormats
    exportAsAllFormats = function(filename){
      formats <- c("BibTeX","CSL","DataCite","DublinCore","DCAT","JSON","JSON-LD","GeoJSON","MARCXML")
      invisible(lapply(formats, self$exportAs, filename))
    },
    
    #listFiles
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
    
    #downloadFiles
    downloadFiles = function(path = ".", parallel = FALSE, parallel_handler = NULL, cl = NULL, ...){
      if(length(self$files)==0){
        self$WARN(sprintf("No files to download for record '%s' (doi: '%s')",
                          self$id, self$doi))
      }else{
        files_summary <- sprintf("Download %s file%s from record '%s' (doi: '%s') - total size: %s",
                                length(self$files), ifelse(length(self$files)>1,"s",""), self$id, 
                                self$doi, sum(sapply(self$files, function(x){x$filesize})))
        
        download_file <- function(file){
          cat(sprintf("Downloading file '%s' from record '%s' (doi: '%s') - size: %s\n", 
                            file$filename, self$id, self$doi, file$filesize))
          download.file(url = file$links$download, destfile = file.path(path, file$filename))
          cat(sprintf("File '%s' successfully downloaded at '%s'\n",
                            file$filename, file.path(path, file$filename)))
        }
        
        if(parallel){
          self$INFO("Download in parallel mode")
          if(is.null(parallel_handler)){
            self$INFO("Using default parallel 'mclapply' handler")
            self$INFO(files_summary)
            invisible(mclapply(self$files, download_file, ...))
          }else{
            self$INFO("Using cluster-based parallel handler")
            if(is.null(cl)){
              errMsg <- "No cluster object defined as 'cl' argument. Aborting file download..."
              self$ERROR(errMsg)
              stop(errMsg)
            }
            self$INFO(files_summary)
            invisible(parallel_handler(cl, self$files, download_file, ...))
            try(stopCluster(cl))
          }
        }else{
          self$INFO("Download in sequential mode")
          self$INFO(files_summary) 
          invisible(lapply(self$files, download_file))
        }
        self$INFO("End of download")
      }
    }
    
  )
)
