function export_historical_comparison
% Audited targets kept separate. Missing earlier experiments are not scored 0.
root=fileparts(fileparts(fileparts(mfilename('fullpath')))); out=fullfile(root,'results','reproduced');
h=historical_targets; names={'table5','modelIIpaper','modelIIalternate','modelIII','table7'};
for i=1:numel(names)
    T=h.(names{i}); T.Classification=repmat(string(h.classification),height(T),1);
    T.Source=repmat(string(h.sources.(names{i})),height(T),1);
    writetable(T,fullfile(out,['historical_' names{i} '_targets.csv']),'Encoding','UTF-8');
end
a=sensitivity_arithmetic(h.table7);
write_json(fullfile(out,'sensitivity_arithmetic.json'),struct('source',h.sources.table7, ...
 'classification','RECALCULATED DOCUMENTED ARITHMETIC, not regenerated population response', ...
 'matlab',version,'runId','table7-arithmetic-v1','arithmetic',a));
sets={'modelIIpaper','modelIIalternate','modelIII'}; rows={};
for i=1:3
    T=h.(sets{i}); metrics=T.Properties.VariableNames;
    for phase=1:2
        for j=1:numel(metrics)
            rows(end+1,:)={sets{i},phase,metrics{j},T{phase,j},NaN,NaN,NaN, ...
                'EXACT HISTORICAL RUN NOT RECOVERED; separate assumed comparisons in full/',h.sources.(sets{i})}; %#ok<AGROW>
        end
    end
end
T=cell2table(rows,'VariableNames',{'ResultSet','PhaseBefore1After2','Metric','ArchivedValue', ...
    'RegeneratedValue','AbsoluteDifference','RelativeDifference','Interpretation','Source'});
writetable(T,fullfile(out,'earlier_model_comparison_status.csv'),'Encoding','UTF-8');
meta=struct('runId','historical-target-transcription-v1','matlab',version, ...
 'generatedUTC',char(datetime('now','TimeZone','UTC')),'source',h.sources, ...
 'classification',h.classification,'config','No simulation inputs: transcription/arithmetic only', ...
 'earlierComparisons','Exact historical runs unrecovered; new assumed comparisons in full/; conflicting result sets separate', ...
 'task4Comparisons','table5_<variant>_comparison.csv: actual regenerated C42 scalar variants');
write_json(fullfile(out,'historical_comparison_metadata.json'),meta);
fprintf('HISTORICAL_COMPARISON_EXPORT_PASS\n');
end
