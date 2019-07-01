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
  expect_is(zen_funders_df, "data.frame")
  zen_funders_raw <- zenodo$getFunders(pretty = FALSE)
  expect_is(zen_funders_raw, "list")
})

test_that("funder is retrieved by id",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_funder <- zenodo$getFunderById("10.13039/100000863")
  expect_equal(zen_funder$metadata$doi, "10.13039/100000863")
})