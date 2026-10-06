function c = task4_config(variant)
% RECONSTRUCTED C42 configuration; private surviving scalar evidence.
% Paper physical pp17-18, (29)-(34). Values DOCUMENTED in surviving source.
% Unused historical parameters are deliberately omitted. No earlier-model defaults.
if nargin == 0, variant = 'historical_compat'; end
assert(ismember(variant,{'historical_compat','corrected'}),'task4:variant','Unknown variant');
c.variant = variant;
c.dt = 0.1; c.duration = 100;
c.initial = [200 40 30 20 20 10 50 10];
c.fertilizerOn = 10; c.pestCapacity = 125.7569;
c.harvestPeriod = 12; c.managementPeriod = 6;
c.weedRetention = 0.6; c.pestRetention = 0.4;
c.costConvention = 'c42'; c.metric = 'c42';
c.source = 'Private C42 scalar implementation; paper physical pp17-18';
c.evidence = 'DOCUMENTED source values; RECONSTRUCTED implementation';
c.sourceSHA256 = '8CB213B6AF8890B4D54244CA8393B74ABAE54C6974D011013E86F48604D3D996';
if strcmp(variant,'corrected'), c.metric='corrected'; end
end
