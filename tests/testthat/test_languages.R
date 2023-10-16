# test_languages.R
# Author: Emmanuel Blondel <emmanuel.blondel1@gmail.com>
#
# Description: Unit tests for Zenodo supported languages
#=======================
require(zen4R, quietly = TRUE)
require(testthat)

context("languages")

test_that("languages are retrieved",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_languages_df <- zenodo$getLanguages()
  Sys.sleep(2)
  expect_is(zen_languages_df, "data.frame")
  zen_languages_raw <- zenodo$getLanguages(pretty = FALSE)
  expect_is(zen_languages_raw, "list")
  Sys.sleep(2)
})

test_that("language is retrieved by id",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_license <- zenodo$getLanguageById("eng")
  expect_equal(zen_license$id, "eng")
  expect_equal(zen_license$title[[1]], "English")
  Sys.sleep(2)
})