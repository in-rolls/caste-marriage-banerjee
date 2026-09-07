# The bride-income coefficient reproduces, but its income conversion is not determined by the earnings data

We can now reproduce all 18 coefficients printed for the simplified bride model in Table 4, including the same-caste coefficient of 0.1800 and predicted-income coefficient of 0.0817. The earlier R discrepancy had a specific cause: Stata’s supplied predictions and R’s default fit used different ways of resolving a redundant set of education variables. This is a resolved point-estimate discrepancy, not a failed replication of the published coefficient. See the paper, printed pp. 54–55, and [the complete coefficient comparison](../output/bride_income_published_comparison.csv).

But the investigation finds a more consequential problem. The earnings regression has only **83 usable letters from 62 advertisers** to predict income for **3,944 letters from 277 advertisers**. It cannot determine predicted incomes for 115 of those letters without additional restrictions. Choosing among restrictions that fit every observed earnings value equally well materially changes the income coefficient in the shortlisting regression. Consequently, we should not turn the bride-side caste coefficient into a defensible amount of income that families would sacrifice.

The original Stata program multiplies the outcome and regressors by the square root of the sampling weight, estimates the earnings regression, and supplies its predictions to the shortlisting regression with advertiser effects. The relevant commands are [Data_analysis.do, lines 455–469](../data/original/AEJMicro-2011-0182-Data/do/Data_analysis.do#L455). Its subsequent Murphy–Topel calculations concern standard errors, rather than the point-estimate discrepancy diagnosed here. This audit verifies point estimates; it does not claim to reproduce the printed Murphy–Topel standard errors or run native Stata.

The supplied [bridewanted_for_r.txt](../data/original/AEJMicro-2011-0182-Data/R/bridewanted_for_r.txt) contains the authors’ predicted log incomes. Setting the PhD education coefficient to zero, with compensating changes to the intercept and other education coefficients, reconstructs every exported prediction to within 0.000001 log-income units. This is evidence from the supplied predictions, rather than a normalization selected merely because it matches two published numbers.

For this check, all 3,944 exported profiles were matched as a multiset using all 45 other exported columns. The export uses the opposite signs for four caste-distance variables (`diff_above`, `diff_below`, `casteimportantdiff`, `castenotimpdiff`); these signs were harmonized solely to compare the files. Every matched covariate agrees within 0.000000058. The files contain 3,925 distinct profiles, so duplicate profiles were retained and their incomes compared as multisets. This establishes agreement of the analysis inputs; it does not create unique letter identifiers. The [row-level comparison](../output/bride_income_author_comparison.csv) preserves the matching audit.

There are three exact gaps in the earnings information:

- Sixteen letters have the post-secondary education category, but no usable reported earnings in that category appear in the earnings regression.
- Thirty-nine letters report an “other” field of education, but none of the earnings observations do.
- Among earnings observations, the intercept equals the sum of six education indicators. That equality fails for 80 letters to which the earnings equation is applied. Increasing the intercept while decreasing each of those six education coefficients leaves the fitted earnings unchanged, but changes predictions for those 80 letters.

These groups overlap; their union is 115 letters. There are 84 letters flagged as reporting income, but one has a missing logged income and is excluded from the earnings fit. The earnings design matrix therefore has 83 rows, 14 columns, and rank 11. “Supported” below means the fitted linear prediction is uniquely determined by this design matrix. It does not establish that reporting and nonreporting women are comparable, or that a linear earnings equation is substantively appropriate.

The following normalizations produce the same fitted earnings and the same weighted residual sum of squares for all 83 training observations. The numbers in the last two columns are coefficients in the complete shortlisting regression, using all 3,944 letters.

| Earnings normalization | Same-caste coefficient | Predicted log-income coefficient |
|---|---:|---:|
| R default: missing-education coefficient set to zero | 0.17738 | 0.12229 |
| PhD coefficient set to zero: matches author predictions | 0.18002 | 0.08174 |
| Intercept set to zero | 0.17505 | 0.03628 |
| Intercept raised by 5, six education coefficients lowered by 5 | 0.17914 | −0.00096 |

The last row demonstrates lack of identification, rather than recommending an earnings model. The observed earnings cannot reject that change: it has exactly zero effect on their fitted values. It changes predictions for women outside the observed design’s span. Additional substantive restrictions could rule out some extrapolations, but those restrictions would need justification beyond the earnings data. [All seven zero-coefficient normalizations and the additional shift](../output/bride_income_normalizations.csv) are reported, including their training-fit checks.

The same-caste association changes little across these alternatives. The income coefficient changes substantially and can even change sign. Thus the problem is particularly serious for the proposed income conversion: dividing the caste coefficient by a normalization-dependent income coefficient cannot reveal a uniquely estimated willingness to sacrifice income. A confidence interval computed while holding one arbitrary normalization fixed would not resolve this issue.

As a diagnostic, restricting the shortlisting regression to the **3,829 letters with uniquely determined linear predictions** makes every normalization in the table produce the same estimates: **0.17437 for same caste and 0.11326 for predicted log income**. All 277 advertisers remain. This isolates the source of the discrepancy. It is not a repaired population estimate: it changes the comparison sample, and still predicts most women’s earnings from a small, selected group who reported earnings. We therefore do not publish a bride-income sacrifice from this restriction either.

This issue concerns the simplified model of men or their families shortlisting prospective brides. It does not overturn the separate main-model same-caste association, and this audit does not establish the same defect in the groom-income model. Nor does it measure the economic cost of final marriages, which requires the separate matching analysis.

Reproduce the audit with `Rscript src/bride_income_audit.R`, then run `Rscript tests/test_bride_income.R`. The tests check the complete three-dimensional unidentified space, agreement with R’s independent non-estimability diagnostic, all supplied predictions, all 18 printed coefficients, unchanged earnings fit across normalizations, the changed full-sample income slope, and invariant estimates on the restricted sample. All 26 assertions pass. Counts and the exact affected rows are in [bride_income_counts.csv](../output/bride_income_counts.csv) and [bride_income_support.csv](../output/bride_income_support.csv).
