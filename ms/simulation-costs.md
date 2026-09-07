# What do the conditional caste-cost regressions identify?





Table 8 estimates conditional associations within each simulated allocation. Its first two columns regress a partner's attribute on indicators for marrying within caste or marrying a higher-ranked caste, controlling for the other spouse's observed characteristics. Its third column instead estimates associations with the partner's education. The published brackets summarize coefficients across 250 preference draws. They are not confidence intervals from one ordinary regression.

We extracted the regression commands and requested coefficients directly from `correlations_results.do` and applied them to the ten saved allocations. This produces 33 published-cell coefficients and two additional, unreported female-income coefficients per allocation and population. The archive reports both full-market and interview-sample versions, so both are retained. Our interview definition conservatively recovers 736 of 783 participants through verified identifiers; it is not an exact reconstruction of the original reporting sample. The original README also names the search-friction reporting program alongside this program. Without the complete published-output trace, these selected no-friction results cannot certify the exact variant underlying every Table 8 entry.

## The reference group is not always a lower caste

The program defines same caste using detailed subcastes, but higher caste using a coarser ranking. Two people can belong to different subcastes at the same broad rank. Both indicators then equal zero, and the pair enters the reference category. Thus the reference can combine lower-ranked partners with equal-rank partners from another subcaste, despite Table 8's note describing it as lower caste.

This matters when that category is small. In the first supplied draw's recovered-interview groom-income regression, there are 132 couples, but only 2 reference pairs. Both have equal broad rank; none has a strictly lower-ranked groom. The estimated same-caste coefficient of ₹4,986 per month therefore cannot be described as a trade-off against a lower-caste groom in that allocation.

The following table records the exact regression sample and reference composition. Positive coefficients mean that same-caste grooms have higher reported monthly income than the reference group, conditional on the included characteristics of the women. Negative coefficients mean lower income. These are simulated conditional associations, not identified WTP.


|Allocation          |Population                | Same-caste income coefficient (monthly ₹)|    N| Lower-rank reference N| Equal-rank reference N|
|:-------------------|:-------------------------|-----------------------------------------:|----:|----------------------:|----------------------:|
|original            |full market               |                                    391.09| 1665|                      7|                      8|
|original            |verified interview subset |                                   4986.39|  132|                      0|                      2|
|residence corrected |full market               |                                   1581.88| 1663|                      7|                      7|
|residence corrected |verified interview subset |                                  -1234.35|  136|                      0|                      2|
|unweighted          |full market               |                                 -13199.18| 1674|                    101|                      0|
|unweighted          |verified interview subset |                                  18179.99|  123|                      6|                      0|
|weighted            |full market               |                                  -3590.65| 1678|                    108|                      0|
|weighted            |verified interview subset |                                   6959.03|  121|                      8|                      0|
|weighted handoff    |full market               |                                  -6518.19| 1681|                     94|                      2|
|weighted handoff    |verified interview subset |                                    145.14|  127|                      6|                      0|

The corrected weighted allocation gives different answers across reporting populations: its full-market coefficient is negative, while the conservative interview-subset coefficient is near zero and rests on six reference couples. These selected coefficients do not establish either a stable economic sacrifice or negligible cost. They show why the reporting sample, support in the comparison group, and uncertainty across preference draws must accompany the claim.

## Some selected contrasts are unidentified

A regression can be rank-deficient because a requested caste indicator has no independent variation after the controls. We check whether each requested coefficient is uniquely determined by the model matrix, rather than treating an omitted or normalized coefficient as a zero cost. Across these selected allocations and the two reporting populations, 12 published-cell coefficients are not identified. This count concerns the selected runs; it does not establish how often the issue occurs in the full 250 draws.


|Allocation          |Population                |Outcome           |Coefficient        |   N| Reference N|
|:-------------------|:-------------------------|:-----------------|:------------------|---:|-----------:|
|original            |verified_interview_subset |logwage_female    |highercaste_female |  98|          12|
|original            |verified_interview_subset |skinrank_female   |highercaste_female | 400|          37|
|original            |verified_interview_subset |vbeautiful_female |highercaste_female | 430|          34|
|original            |verified_interview_subset |beautiful_female  |highercaste_female | 430|          34|
|residence_corrected |verified_interview_subset |logwage_female    |highercaste_female | 105|          11|
|residence_corrected |verified_interview_subset |skinrank_female   |highercaste_female | 400|          37|
|residence_corrected |verified_interview_subset |vbeautiful_female |highercaste_female | 431|          33|
|residence_corrected |verified_interview_subset |beautiful_female  |highercaste_female | 431|          33|
|unweighted          |verified_interview_subset |logincome_male    |highercaste        | 123|           6|
|weighted_handoff    |verified_interview_subset |logincome_male    |highercaste        | 127|           6|
|weighted_handoff    |verified_interview_subset |logwage_female    |samecaste          | 102|           0|
|weighted_handoff    |verified_interview_subset |logwage_female    |highercaste_female | 102|           0|

Education is measured in ordered categories, age differences in years, and height differences in metres. The program exponentiates the variable named `logincome` before these regressions, so those coefficients are monthly rupees. `logwage` remains the log occupation-based wage measure. Beauty variables are indicators and skin tone is an ordered category. Panel labels refer to whose attributes are the outcomes: the groom-income regression conditions on the woman's characteristics and compares the caste position of the groom relative to her.

This extension does not equate partner reassignment or unchanged total income with the paper's conditional cost estimates. It reconstructs the actual conditional regressions. No uncertainty band from ten selected allocations is presented as the paper's 250-draw interval.

The source-to-coefficient map is saved in `output/simulation_cost_source_map.csv`; all estimates, sample sizes, reference counts, ranks, and identification flags are in `output/simulation_cost_estimates.csv`. Run `Rscript src/simulation_costs.R`, followed by `Rscript tests/test_simulation_costs.R`, to reproduce and test this extension.
