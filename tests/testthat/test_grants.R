# test_grants.R
# Author: Emmanuel Blondel <emmanuel.blondel1@gmail.com>
#
# Description: Unit tests for Zenodo grants operations
#=======================
require(zen4R, quietly = TRUE)
require(testthat)

context("grants")

#as of 2020-04-14 this method doesn't respond, to liaise with Zenodo team if it persists
test_that("grants are retrieved",{ 
  #zenodo <- ZenodoManager$new(logger = "INFO")
  #zen_grants_df <- zenodo$getGrants()
  #expect_is(zen_grants_df, "data.frame")
  #zen_grants_raw <- zenodo$getGrants(pretty = FALSE)
  #expect_is(zen_grants_raw, "list")
})

test_that("grant is retrieved by id",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_grant <- zenodo$getGrantById("10.13039/100000002::5R01DK049482-03")
  expect_equal(zen_grant$metadata$internal_id, "10.13039/100000002::5R01DK049482-03")
  Sys.sleep(2)
})