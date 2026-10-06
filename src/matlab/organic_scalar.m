function out = organic_scalar(s,c)
% RECONSTRUCTED C42 source semantics, NOT the complete competition source.
% Source: c.source; paper pp17-18 (29)-(34); C42 governs actual RHS.
% Preserves sequential N8 update, frozen N4/N6/N7, per-step controls, no harvest.
validateattributes(s,{'numeric','logical'},{'size',[1 4],'binary'});
validateattributes(c.dt,{'numeric'},{'scalar','positive','finite'});
validateattributes(c.duration,{'numeric'},{'scalar','nonnegative','finite'});
validateattributes(c.initial,{'numeric'},{'size',[1 8],'finite','nonnegative'});
time=0:c.dt:c.duration;
if strcmp(c.variant,'corrected')
    steps=round(c.duration/c.dt);
    assert(steps>0 && abs(steps*c.dt-c.duration)<1e-10,'task4:grid','Duration must be an integer step count');
    time=(0:steps-1)*c.dt; % exactly duration/dt updates, no extra terminal update
end
N=c.initial; N(8)=N(8)*s(2); F=c.fertilizerOn*s(1);
states=zeros(numel(time),8); metrics=zeros(numel(time),3); clipped=0;
for k=1:numel(time)
    t=time(k);
    r1=(0.6+0.02*F*exp(-0.005*mod(t,12)) ...
       +0.001*N(4)*exp(-0.005*mod(t+8,12)) ...
       +0.001*N(7)*exp(-0.005*mod(t+8,12)))*(1+0.5*sin(2*pi*t/12));
    K1=400*(exp(-0.003*t)+0.01*(c.harvestPeriod-1))+0.02*F*exp(-0.05*t);
    d1=r1*N(1)*(1-N(1)/K1)-0.0025*N(1)*N(3)-0.002*N(1)*N(2)-0.002*N(1)*N(5);
    d2=0.75*N(2)*(1-N(2)/180)-0.002*N(1)*N(2);
    raw=(N(2)+d2*c.dt)*(1-s(3)+s(3)*c.weedRetention);
    clipped=clipped+(raw<0); N(2)=max(raw,0);
    d3=0.05*N(3)*(1-N(3)/c.pestCapacity)+0.0005*N(1)*N(3)-0.002*N(4)*N(3)-0.001*N(3)*N(8);
    d5=0.03*N(5)*(1-N(5)/c.pestCapacity)+0.0005*N(1)*N(5)-0.002*N(5)*N(3)-0.001*N(5)*N(8);
    raw=(N([3 5])+[d3 d5]*c.dt)*(1-s(4)+s(4)*c.pestRetention);
    clipped=clipped+sum(raw<0); N([3 5])=max(raw,0);
    d8=0.07*N(8)*(1-N(8)/50)+0.001*N(3)*N(8)+0.001*N(5)*N(8);
    raw=N([1 8])+[d1 d8]*c.dt;
    clipped=clipped+sum(raw<0); N([1 8])=max(raw,0);
    assert(all(isfinite(N)),'task4:finite','Nonfinite state');
    states(k,:)=N;
    [metrics(k,1),metrics(k,2),metrics(k,3)]=ecosystem_metrics(N,F,c.metric);
end
out=struct('switches',s,'config',c,'time',time(:),'states',states, ...
    'metrics',metrics,'mean',mean(metrics,1),'cost',organic_cost(s,c.duration,c.costConvention), ...
    'clippedValues',clipped,'F',F);
end
