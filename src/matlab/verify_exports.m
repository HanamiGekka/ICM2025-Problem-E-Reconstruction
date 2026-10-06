function report = verify_exports
% Validate actual bundled/exported experiments; suitable without Original/.
root=fileparts(fileparts(fileparts(mfilename('fullpath')))); out=fullfile(root,'results','reproduced','full');
metadata=jsondecode(fileread(fullfile(out,'experiment_metadata.json')));
assert(~metadata.historicalTargetsUsedForCalibration,'exports:calibration','Unexpected calibration');
files=dir(fullfile(out,'*_trajectory.csv'));
assert(numel(files)==13,'exports:count','Expected six Model I + seven Model II/III runs');
for k=1:numel(files)
    T=readtable(fullfile(files(k).folder,files(k).name));
    A=T{:,:}; assert(all(isfinite(A),'all') && all(A>=0,'all'),'exports:finite','Invalid trajectory');
    assert(T.Time(1)==0 && T.Time(end)==36 && height(T)==73,'exports:grid','Unexpected baseline grid');
    name=strrep(files(k).name,'_trajectory.csv','_metadata.json');
    M=jsondecode(fileread(fullfile(out,name)));
    assert(width(T)==M.config.species+3,'exports:dimension','Unexpected species columns');
end
for m=2:3
    key=sprintf('model%d',m); M=metadata.(key); G=readtable(fullfile(out,[key '_independent_grid.csv']));
    C=readtable(fullfile(out,[key '_comparison.csv']));
    H=readtable(fullfile(out,[key '_convergence.csv']));
    assert(max(abs(H{1,2:4}-C{1,1:3}))<1e-12 && abs(H.Fitness(1)-C.Utility(1))<1e-12 && ...
        abs(H.BestFitness(end)-C.Utility(2))<1e-12,'exports:history','History must preserve float doses/fitness');
    assert(C.Utility(2)>=max(G.Fitness)-1e-12 && C.Utility(2)>=C.Utility(1)-1e-12, ...
        'exports:grid','Optimized solution inferior to independently evaluated grid/baseline');
    c=reconstruction_config(m); run=simulate_reconstructed(c,M.optimization.decision');
    assert(abs(run.objective.fitness-C.Utility(2))<1e-12,'exports:repeat','Exported decision not reproducible');
end
S=readtable(fullfile(out,'sensitivity_oat.csv')); R=readtable(fullfile(out,'robustness_profiles.csv'));
assert(height(S)==44 && height(R)==9,'exports:sensitivity','Incomplete sensitivity study');
assert(all(isfinite(S{:,{'Crop','Stability','Fitness','RelativeCrop','RelativeStability','RelativeFitness'}}),'all'), ...
    'exports:sensitivity','Nonfinite sensitivity effects');
images=dir(fullfile(out,'*.png')); assert(numel(images)==12,'exports:figures','Incomplete reconstructed figures');
for k=1:numel(images)
    pixels=imread(fullfile(images(k).folder,images(k).name));
    assert(size(pixels,1)>300 && size(pixels,2)>300,'exports:figures','Invalid image dimensions');
end
report=struct('status','PASS','trajectories',numel(files),'figures',numel(images),'sensitivityRows',height(S), ...
    'profileRows',height(R),'matlab',version,'historicalArchiveRequired',false);
write_json(fullfile(root,'results','reproduced','verification_exports.json'),report);
fprintf('EXPORT_VERIFICATION_PASS\n');
end
