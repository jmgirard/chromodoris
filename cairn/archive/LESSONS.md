<!-- Instantiated by /cairn-init as cairn/LESSONS.md (file header; the
     scaffold ships it empty of lessons). One line per lesson; corrected in
     place when proven false; retirement per tracking-rules "Retiring a
     lesson". -->
# Lessons

Durable repo lessons — build quirks, testing tricks, gotchas worth
remembering next time — captured at milestone end and surfaced at plan time.
Not status, not decisions: a lesson is a reusable "how this repo actually
behaves" note. Cross-cutting *choices* still go to `DECISIONS.md`.

One line per lesson: `- YYYY-MM-DD (M<NNN>): <lesson>`. Two caps: 50 lines
and 20,000 bytes; over either, retire or prune before adding. Corrected in
place when proven false (never append a correction).

- 2026-09-15 (M001): `devtools::check()` NOTEs "No news entries found" while NEWS.md has only the `(development version)` heading, because R's parser needs a numeric version. Justify it until the release walk retitles the heading.
- 2026-09-15 (M001): `pkgdown::check_pkgdown()` aborts on `url: ~` in `_pkgdown.yml`. Set the url before treating that check as a gate.
- 2026-09-15 (M001): usethis installs a local `.git/hooks/pre-commit` that refuses commits when README.Rmd is newer than README.md. Run `devtools::build_readme()` before committing README.Rmd edits.
- 2026-09-15 (M002): `layer_data()` on a ribbon layer returns `y` equal to `ymin` because `GeomRibbon` overwrites it, so test a stat's computed `y` on a line layer.
- 2026-09-15 (M002): A `cli_abort()` inside a Stat is wrapped by ggplot2 at build time. `expect_error(class =)` still sees the class on the parent condition, but `tryCatch(class = )` in user code does not, so validate arguments at call time in the wrapper too.
- 2026-09-15 (M002): `devtools::test()` under a non-default reporter leaves `Rplots.pdf` and `tests/testthat/testthat-problems.rds` in the tree. Both are in `.gitignore`. Check `git status` before a checkpoint commit.
- 2026-09-15 (M003): Codecov posts `codecov/patch` and `codecov/project` commit statuses that fail on coverage targets, so `gh pr checks --watch --fail-fast` exits on them before the R CMD check jobs finish. Coverage is diagnostic per PROFILE; watch without `--fail-fast` and read the workflow jobs.
- 2026-09-15 (M003): A fixture pinned to an old commit regenerates without a checkout: `git archive <sha> R DESCRIPTION NAMESPACE tests/testthat/helper-sim.R | tar -x -C tmp`, then `pkgload::load_all(tmp)`. Archive the test helpers too, or the fixture silently tracks the working tree.
- 2026-09-15 (M003): `floor(time / width)` misplaces boundary times on decimal grids (`4.3 / 0.1` floors to 42). Oracle tests use times in multiples of 1/8 so the index is exact, and the roxygen states the caveat.
