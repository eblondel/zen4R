# test_awards.R
# Author: Emmanuel Blondel <emmanuel.blondel1@gmail.com>
#
# Description: Unit tests for Zenodo awards operations
#=======================
require(zen4R, quietly = TRUE)
require(testthat)

context("awards")

test_that("awards are retrieved",{ 
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_awards_df <- zenodo$getAwards()
  expect_is(zen_awards_df, "data.frame")
  zen_awards_raw <- zenodo$getAwards(pretty = FALSE)
  expect_is(zen_awards_raw, "list")
})

test_that("grant is retrieved by id",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_award <- zenodo$getAwardById("001aqnf71::2444954")
  expect_equal(zen_award$id, "001aqnf71::2444954")
  Sys.sleep(2)
})