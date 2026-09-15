# M001: Package skeleton

- **Status:** in-progress
- **Priority:** high
- **Depends on:** —
- **Driving RR:** —
- **Principles touched:** —
- **Resolves:** —
- **Surface tier:** user-facing — the installable package is the product, even while empty
- **Branch/PR:** m001-package-skeleton

## Goal

Ship an installable, checked, CI-ready chromodoris package with no user-facing functions yet.

## Scope

**In:** DESCRIPTION, MIT license, package-level roxygen imports, testthat 3e
with one placeholder test, NEWS.md, README.Rmd knitted to README.md,
`_pkgdown.yml`, the usethis CI pair, `.Rbuildignore` entries.

**Out:** any exported function → M002. A GitHub remote and a live CI run →
the operator adds the remote; CI is verified to exist here, not to pass.
Vignettes → candidate row after M002.

## Acceptance criteria

- [ ] AC1: `Rscript -e 'devtools::check()'` at the repo root reports 0 errors and 0 warnings; each NOTE is justified by one line in the review evidence.
- [ ] AC2: DESCRIPTION declares Package `chromodoris`, Version `0.0.0.9000`, `License: MIT + file LICENSE` with LICENSE and LICENSE.md present, `Config/testthat/edition: 3`, and Imports of exactly `ggplot2`, `rlang`, `cli`, read back with `desc::desc_get_deps()` and `desc::desc_get_field()`; a package-level roxygen file imports each so `check()` emits no unimported-namespace NOTE.
- [ ] AC3: `Rscript -e 'devtools::test()'` runs under testthat edition 3 and passes with at least one test.
- [ ] AC4: `NEWS.md` has a `# chromodoris (development version)` heading; `README.Rmd` exists and, after `devtools::build_readme()`, `git diff --exit-code README.md` returns 0 on a second run.
- [ ] AC5: `.github/workflows/R-CMD-check.yaml` and `test-coverage.yaml` exist as written by `usethis::use_github_action("check-standard", badge = FALSE)` and `usethis::use_github_action("test-coverage", badge = FALSE)` with usethis >= 3.0.
- [ ] AC6: `.Rbuildignore` contains entries matching `^cairn$`, `^\.github$`, `^README\.Rmd$`, `^LICENSE\.md$`, and `^_pkgdown\.yml$`; `_pkgdown.yml` exists.

## Coverage

- AC1 → T1, T2, T6
- AC2 → T1, T2
- AC3 → T3
- AC4 → T4
- AC5 → T5
- AC6 → T5, T6

## Tasks

- [x] T1: `usethis::create_package()` in place; edit DESCRIPTION (Title, Description, Authors@R, Version 0.0.0.9000); `usethis::use_mit_license()`; `usethis::use_package()` for ggplot2, rlang, cli.
- [x] T2: `R/chromodoris-package.R` with `@keywords internal`, `@import ggplot2`, `@importFrom rlang .data`, `@importFrom cli cli_abort`; `devtools::document()`.
- [x] T3: `usethis::use_testthat(3)`; one placeholder test (e.g. the package namespace loads); `devtools::test()` clean.
- [x] T4: `usethis::use_news_md()`; `usethis::use_readme_rmd()` with a two-paragraph description of the Chromodoris plot; `devtools::build_readme()`.
- [x] T5: `usethis::use_github_action("check-standard", badge = FALSE)` and `("test-coverage", badge = FALSE)`; `usethis::use_pkgdown()`; confirm `.Rbuildignore` entries.
- [x] T6: `devtools::check()`; record each NOTE and its justification.

## Work log

- 2026-09-15: created by /milestone-plan; absorbs ROADMAP candidate "Package skeleton".
- 2026-09-15: criteria audit ran in full mode; returned 7 fixes (imports stub, badge = FALSE, git-diff wording, oracle types, bounded x, wrapper-only errors, verify wording) and 4 questions; all disposed at the gate or autonomously.
- 2026-09-15: plan gate chose two milestones over one combined because the combined goal needs "and"; falsified by M001 review finding nothing to verify on its own.
- 2026-09-15: plan gate chose adding CI workflows now over deferring because the files cost nothing without a remote; falsified by the workflows failing on first push for a template reason.
- 2026-09-15: implement started; branch m001-package-skeleton cut from local main (no remote exists; the operator adds it). Gate: author Jeffrey Girard <me@jmgirard.com>; URL and BugReports point at github.com/jmgirard/chromodoris; .DS_Store added to .gitignore.
- 2026-09-15: T1 done. `create_package()` refused the git root as a nested project in a non-interactive session, so `use_description()` + `use_namespace()` + `use_mit_license()` + `use_package()` were run instead (the same files). `desc::desc_get_deps()` reads Imports cli, ggplot2, rlang; License `MIT + file LICENSE`; Version 0.0.0.9000.
- 2026-09-15: T2 done. `R/chromodoris-package.R` documents the package; `document()` writes NAMESPACE with import(ggplot2), importFrom(cli, cli_abort), importFrom(rlang, .data) and man/chromodoris-package.Rd.
- 2026-09-15: T3 done. testthat 3e set up; tests/testthat/test-package.R checks the namespace loads with the three declared imports. `devtools::test()`: FAIL 0, WARN 0, SKIP 0, PASS 4.
- 2026-09-15: T4 done. NEWS.md dev heading with one skeleton line (the usethis "Initial CRAN submission" line replaced; the package is GitHub-only). README.Rmd: two paragraphs on the plot plus a pak install line; knitted twice, `git diff --exit-code README.md` returned 0. usethis also installed a local `.git/hooks/pre-commit` that refuses commits when README.Rmd is newer than README.md.
- 2026-09-15: T5 done. usethis 3.2.1 wrote .github/workflows/R-CMD-check.yaml and test-coverage.yaml from r-lib/actions v2 examples, and _pkgdown.yml (url left as ~ until a site exists). .Rbuildignore now holds ^cairn$, ^LICENSE\.md$, ^README\.Rmd$, ^\.github$, ^_pkgdown\.yml$, ^docs$, ^pkgdown$; .gitignore gained docs.
- 2026-09-15: T6 done. First `devtools::check()` (R 4.6.1): 0 errors, 0 warnings, 2 NOTEs. NOTE 1 (non-standard top-level file CLAUDE.md) fixed by a `^CLAUDE\.md$` .Rbuildignore entry. NOTE 2 ("Problems with news in NEWS.md: No news entries found") stands: R's NEWS.md parser (`tools:::.build_news_db_from_package_NEWS_md`) only recognizes a heading that carries a numeric package version, and AC4 fixes the heading as `# chromodoris (development version)`; the NOTE clears when the release walk retitles the heading to a version. Second check: 0 errors, 0 warnings, 1 NOTE (NOTE 2).

## Decisions

## Review
