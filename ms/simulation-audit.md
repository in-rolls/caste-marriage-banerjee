# What changes when the matching code is corrected?





We completed ten allocations of the full market of 8,038 men and 14,172 women. Each contains 8,038 distinct couples and zero blocking pairs under its computed preferences. The first four scenarios use **the first supplied coefficient draw**: original code, corrected residence feature, caste preferences removed, and both changes together. These comparisons hold the people and coefficients fixed. They are a correction sensitivity, not a reproduction of the paper's average over 250 draws or its sampling uncertainty. The original coefficient draw remains unweighted. A separate weighted/unweighted point-estimate comparison follows below.

The implementation uses R with a compiled ranking and matching kernel. It preserves complete preference lists, men proposing, the original mean-rank ordering of men before resolving women's ties, and single-precision feature storage. Native Matlab has not been run, so bit-for-bit agreement in floating-point scoring remains unverified. Independent R tests check the features, tie ordering, known matching examples, and randomly generated small markets.

## The residence error changes partners and geography

Correcting the residence indicator changes 2,190 matches (27.25%). On the common group with residence known for the man and both potential wives, the same-residence share changes from 49.57% to 38.61% (N = 922). The same-residence coefficient in this draw is negative, so the direction is consistent with the corrected feature.

Caste sorting hardly changes. The table uses the caste classification in the original outcome-reporting program; that program's classification differs slightly from the utility feature, and both definitions are retained in the CSV.


|Scenario                     |Same caste |Same residence | Residence observed N| Original quality gap| Corrected quality gap|
|:----------------------------|:----------|:--------------|--------------------:|--------------------:|---------------------:|
|original                     |89.69%     |57.11%         |                 1175|               0.1398|                0.0614|
|residence corrected          |89.67%     |37.48%         |                 1118|               0.1399|                0.0615|
|no caste original            |17.62%     |66.89%         |                 1314|               0.1354|                0.0583|
|no caste residence corrected |17.84%     |33.15%         |                 1303|               0.1354|                0.0583|

The quality-index correction affects the reported index and its correlation; it does not change the preference coefficients or matches. Its units are constructed index units, not rupees or a measured welfare loss. The residence error therefore matters, but in this draw it does not explain the model's high caste sorting.

## Small averages can hide substantial individual reallocations

Removing caste preferences after correcting residence changes 97.51% of men's partners. Among women who are matched in both allocations and whose husbands' education is known in both, 37.57% get a different education category (N = 4,519). The average change is only -0.021 categories because gains and losses offset. Categories are not years of schooling.

For the smaller, selected group with both husbands' reported income observed (N = 410), the mean monthly income change is ₹-176, while the mean absolute monthly change is ₹19,809. The median absolute monthly change is ₹4,250; the maximum is ₹567,997, so the mean is sensitive to large changes. Husband income rises for 39.51% and falls for 41.71% of this group. This is an income-attribute comparison between simulated husbands, not compensation, WTP, or a universal loss from caste. It does show why nearly unchanged average matching statistics do not establish that each person would get an almost identical partner.

## A conservative interview comparison

The paper reports moments for couples containing an original interview participant. An exact identifier-and-attribute audit recovers 736 distinct participants, of 783, in the simulation inputs: 259 men and 477 women. Ambiguous IDs and sex conflicts are excluded. The conservative recovered subset is incomplete, and the number of matched couples changes when different women match.


|Scenario                     | Matched couples|Same caste |Same residence | Residence observed N|
|:----------------------------|---------------:|:----------|:--------------|--------------------:|
|original                     |             546|90.29%     |65.91%         |                  132|
|residence corrected          |             549|90.35%     |50.00%         |                  126|
|no caste original            |             552|18.87%     |71.72%         |                  145|
|no caste residence corrected |             553|18.66%     |48.32%         |                  149|

Consequently, these values cannot replace the published 93% versus 69% comparison. They show how the correction behaves in the verified portion of the relevant sample. The next discriminating checks are more coefficient draws, the remaining identifier conflicts, native scoring equivalence, uncertainty under the weighted coefficient handoff, and the paper's stochastic search-friction assumptions.

Run `make simulation` for the default first draw and `make simulation-test` for the independent tests. Set `SIMULATION_DRAWS=1,2,3` to run a specified set of draws; outputs describe only that set. `make simulation-report` rebuilds summaries and this note from saved allocations.

## Using the published regression weights



A second comparison uses weighted and unweighted point estimates on the same regression samples, with the residence feature corrected in both. Every coefficient is checked against the separately produced regression results and its position in the original bootstrap command. Common intercepts and advertiser fixed effects do not distinguish potential partners within a person's ranking; the point-estimate inputs consistently set the common intercept to zero. These are point estimates, not bootstrap averages.

Applying the published weights changes 6,643 matches (82.64%). The caste proportions below change much less. Thus a stable aggregate moment can coexist with substantial differences in individual partners.


|Scenario            | Matched couples|Same caste | Caste observed N|
|:-------------------|---------------:|:----------|----------------:|
|unweighted          |             544|92.28%     |              544|
|weighted            |             544|91.73%     |              544|
|no caste unweighted |             548|19.20%     |              547|
|no caste weighted   |             547|18.68%     |              546|

Only 17 men have their own residence and both wives' residence observed across the weighted and unweighted allocations. These point-estimate residence comparisons therefore have little common support. The full CSV includes the denominator for every reported matching moment.

## Additional confirmed feature errors



An [independent feature review](simulation-feature-review.md) found additional discrepancies between the original bride-side utility features and the regressions supplying their coefficients. The caste-rank differences and two stated-preference interactions have reversed signs. The missing-age and missing-height interaction columns are swapped. Synthetic-profile tests verify each discrepancy and its replacement; the groom-side versions already match the regression definitions.

We separately correct these confirmed bride-side features, retain the residence correction, and use weighted point estimates. This changes 5,176 matches (64.39%) relative to residence correction alone. The comparison does not certify every remaining modeling choice or native Matlab arithmetic.


|Scenario                  | Matched couples|Same caste | Caste observed N|
|:-------------------------|---------------:|:----------|----------------:|
|weighted                  |             544|91.73%     |              544|
|no caste weighted         |             547|18.68%     |              546|
|weighted handoff          |             545|93.39%     |              545|
|no caste weighted handoff |             550|18.58%     |              549|

The paired attribute changes are descriptive reallocations under the fitted model. In particular, when all men are matched and their attributes are fixed, overall mean husband income or education is unchanged by reassignment. That accounting property limits **our aggregate-mean probe**; it does not make the paper's conditional caste-cost regressions in Table 8 tautological. Changes in partners and their observed attributes also do not establish welfare losses. Table 8's conditional cost estimates and their full uncertainty have not been reproduced in this extension.

Run `make simulation-weighting` for the weighted/unweighted point-estimate comparison and `make simulation-handoff` for the additional confirmed-feature comparison. These targets preserve the original archive and save allocations separately from the initial coefficient-draw sensitivity.
