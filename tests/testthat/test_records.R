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
})

test_that("create and deposit record",{
  myrec <- ZenodoRecord$new()
  myrec$setTitle("my R package")
  myrec$setDescription("A description of my R package")
  myrec$setUploadType("software")
  myrec$addCreator(firstname = "John", lastname = "Doe", affiliation = "Independent")
  myrec$setLicense("mit")
  myrec$setAccessRight("open")
  myrec$addCommunity("ecfunded")
  
  expect_equal(myrec$metadata$title, "my R package")
  expect_equal(myrec$metadata$description, "A description of my R package")
  expect_equal(myrec$metadata$upload_type, "software")
  expect_is(myrec$metadata$creator, "list")
  expect_equal(length(myrec$metadata$creator), 1L)
  expect_equal(myrec$metadata$creator[[1]]$name, "Doe, John")
  expect_equal(myrec$metadata$creator[[1]]$affiliation, "Independent")
  
  expect_true(myrec$metadata$prereserve_doi)
  
  #deposit
  deposit = ZENODO$depositRecord(myrec)
  expect_is(deposit, "ZenodoRecord")
  
  #delete record
  deleted <- ZENODO$deleteRecord(deposit$id)
  expect_true(deleted)
})