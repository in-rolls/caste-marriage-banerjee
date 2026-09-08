# How much income do families sacrifice for caste?



Under a missing-at-random assumption, the corrected, weighted matching model implies a small average husband-income concession. This is consistent with strong caste preferences coexisting with small realized income differences in the model. The calculations below separate that result from shortlisting willingness to sacrifice and from the financial effects of caste in actual marriages.

## Assuming missing incomes are missing at random



For women assigned a same-caste husband in the corrected, weighted baseline, removing caste preferences raises husband income by **₹103 per month on average**, about **0.4%** of the counterfactual income. The main imputation predicts income in rupees. Using log income to select comparable donors gives ₹229 per month as a sensitivity check; that result is also an arithmetic income difference in rupees. Across all women married in both allocations, the main estimate is ₹-106 per month: essentially no net gain. These numbers are much smaller than the roughly one-third shortlisting trade-off. That is economically coherent: a family may value caste strongly yet find a same-caste partner without giving up much income.

The assumption is that income reporting is independent of income conditional on the observed predictor profile. We use 1729 reported male incomes to impute the 6309 missing incomes, using education category, age and age squared, an occupation-based log-wage proxy, caste, residence, family origin, and recorded missing-profile categories. Predictive mean matching uses five observed-income donors and 500 imputations per specification. We compare log-income and income-level prediction. The imputation model has full column rank in the observed-income sample. A man's imputed income is identical wherever he appears across the two marriage allocations; recorded incomes are preserved. Only income is imputed, and all predictor entries are observed codes, so one iteration suffices for each independent imputation.


|Imputation        |Women             |    N|Mean income gain without caste |2.5th percentile |97.5th percentile |
|:-----------------|:-----------------|----:|:------------------------------|:----------------|:-----------------|
|pmm log income    |all common women  | 7573|₹-64                           |₹-373            |₹241              |
|pmm log income    |same caste before | 6992|₹229                           |₹-236            |₹758              |
|pmm income levels |all common women  | 7573|₹-106                          |₹-368            |₹145              |
|pmm income levels |same caste before | 6992|₹103                           |₹-383            |₹646              |

The small mean is not confined to the final coding version. Applying the same income-level MAR procedure to the five saved sensitivity comparisons gives:


|Preference and coding version | Initially same-caste women|Mean income gain without caste |Share of counterfactual income |
|:-----------------------------|--------------------------:|:------------------------------|:------------------------------|
|supplied original             |                       6405|₹602                           |2.5%                           |
|supplied residence repaired   |                       6409|₹522                           |2.2%                           |
|unweighted residence repaired |                       6889|₹18                            |0.1%                           |
|weighted residence repaired   |                       6837|₹-238                          |-1.0%                          |
|weighted all repairs          |                       6992|₹103                           |0.4%                           |

The supplied comparisons use the first coefficient draw; the other versions use fitted point estimates. They are not a distribution of preference uncertainty. Each row refers to women initially matched within caste and married in both allocations under that version.

The displayed ranges reflect **missing-income imputation uncertainty with preferences, people, and allocations fixed**. They are not full confidence intervals for the economic cost of caste: they exclude uncertainty in preference coefficients, market composition, and the matching assumptions. The small net averages coexist with much larger offsetting increases and decreases. For the initially same-caste group, average gains are ₹11,782 per woman and losses ₹11,678, with zeros included for women on the other side of each calculation. Income is only one spouse attribute, so a lower-income counterfactual husband is not proof that relaxing caste makes a family worse off overall.

The data do not reveal a family's actual counterfactual spouse. These calculations maintain the paper's matching framework and treat the imputed incomes as outcomes for saved allocations; they do not feed newly imputed earnings back into search preferences. Everyone's caste terms are removed together. Thus they describe an equilibrium comparison, not how much a single family could obtain by unilaterally relaxing its caste requirement.

The observed-income-only calculation follows below to show how the MAR adjustment changes the estimate. Missingness is an assumption to model here, not an automatic reason to abandon estimation.

## How much income did the same families give up?

The relevant financial comparison is the husband's monthly income for the **same woman**, with and without caste terms in the matching preferences. A positive difference after removing caste means the model assigns her a higher-income husband; a negative difference means a lower-income husband. This is a model counterfactual, not an observed loss, a cash payment, or household profit. It excludes wealth, dowry, transfers, expenses, and the value of other spouse characteristics. Both sides of the market change preferences together, so the result also differs from one family unilaterally relaxing its caste restriction.



Using the weighted point estimates and all confirmed preference-feature repairs, removing caste terms raises husband income by **₹1,776 per month on average** among 449 women with both husbands' incomes recorded. Their mean husband income changes from ₹27,226 to ₹29,002. These 449 women represent only **5.9% of the 7,573 women married in both allocations**. Without adjustment this is a selected comparison. The MAR analysis above uses all men’s observed predictor profiles to extend the calculation to women with missing husband-income observations.

