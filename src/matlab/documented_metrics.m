function [S,D] = documented_metrics(N,c)
% DOCUMENTED paper (16)-(18); not Task4 fertilizer-modified S.
validateattributes(N,{'numeric'},{'2d','finite','nonnegative'});
assert(size(N,2)==c.species,'documented:dimension','Unexpected species count');
w=c.stabilityWeights;
assert(all(isfinite(w)) && all(w>=0) && abs(sum(w)-1)<1e-10, ...
 'documented:missing','Supply documented stability weights (numeric values MISSING)');
p=c.parameters; assert(all(isfinite([p.F p.V1 p.V2])),'documented:missing','Chemical inputs MISSING');
total=sum(N,2); assert(all(isfinite(total)),'documented:finite','Population overflow');
D=1-sum((N./max(total,realmin)).^2,2); D(total==0)=0;
S=D*log1p(w(1)*p.F)*exp(-w(2)*p.V1)*exp(-w(3)*p.V2);
end
