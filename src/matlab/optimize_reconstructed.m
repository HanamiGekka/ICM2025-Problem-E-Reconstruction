function o = optimize_reconstructed(c,evaluateFcn)
% NEW deterministic bounded pattern search, audited with independent grid.
% No GA or historical random state; strict improvement resolves ties stably.
if nargin<2, evaluateFcn=@modelFitness; end
lo=c.lower; hi=c.upper;
validateattributes(lo,{'numeric'},{'size',[1 3],'finite','nonnegative'});
validateattributes(hi,{'numeric'},{'size',[1 3],'finite','nonnegative'});
assert(all(hi>=lo),'reconstruction:optimizer','Upper bounds must exceed lower bounds');
assert(c.gridLevels>=2 && mod(c.gridLevels,1)==0 && c.searchSweeps>=1 && ...
    mod(c.searchSweeps,1)==0,'reconstruction:optimizer','Integer search budgets required');
cache=containers.Map('KeyType','char','ValueType','double'); history=zeros(0,6);
phases=cell(0,1); globalBest=-Inf;
x=min(max([c.parameters.F c.parameters.V1 c.parameters.V2],lo),hi);
[x,f]=refine(x,'coordinate'); rawDecision=x; rawFitness=f;
axes=cell(1,3);
for j=1:3
 if hi(j)==lo(j), axes{j}=lo(j); else, axes{j}=linspace(lo(j),hi(j),c.gridLevels); end
end
[a,b,d]=ndgrid(axes{:}); grid=[a(:) b(:) d(:)]; gridFitness=zeros(size(grid,1),1);
for i=1:size(grid,1), gridFitness(i)=evaluate(grid(i,:),'independent_grid'); end
[gf,index]=max(gridFitness); gx=grid(index,:);
if gf>f, [x,f]=refine(gx,'grid_refinement'); end
o=struct('decision',x,'fitness',f,'coordinateDecision',rawDecision,'coordinateFitness',rawFitness, ...
 'gridDecision',gx,'gridFitness',gf,'improvementOverGrid',f-gf, ...
 'evaluationCount',cache.Count,'grid',array2table([grid gridFitness], ...
 'VariableNames',{'F','V1','V2','Fitness'}),'config',c, ...
 'algorithm','NEW bounded coordinate search + independent Cartesian grid; no RNG');
o.history=array2table(history,'VariableNames',{'Evaluation','F','V1','V2','Fitness','BestFitness'});
o.history.Phase=phases;
assert(f>=gf-1e-12,'reconstruction:grid','Final choice inferior to verified grid');
    function [q,v]=refine(q,phase)
        v=evaluate(q,phase); step=(hi-lo)*c.searchStepFraction;
        for sweep=1:c.searchSweeps
            for coordinate=find(hi>lo)
                for sign=[-1 1]
                    candidate=q; candidate(coordinate)=min(max(q(coordinate)+sign*step(coordinate),lo(coordinate)),hi(coordinate));
                    fv=evaluate(candidate,phase);
                    if fv>v, q=candidate; v=fv; end
                end
            end
            step=step/2;
        end
    end
    function f=evaluate(q,phase)
        key=mat2str(q,17);
        if isKey(cache,key), f=cache(key); return; end
        f=evaluateFcn(q); validateattributes(f,{'numeric'},{'scalar','real','finite'});
        cache(key)=f; globalBest=max(globalBest,f);
        % Map.Count is an integer; cast before concatenation to preserve doses/fitness.
        history(end+1,:)=[double(cache.Count) q f globalBest];
        phases{end+1,1}=phase;
    end
    function f=modelFitness(q)
        run=simulate_reconstructed(c,q); f=run.objective.fitness;
    end
end
