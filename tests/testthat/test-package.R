test_that("the package namespace loads with its declared imports", {
  ns <- asNamespace("chromodoris")
  expect_true(isNamespace(ns))
  imports <- getNamespaceImports(ns)
  expect_true("ggplot2" %in% names(imports))
  expect_true("rlang" %in% names(imports))
  expect_true("cli" %in% names(imports))
})
