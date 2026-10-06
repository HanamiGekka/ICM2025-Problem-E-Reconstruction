function report = run_checks(label)
% Native batch verification entry. Test failure throws and yields nonzero exit.
if nargin==0, label='task4'; end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(fullfile(root,'src','matlab'),fullfile(root,'tests','matlab'));
if strcmp(label,'public')
    files=dir(fullfile(root,'tests','matlab','test_*.m'));
    files=files(~startsWith({files.name},'test_private_'));
    r=[];
    for k=1:numel(files), r=[r runtests(fullfile(files(k).folder,files(k).name))]; end %#ok<AGROW>
else
    assert(verify_historical(root)==74,'verification:preservation','Private historical gate required');
    r=runtests(fullfile(root,'tests','matlab'));
end
report=struct('label',label,'matlab',version,'batch',batchStartupOptionUsed, ...
    'passed',sum([r.Passed]),'failed',sum([r.Failed]),'incomplete',sum([r.Incomplete]), ...
    'names',{ {r.Name} },'mode',label);
if strcmp(label,'public'), report.historicalHashStatus='EXCLUDED: public has no Original archive';
else, report.historicalHashStatus='PASS: 74 unchanged files'; end
files=[dir(fullfile(root,'src','matlab','*.m'));dir(fullfile(root,'tests','matlab','*.m'))];
report.static=cell(numel(files),1);
for i=1:numel(files)
    messages=checkcode(fullfile(files(i).folder,files(i).name),'-id');
    report.static{i}=struct('file',files(i).name,'messages',messages);
end
out=fullfile(root,'results','reproduced'); if ~isfolder(out), mkdir(out); end
fid=fopen(fullfile(out,['verification_' label '.json']),'w');
fwrite(fid,jsonencode(report,PrettyPrint=true),'char'); fclose(fid);
disp(report); assert(report.failed==0 && report.incomplete==0,'verification:failed','Tests did not pass');
assert(all(cellfun(@(s)isempty(s.messages),report.static)),'verification:static','Code Analyzer diagnostics remain');
fprintf('VERIFICATION_PASS %s\n',label);
end
