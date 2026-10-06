# Reproducibility and verification

Verified: native MATLAB R2023b, Windows x64, base MATLAB only. No installation is needed. README provides direct MATLAB and PowerShell commands. The wrapper defaults to matlab on PATH or an explicitly supplied existing executable. Process-local TEMP/TMP/MATLAB_PREFDIR and logs use ignored .work; caller values are restored. temp remains a flat handoff.

Private run_checks('full') requires all74 original SHA256/size/file-set checks and cross-checks reviewed Table5 against the private audit. Public run_checks('public') excludes only private preservation tests. All reconstructed scientific and Task4 behavior/static checks run publicly. Missing private archive is reported as EXCLUDED, never public hash PASS. Failed/incomplete tests, static diagnostics or invalid exports stop the native batch with nonzero exit.

Full export produces six Model I cases; Model II/III baseline/optimized/literal variants; Model III no-bee comparison; independent grids/search histories;44 OAT/bounds rows;9 stress profiles;12 scientific plots. Every trajectory has configuration/provenance/metrics/positivity metadata and an event CSV. full/experiment_metadata.json declares all experiments and visualization conventions. verify_exports checks actual dimensions, nonnegative finite values, grid/horizon, utility vs independent grid, optimized-decision replay, sensitivity completeness and image dimensions. Top-level CA exports supply four additional images, raw RGB/state/event/metric CSVs and metadata.

Earlier models use no randomness. Coordinate search begins at baseline, performs6 sweeps with halving steps, then independently evaluates a four-level Cartesian grid (64 points Model II,16 Model III). If the grid improves the original search, coordinate refinement follows. A cache avoids repeated decisions; histories show unique evaluations and phases. Stopping is fixed budget. No global optimum or original GA replay is claimed. Bound sensitivity consistently uses grid3/sweeps3 for control and perturbations.

ODE output spacing .5, horizon36, applications6, harvest12 are new normalized monthly choices. Event samples are post-reset; time integrals use pre-event segment endpoints. Resolution .25/tighter tolerance is tested against aggregates. Projected derivative/nonnegative policy is new; counters measure RHS evaluations, not physical events. Raw documented equations remain available.

CA source n80/3000 defaults remain; exports use new n24/420/seed20251027 choices. Random draw order and scalar noise are preserved, RNG restored, each export repeated exactly. Corrected RGB uses common fixed scales; compatible raw RGB can exceed gamut and displayed PNG explicitly clips it. Numeric CSV arrays are deterministic. PNG pixels are deterministic while timestamp chunks can vary; JSON UTC times vary.

Task4 Table5 tolerances reflect displayed rounding, not agricultural accuracy. Corrected max field difference58.2864 is disclosed. historical_*_targets.csv is transcription; full/*_historical_comparison.csv compares NEW assumed results. Top-level earlier status marks exact historical experiments unrecovered. No regression data/R² or historical GA/RNG state is invented.

The public repository has fresh history and only release_whitelist.csv paths. scripts/verify_public.ps1 scans contents, paths and every commit. Two expressly authorized historical PDFs are checked against exact pinned hashes rather than incorrectly claiming their names/signatures/metadata were removed. All other private directories, audits and binaries remain excluded. After publication, pass -ExpectedOrigin with the explicitly reviewed repository URL so the scanner also verifies fetch/push origin.


