function [rgb,peak,raw] = ecosystem_rgb(cost,g,S,peak,c)
% RGB_color_matrix.m SHA E43A...54A2. Separate mapping, no UI/toolbox resize.
% kron exactly replicates nearest-neighbor integer enlargement.
assert(isequal(size(cost),size(g),size(S)),'task4:rgbSize','Channel dimensions differ');
validateattributes(c.blockSize,{'numeric'},{'scalar','integer','positive'});
peak=max(peak,[max(cost,[],'all'),max(g,[],'all'),max(S,[],'all')]);
if strcmp(c.variant,'historical_compat')
    green=g; blue=S;
    if peak(2)>0, green=g/peak(2); end
    if peak(3)>0, blue=S/peak(3); end
    raw=cat(3,cost/566.67,green,blue);
else
    validateattributes(c.rgbScales,{'numeric'},{'size',[1 3],'finite','positive'});
    raw=cat(3,cost,g,S)./reshape(c.rgbScales,1,1,3); raw=max(0,min(1,raw));
end
assert(all(isfinite(raw),'all'),'task4:rgbFinite','Nonfinite RGB');
rgb=zeros(size(raw,1)*c.blockSize,size(raw,2)*c.blockSize,3);
for i=1:3, rgb(:,:,i)=kron(raw(:,:,i),ones(c.blockSize)); end
end
