test_that("bbs_sites() works", {
  expect_equal(object = bbs_sites() |> dim(),
               expected = c(4160, 6))
})
