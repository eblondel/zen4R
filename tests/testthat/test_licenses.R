# test_licenses.R
# Author: Emmanuel Blondel <emmanuel.blondel1@gmail.com>
#
# Description: Unit tests for Zenodo licenses operations
#=======================
require(zen4R, quietly = TRUE)
require(testthat)

context("licenses")

test_that("licenses are retrieved",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_licenses_df <- zenodo$getLicenses()
  Sys.sleep(2)
  expect_is(zen_licenses_df, "data.frame")
  zen_licenses_raw <- zenodo$getLicenses(pretty = FALSE)
  expect_is(zen_licenses_raw, "list")
  Sys.sleep(2)
})

test_that("license is retrieved by id",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_license <- zenodo$getLicenseById("mit")
  expect_equal(zen_license$metadata$id, "MIT")
  expect_equal(zen_license$metadata$title, "MIT License")
  Sys.sleep(2)
})