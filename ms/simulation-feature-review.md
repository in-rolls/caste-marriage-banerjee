An independent review of the original Matlab feature construction and the Stata coefficient ordering found additional inconsistencies in the bride-side preference calculation. The R/C++ translation preserves these original expressions; the findings concern the handoff from estimated regressors to simulated preferences. Their effects on matching outcomes require separately labeled simulation runs. Correcting residence alone does not repair these other inconsistencies.

The coefficient order comes from the groom-search regression in [bootstrap_witherrors.do](../data/original/AEJMicro-2011-0182-Data/do/bootstrap_witherrors.do), line 54, followed by `e(b)` export in lines 55–59. Here “bride side” means the family seeking a groom. The main analysis defines the regressors in [Data_analysis.do](../data/original/AEJMicro-2011-0182-Data/do/Data_analysis.do), lines 376–398. The simulated features are in [algorithm_new.m](../data/original/AEJMicro-2011-0182-Data/matlab/algorithm_new.m), lines 73–88.

**Caste-rank signs are reversed on the bride side.** The Stata program defines `diffcaste = -(main_caste_rank_male - main_caste_rank_female)` at line 376. Lines 378–381 partition that signed distance into the man being above or below the woman. Matlab columns 9 and 10 instead use the unnegated male-minus-female rank difference. Columns 14 and 17 multiply the same reversed distance by the stated-caste-preference indicators.

For a known-rank woman coded 4 and a known-rank man coded 1, the estimated regressor `diff_above` is +3, while the current bride-side simulation feature is −3. The discrepancy affects the direction in which the estimated rank coefficients contribute to simulated preferences; it does not merely rename a category. The intended feature correction is to negate bride-side columns 9, 10, 14, and 17. The groom-side construction uses the correct signs because the candidate and chooser sexes reverse there.

**Missing-age and missing-height interactions are swapped on the bride side.** The estimated coefficient order includes `age_noage` then `noage_age`, and `height_noheight` then `noheight_height`. The main Stata definitions are:

```text
age_noage       = age_female * noage_male       (line 394)
noage_age       = noage_female * age_male       (line 395)
height_noheight = height_female * noheight_male (line 397)
noheight_height = noheight_female * height_male (line 398)
```

Matlab columns 19/20 and 25/26 contain these pairs in the opposite order for bride-side choices. Consider a woman whose known age is 27 and known height is 1.6 meters, and a man whose age and height are missing, with the stored values zero and missing flags one:

| Feature in coefficient order | Regression requires | Current bride-side feature |
|:--|--:|--:|
| `age_noage` | 27 | 0 |
| `noage_age` | 0 | 27 |
| `height_noheight` | 1.6 | 0 |
| `noheight_height` | 0 | 1.6 |

The intended correction swaps bride-side columns 19 with 20, and 25 with 26. The groom-side missing-attribute expressions agree with the regression definitions. These examples were checked by evaluating the translated feature function on synthetic profiles and comparing its values to the original Stata formulas; they are not estimated behavioral effects.

**The no-caste counterfactual is translated consistently.** In [algorithm_nocaste_new.m](../data/original/AEJMicro-2011-0182-Data/matlab/algorithm_nocaste_new.m), line 24 initializes the feature matrix to zero, and the subsequent construction leaves caste-related columns 1–18 at zero. The same pattern holds on the groom side. Keeping the feature matrix and setting coefficient positions 1–18 to zero is algebraically equivalent. It removes broad caste-category terms, the own-caste term, rank-distance terms, and their stated-preference and missing-caste interactions. It is broader than removing only the own-caste coefficient.

**A suspected Calcutta mismatch was rejected.** The interview advertisement codes Calcutta as residence category 1, while the all-advertisement/Matlab input codes it as category 2. The latter's existing `calcutta` field verifies that mapping. Therefore Matlab's `resstatus == 2` Calcutta feature is consistent with the input coding. It should not be changed to 1 just because the estimation dataset uses 1.

**Attribute changes support a limited individual comparison.** [simulation_summarize.R](../src/simulation_summarize.R), lines 72–83, follows women matched in both allocations, then requires both simulated husbands' education or income to be observed for the corresponding comparison. These checks prevent treating an encoded missing log income of zero as an actual income of one rupee. Reported income is monthly under the article's data appendix; education categories are not years of schooling.

The resulting signed and absolute changes can demonstrate that similar average matching statistics coexist with substantially different partners. They do not measure WTP, utility losses, dowry compensation, or the experience of women entering or leaving the matched set. There is an additional accounting issue with aggregate means: every man is matched in this complete-list market, so redistributing a fixed set of men cannot change their total income or education. A near-zero average husband-attribute change therefore is not itself evidence of low welfare cost. The common-women/known-attribute restriction can make the reported subset mean change nonzero, but does not turn it into aggregate welfare.

The recovered interview subset is incomplete, and its couple composition changes when different women become matched. Its moments must remain labeled as a conservative subset comparison rather than an exact reconstruction of the publication's Table 6. This review did not rerun the full market or establish native Matlab floating-point equivalence. The existing small-market tests check the R/C++ implementation against each other and known matching examples; that agreement cannot detect an inconsistency inherited by both translations from the original feature construction.
