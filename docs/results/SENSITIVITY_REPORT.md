# Reconstruction sensitivity and robustness

NEW assumption study; not the historical competition sensitivity/regression. Forty fixed-decision OAT simulations perturb ten selected initial/interaction/chemical-decay/effect/pollination/preference settings by −20%,−10%,+10%,+20%. Four additional upper-bound reoptimizations perturb Model II F/V2 bounds by±20%. Nine joint low/baseline/high profile simulations span three models.

Initial crop also changes each replant value. Objective-weight perturbations renormalize the entire simplex; raw perturbed values are recorded before normalization. OAT uses baseline doses; it does not optimize all40 cases. Bounds use grid3/sweeps3 consistently for control and perturbations. Parameter ranges are exploratory assumptions, not calibrated uncertainty intervals or ecological probabilities.

Ranking uses the maximum absolute relative change across crop, stability and utility, normalized by baseline absolute output with denominator floor1e−12. This mixes endpoints and is a screening score, not a derivative norm or empirical importance measure. At the bound-study zero-chemical optimum, changes remain zero; that demonstrates local domain robustness under these preferences only.

| Parameter | Maximum relative influence |
| --- | --- |
| income_utility_weight | 0.133812 |
| crop_pest_interaction | 0.111988 |
| initial_pests | 0.050008 |
| herbicide_efficacy | 0.046361 |
| initial_crop | 0.044301 |
| stability_utility_weight | 0.037602 |
| herbicide_decay | 0.011495 |
| fertilizer_efficacy | 0.006794 |
| bee_pollination | 0.004103 |
| pollination_decay | 0.000522 |
| upper_bound_1 | 0 |
| upper_bound_3 | 0 |
Income preference and crop–pest interaction dominate this screening (.133812/.111988). Initial pests, herbicide efficacy and initial/replant crop follow. Bee-coupling influence is smaller for these settings; this is not evidence that pollination is unimportant in agriculture. Upper F/V2 bound variation has no effect because the selected optimum is at all lower bounds.

Joint stress profiles produce crop ranges318.251–374.154 (Model I),324.979–360.310 (II),332.499–355.533 (III). The profiles simultaneously change initial abundances and interactions, so their effects are not additive OAT effects. Neither profile bounds real-world risk, and no probability bands are claimed. Machine-readable OAT, ranking and stress-profile CSVs accompany the full experiment configuration.

The tests replay representative OAT cases across all three models and check declared registry bounds and export completeness. Entire private/public numerical reruns compare CSV bytes; timestamp-bearing JSON/PNG containers are treated separately from numerical values. No Monte Carlo, regression fitting or post-hoc calibration is presented.
