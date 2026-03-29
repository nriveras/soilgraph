# Contributing to soilgraph

Thank you for your interest in contributing to **soilgraph**. This document describes the development workflow, conventions, and requirements for all contributions.

## Prerequisites

- **R >= 4.1.0**
- **Python 3.8+** (required by the `precommit` R package, which wraps Python's [pre-commit](https://pre-commit.com/) framework)
- **devtools**, **roxygen2** (standard R package development tools)

## Getting Started

```bash
# Clone the repository
git clone https://github.com/nriveras/soilgraph.git
cd soilgraph

# Run the one-time developer setup
make setup
```

`make setup` installs the dev-only R packages (`precommit`, `lintr`, `styler`, `pkgdown`) and activates git pre-commit hooks. You only need to run this once.

Run `make help` to see all available convenience commands.

## Branch Workflow

**Never commit directly to `main`.** All work happens in branches.

1. **Create an issue** on GitHub describing the feature, bug, or task.
2. **Create a branch** from `main` with a descriptive name:

   ```
   {type}/{issue-number}-short-description
   ```

   Types: `feature/`, `fix/`, `docs/`, `test/`, `chore/`

   Examples:
   ```
   feature/15-add-gravel-support
   fix/22-boundary-crash-on-NA
   docs/30-update-vignette-examples
   ```

3. **Make your changes** on the branch.
4. **Open a pull request** against `main` when ready.

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
type: short description (#issue-number)
```

| Type     | When to use                                  |
|----------|----------------------------------------------|
| `feat`   | New feature or exported function             |
| `fix`    | Bug fix                                      |
| `docs`   | Documentation only (roxygen, vignettes, README) |
| `test`   | Adding or updating tests                     |
| `chore`  | Build, CI, dev tooling, dependency updates   |
| `refactor` | Code restructuring with no behavior change |

Examples:
```
feat: add gravel fragment support to coarse engine (#15)
fix: correct boundary smoothing for irregular horizons (#22)
docs: update getting-started vignette with JSON examples
test: add edge-case coverage for empty profiles (#28)
chore: bump ggplot2 minimum to 3.5.0
```

## Pre-commit Hooks

Pre-commit hooks run automatically on every `git commit`. They check:

| Hook                     | What it does                                      |
|--------------------------|---------------------------------------------------|
| `parsable-R`             | Verifies all R files have valid syntax            |
| `no-browser-statement`   | Blocks `browser()` calls from being committed     |
| `deps-in-desc`           | Ensures used packages are listed in DESCRIPTION   |
| `use-tidy-description`   | Keeps DESCRIPTION consistently formatted          |
| `style-files`            | Auto-formats R code with `styler`                 |
| `lintr`                  | Runs `lintr` on staged R files                    |
| `roxygenize`             | Regenerates roxygen docs if needed                |
| `trailing-whitespace`    | Removes trailing whitespace                       |
| `end-of-file-fixer`      | Ensures files end with a newline                  |
| `check-yaml`            | Validates YAML syntax                             |
| `check-added-large-files` | Blocks files > 500 KB                            |

If a hook modifies files (e.g., `style-files` reformats code), the commit is aborted. Review the changes, `git add` them, and commit again.

**Emergency bypass** (use sparingly):
```bash
git commit --no-verify -m "wip: temporary bypass"
```

## Pull Request Requirements

Every PR must include:

- [ ] **Tests** — add or update `testthat` tests for any changed behavior
- [ ] **NEWS.md** — add a bullet under the development version heading
- [ ] **Roxygen docs** — update `@param`, `@return`, `@examples` if the API changed
- [ ] **Examples** — add usage examples for new exported functions
- [ ] **R CMD check** passes cleanly (`make check`)
- [ ] **Lintr** passes (`make lint`)

## Makefile Targets

| Target          | Command                  | Purpose                                |
|-----------------|--------------------------|----------------------------------------|
| `make setup`    | `Rscript dev/setup.R`   | One-time dev environment setup         |
| `make test`     | `devtools::test()`       | Run testthat tests                     |
| `make check`    | `devtools::check()`      | Full R CMD check                       |
| `make document` | `devtools::document()`   | Regenerate roxygen2 docs and NAMESPACE |
| `make lint`     | `lintr::lint_package()`  | Run lintr on all package code          |
| `make style`    | `styler::style_pkg()`    | Auto-format all R files with styler    |
| `make site`     | `pkgdown::build_site()`  | Build the pkgdown documentation site   |
| `make clean`    | Remove build artifacts   | Clean up generated files               |

## Versioning

soilgraph uses [semantic versioning](https://semver.org/) with R conventions:

### Format: `MAJOR.MINOR.PATCH`

| Component | Bump when...                                          | Example             |
|-----------|-------------------------------------------------------|---------------------|
| **MAJOR** | Breaking API changes (renamed/removed exports, changed return types) | `0.1.0` → `1.0.0` |
| **MINOR** | New features, new exported functions, backward-compatible additions | `0.1.0` → `0.2.0` |
| **PATCH** | Bug fixes, documentation improvements, internal refactors | `0.1.0` → `0.1.1` |

### Development versions

Between releases, the version in `DESCRIPTION` carries a `.9000` suffix:

```
0.1.0         ← released (tagged v0.1.0)
0.1.0.9000    ← development starts immediately after release
0.2.0         ← next release (tagged v0.2.0)
0.2.0.9000    ← development starts again
```

The `.9000` suffix means "development version, not yet released." It is an R community convention.

### When to bump

- **During development**: the version stays at `X.Y.Z.9000`. You do not need to bump it on every commit.
- **At release time**: decide whether the accumulated changes are a patch, minor, or major bump. Update `DESCRIPTION` and `NEWS.md` accordingly.

## Release Process

1. Decide the release version (e.g., `0.2.0`).
2. Update `Version:` in `DESCRIPTION` to `0.2.0`.
3. Update `NEWS.md` — change the heading from `# soilgraph (development version)` to `# soilgraph 0.2.0`.
4. Run `make check` — must pass cleanly.
5. Commit: `chore: release v0.2.0`
6. Merge the PR to `main`.
7. Tag the release:
   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   ```
8. Create a GitHub Release from the tag (this triggers pkgdown site deployment).
9. Immediately bump `DESCRIPTION` to `0.2.0.9000` and add a new `# soilgraph (development version)` heading to `NEWS.md`.
10. Commit: `chore: bump dev version to 0.2.0.9000`

## Code Style

- Prefer base R over external dependencies unless there is a clear benefit.
- Use `pkg::fun()` for calls to imported packages when it aids clarity.
- Use `TRUE` and `FALSE`, never `T` and `F`.
- Maximum line length: **120 characters** (enforced by lintr).
- Both `snake_case` and `dotted.case` names are accepted (matching existing conventions).
- Keep examples lightweight, deterministic, and CRAN-safe.

## Running Checks Locally

Before pushing a PR:

```bash
make document   # Regenerate roxygen docs
make lint       # Check code style
make test       # Run tests
make check      # Full R CMD check
```

All four should pass without errors or warnings.
