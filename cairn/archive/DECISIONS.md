<!-- Instantiated by /cairn-init as cairn/DECISIONS.md (file header; entries
     are appended from templates/decision.md). A migration replaces the body
     note with its pointer-only or re-recorded disposition (migration
     protocol step 5). -->
# Decisions

Append-only. Never renumber; supersede with a new entry. D-entries record
choices with rationale — never deferrals ("not now" is a ROADMAP fact).

### D-001: vdiffr and ggdist in Suggests (2026-09-15, M002)

Add vdiffr and ggdist to Suggests. vdiffr supplies the plot snapshot test.
ggdist supplies the live second oracle for the band math. Neither enters
Imports. The Imports set stays ggplot2, rlang, and cli (DESIGN Conventions).
Tests that use either package skip when it is not installed.
