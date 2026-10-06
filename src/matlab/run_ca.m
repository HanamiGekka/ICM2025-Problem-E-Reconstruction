function out = run_ca(c)
% RECONSTRUCTED CA simulation only; c.source/provenance travels with output.
% Source had no seed. NEW fixed twister seed in BOTH modes restores caller RNG.
validateattributes(c.n,{'numeric'},{'scalar','integer','positive'});
validateattributes(c.steps,{'numeric'},{'scalar','integer','positive'});
validateattributes(c.dt,{'numeric'},{'scalar','finite','positive'});
validateattributes(c.switches,{'numeric','logical'},{'size',[1 4],'binary'});
saved=rng; cleanup=onCleanup(@()rng(saved)); rng(c.seed,c.rngAlgorithm);
N=zeros(c.n,c.n,8); N(:,:,1)=c.initial(1);
for i=2:8, N(:,:,i)=c.initial(i)*rand(c.n); end
F=c.fertilizerOn;
if strcmp(c.variant,'corrected'), F=F*c.switches(1); N(:,:,8)=N(:,:,8)*c.switches(2); end
initial=N; peak=[-Inf -Inf -Inf]; summary=zeros(c.steps,12); clipped=0;
cost=organic_cost(c.switches,c.costDuration,c.costConvention)*ones(c.n);
events=false(c.steps,3); order=[1 2 3 5 4 6 7 8];
for k=1:c.steps
    noise=ones(1,8); noise(order)=1+c.noiseAmplitude*(rand(1,8)-.5);
    [N,count]=farmland_ca_step(N,(k-1)*c.dt,F,c,noise); clipped=clipped+count;
    [N,events(k,:)]=management_events(N,k,c);
    [g,S,D]=ecosystem_metrics(N,F,c.metric);
    [rgb,peak]=ecosystem_rgb(cost,g,S,peak,c);
    summary(k,:)=[(k-1)*c.dt,reshape(mean(N,[1 2]),1,8),mean(g,'all'),mean(S,'all'),mean(D,'all')];
end
out=struct('config',c,'F',F,'initial',initial,'final',N,'summary',summary, ...
    'events',events,'rgb',rgb,'normalizationPeaks',peak,'clippedValues',clipped);
end
