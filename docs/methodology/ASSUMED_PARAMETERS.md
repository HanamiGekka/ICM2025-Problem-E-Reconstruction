# Explicit numerical reconstruction assumptions

Models I–III were not numerically recoverable from the surviving evidence. RUN #2.x authorizes a runnable demonstration with new assumptions. The complete machine-readable registry is [reconstruction_parameters.csv](../../config/reconstruction_parameters.csv). Each row specifies its model, value, profile values, exploratory bounds, normalized unit, meaning, evidence class, rationale, sensitivity relevance and historical dependence. None is a recovered earlier-model measurement.

`documented_only` retains NaN missing coefficients and Model III's documented V1=0. `reconstructed_baseline` supplies the principal experiment. `reconstructed_low` and `reconstructed_high` jointly change initial abundances and selected interactions/effects by −20%/+20%; they are stress profiles, not confidence intervals. Other settings and simplex weights remain fixed. The lower/upper registry columns are exploratory plausibility bounds, not empirical uncertainty estimates. No post-hoc calibration is used and no historical target is used to fit these profiles.

`INFERRED_FROM_TASK4_SCALE` means only that late source gives an order-of-magnitude reference. It is not documentary evidence for Models I–III. Other coefficients and numerical settings are `NORMALIZED_RECONSTRUCTION_ASSUMPTION`, a subclass of reconstruction assumption. Population units, chemical intensities and cost units are normalized; time is a newly assumed monthly scale. Species labels and pollination relationships follow the historical equations without claiming empirical biology.

The principal six-species equation uses `N4*N6` because reproduction then depends on the predator's presence; `N4^2` remains available and is exported as an alternative. The principal seven-species pollination uses N4/N7 so bee introduction affects crop growth; the literal fertilizer-multiplied equation remains available. Both alternatives retain the paper's exponential application-age convention, and neither is a recovered competition run.

The solver is segmented ode45. Applications occur at 0,6,12,… and reset chemical age. Harvest occurs at 12,24,…, records pre-harvest crop, removes it and immediately replants the initial crop amount. Outputs at event times are post-event; crop/diversity/stability integrals use each segment's pre-event endpoint and never integrate across a reset discontinuity. All events through the final time are included. No harvest occurs at t=0. Chemical removal is additive as printed. A projected boundary vector field prevents removal from an absent population; trial-negative and blocked-removal evaluation counts are disclosed. This is a new positivity policy, separate from the raw documented RHS.

The mean standing crop, not cumulative harvested yield, defines income. Mean stability is a chemical-weighted Simpson proxy, not a dynamical stability certificate. Objective weights and price are new preferences. Unit costs [2,50,40] are documented; cost retains the printed one-dose convention even though the reconstructed solver repeats applications. It is a normalized comparison index, not a full recurrent farm budget.

Optimization uses base MATLAB only: independent Cartesian grid over the declared bounds, followed by deterministic bounded coordinate refinement beginning at the best grid/baseline candidate. Both evaluations and incumbents are exported. Each sweep tests plus/minus each free coordinate and halves its step. Model III fixes V1=0. There is no random sampling or GA seed, and no original GA convergence is claimed. Grid agreement provides a finite-domain check, not proof of a global continuous optimum.

The six Model I dose pairs alone are DOCUMENTED Figure4 labels. Model III herbicide zero and unit costs are DOCUMENTED. All other numeric earlier-model defaults are explicitly new. Historical initial conditions, parameters, application logic, solver, original GA history, RNG state and regression samples remain unrecoverable.

## Registry values

