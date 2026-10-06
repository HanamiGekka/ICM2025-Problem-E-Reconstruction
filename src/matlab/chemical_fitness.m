function value = chemical_fitness(time,crop,stability,decision,weights,cropPrice)
% DOCUMENTED paper (24), R2 unit costs [2,50,40]. NEW declared aggregation:
% trapezoidal time averages for supplied crop/S, NOT a recovered GA fitness.
validateattributes(time,{'numeric'},{'column','finite','increasing','numel',numel(crop)});
validateattributes(crop,{'numeric'},{'column','finite','nonnegative'});
validateattributes(stability,{'numeric'},{'column','finite','nonnegative','numel',numel(crop)});
validateattributes(decision,{'numeric'},{'size',[1 3],'finite','nonnegative'});
validateattributes(weights,{'numeric'},{'size',[1 3],'finite','nonnegative'});
validateattributes(cropPrice,{'numeric'},{'scalar','finite','nonnegative'});
assert(numel(time)>=2 && abs(sum(weights)-1)<1e-10,'documented:objective','Need time interval and weights sum1');
T=time(end)-time(1); Y=trapz(time,crop)/T; S=trapz(time,stability)/T;
cost=dot(decision,[2 50 40]); income=Y*cropPrice;
value=struct('fitness',weights(1)*log1p(S)+weights(2)*log1p(income)-weights(3)*log1p(cost), ...
 'meanCrop',Y,'meanStability',S,'income',income,'cost',cost,'weights',weights, ...
 'cropPrice',cropPrice,'decision',decision,'aggregation','NEW trapezoidal time_average');
end
