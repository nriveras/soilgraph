.PHONY: setup test check document lint style site clean help

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## Install dev dependencies and pre-commit hooks
	Rscript dev/setup.R

test: ## Run testthat tests
	Rscript -e "devtools::test()"

check: ## Run R CMD check (full package check)
	Rscript -e "devtools::check()"

document: ## Regenerate roxygen2 documentation and NAMESPACE
	Rscript -e "devtools::document()"

lint: ## Run lintr on package code
	Rscript -e "lintr::lint_package()"

style: ## Auto-style R files with styler
	Rscript -e "styler::style_pkg()"

site: ## Build pkgdown documentation site
	Rscript -e "pkgdown::build_site()"

clean: ## Remove build artifacts
	rm -rf docs/ man/*.Rd.bak *.Rcheck *.tar.gz
	Rscript -e "devtools::clean_vignettes()"
