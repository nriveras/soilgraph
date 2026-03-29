# dev/setup.R — One-time developer environment setup
#
# Run this once after cloning the repository:
#   Rscript dev/setup.R
# Or from the Makefile:
#   make setup

cat("=== soilgraph developer setup ===\n\n")

# Install dev-only packages if not already present
dev_pkgs <- c("devtools", "precommit", "lintr", "styler", "pkgdown")
missing <- dev_pkgs[!vapply(dev_pkgs, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing) > 0L) {
  cat("Installing missing dev packages:", paste(missing, collapse = ", "), "\n")
  install.packages(missing, repos = "https://cloud.r-project.org")
} else {
  cat("All dev packages already installed.\n")
}

# Install pre-commit git hook
# Use pip directly instead of reticulate to avoid extra dependencies
cat("\nInstalling pre-commit (Python)...\n")
pre_commit_found <- nzchar(Sys.which("pre-commit"))

if (!pre_commit_found) {
  cat("Installing pre-commit via pip...\n")
  pip_exit <- system2("pip", c("install", "pre-commit"))
  if (pip_exit != 0L) {
    stop("Could not install pre-commit via pip. Install it manually: pip install pre-commit")
  }
} else {
  cat("pre-commit already installed.\n")
}

# Activate pre-commit hooks in this repo
cat("Activating pre-commit hooks...\n")
hook_exit <- system2("pre-commit", c("install"))
if (hook_exit != 0L) {
  warning("Could not activate pre-commit hooks. Run manually: pre-commit install")
} else {
  cat("Pre-commit hooks activated successfully.\n")
}

cat("\n=== Setup complete ===\n")
cat("You can now use the following Makefile targets:\n")
cat("  make test      — run tests\n")
cat("  make check     — run R CMD check\n")
cat("  make document  — regenerate roxygen docs\n")
cat("  make lint      — run lintr\n")
cat("  make style     — auto-style with styler\n")
cat("  make site      — build pkgdown site\n")
