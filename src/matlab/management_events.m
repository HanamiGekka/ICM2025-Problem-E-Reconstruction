function [N,event] = management_events(N,step,c)
% CA source update -> clip -> harvest -> physical controls -> metrics.
% Both modes retain events at source RHS label t=0 (step1). Corrected uses
% integer step modulo, periods must divide dt; no inferred phase shift.
t=(step-1)*c.dt;
if strcmp(c.variant,'historical_compat')
    harvest=mod(t,c.harvestPeriod)==0; manage=mod(t,c.managementPeriod)==0;
else
    h=round(c.harvestPeriod/c.dt); m=round(c.managementPeriod/c.dt);
    assert(h>0 && m>0 && abs(h*c.dt-c.harvestPeriod)<1e-10 ...
        && abs(m*c.dt-c.managementPeriod)<1e-10,'task4:eventGrid','Periods must align with dt');
    harvest=mod(step-1,h)==0; manage=mod(step-1,m)==0;
end
if harvest, N(:,:,1)=c.initial(1); end
if manage && c.switches(3), N(:,:,2)=N(:,:,2)*c.weedRetention; end
if manage && c.switches(4), N(:,:,[3 5])=N(:,:,[3 5]).*c.pestRetention; end
event=[harvest,manage&&c.switches(3),manage&&c.switches(4)];
end
