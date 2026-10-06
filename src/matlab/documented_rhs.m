function d = documented_rhs(t,N,c)
% RECONSTRUCTED shared continuous equations, source in c.source.
% No solver, implicit workspace, harvest schedule, clipping or numeric defaults.
% The two conflicting peregrine/pollination expressions remain explicit.
validateattributes(N,{'numeric'},{'column','numel',c.species,'finite','nonnegative'});
validateattributes(t,{'numeric'},{'scalar','real','finite'});
p=c.parameters; values=cell2mat(struct2cell(p)); % base MATLAB only
assert(all(isfinite(values)),'documented:missing','Supply all MISSING coefficients with provenance');
assert(p.Ts>0 && p.K10>0 && p.K2>0 && p.K30>0 && abs(p.rhoN1+p.rhoN2-1)<1e-10, ...
    'documented:domain','Positive capacities/period and rho sum1 required');
assert(all([p.F p.V1 p.V2]>=0),'documented:domain','Nonnegative chemical intensities required');
age=t-p.ti; seasonal=1+p.A*sin(2*pi*t/p.Ts);
r1=p.r10+p.tauF*p.F*exp(-p.betaF*age);
if c.model==3
 assert(p.V1==0,'documented:herbicide','Model III requires V1=0');
 if strcmp(c.pollination,'paper_literal'), q4=p.F; q7=p.F;
 else, q4=N(4); q7=N(7); end
 r1=r1+p.tauN4*q4*exp(-p.betaN4*age)+p.tauN7*q7*exp(-p.betaN7*age);
end
r1=r1*seasonal;
K1=p.K10*(exp(-p.iota*t)+p.capacityLambda*(p.Ts-1))+p.capacityLambda*p.F*exp(-p.betaF*age);
K3=p.K30+p.rhoN1*N(1)+p.rhoN2*N(2);
assert(K1>0 && K3>0,'documented:domain','Nonpositive instantaneous capacity');
v1=0; if c.model~=3, v1=p.V10*exp(-p.phi1*age)*p.V1; end
v2=p.V20*exp(-p.phi2*age)*p.V2;
d=zeros(c.species,1);
d(1)=r1*N(1)*(1-N(1)/K1)-p.lambda13*N(1)*N(3)-p.lambda12*N(1)*N(2);
d(2)=p.r2*N(2)*(1-N(2)/p.K2)-v1-p.lambda12*N(1)*N(2);
d(3)=p.r3*N(3)*(1-N(3)/K3)-v2+p.lambda13*N(1)*N(3)-p.lambda34*N(4)*N(3);
if c.model==1, d(4)=p.lambda34*N(3)*N(4)-p.gamma4*N(4); end
if c.model>=2
 assert(p.K4>0 && p.K5>0,'documented:domain','Positive K4,K5 required');
 d(1)=d(1)-p.lambda15*N(1)*N(5);
 d(3)=d(3)-p.lambda35*N(3)*N(5);
 d(5)=p.r5*N(5)*(1-N(5)/p.K5)+p.lambda15*N(1)*N(5)-p.lambda35*N(3)*N(5)-v2;
 d(4)=p.r4*N(4)*(1-N(4)/p.K4)+p.lambda34*N(3)*N(4)-p.lambda46*N(4)*N(6);
 if strcmp(c.peregrine,'paper_literal'), preyTerm=N(4)*N(4);
 else, preyTerm=N(4)*N(6); end
 d(6)=p.lambda46*preyTerm-p.gamma6*N(6);
end
if c.model==3
 assert(p.K7>0,'documented:domain','Positive K7 required');
 d(7)=p.r7*N(7)*(1-N(7)/p.K7);
end
assert(all(isfinite(d)),'documented:finite','Nonfinite derivative');
end
