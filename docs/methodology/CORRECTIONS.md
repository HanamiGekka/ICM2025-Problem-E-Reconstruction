# Disclosed corrections

`historical_compat` and `corrected` are separate configurations, never edits to Original. The corrected mode is a limited engineering reconstruction, not a validated agricultural model.

| Evidence | Historical behavior | Corrected behavior / reason | Class and impact |
| --- | --- | --- | --- |
| C42 passes [g,b,-cost] then minimizes it; N41 specifies max g,b/min cost | Reversed preference | Intended flag maximizes g,b, minimizes cost; reversed flag also preserved in every scalar export | DOCUMENTED intended rule; changes frontier membership, not trajectories |
| C42 iterates 0:.1:100, updating at every label | 1001 Euler updates, final state advanced to100.1 | Exactly duration/dt updates; RHS labels 0 through duration-dt | Newly selected engineering correction; aggregation/horizon changes |
| Paper (32)-(34), C42 metric, CA matrix-wide if | C42 zero-pest field equals crop; CA one zero cell can suppress the whole metric matrix | Corrected per-cell zero-pest field0 (literal paper32), zero-total D0; retain source modified S separately from plain D | DOCUMENTED guard; can change field scores after numerical pest underflow, especially per-step PPC |
| C42 every-step .6/.4 retention, frozen species/no harvest; C41/CA differs | Strong dt-dependent suppression | Remains explicitly C42 in both scalar modes; do not import six-month .8 controls or full-species dynamics as an alleged repair | Scientific ambiguity retained; convergence checked only without discrete controls |
| Paper34 plain Simpson versus source modified S | S=D(1+ln(1+.005F)) | Keep named source S and separately return D in both modes | Unresolved metric choice, no silent biological/scientific change |

Scalar F and N8 switches already work in source and remain functional. The scalar update order is derivative-old-state -> weed/pest removal -> N8 using updated pests -> crop update -> metrics. Negative attempted values are clipped and counted; nonfinite states and totals throw. No biological rate was changed or fitted.

## Spatial corrections and retained ambiguities

CA source assigns F10 and random N8 independently of OFU/BPC. Corrected uses F10*OFU and N8 random*BPC; source-compatible keeps both effects present when these cost switches are off. This is a DOCUMENTED switch defect (audit F08), directly tested.

Both modes use the source event order (clipped Euler, harvest, physical controls, metrics, RGB), including step1/t0 events. Corrected replaces floating mod equality with integer step modulo; periods must divide dt or an error is raised. It preserves source anchoring, not a newly inferred six-month delay. Newly selected twister seed20251027 makes both reconstructed stochastic modes repeatable and restores caller RNG. Source initialization draw order and noise draw order [1,2,3,5,4,6,7,8], one scalar per species/step, are retained.

Corrected RGB uses fixed positive scales [616.6666666666667,400,(7/8)*(1+ln(1+.05))] and clips channels to [0,1]. These are NEW engineering display settings shared across selected scenarios, not fitted scientific parameters. Compatibility retains cost/566.67 and running g/S maxima without clipping; raw RGB CSV can lie outside gamut, while PNG display explicitly clips it. Uniform cost red, zero-padded center-inclusive /9 neighborhood, neighborhood-based N5 growth and constant sin(2*pi*Ts) capacity term are retained in both variants. Their biological interpretation remains unresolved.

## Earlier equation conflicts

The new shared earlier-model kernel retains literal paper equations and exposes variants for N6 N4² versus N4*N6, and pollination F versus N4/N7. The latter uses paper decay time t-ti, not the later C41 seasonal application phase. The alternative structure is INFERRED, labeled explicitly, and has no claimed recovered parameterization. No earlier-model scientific correction or solver/event convention is silently borrowed from Task4. Chemical removal remains an additive term and may generate negative derivatives; the continuous RHS does not silently clip.
