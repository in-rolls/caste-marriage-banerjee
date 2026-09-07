R := R_LIBS_USER=$(CURDIR)/.R/library Rscript

.PHONY: run replicate diagnostics report test lint format deps

run: replicate
	$(R) src/robustness.R
	$(R) src/diagnostics.R
	$(R) src/income_uncertainty.R
	$(R) src/income_contrasts.R
	$(R) src/structural_checks.R
	$(MAKE) report

replicate:
	$(R) src/prepare.R
	$(R) src/replicate.R
	$(R) src/compare_published.R

diagnostics:
	$(R) src/diagnostics.R
	$(R) src/structural_checks.R

report:
	$(R) src/figures.R
	$(R) -e 'knitr::knit("README.Rmd", output = "README.md", quiet = TRUE)'

test:
	$(R) tests/test_replication.R

lint:
	$(R) -e 'x <- lintr::lint_dir("src"); y <- lintr::lint_dir("tests"); print(c(x,y)); stopifnot(length(x) + length(y) == 0L)'

format:
	$(R) -e 'styler::cache_deactivate(); styler::style_dir("src"); styler::style_dir("tests")'

deps:
	@mkdir -p .R/library
	$(R) -e 'if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv", repos = "https://cloud.r-project.org"); renv::restore(library = ".R/library", prompt = FALSE)'
