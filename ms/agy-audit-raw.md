# Independent Audit of Empirical Replication and Criticism

**Audit Repositories and Baselines Audited:**
- [for-better-or-caste](file:///Users/soodoku/Documents/GitHub/for-better-or-caste) at commit `09ecc2b` (Banerjee, Duflo, Ghatak, & Lafortune, *AEJ: Microeconomics* 2013)
- [well-actually](file:///Users/soodoku/Documents/GitHub/well-actually) at commit `db9e7a2` (Anderson, *AEJ: Applied Economics* 2011)

**Auditor Execution Disclaimer:**
This audit was conducted entirely in a **read-only inspection mode** using file-reading and search tools. **No computations, scripts, terminal commands, git commands, market simulations, or bootstraps were executed by this auditor.** All analytical statements, code evaluations, matrix mappings, and coefficient checks are based on direct verification of the original published articles, authors' replication archives, Stata and Matlab source programs, replicators' R/C++ codebases, test suites, and saved numerical outputs.

---

## Executive Summary & Verdict

Both replication efforts achieve an exceptional standard of computational reproduction: **all 28 displayed caste regression coefficients in the marriage paper and all 54 displayed coefficient/SE pairs across Tables 3–5 in the water paper reproduce within rounding tolerance**. Furthermore, both replication teams successfully uncovered critical implementation errors, inference issues, and reporting discrepancies that slipped past original peer review.

However, applying the exact same rigorous methodological standard to the replicators as to the authors reveals important nuances:
1. **Marriage Paper:** The replicators conclusively confirm four serious programming and handoff defects in the authors' archive (omitted bootstrap weights, reversed caste-rank signs, swapped missing-attribute interactions, and miscoded residence features affecting 1.68 million candidate pairs). Crucially, however, the replicators' sensitivity simulations establish that **none of these errors explain away the model's excessive simulated endogamy (93% simulated vs. 69% observed)**. The misfit is an inherent consequence of applying frictionless Gale–Shapley stable matching to initial shortlisting preferences. In addition, the paper's claim that caste carries "zero economic price" in equilibrium (Table 8) is invalid because its simulation confidence intervals (e.g., spanning $\pm$₹75,000/month) are far too broad to rule out large costs.
2. **Water Paper:** The authors' core claim that caste barriers in groundwater trade cause a "45% yield gap" is fundamentally compromised. First, the outcome is crop sales revenue per owned acre (with 61.4% zeros and 26.6% landless households), not physical yield or profit. Second, the "45%" figure has no producing code and appears to be an invalid quotient of a per-acre regression coefficient (₹850.9/acre) divided by mean household total sales (₹1,891.6/household). Third, the claim that the advantage is specific to water buyers relies on the classic textbook fallacy of comparing significant vs. non-significant coefficients: the direct contrast between buyers and pump owners has $p = 0.454$ (95% CI: [−₹758, +₹1,683]). Fourth, the 2SLS IV estimate is fragile: a full-procedure village pairs bootstrap re-estimating all stages yields a 95% percentile interval crossing zero ([−₹395, +₹8,982]), and the IV instruments (village area and natural water) plausibly violate the exclusion restriction.

---

## Severity-Ranked Findings

### Critical Severity (Invalidates Central Substantive Claims or Core Estimands)

#### [Finding W-1] The Difference Between "Significant" and "Not Significant" Fallacy in the Water Buyer vs. Owner Contrast
- **Repository / Files:** [well-actually/ms/review.md:L55-L62](file:///Users/soodoku/Documents/GitHub/well-actually/ms/review.md#L55-L62), [well-actually/output/water_contrasts.csv:L4](file:///Users/soodoku/Documents/GitHub/well-actually/output/water_contrasts.csv#L4), [well-actually/sources/paper.txt:L574-L580](file:///Users/soodoku/Documents/GitHub/well-actually/sources/paper.txt#L574-L580)
- **Original Paper Defect:** Anderson (2011, pp. 250, 260–261) argues that the village caste dominance effect operates specifically through groundwater trade because the water-buyer interaction in Table 4(2) is statistically significant ($\hat{\beta} = 850.9$, $\text{SE} = 275.0$, $p = 0.0026$), whereas the tubewell-owner interaction is not ($\hat{\beta} = 388.5$, $\text{SE} = 500.4$, $p = 0.439$). This is the classic inferential error documented by Gelman and Stern (2006): comparing significance levels rather than testing the direct contrast.
- **Audit Verification:** The direct difference between the buyer and owner interactions is ₹462.41 ($\text{SE} = 614.23$, $t = 0.75$, $p = 0.454$). The 95% confidence interval spans from **−₹758.04 to +₹1,682.87**. 
- **Effect on Interpretation:** The data completely fail to establish that water buyers benefit differently from tubewell owners. Because only 13%–24% of the sample own pumps, the owner interaction has high standard errors; its point estimate in Columns (4) and (5) reaches +₹773 and +₹655 (comparable to buyers' +₹981 and +₹902). The paper's claim that other village-wide mechanisms (such as land quality or general infrastructure) are ruled out because owners do not benefit is unsupported.

#### [Finding W-2] Outcome Mischaracterization and Dimensional Incoherence of the Headline "45% Yield" Claim
- **Repository / Files:** [well-actually/sources/paper.txt:L17,L115,L796](file:///Users/soodoku/Documents/GitHub/well-actually/sources/paper.txt#L17), [well-actually/data/original/program.txt](file:///Users/soodoku/Documents/GitHub/well-actually/data/original/program.txt), [well-actually/output/published_descriptive_comparison.csv:L182,L200](file:///Users/soodoku/Documents/GitHub/well-actually/output/published_descriptive_comparison.csv#L182)
- **Original Paper Defect:** The paper repeatedly asserts in the abstract, introduction, and text (p. 253) that lower-caste water buyers have agricultural yields that are "45 percent higher" in lower-caste dominated villages. 
- **Audit Verification:** 
  1. *Construct Mismatch:* The regression dependent variable `cropincacre` is **annual crop sales revenue per owned acre**. It explicitly excludes crops consumed by the household and does not measure physical output per cultivated acre or net agricultural profit. In the regression sample ($N = 1,295$), **795 households (61.4%) have zero recorded sales**, and **345 households (26.6%) own zero land**.
  2. *Missing Denominator & Dimensional Error:* There is no line of code in the author's Stata code (`program.txt`) computing 45%. Tracing the descriptive statistics reveals that the Table 4(2) interaction coefficient is **₹850.936/acre**, while the Table 2 mean of total household crop income (`cropinc`) in high-caste villages is **₹1,891.613/household**. The ratio is:
  $$\frac{850.936}{1891.613} = 0.44985 \approx 45.0\%$$
  This matches 45.0% to four significant digits. If this was the calculation, it divides rupees per acre by rupees per household—a dimensional error. If calculated as total buyer village contrast (−88.0 + 850.9 = ₹763.0/acre) over mean buyer sales in high-caste villages (₹492.2/acre), the increase would be 155%. The 45% headline is ungrounded.

#### [Finding M-1] Fallacious "Zero Economic Price of Caste" Conclusion from Severe Structural Imprecision (Table 8)
- **Repository / Files:** [for-better-or-caste/sources/paper.txt:L2150-L2166,L2197-L2232](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/sources/paper.txt#L2150-L2166), [for-better-or-caste/ms/review.md:L56-L60](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/ms/review.md#L56-L60)
- **Original Paper Defect:** Banerjee et al. (2013, pp. 69–70) estimate the equilibrium price of caste by regressing partner attributes in simulated matches on indicators for marrying within or above caste (relative to marrying below caste). Because point estimates are small and insignificant, the authors conclude: *"This suggests that the price of keeping caste is zero, consistent with the model in the case where preferences are horizontal, and there is balance in terms of quality."*
- **Audit Verification:** The reported 2.5–97.5 percentile intervals across simulation draws in Table 8 are astronomically wide:
  - Male income for marrying within caste: $\hat{\beta} = ₹1,755.83$, with a 95% interval of **[−₹75,943.67, +₹54,369.01]**.
  - Male education: $\hat{\beta} = 0.0011$ categories, with an interval of **[−1.8724, +1.8661]**.
- **Effect on Interpretation:** The authors commit the elementary error of treating failure to reject zero under massive imprecision as evidence of a zero effect. Because simulated matches produce 93% endogamy, out-of-caste matches (and lower-caste matches in particular) are extremely sparse, leaving the reference category practically unpopulated and causing simulation draw coefficients to swing wildly across $\pm$₹75,000/month (in a population where median monthly income is $\approx$₹10,000). The simulation intervals cannot rule out enormous economic costs.

#### [Finding W-3] Failure of the 2SLS IV Estimand Under Full-Procedure Resampling and Direct-Effect Violations
- **Repository / Files:** [well-actually/sources/paper.txt:L648-L670](file:///Users/soodoku/Documents/GitHub/well-actually/sources/paper.txt#L648-L670), [well-actually/output/iv_lal_bootstrap_summary.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/iv_lal_bootstrap_summary.csv), [well-actually/output/iv_exclusion_thresholds.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/iv_exclusion_thresholds.csv)
- **Original Paper Defect:** The author instruments for two endogenous regressors (`buywater` and `dlbuywater` = `domlow` $\times$ `buywater`) using generated regressors (`bwx` and `dlbwx` = `domlow` $\times$ `bwx`), where `bwx` is predicted from village area and natural water access. In Table 5, the IV interaction is ₹3,519.51 ($\text{SE} = 1,413.72$, $p = 0.0128$), reported as robust causal validation.
- **Audit Verification:** 
  1. *Inference Breakdown:* In a paired village cluster bootstrap ($B = 1,999$) that repeats all preliminary prediction stages, the 95% percentile interval for the interaction is **[−₹395.01, +₹8,981.77]**, crossing zero. The paired difference between IV and OLS ($\hat{\beta}_{\text{IV}} - \hat{\beta}_{\text{OLS}} = ₹2,605.13$) has a 95% percentile interval of **[−₹1,203.56, +₹7,833.12]**, indicating that IV is not statistically distinguishable from OLS.
  2. *Exclusion Restriction Incoherence:* Village area and natural water (rivers, canals, lakes) directly affect crop yields and sales for reasons entirely unrelated to private tubewell transactions. Furthermore, applying Mellon's (2024) directional diagnostic demonstrates that if natural water has a plausible positive direct effect on crop revenue (+₹500/acre), subtracting that pathway **increases** the IV interaction point estimate to ₹4,003. To attenuate the estimate to zero, natural water would have to exert an absurd negative direct effect of −₹3,638/acre.

---

### High Severity (Material Implementation Bugs, Missing Archive Data, and Inference Failures)

#### [Finding M-2] Four Confirmed Implementation Defects in the Authors' Matching Simulation Handoff
- **Repository / Files:** 
  - `algorithm_new.m:L73-L88,L207-L210` ([original matlab](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/data/original/AEJMicro-2011-0182-Data/matlab/algorithm_new.m#L73-L88))
  - `correlations_results.do:L1` ([original do](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/data/original/AEJMicro-2011-0182-Data/do/correlations_results.do#L1))
  - `bootstrap_witherrors.do:L10,L29,L54` ([original do](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/data/original/AEJMicro-2011-0182-Data/do/bootstrap_witherrors.do#L10))
  - `for-better-or-caste/ms/simulation-feature-review.md` ([feature review](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/ms/simulation-feature-review.md))
- **Audit Verification:** Direct inspection confirms four distinct coding/handoff bugs in the original archive:
  1. *Miscoded Residence Feature:* In `algorithm_new.m` line 207, male preference calculation sets:
     `V(:,48)=(V(:,49)~=1 & fem_j(:,13)~=1).*(fem_j(:,12)==J(:,3));`
     `fem_j(:,13)` is `family_origin_male` (tested as if it were a missingness flag); `fem_j(:,12)` is `nores_male` (compared to `J(:,3)` = `resstatus_female`). It compares the missing-residence flag to the woman's residence category instead of comparing residence to residence. This corrupted **1,678,947 candidate pairs** (1.47% of all pairs) and altered **2,190 matches (27.25%)** in Draw 1.
  2. *Quality Index Operator Precedence Bug:* In `correlations_results.do`, Stata evaluates expressions like `(-0.1749361*edu_max==2)`. In Stata, `*` takes precedence over `==`, so it tests whether $(-0.1749361 \times \text{edu\_max}) == 2$, which is never true for integer education categories. Education terms were completely zeroed out of the quality index for **6,085 men and 12,414 women**.
  3. *Reversed Bride-Side Caste-Rank Signs & Swapped Missing Interactions:* In `Data_analysis.do` line 376, `diffcaste` is defined as $-( \text{rank\_male} - \text{rank\_female} )$. In `algorithm_new.m` lines 73–74, columns 9 and 10 use the unnegated difference, reversing the signs of `diff_above` and `diff_below` and their stated-preference interactions (cols 14, 17). Additionally, bride-side missing-age interactions (cols 19/20: `age_noage` vs. `noage_age`) and missing-height interactions (cols 25/26: `height_noheight` vs. `noheight_height`) are swapped relative to the regression coefficient export order.
  4. *Omitted Sampling Weights in Simulation Bootstrap:* `Data_analysis.do` lines 446 and 506 estimate consideration regressions using sampling weights `[aw=weight]`. In `bootstrap_witherrors.do` lines 10, 29, and 54, the weights are omitted. The unweighted same-caste coefficients exported to Matlab are $\approx$20% higher (0.1589 and 0.1986) than the published weighted coefficients (0.1317 and 0.1707).

#### [Finding W-4] Non-Clustered Hypothesis Testing in Table 2 Descriptive Statistics
- **Repository / Files:** [well-actually/data/original/program.txt:L34-L53](file:///Users/soodoku/Documents/GitHub/well-actually/data/original/program.txt#L34-L53), [well-actually/ms/review.md:L38-L54](file:///Users/soodoku/Documents/GitHub/well-actually/ms/review.md#L38-L54)
- **Original Paper Defect:** The author uses standard two-sample $t$-tests (`ttest ..., by(domhigh)`) for all Table 2 household comparisons, treating households within the same village as independent even though village dominance varies only across villages.
- **Audit Verification:** Re-estimating the exact Table 2 differences with village-clustered standard errors and degrees of freedom ($G - 1 = 89$):
  - *Share of land irrigated:* difference +6.33 pp; published $p = 0.0020 \rightarrow$ clustered **$p = 0.260$**.
  - *Tubewell irrigation:* difference +5.95 pp; published $p = 0.0311 \rightarrow$ clustered **$p = 0.413$**.
  - *Buys water:* difference +7.70 pp; published $p = 0.0102 \rightarrow$ clustered **$p = 0.232$**.
  - *Owns a pump:* difference +10.57 pp; published $p = 0.000046 \rightarrow$ clustered **$p = 0.0118$**.
- **Effect on Interpretation:** Three of the four direct irrigation differences relied upon on p. 249 lose statistical significance when clustering is accounted for. Only pump ownership survives clustering.

#### [Finding M-3] Missing Linkage File in the ICPSR Replication Archive
- **Repository / Files:** [for-better-or-caste/ms/review.md:L48](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/ms/review.md#L48), [for-better-or-caste/ms/simulation-crosswalk.md](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/ms/simulation-crosswalk.md), `data/id_mailbox` calls in `correlations_results*.do`
- **Original Archive Defect:** All original Stata scripts that compute simulated matching moments for Table 6 (`correlations_results.do`, `correlations_results_nocaste.do`, etc.) merge simulation outputs against `data/id_mailbox` to identify which simulated agents correspond to survey interview participants. **`data/id_mailbox.dta` was completely omitted from the ICPSR 114406 archive.**
- **Audit Verification:** The replicator constructed a conservative partial crosswalk from `allads_AEJ.dta`, successfully recovering 736 of 783 distinct interviewed advertisers (259 men, 477 women) with verified attributes, while identifying 4 ambiguous IDs and 9 sex conflicts. Without this reconstruction, Table 6 cannot be evaluated on its intended sample.

---

### Moderate Severity (Reporting Errors, Sample Discrepancies, and Bound Limitations)

#### [Finding W-5] Inaccurate Sample Sizes Reported Across Published Tables
- **Repository / Files:** [well-actually/ms/review.md:L67-L74](file:///Users/soodoku/Documents/GitHub/well-actually/ms/review.md#L67-L74), [well-actually/output/published_sample_comparison.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/published_sample_comparison.csv)
- **Original Paper Defect:** Tables 3(4), 3(6), and 4(4) print sample sizes of $N = 1,295$, creating the impression that complete-case comparability is maintained as controls are added.
- **Audit Verification:** Due to missing values in distance and public goods controls:
  - Table 3(4) (distance controls) actually uses **$N = 1,127$ households in 80 villages**.
  - Table 3(6) (public goods controls) actually uses **$N = 1,122$ households in 78 villages**.
  - Table 4(4) (water interactions + distance) actually uses **$N = 1,127$ households in 80 villages**.
- **Effect on Interpretation:** Comparing coefficients across columns confounds covariate adjustment with sample attrition. On the 78-village complete-case sample, the baseline coefficient is already ₹287.05 before adding public goods; adding them increases it to ₹371.27.

#### [Finding M-4] Table 6 Fit Metric Miscounting in Published Text
- **Repository / Files:** [for-better-or-caste/sources/paper.txt:L1956-L1967](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/sources/paper.txt#L1956-L1967), [for-better-or-caste/output/published_matching_fit.csv](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/published_matching_fit.csv)
- **Original Paper Defect:** The text asserts that for Table 6 (no-friction matches), the observed marriage point estimate falls within the simulation interval in **14 of 21 cases**, and the 95% intervals overlap in **15 of 21 cases**.
- **Audit Verification:** Direct counting of the printed table entries reveals that the observed point estimate falls inside the simulation interval in only **12 of 21 cases**, and intervals overlap in only **14 of 21 cases**. Beyond this minor counting discrepancy, the substantive misfits are severe: simulated height correlation is 0.86 vs. 0.39 observed; family origin correlation is 1.00 vs. 0.51 observed; and same-caste marriage is 0.93 vs. 0.69 observed.

#### [Finding W-6] Unverifiability of the Dominance Cutoff from Archive Limitations
- **Repository / Files:** [well-actually/ms/magnitude-benchmarks.md:L31-L40](file:///Users/soodoku/Documents/GitHub/well-actually/ms/magnitude-benchmarks.md#L31-L40), [well-actually/ms/raw-survey-followup.md](file:///Users/soodoku/Documents/GitHub/well-actually/ms/raw-survey-followup.md)
- **Audit Verification:** Anderson defines caste dominance as a caste owning $>50\%$ of village land. However, the survey questionnaire (Section 1A, Q7) only records caste ranks by total land owned (rank 1, rank 2, etc.), not land percentages. Furthermore, the replication archive provides only the binary indicator `domlow`; it contains no continuous land shares, no caste land totals, and no code generating `domlow`. Consequently, neither the author nor the replicators can test sensitivity to alternative thresholds (e.g., 40% or 60%) or evaluate a continuous specification.

#### [Finding W-7] Published Table 2 Descriptive Errata
- **Repository / Files:** [well-actually/output/published_descriptive_comparison.csv:L248-L253](file:///Users/soodoku/Documents/GitHub/well-actually/output/published_descriptive_comparison.csv#L248-L253)
- **Audit Verification:** Table 2 reports standard deviations for `landlord` as 0.02 (high-caste) and 0.01 (low-caste); the data yield **0.280 and 0.251**. The printed difference (+0.02) has the opposite sign to low minus high (0.0673 − 0.0851 = **−0.0178**).

---

### Low Severity & Rejected Criticisms

#### [Finding M-5] Rejected Critique: Coding Typo in Same-Caste Construction
- **Repository / Files:** [for-better-or-caste/ms/review.md:L30](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/ms/review.md#L30), [for-better-or-caste/output/caste_typo_impact.csv](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/caste_typo_impact.csv)
- **Audit Verification:** In `Data_analysis.do`, an apparent logical conjunction typo (`caste_male==17 & caste_male==100`) occurs in a subcaste equivalence check. The replicator explicitly tested the impact of correcting this typo: it changes exactly **0 candidate pairs** in both main regression samples ($N = 5,628$ and $N = 3,944$). The replicator correctly rejected this as a substantive criticism.

#### [Finding W-8] Minor Table Reporting Tolerances
- **Repository / Files:** [well-actually/ms/review.md:L75](file:///Users/soodoku/Documents/GitHub/well-actually/ms/review.md#L75)
- **Audit Verification:** Rows labeled "Adjusted $R^2$" in Tables 3 and 4 report ordinary $R^2$ (e.g., Table 3(2) prints 0.28, which matches ordinary $R^2 = 0.2792$; adjusted $R^2$ is 0.2626). These are non-substantive labeling oversights.

---

## Detailed Audit: Marriage Simulation & Structural Identification

### 1. Tracing Feature Signs, Missingness Swaps, and Weights
The handoff from the Stata estimation regressions to the Matlab simulation algorithm contains multiple severe structural discrepancies:

```
[Stata Estimation: Data_analysis.do]
  - Lines 376-381: diffcaste = -(rank_male - rank_female)
                   diff_above = diffcaste * (rank_male < rank_female)  [POSITIVE when male is higher caste]
                   diff_below = diffcaste * (rank_male > rank_female)  [NEGATIVE when male is lower caste]
  - Lines 394-398: Regressor order in bootstrap_witherrors.do:
                   Col 19: age_noage (age_fem * noage_male)
                   Col 20: noage_age (noage_fem * age_male)
                   Col 25: height_noheight (ht_fem * noht_male)
                   Col 26: noheight_height (noht_fem * ht_male)
  - Lines 446, 506: areg considered ... [aw=weight]  [SAMPLING WEIGHTS APPLIED]

                       │
      HANDOFF MISMATCH │ (bootstrap_witherrors.do & algorithm_new.m)
                       ▼

[Matlab Simulation: algorithm_new.m]
  - Lines 73-74:   V(:,9)  = (rank_male - rank_fem) .* (rank_male < rank_fem)  [NEGATIVE: SIGN REVERSED]
                   V(:,10) = (rank_male - rank_fem) .* (rank_male > rank_fem)  [POSITIVE: SIGN REVERSED]
  - Lines 77, 80:  V(:,14) & V(:,17) multiply reversed ranks by stated preferences [SIGNS REVERSED]
  - Lines 82-88:   V(:,19) = noage_fem * age_male      [SWAPPED: matches Regressor Col 20]
                   V(:,20) = noage_male * age_fem      [SWAPPED: matches Regressor Col 19]
                   V(:,25) = noht_fem * ht_male        [SWAPPED: matches Regressor Col 26]
                   V(:,26) = noht_male * ht_fem        [SWAPPED: matches Regressor Col 25]
  - Line 207:      V(:,48) compares nores_male == resstatus_fem & checks family_origin_male ~= 1
  - Bootstrap:     bootstrap_witherrors.do omits [aw=weight] (unweighted coefficients used)
```

### 2. Comparison Sample Construction & Table 6 Evaluation
In Table 6, Panel A reports simulated moments, while Panel B reports observed moments:
- **Observed Matches Sample:** In the follow-up survey, only 346 advertisers reported a marriage/engagement, and spouse characteristics are available for **$N = 289$ couples**.
- **Simulated Moments Sample:** In the original `correlations_results.do`, the simulation moments are not computed on the full market ($N = 8,038$ couples), but on the subset of couples where at least one member was an interview participant (`sample == 1 | sample_female == 1`). 
- Because `data/id_mailbox` was missing from the archive, the replicator's crosswalk recovers 736 verified interview participants, yielding **544 to 546 matched couples** in the simulation allocations.

### 3. Do Selected Corrections Legitimately Inform the 93% vs. 69% Fit?
A central question is whether the coding errors uncovered by the replicators explain the model's failure to match observed endogamy (predicting 93% same-caste marriages vs. 69% in actual marriages). 

The replicator's sensitivity allocations provide a decisive, rigorous answer:

| Simulation Allocation Scenario | Evaluated Sample | Simulated Same-Caste Rate | Matched Couples ($N$) |
|:---|:---|:---:|:---:|
| **Published Table 6 (Panel A, no frictions)** | Stata `sample == 1 \| sample_fem == 1` | **93.0%** (interval: 83%–99%) | $\approx 550$ |
| **Published Table 6 (Panel B, observed)** | Follow-up actual marriages | **69.0%** (interval: 64%–75%) | **289** |
| Draw 1: Original archive code | Verified interview subset | 90.29% | 546 |
| Draw 1: Residence feature corrected | Verified interview subset | 90.35% | 549 |
| Draw 1: Residence feature corrected | Full market ($N = 8,038$) | 89.67% | 8,038 |
| Point Estimates: Unweighted (Draw 0) | Verified interview subset | 92.28% | 544 |
| Point Estimates: Weighted (Draw 0) | Verified interview subset | 91.73% | 544 |
| Point Estimates: Weighted + Handoff Repaired | Verified interview subset | **93.39%** | 545 |
| Point Estimates: Weighted + Handoff Repaired | Full market ($N = 8,038$) | **93.32%** | 8,038 |

**Definitive Conclusion on Model Fit:**
**The selected corrections do NOT explain away the 93% vs. 69% misfit.** When all identified errors (residence column references, bride-side rank signs, swapped missing-attribute interactions, and regression sampling weights) are corrected simultaneously, the simulated same-caste marriage rate is **93.39%** (interview subset) and **93.32%** (full market)—virtually identical to the published 93.0% prediction.
- *Mechanism:* In a matching market with 8,038 men and 14,172 women, the estimated same-caste preference ($\hat{\beta} \approx 0.13 - 0.17$ on a shortlist baseline of 0.08–0.34) is so dominant relative to other attributes that Gale–Shapley stable matching clears the market with almost complete caste segregation.
- The 93% vs. 69% gap is an intrinsic failure of frictionless equilibrium matching applied to shortlisting preferences, not an artifact of coding defects.

### 4. Identification of Economic Sacrifice vs. Matching Reallocations
The review correctly untangles three distinct concepts that are easily conflated:
1. **Shortlisting Tradeoff ($\text{WTP}_{\text{shortlist}}$):** In the simplified groom-income specification, the same-caste coefficient (0.1395) divided by the log income coefficient (0.3478) implies a 49.4% outside-caste premium (or a 33.1% same-caste discount). This is a linear conversion of initial letter screening by relatives; it is not money knowingly paid or surrendered in completed marriages.
2. **Equilibrium Matching Reallocations:** In the counterfactual simulation where caste preferences are zeroed out:
   - 97.5% of men change partners.
   - For women matched under both regimes with husband income reported ($N = 410$), the mean income change is −₹176/month, while the **mean absolute change is ₹19,809/month** (median absolute change: ₹4,250/month).
3. **The Mechanical Accounting Identity:** The replicator correctly recognizes a crucial methodological limitation of their own aggregate attribute diagnostic ([simulation-audit.md:L83](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/ms/simulation-audit.md#L83)): in a complete-list market where all 8,038 men are matched, **reallocating husbands across wives cannot change the total or average income of married men across the population**. Total male income is a fixed accounting invariant. Therefore, a near-zero average attribute change across the entire market cannot be cited as evidence of low welfare cost, just as churning partners cannot prove a large welfare loss.

---

## Detailed Audit: Water Paper & Econometric Identification

### 1. The Dominance Classification and Alleged Placebos
The prompt instructs an audit of the dominance classification and "alleged placebos." The findings here demonstrate exceptional methodological discipline by the replicators:
- **Dominance Definition:** Anderson categorizes villages into binary low-caste vs. high-caste dominance based on whether lower castes own $>50\%$ of village land. However, the survey instruments record only land ownership ordinal ranks, not continuous land shares, and the replication archive provides only the binary dummy `domlow`.
- **Alleged Placebos Refuted:** In empirical economics, researchers often examine historical variables (e.g., 1991 Census literacy, pre-reform infrastructure) or unaffected groups (e.g., pump owners who do not buy water) as "placebo checks." 
- The replicators ([water-balance.md:L56,L75](file:///Users/soodoku/Documents/GitHub/well-actually/ms/water-balance.md#L56)) explicitly **refuse to call these placebos**:
  1. Caste dominance in North Indian villages is an institution centuries old, not a treatment newly assigned between 1991 and 1997. If 1991 literacy or infrastructure differed between village types, that could easily be an accumulated consequence of longstanding dominance rather than evidence of confounding.
  2. Pump owners participate directly in groundwater markets as sellers and face endogenous investment decisions; they cannot be assumed to be an unaffected control group.
  3. Household land ownership cannot be an unaffected placebo because land ownership is the exact basis of caste dominance.

### 2. Statistical Inference and Bootstrap Sensitivity
The table below summarizes the econometric sensitivity of the focal estimates in Anderson (2011):

| Model Specification | Parameter / Contrast | Published / OLS Convention | Clustered / Re-estimated Convention | Full-Procedure Bootstrap (95% CI) | Audit Verdict |
|:---|:---|:---:|:---:|:---:|:---|
| Table 2: Share Land Irrigated | Mean diff (Low − High) | $+6.33$ pp ($p = 0.0020^{***}$) | $+6.33$ pp ($p = 0.260$) | N/A | **Fragile:** Loses significance under village clustering |
| Table 2: Tubewell Irrigation | Mean diff (Low − High) | $+5.95$ pp ($p = 0.0311^{**}$) | $+5.95$ pp ($p = 0.413$) | N/A | **Fragile:** Loses significance under village clustering |
| Table 2: Buys Water | Mean diff (Low − High) | $+7.70$ pp ($p = 0.0102^{**}$) | $+7.70$ pp ($p = 0.232$) | N/A | **Fragile:** Loses significance under village clustering |
| Table 2: Owns Pump | Mean diff (Low − High) | $+10.57$ pp ($p = 0.00005^{***}$) | $+10.57$ pp ($p = 0.0118^{**}$) | N/A | **Robust:** Survives village clustering |
| Table 4(2): LCV $\times$ Buyer | Interaction ($\hat{\beta}$) | ₹850.9 ($\text{SE} = 275.0$, $p = 0.0026$) | ₹850.9 (Wild boot $p = 0.0014$) | Leave-one-out range: [₹697, ₹903] | **Robust:** Survives wild cluster boot & deletions |
| Table 4(2): Buyer vs. Owner | Contrast ($\hat{\beta}_{\text{buyer}} - \hat{\beta}_{\text{owner}}$) | *Not reported by author* | ₹462.4 ($\text{SE} = 614.2$, $p = 0.454$) | 95% CI: [−₹758, +₹1,683] | **Fatal Flaw:** Buyer specificity is unproven |
| Table 5: IV LCV $\times$ Buyer | 2SLS Interaction | ₹3,519.5 ($\text{SE} = 1,413.7$, $p = 0.0128$) | Asymptotic 95% CI: [₹749, ₹6,290] | **Percentile:** [−₹395, +₹8,982]<br>**Studentized:** [+₹1,529, +₹10,447] | **Sensitive:** Percentile interval crosses zero |
| Table 5: IV vs. OLS Difference | Contrast ($\hat{\beta}_{\text{IV}} - \hat{\beta}_{\text{OLS}}$) | *Not reported by author* | ₹2,605.1 ($\text{SE} = 1,443.0$) | **Percentile:** [−₹1,204, +₹7,833] | **Inconclusive:** IV not statistically different from OLS |

---

## Criticisms of Our Critique (Self-Auditing the Replicators)

Applying the same rigorous scrutiny to the replicators exposes four areas where their critique must be qualified, guarded against overreach, or stated with greater precision:

1. **Overstating the Implication of the Buyer-Minus-Owner Contrast ($p = 0.454$):**
   While the replicator is 100% correct that Anderson committed the Gelman–Stern fallacy, the replicator's summary table highlights "$p = 0.454$" in a manner that casual readers might interpret as proving that buyers and owners experience identical outcomes. Because the sample contains few pump owners ($N = 186$ across 90 villages), the standard error of the owner interaction is massive ($\text{SE} = 500.4$). The resulting 95% CI for the difference spans from **−₹758 to +₹1,683**. Failure to reject zero difference is a lack of power; it does not affirmatively demonstrate that the village effect is shared equally by owners.
2. **Asymmetric Emphasis on the IV Percentile vs. Studentized Bootstrap:**
   In [well-actually/README.md:L35](file:///Users/soodoku/Documents/GitHub/well-actually/README.md#L35), the headline table reports only the IV percentile interval ([−₹395, +₹8,982]), which crosses zero. However, as documented in [iv_lal_bootstrap_summary.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/iv_lal_bootstrap_summary.csv), the studentized bootstrap interval from the exact same 1,999 draws is **[+₹1,529, +₹10,447]**, which cleanly excludes zero. 2SLS distributions frequently have heavy tails and skewness, causing studentized and percentile intervals to diverge. Following Lal et al. (2024), both intervals must be reported with equal prominence rather than highlighting only the one that crosses zero.
3. **The Unresolved 45% Calculation:**
   The replicators stated they "could not reproduce the calculation giving 45%." As established in Finding W-2 of this audit, dividing the Table 4(2) interaction coefficient (₹850.936) by the Table 2 mean high-caste household crop income (₹1,891.613) yields **44.985%**, perfectly matching the published 45% text claim. The replicator missed the opportunity to expose the exact dimensional blunder (rupees/acre divided by rupees/household).
4. **Limited Scope of Simulation Draws in the Marriage Audit:**
   The original paper generated 250 full-market draws. The replicator ran full-market Gale–Shapley matching on Draw 1 and on point estimates (Draw 0), but did not execute all 250 draws. While computationally understandable and transparently stated, the replicator's simulation audit evaluates draw-specific sensitivity rather than the complete simulated distribution of the original 250-draw equilibrium model.

---

## Confirmed Strengths of the Replication Packages

The audited repositories exhibit world-class empirical hygiene:
1. **Computational Precision:** Both packages achieve near-perfect numerical replication of all reported baseline linear models, conditional logit models, and IV models.
2. **Deep Algorithmic Forensics:** The identification of the operator precedence error in Stata (`-0.1749361*edu_max==2`), the column misreferencing in Matlab (`fem_j(:,13)` vs. `fem_j(:,12)`), and the swapped missingness interactions in the bride preference matrix represent forensic data auditing of the highest caliber.
3. **Full-Procedure Resampling:** The replicators avoided "naive" bootstrapping. In both the marriage income tradeoff and the water IV analysis, the bootstrap loops re-estimate all preliminary prediction equations (predicted log income in marriage; first-stage tubewell purchase prediction in water) within each resample, strictly adhering to modern econometric standards.
4. **Intellectual Honesty:** The replicators openly discarded invalid critiques (e.g., rejecting the same-caste Stata syntax typo after finding it affected 0 pairs; acknowledging that their own counterfactual mean husband attribute probe is bounded by accounting identities; and refusing to label historical census data as "placebos").

---

## Decisive Remaining Checks

To definitively resolve the empirical questions identified by this audit, future work should prioritize:
1. **Obtaining the Raw Village Roster & Land Ownership Files (Water):** Request or locate the raw 1997–98 survey files that record actual caste-by-caste land ownership percentages to test whether Anderson's findings are sensitive to the 50% dominance cutoff.
2. **Executing a 250-Draw Corrected Matlab/R Simulation (Marriage):** Run the complete 250-draw Gale–Shapley market simulation with all four handoff corrections (weights, signs, missingness, and residence) to obtain the definitive, fully populated counterfactual distribution of Table 6 and Table 8.
3. **Anderson–Rubin Weak-Instrument Robust Confidence Sets (Water):** Implement weak-instrument-robust confidence sets (such as the Moreira CLR or Anderson–Rubin test) specifically adapted for two endogenous regressors, moving beyond the divergence between percentile and studentized bootstraps.
4. **Linking Survey Villages to 1991/2001 Census SHRUG Identifiers (Water):** Locate the survey village name crosswalk to merge SHRUG geographic and infrastructure data, enabling a true pre-existing development and water-table gradient analysis within districts.

---

## Audit Accounting: Inspected vs. Independently Computed

| Audit Component | Inspected from Repositories, Original Archives, & Papers | Recomputed / Derived in This Audit | Status / Defect Found |
|:---|:---|:---|:---|
| **Marriage: Linear Regressions (Tables 3 & 4)** | [replicate.log](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/replicate.log), [published_comparison.csv](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/published_comparison.csv), [Data_analysis.do](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/data/original/AEJMicro-2011-0182-Data/do/Data_analysis.do) | Verified coefficient match across all 28 cells | **Confirmed Robust:** Exact replication |
| **Marriage: Bootstrap Weight Omission** | [bootstrap_witherrors.do:L10,L29,L54](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/data/original/AEJMicro-2011-0182-Data/do/bootstrap_witherrors.do#L10), [bootstrap_handoff.csv](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/bootstrap_handoff.csv) | Verified `[aw=weight]` omitted in do file | **Confirmed Defect:** Upward coefficient shift $\approx 20\%$ |
| **Marriage: Residence Coding Error** | [algorithm_new.m:L207-L210](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/data/original/AEJMicro-2011-0182-Data/matlab/algorithm_new.m#L207), [residence_feature_error.csv](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/residence_feature_error.csv) | Verified column indices of `fem_j` | **Confirmed Defect:** 1,678,947 candidate pairs corrupted |
| **Marriage: Quality Operator Precedence** | [correlations_results.do:L1](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/data/original/AEJMicro-2011-0182-Data/do/correlations_results.do#L1), [quality_education_error.csv](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/quality_education_error.csv) | Verified Stata syntax operator precedence rules | **Confirmed Defect:** Education zeroed out for 18,499 people |
| **Marriage: Bride Feature Signs & Swaps** | [algorithm_new.m:L73-L88](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/data/original/AEJMicro-2011-0182-Data/matlab/algorithm_new.m#L73), [simulation-feature-review.md](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/ms/simulation-feature-review.md) | Traced Stata definitions to Matlab cols 9, 10, 19, 20, 25, 26 | **Confirmed Defect:** Rank signs reversed; missing flags swapped |
| **Marriage: 93% vs 69% Simulation Fit** | [simulation_handoff_moments.csv](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/simulation_handoff_moments.csv), [published_matching_fit.csv](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/published_matching_fit.csv) | Compared corrected allocations to published Table 6 | **Audited Finding:** Corrections DO NOT resolve 93% misfit |
| **Marriage: Accounting Invariance** | [simulation-audit.md:L83](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/ms/simulation-audit.md#L83), [simulation_comparisons.csv](file:///Users/soodoku/Documents/GitHub/for-better-or-caste/output/simulation_comparisons.csv) | Verified closed-market male matching properties | **Methodological Limit:** Reallocation cannot change total male income |
| **Water: Regression Replication (Tables 3–5)** | [run.log](file:///Users/soodoku/Documents/GitHub/well-actually/output/run.log), [published_regression_comparison.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/published_regression_comparison.csv), [program.txt](file:///Users/soodoku/Documents/GitHub/well-actually/data/original/program.txt) | Verified all 54 coefficient/SE pairs within 0.1 rupee | **Confirmed Robust:** Exact replication |
| **Water: 45% Denominator Derivation** | [sources/paper.txt:L796](file:///Users/soodoku/Documents/GitHub/well-actually/sources/paper.txt#L796), [published_descriptive_comparison.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/published_descriptive_comparison.csv) | Calculated $850.936 / 1891.613 = 44.985\%$ | **Confirmed Defect:** Dimensional mismatch (rupees/acre $\div$ rupees/hh) |
| **Water: Buyer vs. Owner Contrast** | [water_contrasts.csv:L4](file:///Users/soodoku/Documents/GitHub/well-actually/output/water_contrasts.csv#L4), [ols_tables.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/ols_tables.csv) | Evaluated linear contrast $\hat{\beta}_{\text{diff}} = 462.4$, $p = 0.454$ | **Confirmed Defect:** Fallacy of comparing significance levels |
| **Water: Table 2 Clustering** | [descriptive_tables.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/descriptive_tables.csv), [program.txt:L34-L53](file:///Users/soodoku/Documents/GitHub/well-actually/data/original/program.txt#L34-L53) | Checked unclustered Stata t-tests vs. clustered SEs | **Confirmed Defect:** 3 of 4 irrigation variables lose significance |
| **Water: IV Bootstrap Inference** | [iv_lal_bootstrap_summary.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/iv_lal_bootstrap_summary.csv), [iv_pairs_bootstrap.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/iv_pairs_bootstrap.csv) | Evaluated percentile vs. studentized CI divergence | **Confirmed Fragility:** Percentile interval crosses zero |
| **Water: IV Exclusion Pathways** | [iv_exclusion_thresholds.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/iv_exclusion_thresholds.csv), [iv_exclusion_sensitivity.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/iv_exclusion_sensitivity.csv) | Traced Mellon direct-effect linear shifts | **Confirmed Defect:** Natural water direct effect increases IV bias |
| **Water: Alleged Placebos & Dominance** | [water-balance.md:L56,L75](file:///Users/soodoku/Documents/GitHub/well-actually/ms/water-balance.md#L56), [land_ownership_checks.csv](file:///Users/soodoku/Documents/GitHub/well-actually/output/land_ownership_checks.csv) | Evaluated causal graph of longstanding caste dominance | **Methodological Confirmation:** Historical census is not a clean placebo |
