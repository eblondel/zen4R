# test_funders.R
# Author: Emmanuel Blondel <emmanuel.blondel1@gmail.com>
#
# Description: Unit tests for Zenodo funders operations
#=======================
require(zen4R, quietly = TRUE)
require(testthat)

context("funders")

test_that("funders are retrieved",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_funders_df <- zenodo$getFunders()
  Sys.sleep(2)
  expect_is(zen_funders_df, "data.frame")
  zen_funders_raw <- zenodo$getFunders(pretty = FALSE)
  expect_is(zen_funders_raw, "list")
  Sys.sleep(2)
})

test_that("funder is retrieved by id",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_funder <- zenodo$getFunderById("0553w5c95")
  expect_equal(zen_funder$identifiers[[1]]$identifier, "0553w5c95")
  Sys.sleep(2)
})