The net average combines increases and decreases. Husband income rises for 39.6%, falls for 37.2%, and is unchanged for 23.2% of the income-observed group. Counting zero for women without a gain, average gains are ₹9,515 per woman; counting zero for women without a loss, average losses are ₹7,739. Their difference gives the net increase above. The median signed change is ₹0. Omitting the single largest absolute change reduces the net mean to ₹751; this is a sensitivity check, not a reason to delete that observation.

Among women assigned a same-caste husband before removing caste terms, the corresponding mean increase is ₹3,321 per month, based on 421 income-observed women out of 6992. This is a subgroup defined by the baseline simulation, not actual same-caste marriages in the follow-up data.

The answer changes across coding and weighting versions:


|Preferences and coding        | Women with both incomes|Coverage of women married in both |Mean income gain without caste, monthly |
|:-----------------------------|-----------------------:|:---------------------------------|:---------------------------------------|
|supplied original             |                     405|5.7%                              |₹1,580                                  |
|supplied residence repaired   |                     410|5.7%                              |₹-176                                   |
|unweighted residence repaired |                     465|6.1%                              |₹-1,675                                 |
|weighted residence repaired   |                     470|6.2%                              |₹-695                                   |
|weighted all repairs          |                     449|5.9%                              |₹1,776                                  |

The first two rows use the first supplied coefficient draw; the other three use fitted point estimates. These are selected sensitivity comparisons, not a bootstrap distribution. Differences between rows can also reflect different women having both incomes recorded.

There are 465 women who enter marriage and 465 who leave marriage when caste terms are removed. The table excludes them; it does not assign a monetary value to remaining single. Since every man is matched in both allocations, reallocating this fixed set of husbands cannot change their total income. That accounting constraint is why a small overall average would not by itself establish a small individual sacrifice. It does not make Table 8's conditional regressions mechanically constant.

## A larger weighted bootstrap needs a supported prediction rule



We generated 250 fresh advertiser-bootstrap draws of both preference regressions, retaining the published letter weights and assigning a new advertiser fixed effect to each sampled copy. This produces 500 regression fits. In 134 fits, and 115 paired draws, at least one requested coefficient is not identified. The omitted terms concern both parties having missing caste information or both having missing age information. These terms are zero throughout the affected estimation samples, but vary across potential partners for some people in the full simulated market.

For example, women with unreported caste can rank 220 men with unreported caste against 7818 men with recorded caste. When the both-missing term is absent from a bootstrap estimation sample, changing its coefficient leaves every training fitted value unchanged but changes that comparison. It is therefore not merely an irrelevant common intercept.

We retain these coefficients as missing. We have not silently set them to zero, discarded the affected draws, or presented the remaining draws as the full weighted uncertainty distribution. This finding does not invalidate the reproduced shortlisting coefficients or establish a large financial sacrifice. It identifies a prediction rule that must be justified or tested before treating a larger weighted matching run as a well-defined income-cost interval. Options include explicit normalization sensitivity or a separately defined market restricted to supported profiles; either changes the scope of the result and must be reported.

Run `make simulation-income` for the five income comparisons and 250 weighted coefficient resamples. The target also runs the 500-imputation MAR analysis in both income specifications. Monetary comparisons use saved full-market allocations; the separate coefficient-resampling step audits support and does not claim 250 new weighted allocations.


## What the published conditional cost regressions estimate





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

A regression can be rank-deficient because a requested caste indicator has no independent variation after the controls. We check whether each requested coefficient is uniquely determined by the model matrix, rather than treating an omitted or normalized coefficient as a zero cost. Across these selected allocations and the two reporting populations, 12 published-cell coefficients are not identified. This count concerns the earlier selected runs. Frequencies across all 250 supplied draws follow below.


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


## Conditional cost regressions across all supplied draws



The reporting audit now covers all 500 original/corrected allocations, using the 250 supplied unweighted preference draws under each coding version. There were no regression execution errors. Some requested coefficients nevertheless lack independent variation and remain unidentified:


|Coding            |Population                | Completed draws| Identified income coefficients| Unidentified| Minimum N| Maximum N|
|:-----------------|:-------------------------|---------------:|------------------------------:|------------:|---------:|---------:|
|feature corrected |full market               |             250|                            246|            4|      1640|      1692|
|original          |full market               |             250|                            250|            0|      1648|      1692|
|feature corrected |verified interview subset |             250|                            135|          115|       111|       152|
|original          |verified interview subset |             250|                            143|          107|       114|       153|

This table concerns the same-caste coefficient in the paper's conditional groom-income regression. It compares different couples within each allocation. The MAR income analysis above instead follows the same women across allocations with and without caste terms, using weighted point estimates. These are different comparisons; the imputation ranges above do not replace Table 8's preference-draw uncertainty. Full generated coefficient summaries retain identified-draw counts beside their percentiles, rather than treating omitted coefficients as zero or presenting selected finite estimates as the complete published interval.

Run `make simulation-batch-costs RUN_DIRECTORY=output/simulation_runs/<run_hash>` to reproduce the reporting audit and export its summary and provenance. Detailed estimates remain under that run's `table8/` directory.
