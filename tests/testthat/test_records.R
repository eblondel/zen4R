# test_records.R
# Author: Emmanuel Blondel <emmanuel.blondel1@gmail.com>
#
# Description: Unit tests for Zenodo record operations
#=======================
require(zen4R, quietly = TRUE)
require(testthat)

context("records")

test_that("create empty record - with pre-reserved DOI",{
  newRec <- ZENODO$createEmptyRecord()
  expect_is(newRec, "ZenodoRecord")
  
  #expect_is(newRec$metadata$prereserve_doi, "list")
  #expect_true(nchar(newRec$metadata$prereserve_doi$doi)>0)
  #expect_true(!is.null(newRec$recid))
  Sys.sleep(5)
})

test_that("create and deposit record",{
  myrec <- ZenodoRecord$new()
  myrec$setTitle("zen4R")
  expect_true(myrec$addAdditionalTitle("This is an alternative title", type = "alternative-title"))
  expect_false(myrec$addAdditionalTitle("This is an alternative title", type = "alternative-title"))
  myrec$setDescription("Interface to 'Zenodo' REST API")
  expect_true(myrec$addAdditionalDescription("This is an abstract", type = "abstract"))
  expect_false(myrec$addAdditionalDescription("This is an abstract", type = "abstract"))
  myrec$setPublicationDate(Sys.Date())
  myrec$setResourceType("software")
  myrec$addCreator(firstname = "Emmanuel", lastname = "Blondel", role = "datamanager", orcid = "0000-0002-5870-5762")
  myrec$addContributor(firstname = "Peter", lastname = "Lead", role = "workpackageleader")
  myrec$addContributor(firstname = "Frank", "Super", role = "supervisor")
  myrec$setLicense("mit", sandbox = TRUE)
  #expect_true(myrec$addCommunity("openfair", sandbox = TRUE))
  #expect_false(myrec$addCommunity("openfair", sandbox = TRUE))
  myrec$setKeywords(c("R","package","software"))
  myrec$addReference("Author et al., 2019. Title")
  myrec$addReference("Fulano et al., 2018. Título")
  myrec$setPublisher("CRAN")
  #myrec$addGrant("675680", sandbox = TRUE)
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#41-how-to-install-zen4r-in-r", scheme = "url", relation_type = "haspart"))
  expect_false(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#41-how-to-install-zen4r-in-r", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#42-connect-to-zenodo-rest-api", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#43-query-zenodo-deposited-records", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#44-manage-zenodo-record-depositions", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#45-manage-zenodo-record-deposition-files", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#46-export-zenodo-record-metadata", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#47-browse-zenodo-controlled-vocabularies", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#48-query-zenodo-published-records", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#49-download-files-from-zenodo-records", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#user_guide", scheme = "url", "ispartof", "publication-book"))
  expect_false(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#user_guide", scheme = "url", "ispartof", "publication-book"))
  for(i in 1:10){
    expect_true(myrec$addRelatedIdentifier(paste("http://chapter", i), scheme = "url", "haspart"))
  }
  
  expect_equal(myrec$metadata$title, "zen4R")
  expect_equal(myrec$metadata$description, "Interface to 'Zenodo' REST API")
  expect_equal(myrec$metadata$resource_type$id, "software")
  expect_is(myrec$metadata$creators, "list")
  expect_equal(length(myrec$metadata$creators), 1L)
  expect_is(myrec$metadata$contributors, "list")
  expect_equal(length(myrec$metadata$contributors), 2L)
  expect_equal(myrec$metadata$creator[[1]]$person_or_org$name, "Blondel, Emmanuel")
  expect_equal(myrec$metadata$creator[[1]]$person_or_org$identifiers[[1]]$scheme, "orcid")
  expect_equal(myrec$metadata$creator[[1]]$person_or_org$identifiers[[1]]$identifier, "0000-0002-5870-5762")
  
  #add locations
  #myrec$addLocation("Greenwich", description = "Well you know!", lon = -0.001545, lat = 51.477928)
  
  #deposit
  deposit = ZENODO$depositRecord(myrec)
  expect_is(deposit, "ZenodoRecord")
  Sys.sleep(5)
  
  #update metadata
  deposit$addCreator(firstname = "John",lastname = "Doe", role = "supervisor")
  deposit$addContributor(firstname = "Dark", "API", role = "supervisor")
  deposit = ZENODO$depositRecord(deposit)
  expect_equal(length(deposit$metadata$creators), 2L)
  expect_equal(length(deposit$metadata$contributors), 3L)
  
  #add files
  ZENODO$uploadFile("README.md", record = deposit)
  ZENODO$uploadFile("NEWS.md", record = deposit)
  Sys.sleep(5)
  
  #delete record
  deleted <- ZENODO$deleteRecord(deposit$id)
  expect_true(deleted)
  Sys.sleep(5)
})

test_that("create, deposit and publish record",{
  myrec <- ZenodoRecord$new()
  myrec$setTitle("zen4R")
  myrec$setDescription("Interface to 'Zenodo' REST API")
  myrec$setPublicationDate(Sys.Date())
  myrec$setResourceType("software")
  myrec$addCreator(firstname = "Emmanuel", lastname = "Blondel", role = "datamanager", orcid = "0000-0002-5870-5762")
  myrec$addContributor(firstname = "Peter", lastname = "Lead", role = "workpackageleader")
  myrec$addContributor(firstname = "Frank", "Super", role = "supervisor")
  myrec$setLicense("mit", sandbox = TRUE)
  #expect_true(myrec$addCommunity("openfair", sandbox = TRUE))
  #expect_false(myrec$addCommunity("openfair", sandbox = TRUE))
  myrec$setKeywords(c("R","package","software"))
  myrec$addReference("Author et al., 2019. Title")
  myrec$addReference("Fulano et al., 2018. Título")
  myrec$setPublisher("CRAN")
  #myrec$addGrant("675680", sandbox = TRUE)
  expect_true(myrec$addRelatedIdentifier("my-record-id", scheme = "urn", relation_type = "isidenticalto"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#41-how-to-install-zen4r-in-r", scheme = "url", relation_type = "haspart"))
  expect_false(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#41-how-to-install-zen4r-in-r", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#42-connect-to-zenodo-rest-api", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#43-query-zenodo-deposited-records", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#44-manage-zenodo-record-depositions", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#45-manage-zenodo-record-deposition-files", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#46-export-zenodo-record-metadata", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#47-browse-zenodo-controlled-vocabularies", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#48-query-zenodo-published-records", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#49-download-files-from-zenodo-records", scheme = "url", relation_type = "haspart"))
  expect_true(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#user_guide", scheme = "url", "ispartof", "publication-book"))
  expect_false(myrec$addRelatedIdentifier("https://github.com/eblondel/zen4R/wiki#user_guide", scheme = "url", "ispartof", "publication-book"))
  for(i in 1:10){
    expect_true(myrec$addRelatedIdentifier(paste("http://chapter", i), scheme = "url", "haspart"))
  }
  
  expect_equal(myrec$metadata$title, "zen4R")
  expect_equal(myrec$metadata$description, "Interface to 'Zenodo' REST API")
  expect_equal(myrec$metadata$resource_type$id, "software")
  expect_is(myrec$metadata$creators, "list")
  expect_equal(length(myrec$metadata$creators), 1L)
  expect_is(myrec$metadata$contributors, "list")
  expect_equal(length(myrec$metadata$contributors), 2L)
  expect_equal(myrec$metadata$creator[[1]]$person_or_org$name, "Blondel, Emmanuel")
  expect_equal(myrec$metadata$creator[[1]]$person_or_org$identifiers[[1]]$scheme, "orcid")
  expect_equal(myrec$metadata$creator[[1]]$person_or_org$identifiers[[1]]$identifier, "0000-0002-5870-5762")
  
  #deposit
  deposit = ZENODO$depositRecord(myrec)
  expect_is(deposit, "ZenodoRecord")
  
  #update metadata
  deposit$addCommunity("fisheries")
  deposit = ZENODO$depositRecord(deposit)
  
  #add files
  ZENODO$uploadFile("README.md", record = deposit)
  ZENODO$uploadFile("NEWS.md", record = deposit)
  Sys.sleep(5)
  
  #publish record
  deposit <- ZENODO$publishRecord(deposit$id)
  Sys.sleep(5)
  
  #delete record
  deleted <- ZENODO$deleteRecord(deposit$id)
  expect_false(deleted)
  Sys.sleep(5)
})

test_that("get by concept DOI",{
  rec <- ZENODO$getDepositionByConceptDOI("10.5072/zenodo.54893")
  expect_is(rec, "ZenodoRecord")
  expect_equal(rec$getConceptDOI(), "10.5072/zenodo.54893")
  Sys.sleep(5)
})

test_that("get by record DOI",{
  rec <- ZENODO$getDepositionByDOI("10.5072/zenodo.54894")
  expect_is(rec, "ZenodoRecord")
  expect_equal(rec$getConceptDOI(), "10.5072/zenodo.54893")
  Sys.sleep(5)
})

test_that("list & downloading files",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  rec <- zenodo$getRecordByDOI("10.5281/zenodo.3378733")
  expect_is(rec$listFiles(pretty = FALSE), "list")
  files <- rec$listFiles(pretty = TRUE)
  expect_is(files, "data.frame")
  expect_equal(nrow(files), length(rec$files))
  Sys.sleep(5)
  
  dir.create("download_zenodo")
  rec$downloadFiles(path = "download_zenodo")
  downloaded_files <- list.files("download_zenodo")
  expect_equal(length(downloaded_files), length(rec$files))
  unlink("download_zenodo", recursive = T)
  Sys.sleep(5)
  
})

test_that("list & downloading files - using wrapper",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  rec <- zenodo$getRecordByDOI("10.5281/zenodo.3378733")
  dir.create("download_zenodo")
  download_zenodo(path = "download_zenodo", "10.5281/zenodo.3378733")
  downloaded_files <- list.files("download_zenodo")
  expect_equal(length(downloaded_files), length(rec$files))
  unlink("download_zenodo", recursive = T)
  Sys.sleep(5)
})

test_that("versioning",{
  rec <- ZENODO$getDepositionByConceptDOI("10.5072/zenodo.523362")
  rec$setTitle(paste("My publication title -", Sys.time()))
  rec$setPublicationDate(Sys.Date())
  publication_filename <- paste0("publication_", format(Sys.time(), "%Y%m%d%H%M%S"), ".csv")
  write.csv(data.frame(title = rec$metadata$title, stringsAsFactors = FALSE), row.names = FALSE, publication_filename)
  rec_version <- ZENODO$depositRecordVersion(rec, files = publication_filename, publish = TRUE)
  unlink(publication_filename)
})

test_that("mapping to atom4R",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  rec <- zenodo$getRecordByConceptDOI("10.5281/zenodo.2547036")
  dcentry <- rec$toDCEntry()
  expect_is(dcentry, "DCEntry")
  xml <- dcentry$encode()
  expect_is(xml, "XMLInternalNode")
})

test_that("get record by ID",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  rec <- zenodo$getRecordByDOI("10.5281/zenodo.3378733")
  expect_is(rec, "ZenodoRecord")
})

#test_that("versions & DOIs",{
#  rec <- ZENODO$getDepositionByConceptDOI("10.5072/zenodo.523362")
#  Sys.sleep(5)
#  expect_equal(rec$getConceptDOI(), "10.5072/zenodo.523362")
#  Sys.sleep(5)
#  expect_equal(rec$getFirstDOI(), "10.5072/zenodo.523363")
#  Sys.sleep(5)
#  versions <- rec$getVersions()
#  expect_is(versions, "data.frame")
#  Sys.sleep(5)
#  
#  rec <- ZENODO$getDepositionByDOI("10.5072/zenodo.523363")
#  Sys.sleep(5)
#  expect_equal(rec$getConceptDOI(), "10.5072/zenodo.523362")
#  Sys.sleep(5)
#  expect_equal(rec$getFirstDOI(), "10.5072/zenodo.523363")
#  Sys.sleep(5)
#  versions <- rec$getVersions()
#  expect_is(versions, "data.frame")
#  Sys.sleep(5)
#  
#  rec <- ZENODO$getDepositionByDOI(rec$getLastDOI())
#  expect_is(rec, "ZenodoRecord")
#  Sys.sleep(5)
#})

#test_that("versions & DOIS - using wrapper",{
#  df <- get_versions("10.5281/zenodo.2547036")
#  expect_is(df, "data.frame")
#  Sys.sleep(5)
#})
