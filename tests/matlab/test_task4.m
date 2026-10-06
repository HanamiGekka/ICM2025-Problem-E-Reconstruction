function tests = test_task4
tests=functiontests(localfunctions);
end
function testCosts(t)
verifyEqual(t,organic_cost([1 1 1 1],100,'c42'),566.6666666666667,'AbsTol',1e-10);
verifyEqual(t,organic_cost([1 1 1 1],100,'ca'),616.6666666666667,'AbsTol',1e-10);
verifyEqual(t,organic_cost([0 1 0 0],0,'c42'),200);
verifyError(t,@()organic_cost([0 0 0 0],1,'bad'),'task4:cost');
end
function testMetrics(t)
[g,b,D]=ecosystem_metrics(zeros(1,8),0,'c42'); verifyEqual(t,[g b D],[0 0 0]);
N=zeros(1,8); N(1)=5; [g,b]=ecosystem_metrics(N,10,'c42');
verifyEqual(t,g,5); verifyEqual(t,b,0);
end
function testPareto(t)
A=[5 5 2; 4 4 3; 5 5 2; 6 3 1];
verifyEqual(t,pareto_filter(A,[1 1 -1]),[true;false;true;true]);
verifyEqual(t,pareto_filter(A,[-1 -1 1]),[false;true;false;true]);
verifyEqual(t,pareto_filter(zeros(2,3),[1 1 -1]),true(2,1));
end
function testHistoricalScenarios(t)
c=task4_config; [T,runs]=organic_scenarios(c); verifyEqual(t,height(T),16);
verifyEqual(t,numel(unique(T{:,1:4},'rows')),64);
verifyEqual(t,size(runs{1}.states),[1001 8]);
for i=1:16
    verifyTrue(t,all(isfinite(runs{i}.states),'all'));
    verifyGreaterThanOrEqual(t,min(runs{i}.states,[],'all'),0);
    verifyEqual(t,runs{i}.states(:,[4 6 7]),repmat([20 10 50],1001,1));
end
verifyEqual(t,sum(T.IntendedPareto),14); verifyEqual(t,sum(T.HistoricalReversedPareto),14);
h=historical_targets; targets=h.table5{:,:}; verifyEqual(t,size(targets),[14 7]);
for i=1:14
    k=find(all(T{:,1:4}==targets(i,[1 4 2 3]),2));
    verifyTrue(t,T.HistoricalReversedPareto(k));
    verifyLessThanOrEqual(t,abs(T.Field(k)-targets(i,5)),0.0051);
    verifyLessThanOrEqual(t,abs(T.Stability(k)-targets(i,6)),0.0000051);
    verifyLessThanOrEqual(t,abs(T.Cost(k)-targets(i,7)),0.0051);
end
verifyEqual(t,sum(T.HistoricalReversedPareto),size(targets,1));
end
function testCorrectedDifference(t)
c=task4_config('corrected'); r=organic_scalar([0 0 0 0],c);
verifyEqual(t,size(r.states),[1000 8]); verifyEqual(t,r.F,0);
verifyEqual(t,r.states(:,8),zeros(1000,1));
h=organic_scalar([0 0 0 0],task4_config);
verifyEqual(t,r.states,h.states(1:1000,:),'AbsTol',1e-12);
N=zeros(1,8); N(1)=200;
[g,b]=ecosystem_metrics(N,0,'corrected'); verifyEqual(t,[g b],[0 0]);
c.duration=0.15; verifyError(t,@()organic_scalar([0 0 0 0],c),'task4:grid');
end
function testIndependentDominance(t)
T=organic_scenarios(task4_config); A=T{:,5:7}; expected=true(16,1);
for i=1:16
 for j=1:16
  better=[A(j,1)>=A(i,1),A(j,2)>=A(i,2),A(j,3)<=A(i,3)];
  strict=[A(j,1)>A(i,1),A(j,2)>A(i,2),A(j,3)<A(i,3)];
  if sum(better)==3 && sum(strict)>0, expected(i)=false; end
 end
