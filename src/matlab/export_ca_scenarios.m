function export_ca_scenarios
% Representative NEW runs, not replacements for unseeded historical images.
root=fileparts(fileparts(fileparts(mfilename('fullpath')))); out=fullfile(root,'results','reproduced');
variants={'historical_compat','corrected'}; switches=[0 0 0 0;1 1 1 1];
for i=1:2
 for j=1:2
    c=ca_config(variants{i}); c.n=24; c.steps=420; c.switches=switches(j,:);
    r=run_ca(c); repeat=run_ca(c);
    assert(isequal(r.final,repeat.final) && isequal(r.summary,repeat.summary) ...
        && isequal(r.rgb,repeat.rgb),'ca:determinism','Repeated run differs');
    id=sprintf('ca_%s_%d%d%d%d',c.variant,c.switches);
    T=array2table(r.summary,'VariableNames',{'RhsTime','N1','N2','N3','N4','N5','N6','N7','N8','Field','Stability','Diversity'});
    T.Harvest=r.events(:,1); T.Weeding=r.events(:,2); T.PestControl=r.events(:,3);
    writetable(T,fullfile(out,[id '_trajectory.csv']));
    writematrix(reshape(r.final,[],8),fullfile(out,[id '_state.csv']));
    % Compatibility may exceed display gamut; raw scientific RGB is exported
    % independently of the clipped PNG display representation.
    writematrix(reshape(r.rgb,[],3),fullfile(out,[id '_rgb.csv']));
    imwrite(max(0,min(1,r.rgb)),fullfile(out,[id '.png']));
    meta=struct('config',c,'runId',id,'matlab',version,'generatedUTC',char(datetime('now','TimeZone','UTC')), ...
        'classification','REGENERATED RECONSTRUCTED RESULT; n24/420steps are NEW representative settings', ...
        'F',r.F,'clippedStateValues',r.clippedValues,'normalizationPeaks',r.normalizationPeaks, ...
        'eventOrder','old-state RHS -> clipped Euler -> harvest -> weed/pest -> metrics -> RGB', ...
        'timeMeaning','RHS label (step-1)*dt; exported final state follows last update/events', ...
        'fixedSeedRepeatExact',true,'stateFlattenOrder','MATLAB column-major, cells x8', ...
        'rgbFlattenOrder','MATLAB column-major, enlarged pixels x3; PNG display clipped');
    write_json(fullfile(out,[id '_metadata.json']),meta);
 end
end
fprintf('CA_EXPORT_REPEAT_PASS four representative runs\n');
end
