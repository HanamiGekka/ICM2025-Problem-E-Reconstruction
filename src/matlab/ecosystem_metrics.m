function [g, stability, diversity] = ecosystem_metrics(N,F,mode)
% C42 metric block; paper (32)-(34). Species always in last dimension.
% c42: crop-minus-pests even at zero pests, modified Simpson diversity.
% ca_compat: matrix-wide historical guards; corrected: per-cell paper guards.
validateattributes(N,{'numeric'},{'real','finite','nonnegative'});
assert(size(N,ndims(N))==8,'task4:dimension','Expected eight species');
dim=ndims(N); total=sum(N,dim); p=N./max(total,realmin);
assert(all(isfinite(total),'all'),'task4:finite','Population total overflow');
diversity=1-sum(p.^2,dim); diversity(total==0)=0;
if dim==2, crop=N(:,1); pests=N(:,3)+N(:,5);
else, crop=N(:,:,1); pests=N(:,:,3)+N(:,:,5); end
g=crop-pests;
switch mode
    case 'c42'
    case 'ca_compat'
        if ~all(pests(:)>0), g=zeros(size(crop)); end
        if ~all(total(:)>0), diversity=zeros(size(total)); end
    case 'corrected'
        g(pests==0)=0; % literal paper (32); not a newly invented crop score
    otherwise, error('task4:metric','Unknown metric mode');
end
stability=diversity.*(1+log1p(0.005*F));
end
