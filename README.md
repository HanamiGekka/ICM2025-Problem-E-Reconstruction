[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [繁體中文](README.zh-TW.md)

# Reconstructed farmland ecosystem models

Release: [v1.0.0](https://github.com/HanamiGekka/ICM2025-Problem-E-Reconstruction/releases/tag/v1.0.0). MATLAB reconstruction of **2025 ICM Problem E**.

A MATLAB reconstruction of four modeling workflows developed around the 2025 ICM Problem E farmland ecosystem problem. The complete original competition codebase was not recovered. Some historical MATLAB implementation survives privately. The public code is a reconstructed implementation based on the competition paper, surviving mathematical notes, selected historical source behavior and documented results.

**Models I–III use explicitly disclosed reconstruction assumptions where historical parameters are unavailable. These are not the exact original competition parameters.** Task4 contains both source-compatible and corrected reconstructed variants. This repository serves reproducibility, portfolio and educational purposes; it is not validated agricultural forecasting.

| Model | Runnable workflow | Evidence / assumptions |
| --- | --- | --- |
| I: four species | Six documented dose scenarios; event-aware ODE; harvest/replant; trajectories and heat map | Paper equations and dose labels; new coefficients, initials, schedule and solver |
| II: six species | F/V1/V2 optimization; independent grid; before/after and convergence | Paper equations and unit costs; explicit N4² vs N4*N6 alternatives; new preferences |
| III: seven species | V1=0; bee introduction; literal vs population-coupled pollination; F/V2 optimization | Documented herbicide removal; disclosed alternative coupling and new coefficients |
| IV / Task4: eight species | Sixteen organic strategies; intended/historical Pareto; deterministic CA/RGB | Surviving source evidence; compatible/corrected modes separate |

Configuration → documented RHS → segmented integration/events → diversity/stability and crop aggregation → bounded search/grid → exports, comparisons and sensitivity. One shared earlier-model kernel avoids three duplicated pipelines. The [70-row registry](config/reconstruction_parameters.csv) and [assumptions](docs/methodology/ASSUMED_PARAMETERS.md) declare normalized units, bounds, provenance and four profiles: documented_only, reconstructed_baseline, reconstructed_low and reconstructed_high. documented_only preserves NaN gaps. No post-hoc calibration or historical target fitting is performed.

![Six reconstructed chemical scenarios](results/reproduced/full/model1_trajectories.png)

![Reconstructed pollination alternatives](results/reproduced/full/model3_pollination.png)

![Reconstruction sensitivity ranking](results/reproduced/full/sensitivity_ranking.png)

## Evidence and terminology

| Material | Meaning in this repository |
| --- | --- |
| Original historical material | The authorized paper and certificate in `historical-documents/`; the remaining historical archive stays private |
| Reconstructed implementation | Runnable MATLAB code based on disclosed evidence and choices; not the complete original competition source |
| New assumptions | Explicit coefficients, initial conditions, schedules, solvers and preferences in the parameter registry and methodology |
| Historical-compatible variant | `historical_compat` preserves the documented surviving Task4 behavior |
| Corrected variant | `corrected` discloses horizon, zero-pest and preference corrections; it intentionally changes some outputs |
| Reproduced outputs | Generated reconstruction plots, CSV and verification files, not measured agricultural observations |

## Quick start

Verified with MATLAB R2023b (23.2.0.2365128), Windows x64, base MATLAB only. No additional toolbox or Python environment is required for the numerical workflows. From the repository root:

```matlab
addpath('src/matlab','tests/matlab');
run_checks('public');
export_task4('historical_compat');
export_task4('corrected');
export_ca_scenarios;
export_historical_comparison;
export_full_reconstruction;
verify_exports;
```

Windows PowerShell wrapper (MATLAB on PATH, or pass an existing executable with -MatlabExe):

```powershell
.\scripts\run_reconstruction.ps1 -Public -MatlabExe matlab
```

For an individual simulation:

```matlab
c = reconstruction_config(3,'reconstructed_baseline');
r = simulate_reconstructed(c);
o = optimize_reconstructed(c);
rOptimized = simulate_reconstructed(c,o.decision);
```

Public verification requires no Original archive. Private verification additionally checks all74 historical files and audited target transcription. Numerical arrays/CSV are deterministic; UTC generation metadata and PNG timestamps can change. CA uses a disclosed fixed twister seed and restores caller RNG. Read [reproducibility](docs/methodology/REPRODUCIBILITY.md).

## Results and limits

The reconstructed objective selects zero chemicals for Models II and III under baseline preferences. Utility rises while crop falls; the printed stability proxy becomes zero at F=0. This follows the assumed objective, **not a farmer recommendation**. Grid agreement does not prove a global continuous optimum. [Results](docs/results/RECONSTRUCTION_RESULTS.md) report decisions, disagreements and structural alternatives. [Sensitivity](docs/results/SENSITIVITY_REPORT.md) covers ±10%/±20%, renormalized objective weights, bounds and low/high stress profiles.

Task4 compatibility matches all14 Table5 rows at displayed rounding. Intended preference differs from the surviving reversed Pareto filter. Corrected field values deliberately differ because of horizon/zero-pest rules. Models I–III disagree with historical targets because their settings are new. Conflicting Model II target blocks remain separate. Figure normalizations are reconstructed visualization conventions.

Strong structural evidence does not establish empirical validity. Exact earlier parameters, original solver/events, GA history, RNG states and regression samples/R² remain unrecoverable. Bee/crop coupling follows a disputed model and is not verified biology. Cost remains a normalized one-dose index despite recurring applications. Read [scope](docs/methodology/RECONSTRUCTION_SCOPE.md), [corrections](docs/methodology/CORRECTIONS.md) and [traceability](docs/methodology/PARAMETER_PROVENANCE.md).

```text
config/                 reviewed parameter and target registries
src/matlab/             equations, simulation, optimization, CA and export
tests/matlab/           public scientific/behavior checks
scripts/                batch runner and release verification
docs/methodology/        assumptions, traceability, corrections, reproduction
docs/results/           findings and sensitivity
results/reproduced/     new plots, CSV, configurations and verification JSON
historical-documents/   authorized historical paper and certificate; outside MIT
```

## Context, acknowledgment and license

Historical contest mathematics and competition work motivate this reconstruction. The [original paper and award certificate](historical-documents/README.md) are included as explicitly authorized historical copies in a separate folder. Their historical names, signatures and document metadata are retained; the rest of the private archive remains excluded. Cite the release tag and parameter profile when using an output; do not cite this as the full original competition source.

[MIT](LICENSE) applies to newly authored reconstructed software only. It grants no rights over contest documents, private historical source/documents, reference papers, datasets, photographs, certificates or third-party artifacts. Reviewed target transcriptions are attributed evidence outside the software license claim. All displayed images are newly generated plots/CA renderings. This public repository was prepared from an explicit whitelist and fresh Git history. Internal audit/history and the private archive are excluded, with only the two hash-pinned historical PDF copies explicitly authorized.
