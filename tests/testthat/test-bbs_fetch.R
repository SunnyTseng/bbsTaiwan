test_that("return NULL when the input is NULL", {
  expect_type(object = bbs_fetch(), type = "NULL")
})

test_that("return all species when the input is 'all'", {
  expect_equal(object = bbs_fetch("all") |> dim(),
               expected = c(373786, 16))
})

test_that("return the species specified according to input", {
  expect_identical(object = bbs_fetch(bbs_translate(c("深山竹雞", "藍腹鷴", "帝雉"))),
                   expected = bbs_fetch(bbs_translate(c("藍腹鷴", "帝雉", "深山竹雞"))))
})
