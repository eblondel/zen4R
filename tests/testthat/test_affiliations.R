# test_affiliations.R
# Author: Emmanuel Blondel <emmanuel.blondel1@gmail.com>
#
# Description: Unit tests for Zenodo affiliation operations
#=======================
require(zen4R, quietly = TRUE)
require(testthat)

context("affiliation")

test_that("affiliation are retrieved",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_affiliations_df <- zenodo$getAffiliations()
  expect_is(zen_affiliations_df, "data.frame")
  Sys.sleep(2)
  zen_affiliations_raw <- zenodo$getAffiliations(pretty = FALSE)
  expect_is(zen_affiliations_raw, "list")
  Sys.sleep(2)
})

test_that("affiliation is retrieved by id",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_affiliation <- zenodo$getAffiliationById("fisheries")
  Sys.sleep(2)
})