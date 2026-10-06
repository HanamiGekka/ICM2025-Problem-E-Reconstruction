# Parameter and equation provenance

ORIGINAL denotes preserved evidence. DOCUMENTED denotes explicit equations/values. INFERRED_FROM_TASK4_SCALE is an analogy only; NORMALIZED_RECONSTRUCTION_ASSUMPTION is a new choice. Neither is recovered earlier competition provenance. Full source mapping/hashes remain in private audit; reviewed public references use abstract labels.

| Module | Source trace | Numeric status |
| --- | --- | --- |
| Model I documented_rhs | Private paper pp7–8 eq5–14; four-species notes | Structural equations documented; earlier numbers missing |
| Harvest | Paper p8 eq15 | First-cycle reset documented; repeating schedule/ordering new |
| documented_metrics | Paper p8 eq16–18 | Formula documented; weights assumed |
| Model II RHS | Paper p11 eq19–23 | Both printed N4² and code-informed N4*N6 retained |
| chemical_fitness | Paper p12 eq24; Model II result notes | Unit costs2/50/40 documented; price/preferences/segmented mean new |
| Model III | Paper p15 eq26–27 | V1=0 documented; F versus population coupling explicit |
| Model I six pairs | Paper p9 Figure4 | Dose labels documented; second source filename conflicts tenfold |
| historical_targets | Paper p13 Table4, p18 Table5, p17 Figure12, p23 Table7; separate result notes | Transcribed evidence; never substituted simulations |
| Earlier numerical registry | config/reconstruction_parameters.csv | All70 rows assumed/inferred, with model-specific selection |

C42 scalar: initial[200,40,30,20,20,10,50,10 BPC], F10 OFU,dt.1,horizon100,K3/K5=125.7569,frozen N4/N6/N7,no harvest and per-step .6/.4 removal are surviving source behavior. Crop growth .6/.02/.001/.001, season.5/period12,phase+8,decay.005,capacity400/decline.003/offset.01 and fertilizer.02 exp(−.05t) are documented late values, not earlier defaults. Bilinear interactions and sequential update order are preserved. C42 costs use introduction200, maintenance2/3, fertilizer1/6, weeding5/6,pest control12/6. Currency unknown. Field is crop−pests; modified S=D[1+ln(1+.005F)] differs from paper plain D.

CA: source n80/3000/dt.1,crop200,random species bounds,periods6/12,retention.8,center-inclusive zero-padded /9 neighborhoods and scalar noise1+.03(U−.5) are preserved. Unusual neighborhood/constant-season terms remain. CA pest cost15 differs from C42's12. Export n24/420/seed20251027 and corrected fixed RGB scales are NEW engineering choices, not recovered original RNG/pixels.

Every earlier analogy is tagged in the CSV and human ASSUMED_PARAMETERS registry, with values, units, bounds, rationale and confidence. Model III herbicide zero overrides the shared assumed baseline. Algebra-test toy values are test-only fixtures. No historical target or convergence/regression sample is used for fitting.

