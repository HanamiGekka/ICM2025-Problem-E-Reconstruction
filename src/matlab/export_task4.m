function export_task4(variant)
% RECONSTRUCTED C42 export, source c.source; paper Table5 physical p18.
% Archived numbers are transcription, never substituted for regenerated output.
if nargin==0, variant='historical_compat'; end
root=fileparts(fileparts(fileparts(mfilename('fullpath')))); c=task4_config(variant);
[T,~]=organic_scenarios(c); out=fullfile(root,'results','reproduced');
if ~isfolder(out), mkdir(out); end
writetable(T,fullfile(out,['task4_' variant '.csv']));
h=historical_targets; A=h.table5{:,:}; differences=zeros(14,13);
for i=1:14
    k=all(T{:,1:4}==A(i,[1 4 2 3]),2);
    generated=T{k,5:7}; delta=generated-A(i,5:7);
    differences(i,:)=[A(i,1:4) A(i,5:7) generated abs(delta)];
end
comparison=array2table(differences,'VariableNames',{'OFU','PWC','PPC','BPC', ...
    'ArchivedField','ArchivedStability','ArchivedCost','GeneratedField','GeneratedStability', ...
    'GeneratedCost','AbsoluteFieldDifference','AbsoluteStabilityDifference','AbsoluteCostDifference'});
comparison.RelativeFieldDifference=comparison.AbsoluteFieldDifference./abs(comparison.ArchivedField);
comparison.RelativeStabilityDifference=comparison.AbsoluteStabilityDifference./abs(comparison.ArchivedStability);
comparison.RelativeCostDifference=comparison.AbsoluteCostDifference./abs(comparison.ArchivedCost);
writetable(comparison,fullfile(out,['table5_' variant '_comparison.csv']));
meta=struct('variant',variant,'config',c,'seed',[],'runId',['task4-c42-' variant '-v1'], ...
    'matlab',version,'generatedUTC',char(datetime('now','TimeZone','UTC')), ...
    'classification','REGENERATED RECONSTRUCTED RESULT; comparison targets TRANSCRIBED HISTORICAL RESULT', ...
    'targetSource','Private paper physical p18 Table5; reviewed numeric transcription', ...
    'maxAbsoluteDifference',max(abs(differences(:,11:13)),[],1));
write_json(fullfile(out,['task4_' variant '_metadata.json']),meta);
fprintf('EXPORT_TASK4_PASS %s\n',variant);
end
