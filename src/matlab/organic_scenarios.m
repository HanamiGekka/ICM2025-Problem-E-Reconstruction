function [T,runs] = organic_scenarios(c)
% C42 nested-loop order: OFU/BPC/PWC/PPC. All 16 feasible states, no GA.
bits=dec2bin(0:15,4)-'0'; data=zeros(16,7); runs=cell(16,1);
for i=1:16
    runs{i}=organic_scalar(bits(i,:),c);
    data(i,:)=[bits(i,:) runs{i}.mean(1:2) runs{i}.cost];
end
T=array2table(data,'VariableNames',{'OFU','BPC','PWC','PPC','Field','Stability','Cost'});
T.IntendedPareto=pareto_filter(data(:,5:7),[1 1 -1]);
T.HistoricalReversedPareto=pareto_filter(data(:,5:7),[-1 -1 1]);
end
