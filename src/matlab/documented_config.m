function c = documented_config(model,peregrine,pollination)
% DOCUMENTED equations only: paper §§4-6, (5)-(14),(19)-(23),(26)-(27).
% Original Task1/2/3 model notes; numeric parameterization remains MISSING.
if nargin<2, peregrine='paper_literal'; end
if nargin<3, pollination='paper_literal'; end
assert(ismember(model,[1 2 3]),'documented:model','Model must be 1,2,3');
assert(ismember(peregrine,{'paper_literal','code_informed'}),'documented:variant','Unknown peregrine variant');
assert(ismember(pollination,{'paper_literal','population_coupled'}),'documented:variant','Unknown pollination variant');
names={'r10','tauF','betaF','A','Ts','K10','iota','capacityLambda','r2','K2', ...
 'lambda12','V10','phi1','r3','K30','rhoN1','rhoN2','lambda13','lambda34','V20','phi2','gamma4','ti','F','V1','V2'};
c.species=4;
if model>=2
 names(strcmp(names,'gamma4'))=[];
 names=[names,{'r4','K4','r5','K5','lambda15','lambda35','lambda46','gamma6'}]; c.species=6;
end
if model==3
 names(ismember(names,{'V10','phi1'}))=[];
 names=[names,{'tauN4','tauN7','betaN4','betaN7','r7','K7'}]; c.species=7;
end
c=struct('model',model,'species',c.species,'peregrine',peregrine,'pollination',pollination, ...
 'classification','DOCUMENTED_EQUATIONS_ONLY; numeric parameterization MISSING', ...
 'source','Private paper §§4-6: physical pp7-8,11,15; reviewed equation traceability', ...
 'parameters',cell2struct(num2cell(NaN(size(names))),names,2),'stabilityWeights',[NaN NaN NaN]);
if model==3, c.parameters.V1=0; end % DOCUMENTED herbicide removal
end
