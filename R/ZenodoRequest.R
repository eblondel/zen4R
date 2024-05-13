#' ZenodoRequest
#'
#' @docType class
#' @export
#' @keywords Zenodo Request
#' @return Object of \code{\link{R6Class}} for modelling a generic Zenodo request
#' @format \code{\link{R6Class}} object.
#' 
#' @note Abstract class used internally by \pkg{zen4R}
#' 
#' @author Emmanuel Blondel <emmanuel.blondel1@@gmail.com>
#'
ZenodoRequest <- R6Class("ZenodoRequest",
  inherit = zen4RLogger,                    
  #private methods
  private = list(
    url = NA,
    type = NA,
    request = NA,
    requestHeaders = NA,
    data = NA,
    file = NULL,
    progress = FALSE,
    status = NA,
    response = NA,
    exception = NA,
    result = NA,
    token = NULL,
    agent = paste0("zen4R_", as(packageVersion("zen4R"),"character")),
    
    prepareData = function(data){
      if(is(data, "ZenodoRecord")){
        data <- as.list(data)
        data[[".__enclos_env__"]] <- NULL
        for(prop in names(data)){
          if(is(data[[prop]],"function")){
            data[[prop]] <- NULL
          }
        }
        if(!is.null(data[["submitted"]])) if(!data[["submitted"]]) data[["submitted"]] <- NULL
        if(length(data[["files"]])==0) data[["files"]] <- NULL
        if(length(data[["metadata"]])==0) data[["metadata"]] <- NULL
        data[["links"]] <- NULL
        data[["verbose.info"]] <- NULL
        data[["verbose.debug"]] <- NULL
        data[["loggerType"]] <- NULL
        data <- data[!sapply(data, is.null)]
      }else if(is(data, "list")){
        meta <- data$metadata
        if(!is.null(meta)){
          if(!is.null(meta$prereserve_doi)) meta$prereserve_doi <- NULL
          data <- list(metadata = meta)
        }
      }
      
      data <- as(toJSON(data, pretty=T, auto_unbox=T), "character")
      
      return(data)
    },
    
    GET = function(url, request, progress, use_curl = FALSE){
      req <- paste(url, request, sep="/")
      self$INFO(sprintf("Fetching %s", req))
      headers <- c(
        "User-Agent" = private$agent,
        "Authorization" = paste("Bearer",private$token),
        "Accept" = "application/vnd.inveniordm.v1+json"
      )
      
      responseContent <- NULL
      response <- NULL
      if(use_curl){
        h <- curl::new_handle()
        curl::handle_setheaders(h, .list = as.list(headers))
        response <- curl::curl_fetch_memory(req, handle = h)
        responseContent = jsonlite::parse_json(rawToChar(response$content))
        response <- list(
          request = request, requestHeaders = rawToChar(response$headers), 
          status = response$status_code, response = responseContent$hits[[1]]
        )
      }else{
        r <- NULL
        if(self$verbose.debug){
          r <- with_verbose(GET(req, add_headers(headers), if(progress) httr::progress(type = "up")))
        }else{
          r <- GET(req, add_headers(headers), if(progress) httr::progress(type = "up"))
        }
        responseContent <- content(r, type = "application/json", encoding = "UTF-8")
        response <- list(request = request, requestHeaders = headers(r),
                         status = status_code(r), response = responseContent)
      }
      return(response)
    },
    
    POST = function(url, request, data, file = NULL, progress){
      req <- paste(url, request, sep="/")
      if(!is.null(file)){
        contentType <- "multipart/form-data"
        data <- list(file = file, filename = data)
      }else{
        contentType <- "application/json"
        data <- private$prepareData(data)
      }
      
      #headers
      headers <- c(
        "User-Agent" = private$agent,
        "Authorization" = paste("Bearer",private$token),
        "Content-Type" = contentType,
        "Accept" = "application/vnd.inveniordm.v1+json"
      )
      
      #send request
      if(self$verbose.debug){
        r <- with_verbose(httr::POST(
          url = req,
          add_headers(headers),
          encode = ifelse(is.null(file),"json", "multipart"),
          body = data,
          if(progress) httr::progress(type = "up")
        ))
      }else{
        r <- httr::POST(
          url = req,
          add_headers(headers),
          encode = ifelse(is.null(file),"json", "multipart"),
          body = data,
          if(progress) httr::progress(type = "up")
        )
      }
      
      responseContent <- content(r, type = "application/json", encoding = "UTF-8")
      response <- list(request = data, requestHeaders = headers(r),
                       status = status_code(r), response = responseContent)
      return(response)
    },
    
    PUT = function(url, request, data, progress){
      req <- paste(url, request, sep="/")
      
      if(regexpr("draft/files", req)<0) data <- private$prepareData(data)
      
      #headers
      headers <- c(
        "User-Agent" = private$agent,
        "Authorization" = paste("Bearer",private$token),
        "Content-Type" = if(regexpr("draft/files", req)>0) "application/octet-stream" else "application/json",
        "Accept" = if(regexpr("draft/files", req)>0) NULL else "application/vnd.inveniordm.v1+json"
      )
      
      #send request
      if(self$verbose.debug){
        r <- with_verbose(httr::PUT(
          url = req,
          add_headers(headers),    
          body = data,
          if(progress) httr::progress(type = "up")
        ))
      }else{
        r <- httr::PUT(
          url = req,
          add_headers(headers),    
          body = data,
          if(progress) httr::progress(type = "up")
        )
      }
      
      responseContent <- content(r, type = "application/json", encoding = "UTF-8")
      response <- list(request = data, requestHeaders = headers(r),
                       status = status_code(r), response = responseContent)
      return(response)
    },
    
    DELETE = function(url, request, data){
      req <- paste(url, request, sep="/")
      if(!is.null(data)) req <- paste(req, data, sep = "/")
      #headers
      headers <- c(
        "User-Agent" = private$agent,
        "Authorization" = paste("Bearer",private$token)
      )
      if(self$verbose.debug){
        r <- with_verbose(httr::DELETE(
          url = req,
          add_headers(headers)
        ))
      }else{
        r <- httr::DELETE(
          url = req,
          add_headers(headers)
        )
      }
      responseContent <- content(r, type = "application/json", encoding = "UTF-8")
      response <- list(request = data, requestHeaders = headers(r),
                       status = status_code(r), response = responseContent)
      return(response)
    }
      
  ),
  #public methods
  public = list(
    #' @description Initializes a \code{ZenodoRequest}
    #' @param url request URL
    #' @param type Type of request: 'GET', 'POST', 'PUT', 'DELETE'
    #' @param request the method request
    #' @param data payload (optional)
    #' @param file to be uploaded (optional)
    #' @param progress whether a progress status has to be displayed for download/upload
    #' @param token user token
    #' @param logger the logger type
    #' @param ... any other arg
    initialize = function(url, type, request, data = NULL, file = NULL, progress = FALSE,
                          token, logger = NULL, ...) {
      super$initialize(logger = logger)
      private$url = url
      private$type = type
      private$request = request
      private$data = data
      private$file = file
      private$progress = progress
      private$token = token
     
    },
    
    #' @description Executes the request
    execute = function(){
      
      req <- switch(private$type,
        "GET" = private$GET(private$url, private$request, private$progress),
        "GET_WITH_CURL" = private$GET(private$url, private$request, private$progress, use_curl = TRUE),
        "POST" = private$POST(private$url, private$request, private$data, private$file, private$progress),
        "PUT" = private$PUT(private$url, private$request, private$data, private$progress),
        "DELETE" = private$DELETE(private$url, private$request, private$data)
      )
      
      private$request <- req$request
      private$requestHeaders <- req$requestHeaders
      private$status <- req$status
      private$response <- req$response
      
      if(private$type == "GET"){
        if(private$status != 200){
          private$exception <- sprintf("Error while executing request '%s'", req$request)
          self$ERROR(private$exception)
        }
      }
    },
    
    #'@description Get request
    getRequest = function(){
      return(private$request)
    },
    
    #'@description Get request headers
    getRequestHeaders = function(){
      return(private$requestHeaders)
    },
    
    #'@description Get request status
    getStatus = function(){
      return(private$status)
    },
    
    #'@description Get request response
    getResponse = function(){
      return(private$response)
    },
    
    #'@description Get request exception
    getException = function(){
      return(private$exception)
    },
    
    #'@description Get request result
    getResult = function(){
      return(private$result)
    },
    
    #'@description Set request result
    #'@param result result to be set
    setResult = function(result){
      private$result = result
    }
    
  )
)