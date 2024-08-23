test_that("what would happen when there is no input", {
  expect_error(object = bbs_plotmap())
})

test_that("okay to plot one species with Chinese name", {
  expect_no_error(object = bbs_plotmap(target_species = "臺灣山鷓鴣"))
})

test_that("not okay with scientific name", {
  expect_type(object = bbs_plotmap(target_species = "Arborophila crudigularis"),
              type = "NULL")
})

test_that("okay with two species", {
  expect_no_error(object = bbs_plotmap(target_species = c("台灣竹雞", "臺灣山鷓鴣")))
})

test_that("return NULL when any of the species can't find match", {
  expect_type(bbs_plotmap(target_species = c("台灣竹雞", "台灣特有種鳥類")),
               type = "NULL")
})
