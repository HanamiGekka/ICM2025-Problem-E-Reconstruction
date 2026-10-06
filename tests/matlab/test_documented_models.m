function tests = test_documented_models
tests=functiontests(localfunctions);
end
function c = toy(model)
% DEMONSTRATION_ONLY unit-test algebra fixtures, never historical defaults.
c=documented_config(model); names=fieldnames(c.parameters);
for i=1:numel(names), c.parameters.(names{i})=0; end
p=c.parameters; p.Ts=1; p.K10=10; p.K2=10; p.K30=10;
p.rhoN1=.5; p.rhoN2=.5; p.r10=1; p.r2=1; p.r3=1;
if model>=2, p.K4=10; p.K5=10; end
if model==3, p.K7=10; end
c.parameters=p;
end
function testMissingGate(t)
for model=1:3
 c=documented_config(model); verifyError(t,@()documented_rhs(0,ones(c.species,1),c),'documented:missing');
 verifyError(t,@()documented_metrics(ones(1,c.species),c),'documented:missing');
end
end
function testModelIAlgebra(t)
c=toy(1); d=documented_rhs(0,[2;3;4;5],c);
verifyEqual(t,d,[1.6;2.1;4*(1-4/12.5);0],'AbsTol',1e-13);
c.parameters.V1=2; c.parameters.V10=3;
d=documented_rhs(0,[2;3;4;5],c); verifyEqual(t,d(2),-3.9,'AbsTol',1e-13);
end
function testPeregrineVariants(t)
c=toy(2); c.parameters.lambda46=.5; c.parameters.gamma6=.1;
a=documented_rhs(0,[1;1;1;2;1;3],c);
c.peregrine='code_informed'; b=documented_rhs(0,[1;1;1;2;1;3],c);
verifyEqual(t,a(6),1.7,'AbsTol',1e-13); verifyEqual(t,b(6),2.7,'AbsTol',1e-13);
verifyEqual(t,a(1:5),b(1:5));
end
function testPollinationVariants(t)
c=toy(3); c.parameters.F=2; c.parameters.tauN4=.1; c.parameters.tauN7=.2;
a=documented_rhs(0,[1;1;1;3;1;1;4],c); c.pollination='population_coupled';
b=documented_rhs(0,[1;1;1;3;1;1;4],c);
verifyEqual(t,a(1),1.6*.9,'AbsTol',1e-13); verifyEqual(t,b(1),2.1*.9,'AbsTol',1e-13);
verifyEqual(t,a(2:end),b(2:end));
c.parameters.V1=1; verifyError(t,@()documented_rhs(0,ones(7,1),c),'documented:herbicide');
end
function testMetricsAndObjective(t)
c=toy(1); c.parameters.F=2; c.stabilityWeights=[.5 .25 .25];
[S,D]=documented_metrics(ones(1,4),c); verifyEqual(t,D,.75);
verifyEqual(t,S,.75*log(2),'AbsTol',1e-13);
[S,D]=documented_metrics(zeros(1,4),c); verifyEqual(t,[S D],[0 0]);
v=chemical_fitness([0;1;2],2*ones(3,1),.5*ones(3,1),[1 2 3],[.2 .3 .5],4);
verifyEqual(t,v.cost,222); verifyEqual(t,v.income,8);
verifyEqual(t,v.fitness,.2*log(1.5)+.3*log(9)-.5*log(223),'AbsTol',1e-13);
end
