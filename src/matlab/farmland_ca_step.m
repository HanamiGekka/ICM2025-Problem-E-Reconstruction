function [next,clipped,means] = farmland_ca_step(N,t,F,c,noise)
% RECONSTRUCTED exact CA RHS, c.source SHA in config; paper §7.4.
% Includes center, zero-padding /9; N5 growth uses neighborhood M5 as source.
% noise is eight SCALAR species factors in species order; no cellwise draws.
validateattributes(N,{'numeric'},{'size',[c.n c.n 8],'real','finite','nonnegative'});
validateattributes(noise,{'numeric'},{'size',[1 8],'real','finite','nonnegative'});
means=zeros(size(N)); H=zeros(size(N));
for i=1:8, means(:,:,i)=conv2(N(:,:,i),ones(3),'same')/9; end
M=means;
r1=(.6+.02*F*exp(-.005*mod(t,12))+.001*M(:,:,4)*exp(-.005*mod(t+8,12)) ...
    +.001*M(:,:,7)*exp(-.005*mod(t+8,12)))*(1+.5*sin(2*pi*t/12));
K1=400*(exp(-.003*t)+.01*(c.harvestPeriod-1))+.02*F*exp(-.05*t);
H(:,:,1)=r1.*N(:,:,1).*(1-N(:,:,1)/K1)-.0025*N(:,:,1).*M(:,:,3) ...
    -.002*N(:,:,1).*M(:,:,2)-.002*N(:,:,1).*M(:,:,5);
H(:,:,2)=.75*N(:,:,2).*(1-N(:,:,2)/180)-.002*M(:,:,1).*N(:,:,2);
r3=.05*(1+.1*sin(2*pi*t/12)); r5=.03*(1+.1*sin(2*pi*t/12));
K=120+.02*M(:,:,1)+.01*M(:,:,2)+12*sin(2*pi*c.seasonPeriod);
H(:,:,3)=r3*N(:,:,3).*(1-N(:,:,3)./K)+.0005*M(:,:,1).*N(:,:,3) ...
    -.002*M(:,:,4).*N(:,:,3)-.001*N(:,:,3).*M(:,:,8);
H(:,:,5)=r5*M(:,:,5).*(1-N(:,:,5)./K)+.0005*M(:,:,1).*N(:,:,5) ...
    -.002*N(:,:,5).*M(:,:,3)-.001*N(:,:,5).*M(:,:,8);
H(:,:,4)=.2*N(:,:,4).*(1-N(:,:,4)/100)+.005*M(:,:,3).*N(:,:,4)-.005*N(:,:,4).*M(:,:,6);
H(:,:,6)=.005*M(:,:,4).*N(:,:,6)-.12*N(:,:,6);
H(:,:,7)=.2*N(:,:,7).*(1-M(:,:,7)/100);
H(:,:,8)=.06*N(:,:,8).*(1-N(:,:,8)/50)+.001*M(:,:,3).*N(:,:,8)+.001*M(:,:,5).*N(:,:,8);
raw=N+c.dt.*H.*reshape(noise,1,1,8); clipped=sum(raw<0,'all');
assert(all(isfinite(raw),'all'),'task4:finite','Nonfinite CA update'); next=max(raw,0);
end
