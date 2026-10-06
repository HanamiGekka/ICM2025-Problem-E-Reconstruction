function c = ca_config(variant)
% DOCUMENTED CA defaults, Cellular_Automata_demo.m; paper pp19-20/Table6.
% RNG seed and fixed normalization are NEW engineering choices, not recovered.
if nargin==0, variant='corrected'; end
c=task4_config(variant); c.component='ca';
c.source='Private late cellular automata implementation; paper physical pp19-20';
c.sourceSHA256='83280A889A754EA8B25C18156B5D82DAA3D36859F934F8CE25C27A317296BBD0';
c.n=80; c.steps=3000; c.initial(8)=20;
c.switches=[1 1 1 1]; c.seed=20251027; c.rngAlgorithm='twister';
c.noiseAmplitude=.03; c.weedRetention=.8; c.pestRetention=.8;
c.seasonPeriod=12; c.costDuration=100; c.costConvention='ca'; c.blockSize=3;
c.rgbScales=[organic_cost([1 1 1 1],100,'ca'),400,(7/8)*(1+log1p(.005*10))];
c.normalization='fixed positive channel scales, clipped [0,1]';
if strcmp(variant,'historical_compat')
    c.metric='ca_compat'; c.normalization='source red/566.67; running green/blue maxima, unclipped';
end
end
