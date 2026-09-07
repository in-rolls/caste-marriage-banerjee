# The groom-income model does not have the bride model’s normalization problem

The simplified groom-income model underlying the **49% outside-caste income premium passes this specific check**. Its earnings regression has 14 columns and rank 14, with no aliased coefficients. Every income prediction used in the subsequent shortlisting regression is uniquely determined by that fitted linear model. The bride model’s arbitrary normalization does not carry over to this estimate.

| Quantity | Groom-income model |
|---|---:|
| Usable reported-earnings letters | 1,929 |
| Advertisers contributing those letters | 476 |
| Earnings design columns / rank | 14 / 14 |
| Letters used in the shortlisting regression | 5,629 |
| Advertisers in the shortlisting regression | 506 |
| Downstream predictions outside the earnings design’s linear span | 0 |
| Aliased earnings coefficients | 0 |

The source model starts with 5,635 candidate letters. Of these, 1,930 are flagged as reporting income, but one has a missing logged income; 1,929 enter the earnings regression. The final preference regression uses 5,629 letters. These are the actual fitted samples, rather than counts inferred from an overall study description.

The [original Stata program](../data/original/AEJMicro-2011-0182-Data/do/Data_analysis.do#L524) estimates the groom earnings equation and then uses its predictions in the advertiser-effects shortlisting equation. We checked the corresponding fitted R matrices directly. An independent singular-value decomposition of the weighted earnings design confirms full rank. Projecting all 5,629 downstream profiles onto its row span leaves a maximum numerical discrepancy of 4.4 × 10⁻¹⁵. Reversing the order of all earnings regressors and refitting changes the downstream predictions by at most 8.9 × 10⁻¹⁴ log-income units. There is therefore no alternative alias normalization to investigate in this fit.

The same-caste and predicted-log-income coefficients remain 0.13954 and 0.34780. Their ratio implies an outside-caste predicted-income premium of **49.37%**, or about **33.05% less predicted income** for the same-caste alternative, for the specification’s reference caste-preference category and fixed caste-distance terms. Neither the point estimate nor its previously reported uncertainty needs revision because of the bride-income finding. No new bootstrap was required for this algebraic check.

Passing this check establishes that the linear prediction is numerically identified. It does not establish overlap in the stronger sense of every profile having a close observed-earnings counterpart, or that people who report earnings represent those who do not. The existing qualifications still apply: this is a model-implied tradeoff when shortlisting letters, relies on the earnings equation and preference specification, and is not observed income sacrificed in completed marriages. Full comparisons between particular castes must also include the caste-distance terms; the 49% figure is not a universal penalty for marrying someone from any lower caste.

Reproduce with `Rscript src/groom_income_support.R` and verify with `Rscript tests/test_groom_income_support.R`. The [saved counts and numerical checks](../output/groom_income_support_counts.csv) include all samples and the exact point estimate. All ten assertions pass, and both new R files are lint-clean.
