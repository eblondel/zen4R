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
  expect_is(newRec$metadata$prereserve_doi, "list")
  expect_true(nchar(newRec$metadata$prereserve_doi$doi)>0)
  expect_true(newRec$metadata$prereserve_doi$recid>0)
  Sys.sleep(5)
})

test_that("create and deposit record",{
  myrec <- ZenodoRecord$new()
  myrec$setTitle("My publication title")
  myrec$setDescription("A description of my publication")
  myrec$setUploadType("publication")
  myrec$setPublicationType("article")
  myrec$addCreator(firstname = "John", lastname = "Doe", affiliation = "Independent")
  myrec$setLicense("MIT")
  expect_true(myrec$addCommunity("ecfunded"))
  expect_false(myrec$addCommunity("ecfunded"))
  myrec$setKeywords(c("R","package","software"))
  myrec$addReference("Author et al., 2019. Title")
  myrec$addReference("Fulano et al., 2018. Título")
  myrec$addGrant("675680")
  myrec$setJournalTitle("Journal title")
  myrec$setJournalVolume("1")
  myrec$setJournalIssue("Issue 1")
  myrec$setJournalPages("19")
  myrec$setConferenceTitle("Roots Rock Reggae International Conference")
  myrec$setConferenceAcronym("RRR-IC-VIBES")
  myrec$setConferenceDates("June 2019")
  myrec$setConferencePlace("Kingston, Jamaica")
  myrec$setConferenceSession("I")
  myrec$setConferenceSessionPart("1")
  myrec$setConferenceUrl("http://www.google.com")
  myrec$setImprintPublisher("The Publisher")
  myrec$setImprintISBN("isbn")
  myrec$setImprintPlace("location")
  myrec$setPartofTitle("Book title")
  myrec$setPartofPages("1-30")
  expect_true(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#41-how-to-install-zen4r-in-r"))
  expect_false(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#41-how-to-install-zen4r-in-r"))
  expect_true(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#42-connect-to-zenodo-rest-api"))
  expect_true(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#43-query-zenodo-deposited-records"))
  expect_true(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#44-manage-zenodo-record-depositions"))
  expect_true(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#45-manage-zenodo-record-deposition-files"))
  expect_true(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#46-export-zenodo-record-metadata"))
  expect_true(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#47-browse-zenodo-controlled-vocabularies"))
  expect_true(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#48-query-zenodo-published-records"))
  expect_true(myrec$addRelatedIdentifier("hasPart", "https://github.com/eblondel/zen4R/wiki#49-download-files-from-zenodo-records"))
  expect_true(myrec$addRelatedIdentifier("isPartOf", "https://github.com/eblondel/zen4R/wiki#user_guide"))
  expect_false(myrec$addRelatedIdentifier("isPartOf", "https://github.com/eblondel/zen4R/wiki#user_guide"))
  for(i in 1:10){
    expect_true(myrec$addRelatedIdentifier("hasPart", paste("http://chapter", i)))
  }
  myrec$addContributor(firstname = "Peter", lastname = "Lead", type = "WorkPackageLeader")
  myrec$addContributor(firstname = "Frank", "Super", type = "Supervisor")
  
  expect_equal(myrec$metadata$title, "My publication title")
  expect_equal(myrec$metadata$description, "A description of my publication")
  expect_equal(myrec$metadata$upload_type, "publication")
  expect_equal(myrec$metadata$publication_type, "article")
  expect_is(myrec$metadata$creator, "list")
  expect_equal(length(myrec$metadata$creator), 1L)
  expect_equal(myrec$metadata$creator[[1]]$name, "Doe, John")
  expect_equal(myrec$metadata$creator[[1]]$affiliation, "Independent")
  expect_true(myrec$metadata$prereserve_doi)
  
  #deposit
  deposit = ZENODO$depositRecord(myrec)
  expect_is(deposit, "ZenodoRecord")
  Sys.sleep(5)
  
  #add files
  writeLines("This is a dummy file for testing zen4R", "README.md")
  ZENODO$uploadFile("README.md", record = deposit)
  unlink("README.md")
  Sys.sleep(5)
  
  #delete record
  deleted <- ZENODO$deleteRecord(deposit$id)
  expect_true(deleted)
  Sys.sleep(5)
})

test_that("create, deposit and publish record",{
  myrec <- ZenodoRecord$new()
  myrec$setTitle(paste("My publication title -", Sys.time()))
  myrec$setDescription("A description of my publication")
  myrec$setUploadType("publication")
  myrec$setPublicationType("article")
  myrec$addCreator(firstname = "John", lastname = "Doe", affiliation = "Independent")
  myrec$addCreator(name = "Doe2, John2", affiliation = "Independent")
  myrec$setLicense("mit")
  myrec$addCommunity("ecfunded")
  myrec$setKeywords(c("R","package","software"))
  myrec$addReference("Author et al., 2019. Title")
  myrec$addReference("Fulano et al., 2018. Título")
  
  expect_true(startsWith(myrec$metadata$title, "My publication title"))
  expect_equal(myrec$metadata$description, "A description of my publication")
  expect_equal(myrec$metadata$upload_type, "publication")
  expect_equal(myrec$metadata$publication_type, "article")
  expect_is(myrec$metadata$creator, "list")
  expect_equal(length(myrec$metadata$creator), 2L)
  expect_equal(myrec$metadata$creator[[1]]$name, "Doe, John")
  expect_equal(myrec$metadata$creator[[1]]$affiliation, "Independent")
  expect_equal(myrec$metadata$creators[[2]]$name, "Doe2, John2")
  expect_true(myrec$metadata$prereserve_doi)
  
  #deposit
  deposit = ZENODO$depositRecord(myrec)
  expect_is(deposit, "ZenodoRecord")
  
  #add files
  writeLines("This is a dummy file for testing zen4R", "README.md")
  ZENODO$uploadFile("README.md", record = deposit)
  unlink("README.md")
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
  rec <- ZENODO$getDepositionByConceptDOI("10.5072/zenodo.523362")
  expect_is(rec, "ZenodoRecord")
  expect_equal(rec$conceptdoi, "10.5072/zenodo.523362")
  Sys.sleep(5)
})

test_that("get by record DOI",{
  rec <- ZENODO$getDepositionByDOI("10.5072/zenodo.523363")
  expect_is(rec, "ZenodoRecord")
  expect_equal(rec$conceptdoi, "10.5072/zenodo.523362")
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
  rec <- zenodo$getRecordByDOI("10.5281/zenodo.3378733")
  dcentry <- rec$toDCEntry()
  expect_is(dcentry, "DCEntry")
  xml <- dcentry$encode()
  expect_is(xml, "XMLInternalNode")
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
