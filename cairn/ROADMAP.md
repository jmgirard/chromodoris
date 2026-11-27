# Roadmap

- Classify the banked design principles: Re-run /design-interview Phase 2 (principles) once the skeleton and a first stat exist; the seven banked candidates in DESIGN.md and the defaults-vs-explicit-alignment collision await classification — added 2026-09-15
- Mark ragged ends and clip bounds: Ragged-end support marking and bound-clipping display. Also a time point with every value missing emits no row so the ribbon spans the gap, and one series per time point draws zero-height bands with no signal (M002 review findings 3 and 4) — added 2026-09-15 — DESIGN Known issues
- Check for duplicate and NA-time rows: Input check for duplicate (id, time) rows, which the stat now pools without notice (M002 review finding 9), and for rows with a value but an NA time, which `bin_core()` drops without notice (M003 review finding 3) — added 2026-09-15, extended 2026-09-15 — DESIGN input contract
- Publish the pkgdown site: Deploy the pkgdown site, which now carries the multi-rater vignette as an article, to the url already set in `_pkgdown.yml` and DESCRIPTION — added 2026-09-15, split from the vignette row 2026-11-27
- Walk through interpolation in the vignette: Add a vignette section that interpolates ratings sampled at unaligned times onto a common grid, since the current example data share one timeline and only binning is shown.
