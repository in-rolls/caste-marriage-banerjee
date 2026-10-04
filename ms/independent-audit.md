# Independent implementation review

An independent file review examined the papers, original programs, replication source, tests
and saved outputs at commit `09ecc2b`. It did not execute computations and preceded the
bride-income and conditional-cost extensions. The current 250-pair coding comparison,
conditional cost regressions and MAR income extension are documented in the
[simulation analysis](simulation-audit.md) and [cost analysis](simulation-costs.md).

The audit confirms the weight omission, residence and caste-rank/missing-attribute discrepancies, the quality-index precedence problem, the importance of reporting-sample definitions, and the wide published cost intervals. It agrees that selected corrections do not explain away high simulated endogamy. That conclusion is supported for the tested draws and point estimates, not for an unexecuted distribution of 250 weighted corrected draws.

The available evidence does not establish that the model's fit failure is an inherent consequence of frictionless matching; preferences, market composition, omitted compatibility, search, and other modeling assumptions could contribute. Wide cost intervals undermine an inference of negligible cost but do not establish that true costs are large. Sparse support provides a concrete concern; its consequences must be computed rather than inferred from the same-caste match rate alone.

The audit also repeats the paper's description of a lower-caste reference group. Our subsequent source-based conditional-cost reconstruction shows that some different-subcaste/equal-rank pairs enter that reference. Selected income cells can contain only two comparison couples. That new finding is documented separately in [simulation-costs.md](simulation-costs.md), including unidentified cells and exact reporting populations.

For water, the audit proposed a numerical explanation of 45%: 850.936 / 1891.613 ≈ 44.985%. The units would be incompatible if that were the authors' calculation, but no producing code verifies it. The numerical coincidence does not establish a dimensional error. Disagreement between percentile and studentized IV intervals establishes neither the existence nor the direction of causal bias. The wells README now gives both intervals equal prominence; its detailed review already did so.

The new [bride-income audit](bride-income-audit.md) was completed after the initial file review. It resolves the numerical discrepancy but demonstrates that some predicted incomes—and the income conversion—depend on restrictions the earnings data cannot identify. This distinction is more informative than either declaring a failed reproduction or accepting a monetary trade-off because one normalization matches the publication.
