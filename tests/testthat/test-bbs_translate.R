test_that("what would happen when there is no input", {
  expect_error(object = bbs_translate())
})

test_that("bbs_translate() returns species in scientific name", {
  expect_identical(object = bbs_translate("台灣朱雀"),
                   expected = "Carpodacus formosanus")
})

test_that("bbs_translate() returns NULL when the species is not defined", {
  expect_identical(bbs_translate("台灣特有種鳥類"), expected = NULL)
})

test_that("bbs_translate() returns character", {
  expect_type(object = bbs_translate(c("酒紅朱雀", "台灣特有種鳥類")),
              type = "NULL")
})
