# Design

## Purpose & Scope

<!-- Seeded by /cairn-init on 2026-09-15 in a greenfield repo. Refine with /design-interview. -->

- chromodoris is an R package. At init the repo held no source, so the
  package's purpose is not yet written down. **The user refines this section.**
- Distribution ambition: GitHub-only for now (chosen 2026-09-15). CRAN is not
  ruled out; targeting it later adds check discipline but no rework.
- Pre-1.0: the API can change without a deprecation cycle until 1.0.

## Function Families

_None yet. The package skeleton is the first milestone._

## Conventions

- Pure R: no compiled code (reversible default chosen 2026-09-15; adding
  Rcpp later is additive).
- No numeric work expected (stated 2026-09-15). If numeric computation
  enters the package, this line is replaced by a commitment to oracle
  verification against an independent reference at the ≥2-types bar
  (D-024/D-025 doctrine).
- Toolchain conventions (testthat 3e, roxygen, cli conditions, NEWS.md)
  live in `cairn/PROFILE.md`.

## Design Principles

<!-- IP<n> = Inviolable (hard constraint) first, then GP<n> = Guiding
     (tradeable with justification). Numbers are never reused.
     None elicited yet — run /design-interview. -->

### Inviolable

_None yet._

### Guiding

_None yet._

## Architecture

_Nothing built yet._

## Known issues

_None._
