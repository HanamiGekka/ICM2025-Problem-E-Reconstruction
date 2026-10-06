function [T,runs] = model1_scenarios(c)
% Six DOCUMENTED Figure4 dose pairs; all other values are NEW assumptions.
if nargin==0, c=reconstruction_config(1); end
runs=cell(6,1); rows=zeros(6,7);
for i=1:6
    d=[c.parameters.F c.chemicalScenarios(i,:)]; r=simulate_reconstructed(c,d); runs{i}=r;
    rows(i,:)=[d r.meanCrop r.meanStability r.meanDiversity r.objective.cost];
end
T=array2table(rows,'VariableNames',{'F','V1','V2','Crop','Stability','Diversity','Cost'});
end
