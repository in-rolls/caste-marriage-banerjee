R := R_LIBS_USER=$(CURDIR)/.R/library Rscript

.PHONY: education-capacity caste-benchmarks paper-versions run replicate diagnostics report interpretation simulation simulation-report simulation-weighting simulation-weighting-report simulation-handoff simulation-handoff-report simulation-test test lint format deps simulation-costs simulation-batch-costs simulation-batch-summary simulation-income

run: replicate
	$(R) src/robustness.R
	$(R) src/diagnostics.R
	$(R) src/bride_income_audit.R
	$(R) src/groom_income_support.R
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
	$(R) src/groom_income_support.R
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

report: interpretation caste-benchmarks
	$(R) src/figures.R
	$(R) -e 'knitr::knit("README.Rmd", output = "README.md", quiet = TRUE)'

test: simulation-test
	$(R) tests/test_replication.R
	$(R) tests/test_interpretation.R
	$(R) tests/test_bride_income.R
	$(R) tests/test_groom_income_support.R
	$(R) tests/test_simulation_costs.R
	$(R) tests/test_simulation_batch.R
	$(R) tests/test_simulation_batch_costs.R
	$(R) tests/test_simulation_batch_summary.R

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

simulation-batch-costs:
	@test -n "$(RUN_DIRECTORY)" || (echo "Set RUN_DIRECTORY to a simulation run directory"; exit 1)
	$(R) src/simulation_batch_costs.R "$(RUN_DIRECTORY)"
	cp "$(RUN_DIRECTORY)/table8/simulation_batch_cost_summary.csv" output/
	cp "$(RUN_DIRECTORY)/table8/simulation_batch_cost_provenance.csv" output/

simulation-batch-summary:
	@test -n "$(RUN_DIRECTORY)" || (echo "Set RUN_DIRECTORY to a simulation run directory"; exit 1)
	$(R) src/simulation_batch_summary.R "$(RUN_DIRECTORY)"

simulation-income:
	$(R) src/simulation_income_sacrifice.R
	$(R) src/simulation_income_bootstrap.R
	$(R) src/simulation_income_mar.R

paper-versions:
	$(R) src/paper_version_checks.R

caste-benchmarks:
	$(R) src/caste_matching_benchmarks.R

education-capacity:
	$(R) src/education_capacity.R
