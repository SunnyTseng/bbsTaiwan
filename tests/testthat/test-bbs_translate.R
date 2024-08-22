test_that("bbs_translation() returns species in scientific name", {
  expect_identical(object = bbs_translate("台灣朱雀"),
                   expected = "Carpodacus formosanus")
})

test_that("bbs_translation() returns character", {
  expect_type(object = bbs_translate(c("酒紅朱雀", "台灣特有種鳥類")),
              type = "character")
})

test_that("bbs_translation() returns error message when the species is not defined", {
  expect_identical(bbs_translate("台灣特有種鳥類"), expected = "Bird undefined")
})
