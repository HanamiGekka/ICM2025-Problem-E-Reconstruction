function tests = test_release
tests=functiontests(localfunctions);
end
function testNoPrivateRuntimeDependency(t)
% Actual public entry/config/target modules must use bundled evidence abstractions.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
for file={'historical_targets.m','reconstruction_config.m','export_task4.m','documented_config.m'}
 text=fileread(fullfile(root,'src','matlab',file{1}));
 verifyEmpty(t,regexp(text,'EVIDENCE_CHECKS|Original[\\/]|docs.*audit','once'));
end
h=historical_targets; verifyEqual(t,height(h.table5),14);
end
function testReleaseWhitelist(t)
root=fileparts(fileparts(fileparts(mfilename('fullpath')))); path=fullfile(root,'release_whitelist.csv');
if ~isfile(path)
 % Private checkout validates the release builder's essential exclusions.
 source=fileread(fullfile(root,'scripts','prepare_public.ps1'));
 verifyTrue(t,contains(source,'test_private_')); verifyTrue(t,contains(source,'verify_historical.m'));
 verifyFalse(t,contains(source,"Copy-Item -LiteralPath (Join-Path $root '.git')"));
 return;
end
W=readtable(path,TextType='string',Delimiter=',',VariableNamingRule='preserve');
verifyEqual(t,numel(unique(W.Path)),height(W));
for k=1:height(W)
 if ismember(W.Path(k),["historical-documents/competition-paper.pdf","historical-documents/award-certificate.pdf"])
  verifyTrue(t,isfile(fullfile(root,W.Path(k))));
  continue;
 end
 verifyEmpty(t,regexp(W.Path(k),'^(Original|demand|temp|\.work|docs/audit|docs/development)/|\.(pdf|docx|zip|fig|mat)$','once'));
 verifyTrue(t,isfile(fullfile(root,W.Path(k))));
end
verifyFalse(t,isfolder(fullfile(root,'Original')));
verifyFalse(t,isfile(fullfile(root,'tests','matlab','verify_historical.m')));
end
function testAuthorizedHistoricalCopies(t)
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
M=readtable(fullfile(root,'historical-documents','manifest.csv'),TextType='string',Delimiter=',');
verifyEqual(t,height(M),2);
verifyEqual(t,sort(M.File),sort(["competition-paper.pdf";"award-certificate.pdf"]));
for k=1:height(M)
 path=fullfile(root,'historical-documents',M.File(k)); fid=fopen(path,'rb'); cleaner=onCleanup(@()fclose(fid));
 bytes=fread(fid,Inf,'*uint8'); hash=java.security.MessageDigest.getInstance('SHA-256'); hash.update(bytes);
 actual=upper(reshape(dec2hex(typecast(hash.digest(),'uint8'),2).',1,[]));
 verifyEqual(t,string(actual),M.SHA256(k)); verifyEqual(t,numel(bytes),M.Bytes(k)); clear cleaner;
end
end
