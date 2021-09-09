library(testthat)
library(zen4R)


#test environment
zenodo_url <- "https://sandbox.zenodo.org/api"
zenodo_token <- Sys.getenv("ZENODO_SANDBOX_TOKEN")
zenodo_logger <- "DEBUG"
ZENODO <- try(ZenodoManager$new(url = zenodo_url, token = zenodo_token, logger = zenodo_logger))

if(is(ZENODO, "ZenodoManager")){
  if(!ZENODO$anonymous){
    cat(sprintf("Zenodo sandbox '%s' configured with user token. Running integration tests...\n", zenodo_url))
    test_check("zen4R")
  }else{
    cat("Zenodo sandbox '%s' not configured with user token. Skipping integration tests...\n")
  }
}else{
  cat("Zenodo sandbox '%s' not configured. Skipping integration tests...\n")
}
