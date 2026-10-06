function c = reconstruction_config(model,profile)
% Complete NEW parameter profiles; authoritative values/provenance in CSV.
if nargin<2, profile='reconstructed_baseline'; end
assert(ismember(profile,{'documented_only','reconstructed_baseline','reconstructed_low','reconstructed_high'}), ...
    'reconstruction:profile','Unknown profile');
c=documented_config(model,'code_informed','population_coupled');
c.profile=profile;
if strcmp(profile,'documented_only'), return; end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
M=readtable(fullfile(root,'config','reconstruction_parameters.csv'),TextType='string');
column='baseline';
if strcmp(profile,'reconstructed_low'), column='low'; end
if strcmp(profile,'reconstructed_high'), column='high'; end
c.initial=zeros(1,c.species); c.stabilityWeights=zeros(1,3);
c.objectiveWeights=zeros(1,3); c.lower=zeros(1,3); c.upper=zeros(1,3);
for k=1:height(M)
    value=M.(column)(k); name=char(M.name(k)); group=char(M.group(k));
    switch group
        case 'parameter'
            if isfield(c.parameters,name), c.parameters.(name)=value; end
        case {'initial','stabilityWeights','objectiveWeights','lower','upper'}
            index=M.index(k);
            if index<=numel(c.(group)), c.(group)(index)=value; end
        case 'setting'
            c.(name)=value;
    end
end
if model==3, c.parameters.V1=0; c.lower(2)=0; c.upper(2)=0; end
c.classification='RECONSTRUCTION_ASSUMPTION; NOT recovered historical parameters';
c.source='Paper physical pp7-8 (5)-(18), p11 (19)-(23), p15 (26)-(27); private notes';
c.solver='segmented ode45; projected boundary vector field; right-continuous event outputs';
c.optimizer='NEW deterministic baseline-start coordinate search + independent coarse grid; grid refinement if needed';
c.chemicalScenarios=[.035 .010;.020 .010;.010 .010;.020 .020;.050 .030;.020 .005];
c.scenarioSource='DOCUMENTED paper physical p9 Figure4; second archived filename conflicts';
assert(all(isfinite(cell2mat(struct2cell(c.parameters)))),'reconstruction:missing','Incomplete parameters');
end
