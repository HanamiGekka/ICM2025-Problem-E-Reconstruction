function keep = pareto_filter(objectives, direction)
% DOCUMENTED intended rule: max field/max stability/min cost, paper (29), N41.
% direction=[1 1 -1]; [-1 -1 1] explicitly recovers reversed C42 line168.
validateattributes(objectives,{'numeric'},{'2d','real','finite'});
assert(numel(direction)==size(objectives,2) && all(abs(direction)==1), ...
    'task4:direction','Use +1 maximize / -1 minimize');
oriented=objectives.*reshape(direction,1,[]); keep=true(size(objectives,1),1);
for i=1:size(oriented,1)
    keep(i)=~any(all(oriented>=oriented(i,:),2) & any(oriented>oriented(i,:),2));
end
end
