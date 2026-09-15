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