| Name | Model | Baseline | Low / high profile | Exploratory bounds | Meaning / unit | Class |
| --- | --- | --- | --- | --- | --- | --- |
| r10 | I-II-III | 0.55 | 0.55 / 0.55 | 0.3 to 0.8 | baseline crop growth; per normalized month | INFERRED_FROM_TASK4_SCALE |
| tauF | I-II-III | 0.018 | 0.0144 / 0.0216 | 0.008 to 0.03 | fertilizer growth efficacy; growth per chemical intensity | INFERRED_FROM_TASK4_SCALE |
| betaF | I-II-III | 0.08 | 0.08 / 0.08 | 0.02 to 0.2 | fertilizer decay; per normalized month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| A | I-II-III | 0.35 | 0.35 / 0.35 | 0 to 0.7 | seasonal amplitude; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| Ts | I-II-III | 12 | 12 / 12 | 6 to 24 | seasonal period; normalized months | INFERRED_FROM_TASK4_SCALE |
| K10 | I-II-III | 380 | 380 / 380 | 250 to 500 | baseline crop capacity; normalized population units | INFERRED_FROM_TASK4_SCALE |
| iota | I-II-III | 0.002 | 0.002 / 0.002 | 0 to 0.01 | capacity decline; per normalized month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| capacityLambda | I-II-III | 0.012 | 0.012 / 0.012 | 0.002 to 0.03 | crop capacity offset and fertilizer coupling; normalized capacity coefficient | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| r2 | I-II-III | 0.65 | 0.65 / 0.65 | 0.3 to 1 | weed growth; per normalized month | INFERRED_FROM_TASK4_SCALE |
| K2 | I-II-III | 160 | 160 / 160 | 80 to 250 | weed capacity; normalized population units | INFERRED_FROM_TASK4_SCALE |
| lambda12 | I-II-III | 0.0013 | 0.00104 / 0.00156 | 0.0005 to 0.003 | crop weed competition; per population per month | INFERRED_FROM_TASK4_SCALE |
| V10 | I-II | 180 | 144 / 216 | 50 to 300 | herbicide removal efficacy; population per intensity per month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| phi1 | I-II | 0.12 | 0.12 / 0.12 | 0.03 to 0.3 | herbicide efficacy decay; per normalized month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| r3 | I-II-III | 0.045 | 0.045 / 0.045 | 0.02 to 0.1 | first pest growth; per normalized month | INFERRED_FROM_TASK4_SCALE |
| K30 | I-II-III | 110 | 110 / 110 | 60 to 180 | first pest base capacity; normalized population units | INFERRED_FROM_TASK4_SCALE |
| rhoN1 | I-II-III | 0.7 | 0.7 / 0.7 | 0.4 to 0.9 | crop weight in pest capacity; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| rhoN2 | I-II-III | 0.3 | 0.3 / 0.3 | 0.1 to 0.6 | weed weight in pest capacity; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| lambda13 | I-II-III | 0.00035 | 0.00028 / 0.00042 | 0.0001 to 0.001 | crop first pest interaction; per population per month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| lambda34 | I-II-III | 0.0028 | 0.00224 / 0.00336 | 0.001 to 0.006 | bat predation on first pest; per population per month | INFERRED_FROM_TASK4_SCALE |
| V20 | I-II-III | 100 | 80 / 120 | 30 to 200 | pesticide additive removal efficacy; population per intensity per month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| phi2 | I-II-III | 0.1 | 0.1 / 0.1 | 0.03 to 0.3 | pesticide efficacy decay; per normalized month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| gamma4 | I | 0.055 | 0.055 / 0.055 | 0.02 to 0.12 | Model I bat mortality; per normalized month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| ti | I-II-III | 0 | 0 / 0 | 0 to 0 | most recent application time; normalized months | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| F | I-II-III | 5 | 5 / 5 | 0 to 10 | baseline fertilizer decision; normalized chemical intensity | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| V1 | I-II-III | 0.02 | 0.02 / 0.02 | 0 to 0.06 | baseline herbicide; Model III overrides to documented zero; normalized chemical intensity | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| V2 | I-II-III | 0.02 | 0.02 / 0.02 | 0 to 0.06 | baseline pesticide decision; normalized chemical intensity | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| r4 | II-III | 0.18 | 0.18 / 0.18 | 0.08 to 0.3 | Model II-III logistic bat growth; per normalized month | INFERRED_FROM_TASK4_SCALE |
| K4 | II-III | 90 | 90 / 90 | 50 to 150 | bat capacity; normalized population units | INFERRED_FROM_TASK4_SCALE |
| r5 | II-III | 0.035 | 0.035 / 0.035 | 0.015 to 0.08 | second pest growth; per normalized month | INFERRED_FROM_TASK4_SCALE |
| K5 | II-III | 115 | 115 / 115 | 60 to 180 | second pest capacity; normalized population units | INFERRED_FROM_TASK4_SCALE |
| lambda15 | II-III | 0.0003 | 0.00024 / 0.00036 | 0.0001 to 0.001 | crop second pest interaction; per population per month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| lambda35 | II-III | 0.0016 | 0.00128 / 0.00192 | 0.0005 to 0.004 | pest competition; per population per month | INFERRED_FROM_TASK4_SCALE |
| lambda46 | II-III | 0.0018 | 0.00144 / 0.00216 | 0.0005 to 0.004 | peregrine bat interaction; per population per month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| gamma6 | II-III | 0.08 | 0.08 / 0.08 | 0.03 to 0.2 | peregrine mortality; per normalized month | INFERRED_FROM_TASK4_SCALE |
| tauN4 | III | 0.0008 | 0.00064 / 0.00096 | 0.0002 to 0.002 | bat pollination coefficient; growth per population unit | INFERRED_FROM_TASK4_SCALE |
| tauN7 | III | 0.0012 | 0.00096 / 0.00144 | 0.0003 to 0.003 | bee pollination coefficient; growth per population unit | INFERRED_FROM_TASK4_SCALE |
| betaN4 | III | 0.06 | 0.06 / 0.06 | 0.02 to 0.2 | bat pollination decay; per normalized month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| betaN7 | III | 0.06 | 0.06 / 0.06 | 0.02 to 0.2 | bee pollination decay; per normalized month | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| r7 | III | 0.16 | 0.16 / 0.16 | 0.08 to 0.3 | bee growth; per normalized month | INFERRED_FROM_TASK4_SCALE |
| K7 | III | 85 | 85 / 85 | 40 to 150 | bee capacity; normalized population units | INFERRED_FROM_TASK4_SCALE |
| N1 | I-II-III | 180 | 144 / 216 | 90 to 270 | initial crop and replant amount; normalized population units | INFERRED_FROM_TASK4_SCALE |
| N2 | I-II-III | 35 | 28 / 42 | 15 to 70 | initial weeds; normalized population units | INFERRED_FROM_TASK4_SCALE |
| N3 | I-II-III | 25 | 20 / 30 | 10 to 50 | initial first pests; normalized population units | INFERRED_FROM_TASK4_SCALE |
| N4 | I-II-III | 18 | 14.4 / 21.6 | 8 to 40 | initial bats; normalized population units | INFERRED_FROM_TASK4_SCALE |
| N5 | II-III | 16 | 12.8 / 19.2 | 5 to 35 | initial second pests; normalized population units | INFERRED_FROM_TASK4_SCALE |
| N6 | II-III | 8 | 6.4 / 9.6 | 2 to 20 | initial peregrines; normalized population units | INFERRED_FROM_TASK4_SCALE |
| N7 | III | 40 | 32 / 48 | 0 to 80 | introduced bees; no-bee scenario explicitly zero; normalized population units | INFERRED_FROM_TASK4_SCALE |
| alphaF | I-II-III | 0.4 | 0.4 / 0.4 | 0.2 to 0.6 | fertilizer weight in stability proxy; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| alphaV1 | I-II-III | 0.3 | 0.3 / 0.3 | 0.15 to 0.45 | herbicide weight in stability proxy; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| alphaV2 | I-II-III | 0.3 | 0.3 / 0.3 | 0.15 to 0.45 | pesticide weight in stability proxy; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| omegaS | I-II-III | 0.25 | 0.25 / 0.25 | 0.1 to 0.4 | stability utility weight; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| omegaI | I-II-III | 0.6 | 0.6 / 0.6 | 0.4 to 0.8 | income utility weight; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| omegaT | I-II-III | 0.15 | 0.15 / 0.15 | 0.05 to 0.3 | cost penalty weight; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| Fmin | I-II-III | 0 | 0 / 0 | 0 to 0 | fertilizer lower bound; normalized chemical intensity | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| V1min | I-II-III | 0 | 0 / 0 | 0 to 0 | herbicide lower bound; normalized chemical intensity | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| V2min | I-II-III | 0 | 0 / 0 | 0 to 0 | pesticide lower bound; normalized chemical intensity | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| Fmax | I-II-III | 10 | 10 / 10 | 8 to 12 | fertilizer upper bound; normalized chemical intensity | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| V1max | I-II-III | 0.06 | 0.06 / 0.06 | 0.048 to 0.072 | herbicide upper bound; normalized chemical intensity | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| V2max | I-II-III | 0.06 | 0.06 / 0.06 | 0.048 to 0.072 | pesticide upper bound; normalized chemical intensity | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| horizon | I-II-III | 36 | 36 / 36 | 12 to 60 | simulation horizon; normalized months | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| outputStep | I-II-III | 0.5 | 0.5 / 0.5 | 0.25 to 1 | output quadrature spacing; normalized months | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| applicationPeriod | I-II-III | 6 | 6 / 6 | 3 to 12 | chemical reapplication period; normalized months | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| harvestPeriod | I-II-III | 12 | 12 / 12 | 6 to 24 | harvest replant period; normalized months | INFERRED_FROM_TASK4_SCALE |
| relTol | I-II-III | 0.000001 | 0.000001 / 0.000001 | 0.0000001 to 0.00001 | ode45 relative tolerance; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| absTol | I-II-III | 0.00000001 | 0.00000001 / 0.00000001 | 0.000000001 to 0.0000001 | ode45 absolute tolerance; normalized population units | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| maxStep | I-II-III | 0.5 | 0.5 / 0.5 | 0.1 to 1 | maximum adaptive solver step; normalized months | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| cropPrice | I-II-III | 0.05 | 0.05 / 0.05 | 0.025 to 0.1 | crop income conversion; arbitrary cost per population unit | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| gridLevels | I-II-III | 4 | 4 / 4 | 3 to 5 | independent coarse grid levels per free decision; integer | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| searchSweeps | I-II-III | 6 | 6 / 6 | 3 to 8 | coordinate search sweeps; integer | NORMALIZED_RECONSTRUCTION_ASSUMPTION |
| searchStepFraction | I-II-III | 0.25 | 0.25 / 0.25 | 0.125 to 0.5 | initial coordinate step fraction of bounds span; dimensionless | NORMALIZED_RECONSTRUCTION_ASSUMPTION |

