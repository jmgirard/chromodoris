# Roadmap

_The only authority on milestone status. Grouped by status, not ID._
_Last hygiene check: 2026-09-15, M003 planned; alignment candidate row narrowed to interpolation_

## Milestones

| ID | Title | Status | Depends on | Priority | File/Archive |
|---|---|---|---|---|---|
| M003 | Time binning | review | — | high | milestones/M003-time-binning.md |
| M002 | First stat and wrapper | done | M001 | high | milestones/archive/M002-stat-and-wrapper.md |
| M001 | Package skeleton | done | — | high | milestones/archive/M001-package-skeleton.md |
<!-- rows grouped by status, not sorted by ID; keep only the 3 most recent
     terminal (done or dropped) rows — older ones live in milestones/archive/ + git -->

## Candidates
<!-- unnumbered ideas; one line each, ordered high → normal → low:
     - [high] idea — added YYYY-MM-DD — links
     - idea — added YYYY-MM-DD — links
     the opening token is `[high]`/`[low]` or absent (`normal`) — tracking-rules "Candidate priority token" -->
- Re-run /design-interview Phase 2 (principles) once the skeleton and a first stat exist; the seven banked candidates in DESIGN.md and the defaults-vs-explicit-alignment collision await classification — added 2026-09-15
- Interpolation onto a common time grid, the second alignment method after M003 binning; grid and method as visible arguments — added 2026-09-15, narrowed from the alignment row when M003 absorbed binning — DESIGN Known issues
- Ragged-end support marking and bound-clipping display. Also a time point with every value missing emits no row so the ribbon spans the gap, and one series per time point draws zero-height bands with no signal (M002 review findings 3 and 4) — added 2026-09-15 — DESIGN Known issues
- Input check for duplicate (id, time) rows, which the stat now pools without notice (M002 review finding 9) — added 2026-09-15 — DESIGN input contract
- Vignette showing the Chromodoris plot on a multi-rater example, and publish the pkgdown site at the url M002 set — added 2026-09-15 — after M002
