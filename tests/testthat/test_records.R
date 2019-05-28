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