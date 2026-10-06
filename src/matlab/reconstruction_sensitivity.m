function [T,ranking,profiles] = reconstruction_sensitivity
% NEW bounded OAT perturbations; not historical regression or field evidence.
cases={1,'initial',1,'initial_crop';1,'initial',3,'initial_pests'; ...
 1,'parameters','lambda13','crop_pest_interaction';1,'parameters','tauF','fertilizer_efficacy'; ...
 2,'parameters','V10','herbicide_efficacy';2,'parameters','phi1','herbicide_decay'; ...
 2,'objectiveWeights',1,'stability_utility_weight';2,'objectiveWeights',2,'income_utility_weight'; ...
 3,'parameters','tauN7','bee_pollination';3,'parameters','betaN7','pollination_decay'};
base=cell(3,1); rows=cell(0,1);
for m=1:3, base{m}=simulate_reconstructed(reconstruction_config(m)); end
for i=1:size(cases,1)
 m=cases{i,1}; group=cases{i,2}; key=cases{i,3}; name=cases{i,4}; c=reconstruction_config(m);
 if strcmp(group,'parameters'), original=c.parameters.(key); else, original=c.(group)(key); end
 for delta=[-.2 -.1 .1 .2]
  q=c;
  if strcmp(group,'parameters'), q.parameters.(key)=original*(1+delta);
  else
   q.(group)(key)=original*(1+delta);
   if strcmp(group,'objectiveWeights'), q.objectiveWeights=q.objectiveWeights/sum(q.objectiveWeights); end
  end
  r=simulate_reconstructed(q);
  rows{end+1,1}=record(m,name,'fixed_baseline_decision',delta,original,original*(1+delta),r,base{m}); %#ok<AGROW>
 end
end
% Optimization-bound effects use the same smaller budget for control/perturbation.
c=reconstruction_config(2); c.gridLevels=3; c.searchSweeps=3;
opt=optimize_reconstructed(c); control=simulate_reconstructed(c,opt.decision);
for index=[1 3]
 for delta=[-.2 .2]
  q=c; q.upper(index)=q.upper(index)*(1+delta); o=optimize_reconstructed(q);
  r=simulate_reconstructed(q,o.decision);
  rows{end+1,1}=record(2,sprintf('upper_bound_%d',index),'reoptimized_grid3_sweeps3', ...
      delta,c.upper(index),q.upper(index),r,control); %#ok<AGROW>
 end
end
T=vertcat(rows{:}); names=unique(T.Parameter,'stable'); ranking=table;
for i=1:numel(names)
 mask=strcmp(T.Parameter,names{i}); influence=max(abs(T{mask,{'RelativeCrop','RelativeStability','RelativeFitness'}}),[],'all');
 ranking=[ranking;table(names(i),influence,'VariableNames',{'Parameter','MaxRelativeInfluence'})]; %#ok<AGROW>
end
ranking=sortrows(ranking,'MaxRelativeInfluence','descend');
profiles=table;
for m=1:3
 for profile={'reconstructed_low','reconstructed_baseline','reconstructed_high'}
  r=simulate_reconstructed(reconstruction_config(m,profile{1}));
  profiles=[profiles;table(m,profile,r.meanCrop,r.meanStability,r.objective.fitness, ...
   'VariableNames',{'Model','Profile','Crop','Stability','Fitness'})]; %#ok<AGROW>
 end
end
end
function T=record(m,name,mode,delta,bv,v,r,b)
reference=[b.meanCrop b.meanStability b.objective.fitness]; values=[r.meanCrop r.meanStability r.objective.fitness];
change=(values-reference)./max(abs(reference),1e-12);
T=table(m,{name},{mode},delta,bv,v,values(1),values(2),values(3),change(1),change(2),change(3), ...
 'VariableNames',{'Model','Parameter','Experiment','Perturbation','BaselineValue','PerturbedRawValue', ...
 'Crop','Stability','Fitness','RelativeCrop','RelativeStability','RelativeFitness'});
end
