# Roadmap

- Classify the banked design principles: Re-run /design-interview Phase 2 (principles) once the skeleton and a first stat exist; the seven banked candidates in DESIGN.md and the defaults-vs-explicit-alignment collision await classification — added 2026-09-15
- Add interpolation onto a common grid: Interpolation onto a common time grid, the second alignment method after M003 binning; grid and method as visible arguments — added 2026-09-15, narrowed from the alignment row when M003 absorbed binning — DESIGN Known issues
- Mark ragged ends and clip bounds: Ragged-end support marking and bound-clipping display. Also a time point with every value missing emits no row so the ribbon spans the gap, and one series per time point draws zero-height bands with no signal (M002 review findings 3 and 4) — added 2026-09-15 — DESIGN Known issues
- Check for duplicate and NA-time rows: Input check for duplicate (id, time) rows, which the stat now pools without notice (M002 review finding 9), and for rows with a value but an NA time, which `bin_core()` drops without notice (M003 review finding 3) — added 2026-09-15, extended 2026-09-15 — DESIGN input contract
- Write a multi-rater vignette and publish pkgdown: Vignette showing the Chromodoris plot on a multi-rater example, and publish the pkgdown site at the url M002 set — added 2026-09-15 — after M002
