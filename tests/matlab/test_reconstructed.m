function tests = test_reconstructed
tests=functiontests(localfunctions);
end
function testProfiles(t)
for m=1:3
 d=reconstruction_config(m,'documented_only');
 verifyTrue(t,any(isnan(cell2mat(struct2cell(d.parameters)))));
 for profile={'reconstructed_baseline','reconstructed_low','reconstructed_high'}
  c=reconstruction_config(m,profile{1});
  verifyTrue(t,all(isfinite(cell2mat(struct2cell(c.parameters)))));
  verifyEqual(t,sum(c.stabilityWeights),1,'AbsTol',1e-14);
  verifyEqual(t,sum(c.objectiveWeights),1,'AbsTol',1e-14);
  verifyEqual(t,numel(c.initial),c.species);
 end
end
verifyError(t,@()reconstruction_config(1,'unknown'),'reconstruction:profile');
end
function testModel1EventsAndDeterminism(t)
c=reconstruction_config(1); a=simulate_reconstructed(c); b=simulate_reconstructed(c);
verifyEqual(t,a.states,b.states); verifyEqual(t,a.objective,b.objective);
verifySize(t,a.states,[73 4]); verifyTrue(t,all(isfinite(a.states),'all'));
verifyGreaterThanOrEqual(t,min(a.states,[],'all'),0);
verifyEqual(t,a.events.Time,(6:6:36)');
verifyEqual(t,a.events.Harvest,mod((6:6:36)',12)==0);
verifyEqual(t,a.states(ismember(a.time,[12 24 36]),1),repmat(c.initial(1),3,1));
verifyGreaterThan(t,a.events.PreHarvestCrop(2),0);
[S,D]=documented_metrics(a.states,c); verifyEqual(t,a.stability,S); verifyEqual(t,a.diversity,D);
verifyGreaterThan(t,a.meanCrop,0);
end
function testSixScenarios(t)
[T,r]=model1_scenarios; verifyEqual(t,height(T),6); verifyEqual(t,numel(r),6);
c=reconstruction_config(1); verifyEqual(t,T{:,2:3},c.chemicalScenarios);
verifyGreaterThan(t,range(T.Crop),0.01);
end
function testResolutionAndSensitivity(t)
c=reconstruction_config(1); a=simulate_reconstructed(c);
c.outputStep=.25; c.maxStep=.25; c.relTol=1e-7; b=simulate_reconstructed(c);
verifyLessThan(t,abs(a.meanCrop-b.meanCrop)/b.meanCrop,.005);
verifyLessThan(t,abs(a.meanStability-b.meanStability)/b.meanStability,.005);
for name={'lambda13','tauF','phi1'}
 c=reconstruction_config(1); c.parameters.(name{1})=c.parameters.(name{1})*1.2;
 b=simulate_reconstructed(c); verifyGreaterThan(t,abs(a.meanCrop-b.meanCrop),1e-5);
end
end
function testOptimizerIndependentGrid(t)
c=reconstruction_config(2); c.gridLevels=3; c.searchSweeps=3;
saved=rng; target=[6 .03 .01]; score=@(q)-sum(((q-target)./[10 .06 .06]).^2);
a=optimize_reconstructed(c,score); b=optimize_reconstructed(c,score);
baseline=[c.parameters.F c.parameters.V1 c.parameters.V2];
verifyEqual(t,a.history{1,2:4},baseline);
verifyEqual(t,a.history.Fitness(1),score(baseline),'AbsTol',1e-14);
verifyEqual(t,a.history.BestFitness(end),a.fitness,'AbsTol',1e-14);
verifyEqual(t,rng,saved); verifyEqual(t,a.decision,b.decision); verifyEqual(t,a.history,b.history);
verifyGreaterThanOrEqual(t,a.fitness,a.gridFitness);
verifyGreaterThanOrEqual(t,a.decision,c.lower); verifyLessThanOrEqual(t,a.decision,c.upper);
verifyGreaterThanOrEqual(t,min(diff(a.history.BestFitness)),0);
verifyLessThan(t,norm((a.decision-target)./[10 .06 .06]),.15);
end
function testSixAndSevenSpecies(t)
for m=2:3
 c=reconstruction_config(m); a=simulate_reconstructed(c);
 verifySize(t,a.states,[73 c.species]); verifyGreaterThanOrEqual(t,min(a.states,[],'all'),0);
 verifyTrue(t,all(isfinite(a.states),'all'));
 if m==2, c.peregrine='paper_literal'; else, c.pollination='paper_literal'; end
 b=simulate_reconstructed(c); verifyGreaterThan(t,abs(a.meanCrop-b.meanCrop),1e-5);
end
c=reconstruction_config(3); c.initial(7)=0; noBee=simulate_reconstructed(c);
verifyEqual(t,noBee.states(:,7),zeros(73,1)); c.initial(7)=40; bee=simulate_reconstructed(c);
verifyGreaterThan(t,bee.meanCrop,noBee.meanCrop);
verifyError(t,@()simulate_reconstructed(c,[5 .01 .02]),'documented:herbicide');
end
function testModelOptimizers(t)
for m=2:3
 c=reconstruction_config(m); c.horizon=12; c.gridLevels=3; c.searchSweeps=2;
 a=optimize_reconstructed(c); before=simulate_reconstructed(c); after=simulate_reconstructed(c,a.decision);
 verifyGreaterThanOrEqual(t,a.fitness,a.gridFitness-1e-12);
 verifyGreaterThanOrEqual(t,a.fitness,before.objective.fitness-1e-12);
 verifyEqual(t,a.fitness,after.objective.fitness,'AbsTol',1e-12);
 verifyEqual(t,a.history.Fitness(1),before.objective.fitness,'AbsTol',1e-12);
 if m==3, verifyEqual(t,a.decision(2),0); end
end
end
function testSensitivityExports(t)
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
T=readtable(fullfile(root,'results','reproduced','full','sensitivity_oat.csv'));
verifyEqual(t,height(T),44); verifyEqual(t,unique(T.Perturbation),[-.2;-.1;.1;.2]);
for model=1:3
 if model==1
  label='crop_pest_interaction'; field='lambda13';
 elseif model==2
  label='herbicide_decay'; field='phi1';
 else
  label='bee_pollination'; field='tauN7';
 end
 mask=T.Model==model & strcmp(T.Parameter,label) & T.Perturbation==.2;
 verifyEqual(t,sum(mask),1); c=reconstruction_config(model); c.parameters.(field)=c.parameters.(field)*1.2;
 r=simulate_reconstructed(c); verifyEqual(t,T.Crop(mask),r.meanCrop,'AbsTol',1e-10);
 verifyEqual(t,T.Stability(mask),r.meanStability,'AbsTol',1e-12);
end
end
function testParameterBoundsAndUnits(t)
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
M=readtable(fullfile(root,'config','reconstruction_parameters.csv'),TextType='string');
verifyGreaterThanOrEqual(t,M.baseline,M.lower); verifyLessThanOrEqual(t,M.baseline,M.upper);
verifyGreaterThanOrEqual(t,M.low,M.lower); verifyLessThanOrEqual(t,M.high,M.upper);
verifyFalse(t,any(M.source_class=="DOCUMENTED"));
verifyTrue(t,all(strlength(M.rationale)>0)); verifyTrue(t,all(strlength(M.unit)>0));
end
