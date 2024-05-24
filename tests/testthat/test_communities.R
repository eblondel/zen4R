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
  Sys.sleep(2)
  zen_communities_raw <- zenodo$getCommunities(pretty = FALSE)
  expect_is(zen_communities_raw, "list")
  Sys.sleep(2)
})

test_that("community is retrieved by id",{
  zenodo <- ZenodoManager$new(logger = "INFO")
  zen_community <- zenodo$getCommunityById("fisheries")
  expect_equal(zen_community$slug, "fisheries")
  expect_equal(zen_community$metadata$title, "Fisheries and aquaculture")
  Sys.sleep(2)
})

test_that("record is submitted to a community, with cancel and review actions (decline, accept) performed",{
  rec = ZENODO$getDepositionByDOI("10.5072/zenodo.54894")
  removed = ZENODO$removeRecordFromCommunities(record = rec, communities = "openfair")
  expect_true(removed)
  req = ZENODO$submitRecordToCommunities(record = rec, communities = "openfair")
  #cancel request (for user that submitted the record)
  canceled = ZENODO$cancelRequest(req$processed[[1]]$request_id)
  expect_true(canceled)
  #submit again (new review)
  req = ZENODO$submitRecordToCommunities(record = rec, communities = "openfair")
  declined = ZENODO$declineRequest(req$processed[[1]]$request_id, message = "Please explain why you want to add zen4R to 'Open Fair' community")
  expect_true(declined)
  #submit again (new review)
  req = ZENODO$submitRecordToCommunities(record = rec, communities = "openfair", message = "zen4R supports FAIR principles")
  accepted = ZENODO$acceptRequest(req$processed[[1]]$request_id, message = "Thank you, welcome to the Open FAIR community")
  #get record communities
  req_coms = ZENODO$getRecordCommunities(record = rec)
  expect_true(length(req_coms)>0)
})