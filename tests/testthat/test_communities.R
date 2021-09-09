# test_communities.R
# Author: Emmanuel Blondel <emmanuel.blondel1@gmail.com>
#
# Description: Unit tests for Zenodo communities operations
#=======================
require(zen4R, quietly = TRUE)
require(testthat)

context("communities")

test_that("communities are retrieved",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_communities_df <- zenodo$getCommunities()
  expect_is(zen_communities_df, "data.frame")
  expect_equal(nrow(zen_communities_df), 7249)
  zen_communities_raw <- zenodo$getCommunities(pretty = FALSE)
  expect_is(zen_communities_raw, "list")
  expect_equal(length(zen_communities_raw),  7249)
})

test_that("community is retrieved by id",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_community <- zenodo$getCommunityById("fisheries")
  expect_equal(zen_community$id, "fisheries")
  expect_equal(zen_community$title, "Fisheries and aquaculture")
})