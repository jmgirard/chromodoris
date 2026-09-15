test_that("the package namespace loads with its declared imports", {
  ns <- asNamespace("chromodoris")
  expect_true(isNamespace(ns))
  imports <- getNamespaceImports(ns)
  expect_true("ggplot2" %in% names(imports))
  expect_identical(imports[["rlang"]], c(.data = ".data"))
  expect_identical(imports[["cli"]], c(cli_abort = "cli_abort"))
})
