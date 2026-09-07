R := R_LIBS_USER=$(CURDIR)/.R/library Rscript

.PHONY: run replicate diagnostics report interpretation simulation simulation-report simulation-weighting simulation-weighting-report simulation-handoff simulation-handoff-report simulation-test test lint format deps simulation-costs

run: replicate
	$(R) src/robustness.R
	$(R) src/diagnostics.R
	$(R) src/bride_income_audit.R
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
	$(R) src/bride_income_audit.R
	$(R) src/structural_checks.R

interpretation:
	$(R) src/tradeoff_interpretation.R
	$(R) src/resource_heterogeneity.R
	$(R) src/us_benchmarks.R
	$(R) -e 'knitr::knit("ms/tradeoff-interpretation.Rmd", output = "ms/tradeoff-interpretation.md", quiet = TRUE)'

simulation:
	$(R) src/simulation_sensitivity.R
	$(MAKE) simulation-report

simulation-report:
	$(R) src/simulation_interview_crosswalk.R
	$(R) src/simulation_summarize.R
	SIMULATION_ANALYSIS=weighting $(R) src/simulation_summarize.R
	SIMULATION_ANALYSIS=handoff $(R) src/simulation_summarize.R
	$(R) -e 'knitr::knit("ms/simulation-audit.Rmd", output = "ms/simulation-audit.md", quiet = TRUE)'

simulation-weighting:
	$(R) src/simulation_weighting.R
	$(MAKE) simulation-weighting-report

simulation-weighting-report:
	$(R) src/simulation_interview_crosswalk.R
	SIMULATION_ANALYSIS=weighting $(R) src/simulation_summarize.R

simulation-handoff:
	$(R) src/simulation_handoff.R
	$(MAKE) simulation-handoff-report

simulation-handoff-report:
	$(R) src/simulation_interview_crosswalk.R
	SIMULATION_ANALYSIS=handoff $(R) src/simulation_summarize.R

simulation-test:
	$(R) src/simulation_coefficients.R
	$(R) tests/test_simulation.R

report: interpretation
	$(R) src/figures.R
	$(R) -e 'knitr::knit("README.Rmd", output = "README.md", quiet = TRUE)'

test: simulation-test
	$(R) tests/test_replication.R
	$(R) tests/test_interpretation.R
	$(R) tests/test_bride_income.R
	$(R) tests/test_simulation_costs.R
	$(R) tests/test_simulation_batch.R

lint:
	$(R) -e 'x <- lintr::lint_dir("src"); y <- lintr::lint_dir("tests"); print(c(x,y)); stopifnot(length(x) + length(y) == 0L)'

format:
	$(R) -e 'styler::cache_deactivate(); styler::style_dir("src"); styler::style_dir("tests")'

deps:
	@mkdir -p .R/library
	$(R) -e 'if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv", repos = "https://cloud.r-project.org"); renv::restore(library = ".R/library", prompt = FALSE)'

simulation-costs:
	$(R) src/simulation_costs.R
	$(R) -e 'knitr::knit("ms/simulation-costs.Rmd", output="ms/simulation-costs.md", quiet=TRUE)'
