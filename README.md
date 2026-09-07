

# For Better or Caste

An R reproduction and review of Banerjee, Duflo, Ghatak, and Lafortune's
[*Marry for What? Caste and Mate Selection in Modern India*](https://doi.org/10.1257/mic.5.2.33)
(AEJ: Microeconomics, 2013).

The central same-caste association reproduces and survives several inference and weighting checks.
The larger claim that caste preferences impose little economic cost relies on a matching model whose
fit, code, and interpretation need separate scrutiny. [Read the review](ms/review.md).

![Same-caste differences in consideration with advertiser-clustered intervals](figs/same-caste.png)

The respondents are mostly Bengali upper-middle-class families advertising for spouses in
*Anandabazar Patrika* in 2002–03. Interviews usually involved the relative managing the search.
There are **783 advertisers**. The main regressions use **5,628 letters to 506 advertisers seeking
a groom** and **3,944 letters to 277 advertisers seeking a bride**. These are decisions about
which letters to pursue, not observations of a spouse knowingly accepting a monetary loss.

| Question | Finding |
|---|---|
| Do the displayed caste coefficients reproduce? | All 28 checked coefficients match to printed precision; 27 of 28 SEs do, with the remaining discrepancy below 0.0001. |
| Does advertiser clustering eliminate the same-caste association? | No: about 13.2 percentage points for groom searches and 17.1 for bride searches. |
| Is a few advertisers' influence driving it? | The association survives all 506 and 277 advertiser deletions. |
| What does the headline income trade-off mean? | The simplified groom-income model's same-caste term implies a 49.4% outside-caste premium, with a bootstrap interval of 24.6–82.1%. Specific caste comparisons differ. |
| Does that establish WTP to avoid lower castes? | No. The full comparison also includes the prospective groom's caste, relative rank, and the advertiser's stated preferences. [Computed comparisons](output/lower_caste_income_contrasts.csv). |
| Does the matching model establish negligible costs? | The published uncertainty intervals allow substantial costs, and baseline simulated endogamy is 93% versus 69% in observed marriages. |
| Does the supplied simulation use the headline regressions? | Its coefficient bootstrap omits the weights used for the main tables. |
| Are there concrete code problems? | The male preference calculation miscoded same residence for 1,678,947 candidate pairs; the quality index drops education terms through an operator-precedence error. An independent review also confirms caste-rank and missing-attribute feature errors. Ten complete-market allocations quantify the consequences; the selected corrections do not explain away the model's high endogamy. [Simulation audit](ms/simulation-audit.md). |

The general 49% income premium corresponds to accepting about 33% less income for the same-caste
option, not losing 49%. This is a regression conversion for the reference group, not a universal
price of caste. For a Brahmin family with no stated caste preference, the full model gives a
Baidya-groom premium of about 6% (95% bootstrap interval −22% to 50%) and a Kayastha-groom
premium of about 63% (31% to 108%). Both are lower-ranked in the authors' coding. Negative interval
endpoints mean the data also allow the alternative to be preferred without an income premium.

Run locally:

```sh
make deps
make run
make test
make lint
```

R 4.6.0 was used. `make run` rebuilds the six main linear regressions, two conditional logit fits,
the simplified groom-income specification, robustness checks, complete-procedure income
bootstraps, code diagnostics, and this README. The original files remain unchanged.

**Coverage:** This is a reproduction of the main preference evidence and an audit of the structural
claims, not a complete rerun of every published table. The 250 full-market Matlab simulation draws,
Bayesian Figure 1, and all auxiliary appendix regressions have not been rerun. The simplified bride-income point estimates now reproduce, but some income predictions
depend on restrictions the earnings data cannot identify; this specification is not used for reported WTP. See [coverage and limitations](ms/review.md).

The original [114406 replication archive](https://www.openicpsr.org/openicpsr/project/114406/version/V1/view)
contains two reverse-search datasets larger than GitHub's individual-file limit. They remain in the
local extraction but are excluded from Git; the implemented pipeline does not require them.
Original code and data carry the archive's [license](data/original/LICENSE.txt).
The downloaded article and appendix are reading copies and are not redistributed here.

[Research and writing opportunities arising from the review](ms/research-opportunities.md).

The [tradeoff interpretation](ms/tradeoff-interpretation.md) translates the preference estimates into income and education comparisons and examines family resources and cultural explanations.

Selected complete-market sensitivity runs and their limits are documented in the [simulation audit](ms/simulation-audit.md). The [independent feature review](ms/simulation-feature-review.md) traces the confirmed handoff errors to the original programs. `make simulation`, `make simulation-weighting`, and the additional targets documented in that audit reproduce the separate simulation comparisons; `make test` runs the local validation suite.

The [bride-income audit](ms/bride-income-audit.md) resolves the numerical discrepancy and demonstrates the unsupported income extrapolations. The [conditional matching-cost audit](ms/simulation-costs.md) reconstructs the cost regressions on selected saved allocations and reports sparse or unidentified comparisons. [Independent agy audit and adjudication](ms/independent-audit.md).

For the full paired sensitivity across the first 250 supplied coefficient draws, run `Rscript src/simulation_batch.R --workers=2 --draws=1:250 --scenarios=original,feature_corrected`. The runner saves a separate checkpoint for every validated allocation under `output/simulation_runs/`, resumes matching checkpoints, and stops if its input or source hashes change. This uses the original unweighted coefficient draws. Its manifest and status files distinguish completed work from a partial run; it does not reproduce a weighted coefficient bootstrap or certify native Matlab equivalence.