end
verifyEqual(t,T.IntendedPareto,expected);
end
function testTimestepConvergence(t)
c=task4_config('corrected'); c.duration=12;
r1=organic_scalar([0 0 0 0],c); c.dt=.05; r2=organic_scalar([0 0 0 0],c);
c.dt=.025; r3=organic_scalar([0 0 0 0],c);
e1=norm(r1.states(end,:)-r3.states(end,:)); e2=norm(r2.states(end,:)-r3.states(end,:));
verifyLessThan(t,e2,e1); verifyLessThan(t,e1/norm(r3.states(end,:)),.02);
end
function testNeighborhoodAndUpdate(t)
c=ca_config; c.n=3; N=ones(3,3,8);
[next,clipped,M]=farmland_ca_step(N,0,0,c,ones(1,8));
verifyEqual(t,size(next),[3 3 8]); verifyEqual(t,clipped,0);
verifyEqual(t,M(1,1,1),4/9,'AbsTol',1e-15); verifyEqual(t,M(2,2,1),1);
expected=1+.1*(.06*(1-1/50)+.001*(4/9)+.001*(4/9));
verifyEqual(t,next(1,1,8),expected,'AbsTol',1e-14);
end
function testCARepeatAndSwitches(t)
c=ca_config; c.n=4; c.steps=125; c.switches=[0 0 1 1];
saved=rng; a=run_ca(c); verifyEqual(t,rng,saved); b=run_ca(c);
verifyEqual(t,a.final,b.final); verifyEqual(t,a.summary,b.summary); verifyEqual(t,a.rgb,b.rgb);
verifyEqual(t,a.F,0); verifyEqual(t,a.final(:,:,8),zeros(4));
verifyTrue(t,all(isfinite(a.final),'all')); verifyGreaterThanOrEqual(t,min(a.final,[],'all'),0);
verifyEqual(t,size(a.rgb),[12 12 3]); verifyGreaterThanOrEqual(t,min(a.rgb,[],'all'),0);
verifyLessThanOrEqual(t,max(a.rgb,[],'all'),1);
h=ca_config('historical_compat'); h.n=4; h.steps=1; h.switches=[0 0 0 0]; r=run_ca(h);
verifyEqual(t,r.F,10); verifyGreaterThan(t,min(r.initial(:,:,8),[],'all'),0);
c.steps=1; c.noiseAmplitude=0; r=run_ca(c);
[pre,~]=farmland_ca_step(r.initial,0,0,c,ones(1,8));
verifyEqual(t,r.final(:,:,1),200*ones(4));
verifyEqual(t,r.final(:,:,2),pre(:,:,2)*.8,'AbsTol',1e-13);
verifyEqual(t,r.final(:,:,3),pre(:,:,3)*.8,'AbsTol',1e-13);
end
function testCAEventsAndMetricEdges(t)
c=ca_config; N=ones(2,2,8); [r,e]=management_events(N,1,c);
verifyEqual(t,e,[true true true]); verifyEqual(t,r(:,:,1),200*ones(2));
[~,e]=management_events(N,61,c); verifyEqual(t,e,[false true true]);
[~,e]=management_events(N,121,c); verifyEqual(t,e,[true true true]);
c.dt=.07; verifyError(t,@()management_events(N,1,c),'task4:eventGrid');
N(:,:,1)=20; N(1,1,:)=0;
[g,b]=ecosystem_metrics(N,0,'ca_compat'); verifyEqual(t,g,zeros(2)); verifyEqual(t,b,zeros(2));
[g,b]=ecosystem_metrics(N,0,'corrected'); verifyEqual(t,g(1,1),0); verifyEqual(t,b(1,1),0);
verifyGreaterThan(t,g(2,2),0); verifyGreaterThan(t,b(2,2),0);
end
function testRGBNormalization(t)
c=ca_config; [r,~,raw]=ecosystem_rgb(1000*ones(2),-ones(2),ones(2),[-Inf -Inf -Inf],c);
verifyEqual(t,size(r),[6 6 3]); verifyEqual(t,raw(:,:,1),ones(2)); verifyEqual(t,raw(:,:,2),zeros(2));
c=ca_config('historical_compat'); [~,~,raw]=ecosystem_rgb(zeros(2),-ones(2),ones(2),[-Inf -Inf -Inf],c);
verifyEqual(t,raw(:,:,2),-ones(2));
end
