# M001: Package skeleton

**Status:** done (2026-09-15, PR #1 https://github.com/jmgirard/chromodoris/pull/1)

**Goal:** Ship an installable, checked, CI-ready chromodoris package with no user-facing functions yet.

**Outcome:** DESCRIPTION (Package chromodoris, Version 0.0.0.9000, MIT + file LICENSE,
Imports cli, ggplot2, rlang) and R/chromodoris-package.R with package-level imports.
testthat edition 3 with one namespace test, NEWS.md dev heading, README.Rmd knitted
to README.md, and _pkgdown.yml with the url left empty. The usethis check-standard and
test-coverage workflows and .Rbuildignore entries. The public GitHub repository
jmgirard/chromodoris was created at the review gate. CI passed on all six check
jobs and the coverage job before the merge. One check NOTE stands: NEWS.md has no
versioned heading, cleared by the release walk.

**Decisions:** none.

**Review:** three-lens fan-out. Diff lens returned seven findings. Four fixed on the
branch: LICENSE copyright holder and cph role, README install wording, brittle
import test, R entries in .gitignore. One follow-up: pkgdown url, folded into the
vignette candidate row. Two rejected: roxygen version field, work-log falsifier
lines. History and prior-review lenses found nothing. Nothing graduated or retired.
