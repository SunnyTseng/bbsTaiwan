test_that("what would happen when there is no input", {
  expect_error(object = bbs_fetch())
})

test_that("return NULL when the input is NULL", {
  expect_type(object = bbs_fetch(NULL), type = "NULL")
})

test_that("return all species when the input is 'all'", {
  expect_equal(object = bbs_fetch("all") |> dim(),
               expected = c(373786, 16))
})

test_that("return the species specified according to input", {
  expect_identical(object = bbs_fetch(c("深山竹雞", "藍腹鷴", "帝雉")) |> dim(),
                   expected = bbs_fetch(c("藍腹鷴", "帝雉", "深山竹雞")) |> dim())
})

test_that("include one species", {
  expect_equal(object = bbs_fetch("藍腹鷴") |> dim(),
               expected = c(35851, 16))
})

test_that("include one species", {
  expect_type(object = bbs_fetch("台灣特有種鳥類"),
              type = "NULL")
})

test_that("include one species that is not in the list", {
  expect_type(bbs_fetch(c("藍腹鷴", "台灣特有種鳥類")),
              type = "NULL")
})
