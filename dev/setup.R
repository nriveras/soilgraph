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
  install.packages(missing)
} else {
  cat("All dev packages already installed.\n")
}

# Install pre-commit git hook
if (requireNamespace("precommit", quietly = TRUE)) {
  cat("\nInstalling pre-commit git hook...\n")
  precommit::install_precommit()
  precommit::use_precommit()
  cat("Pre-commit hook installed successfully.\n")
} else {
  warning("precommit package not available. Install it manually and re-run this script.")
}

cat("\n=== Setup complete ===\n")
cat("You can now use the following Makefile targets:\n")
cat("  make test      — run tests\n")
cat("  make check     — run R CMD check\n")
cat("  make document  — regenerate roxygen docs\n")
cat("  make lint      — run lintr\n")
cat("  make style     — auto-style with styler\n")
cat("  make site      — build pkgdown site\n")
