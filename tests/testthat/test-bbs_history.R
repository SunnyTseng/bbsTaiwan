
test_that("bbs_history() returns plot when argument is defined as plot", {
  expect_type(bbs_history("plot"), type = "list")
})

test_that("bbs_history() returns tibble when argument is defined as table", {
  expect_equal(bbs_history("table") |> base::dim(),
               expected = c(8, 6))
})
