function summary = export_full_reconstruction
% Complete assumed numerical study, independent checks, figures and provenance.
root=fileparts(fileparts(fileparts(mfilename('fullpath')))); out=fullfile(root,'results','reproduced','full');
if ~isfolder(out), mkdir(out); end
summary=struct('classification','RECONSTRUCTION WITH ASSUMPTIONS; NOT original competition experiments', ...
 'matlab',version,'rng','None: deterministic ODE/coordinate/grid search', ...
 'historicalTargetsUsedForCalibration',false,'generatedUTC',char(datetime('now',TimeZone='UTC')));
c=reconstruction_config(1); [T,runs]=model1_scenarios(c); writetable(T,fullfile(out,'model1_scenarios.csv'));
for i=1:6, saveRun(runs{i},sprintf('model1_scenario%d',i)); end
f=figure('Visible','off','Position',[0 0 1200 760]); tiledlayout(2,3);
for i=1:6
 nexttile; plot(runs{i}.time,runs{i}.states,'LineWidth',1.2);
 title(sprintf('Scenario %d: V1=%.3f, V2=%.3f',i,T.V1(i),T.V2(i))); xlabel('Normalized month'); ylabel('Normalized population'); grid on;
end
legend({'Crop','Weeds','Pests','Bats'},'Location','best'); sgtitle('Model I: reconstructed chemical scenarios'); saveFigure(f,'model1_trajectories');
normalized=T{:,{'Crop','Stability','Diversity'}}; normalized=normalized./max(normalized,[],1);
f=figure('Visible','off'); imagesc(normalized); colorbar; clim([0 1]);
xticks(1:3); xticklabels({'Mean crop','Mean stability proxy','Mean diversity'}); yticks(1:6);
ylabel('Documented dose scenario'); title('Model I: reconstructed column-maximum normalization'); saveFigure(f,'model1_comparison');
summary.model1=struct('config',c,'scenarios',table2struct(T),'normalization','each column divided by maximum across six scenarios');
for m=2:3
 c=reconstruction_config(m); before=simulate_reconstructed(c); optimization=optimize_reconstructed(c);
 after=simulate_reconstructed(c,optimization.decision);
 prefix=sprintf('model%d',m); saveRun(before,[prefix '_before']); saveRun(after,[prefix '_after']);
 writetable(optimization.history,fullfile(out,[prefix '_convergence.csv']));
 writetable(optimization.grid,fullfile(out,[prefix '_independent_grid.csv']));
 comparison=array2table([before.objective.decision before.meanCrop before.meanStability before.objective.cost before.objective.fitness; ...
  after.objective.decision after.meanCrop after.meanStability after.objective.cost after.objective.fitness], ...
  'VariableNames',{'F','V1','V2','Crop','Stability','Cost','Utility'});
 writetable(comparison,fullfile(out,[prefix '_comparison.csv']));
 alternate=c;
 if m==2, alternate.peregrine='paper_literal'; else, alternate.pollination='paper_literal'; end
 literal=simulate_reconstructed(alternate); saveRun(literal,[prefix '_paper_literal']);
 variants=table({'principal';'paper_literal'},[before.meanCrop;literal.meanCrop], ...
  [before.meanStability;literal.meanStability],[before.meanDiversity;literal.meanDiversity], ...
  'VariableNames',{'Variant','Crop','Stability','Diversity'});
 writetable(variants,fullfile(out,[prefix '_structural_variants.csv']));
 f=figure('Visible','off','Position',[0 0 1100 480]); tiledlayout(1,2);
 nexttile; plot(before.time,before.states,'LineWidth',1.2); title('Baseline'); xlabel('Normalized month'); ylabel('Normalized population'); grid on;
 nexttile; plot(after.time,after.states,'LineWidth',1.2); title('Optimized'); xlabel('Normalized month'); grid on;
 labels={'Crop','Weeds','Pest 1','Bats','Pest 2','Peregrines','Bees'}; legend(labels(1:c.species),'Location','eastoutside');
 sgtitle(sprintf('Model %d: reconstructed before / after',m)); saveFigure(f,[prefix '_trajectories']);
 f=figure('Visible','off'); plot(optimization.history.Evaluation,optimization.history.BestFitness,'LineWidth',1.8);
 xlabel('Unique objective evaluation'); ylabel('Best reconstructed utility'); grid on;
 title(sprintf('Model %d: NEW coordinate search and independent grid',m)); saveFigure(f,[prefix '_convergence']);
 metrics=comparison{:,{'Crop','Stability','Cost','Utility'}}; scale=max(abs(metrics),[],1); scale(scale==0)=1;
 f=figure('Visible','off'); bar((metrics./scale)'); xticklabels({'Crop','Stability proxy','Cost','Utility'});
 ylabel('Value / maximum absolute value within metric'); legend({'Baseline','Optimized'},'Location','best'); grid on;
 title(sprintf('Model %d: reconstructed visualization convention',m)); saveFigure(f,[prefix '_comparison']);
 if m==3
  noBee=c; noBee.initial(7)=0; noBeeRun=simulate_reconstructed(noBee); saveRun(noBeeRun,'model3_no_bees');
  beeTable=table({'no_bees';'introduced_bees';'literal_with_bees'},[noBeeRun.meanCrop;before.meanCrop;literal.meanCrop], ...
   [noBeeRun.meanStability;before.meanStability;literal.meanStability], ...
   'VariableNames',{'Scenario','Crop','Stability'}); writetable(beeTable,fullfile(out,'model3_bee_comparison.csv'));
  f=figure('Visible','off'); plot(before.time,[noBeeRun.states(:,1) before.states(:,1) literal.states(:,1)],'LineWidth',1.5);
  xlabel('Normalized month'); ylabel('Crop population'); legend({'No bees / coupled','Bees / coupled','Bees / literal'},'Location','best'); grid on;
  title('Model III: reconstructed pollination alternatives'); saveFigure(f,'model3_pollination');
 end
 summary.(prefix)=struct('config',c,'optimization',optimization,'comparison',table2struct(comparison),'structuralVariants',table2struct(variants));
 compareHistorical(m,comparison);
end
[sensitivity,ranking,profiles]=reconstruction_sensitivity;
writetable(sensitivity,fullfile(out,'sensitivity_oat.csv')); writetable(ranking,fullfile(out,'sensitivity_ranking.csv'));
writetable(profiles,fullfile(out,'robustness_profiles.csv')); summary.sensitivity=struct('rows',height(sensitivity), ...
 'ranking',table2struct(ranking),'profiles',table2struct(profiles),'perturbations',[-.2 -.1 .1 .2], ...
 'boundsStudy','Model II upper F / V2 ±20%; grid3 sweeps3 for control and all four perturbations');
f=figure('Visible','off','Position',[0 0 900 650]); barh(ranking.MaxRelativeInfluence); yticks(1:height(ranking));
yticklabels(strrep(ranking.Parameter,'_',' ')); set(gca,'YDir','reverse'); xlabel('Maximum absolute relative output change'); grid on;
title('Reconstructed OAT influence: mixed metrics, no empirical confidence'); saveFigure(f,'sensitivity_ranking');
for variant={'historical_compat','corrected'}
 task=organic_scenarios(task4_config(variant{1})); mask=task.IntendedPareto;
 f=figure('Visible','off'); scatter3(task.Cost,task.Field,task.Stability,55,double(mask),'filled');
 xlabel('Arbitrary source cost'); ylabel('Mean crop minus pests'); zlabel('Modified diversity proxy'); grid on;
 title(['Task4 ' strrep(variant{1},'_',' ') ': intended frontier']); saveFigure(f,['task4_pareto_' variant{1}]);
end
summary.figureConvention='NEW English scientific plots; no historical images; normalization disclosed per figure';
write_json(fullfile(out,'experiment_metadata.json'),summary);
disp(summary.sensitivity); fprintf('FULL_NUMERICAL_EXPORT_PASS\n');
    function saveRun(r,name)
        labels=arrayfun(@(j)sprintf('N%d',j),1:r.config.species,'UniformOutput',false);
        tr=array2table([r.time r.states r.diversity r.stability], ...
            'VariableNames',[{'Time'} labels {'Diversity','Stability'}]);
        writetable(tr,fullfile(out,[name '_trajectory.csv'])); writetable(r.events,fullfile(out,[name '_events.csv']));
        meta=rmfield(r,{'time','states','diversity','stability','events'});
        meta.eventConvention='post-event sampled states; segmented pre-event quadrature; pre-harvest crop in events CSV';
        write_json(fullfile(out,[name '_metadata.json']),meta);
    end
    function saveFigure(f,name)
        set(findall(f,'Type','axes'),'FontSize',10); set(f,'Color','white');
        exportgraphics(f,fullfile(out,[name '.png']),'Resolution',140); close(f);
    end
    function compareHistorical(m,new)
        h=historical_targets;
        if m==2, blocks={'modelIIpaper','modelIIalternate'}; else, blocks={'modelIII'}; end
        for block=blocks
            target=h.(block{1}); names=target.Properties.VariableNames;
            A=table;
            for row=1:2
                for col=1:numel(names)
                    original=target{row,col}; simulated=new.(names{col})(row);
                    A=[A;table(row,names(col),original,simulated,simulated-original, ...
                     'VariableNames',{'BeforeAfterRow','Metric','HistoricalTarget','ReconstructedValue','Difference'})]; %#ok<AGROW>
                end
            end
            writetable(A,fullfile(out,[block{1} '_historical_comparison.csv']));
        end
    end
end
