function r = simulate_reconstructed(c,decision)
% NEW event-aware integrator of documented_rhs, not an original solver replay.
if nargin<2, decision=[c.parameters.F c.parameters.V1 c.parameters.V2]; end
validateattributes(decision,{'numeric'},{'size',[1 3],'finite','nonnegative'});
assert(c.model~=3 || decision(2)==0,'documented:herbicide','Model III requires V1=0');
validateattributes(c.initial,{'numeric'},{'row','numel',c.species,'finite','nonnegative'});
assert(c.horizon>0 && c.outputStep>0 && c.applicationPeriod>0 && c.harvestPeriod>0, ...
    'reconstruction:schedule','Positive schedules required');
c.parameters.F=decision(1); c.parameters.V1=decision(2); c.parameters.V2=decision(3);
documented_rhs(0,c.initial',c); % missing/schema/domain gate before integration
T=c.horizon;
applications=0:c.applicationPeriod:T; harvests=c.harvestPeriod:c.harvestPeriod:T;
boundaries=unique([0 applications harvests T]);
time=unique([0:c.outputStep:T boundaries])'; states=zeros(numel(time),c.species);
states(1,:)=c.initial; N=c.initial'; integralCrop=0; integralS=0; integralD=0;
ledger=zeros(0,4); negativeTrialCount=0; boundaryRemovalCount=0;
options=odeset('RelTol',c.relTol,'AbsTol',c.absTol,'NonNegative',1:c.species,'MaxStep',c.maxStep);
for k=1:numel(boundaries)-1
    left=boundaries(k); right=boundaries(k+1);
    c.parameters.ti=applications(find(applications<=left+1e-10,1,'last'));
    sample=time(time>=left & time<=right);
    % Always >=3 points: ode45 otherwise returns its adaptive internal grid.
    grid=unique([sample; (left+right)/2]);
    [tt,NN]=ode45(@rhs,grid,N,options); NN=max(NN,0);
    [SS,DD]=documented_metrics(NN,c);
    integralCrop=integralCrop+trapz(tt,NN(:,1));
    integralS=integralS+trapz(tt,SS); integralD=integralD+trapz(tt,DD);
    [~,q]=ismember(sample,tt); [~,row]=ismember(sample,time); states(row,:)=NN(q,:);
    N=NN(end,:)';
    isHarvest=any(abs(harvests-right)<1e-10); isApplication=any(abs(applications-right)<1e-10);
    preCrop=N(1);
    if isHarvest, N(1)=c.initial(1); end % record harvest, remove crop, immediately replant
    if isHarvest || isApplication
        ledger(end+1,:)=[right isHarvest isApplication preCrop]; %#ok<AGROW>
    end
    states(time==right,:)=N'; % post-harvest output; integral uses pre-event endpoint
end
[S,D]=documented_metrics(states,c);
meanCrop=integralCrop/T; meanS=integralS/T;
value=chemical_fitness([0;T],[meanCrop;meanCrop],[meanS;meanS],decision,c.objectiveWeights,c.cropPrice);
r=struct('config',c,'time',time,'states',states,'stability',S,'diversity',D, ...
    'meanCrop',meanCrop,'meanStability',meanS,'meanDiversity',integralD/T,'objective',value, ...
    'events',array2table(ledger,'VariableNames',{'Time','Harvest','Application','PreHarvestCrop'}), ...
    'negativeTrialCount',negativeTrialCount,'boundaryRemovalCount',boundaryRemovalCount, ...
    'classification','NUMERICALLY RECONSTRUCTED WITH ASSUMPTIONS');
r.events.Harvest=logical(r.events.Harvest); r.events.Application=logical(r.events.Application);
assert(all(isfinite(states),'all'),'reconstruction:finite','Nonfinite trajectory');
    function d=rhs(t,y)
        negativeTrialCount=negativeTrialCount+nnz(y<0);
        d=documented_rhs(t,max(y,0),c);
        blocked=y<=0 & d<0; boundaryRemovalCount=boundaryRemovalCount+nnz(blocked);
        d(blocked)=0; % additive chemical removal cannot remove absent population
    end
end
