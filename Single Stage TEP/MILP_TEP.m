function [result,vect] = MILP_TEP(tsystem,M)
% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021

%% number of buses
nb = length(tsystem.bus(:,1));

%% number of branches & candidate lines
nl = length(tsystem.branch(:,1));
nlz = sum(tsystem.branch(:,12)==0);

%% number of generators
ng = length(tsystem.gen(:,1));

%% number of loads
nd = length(tsystem.load(:,1));

%% system swing bus
swbus = find(tsystem.bus(:,2)==0);

%% suseptance
gl = zeros(nl,1);
bl = -1./tsystem.branch(:,5);

%% variable initialization
nvar = nb+nl+ng+nlz;
nc = nl+3*nlz;
dimNodBal = zeros(nb,nvar);
dimDCFlow = zeros(nl+nlz,nvar); % number of bus angle contraints
dimLnCap = zeros(2*nlz,nvar); % number of line capacity limit
dimPLoad = zeros(nb,1);

tic
for b = 1 : nb
    
    indg = find(b == tsystem.gen(:,2));
    if isempty(indg) == 0
        for i = 1:length(indg)
            dimNodBal(b,nb+nl+indg(i)) = 1;
        end
    end
    
    indd = find(b == tsystem.load(:,2));
    if isempty(indd) == 0
        for i = 1:length(indd)
            dimPLoad(b) = dimPLoad(b) + tsystem.load(indd(i),3);
        end
    end
end
for k = 1 : (nl+nlz)
    if k <= (nl-nlz)
        dimDCFlow(k,tsystem.branch(k,2)) = +1;
        dimDCFlow(k,tsystem.branch(k,3)) = -1;
        dimDCFlow(k,nb+k) = 1./(bl(k)*tsystem.baseMVA);
        
        dimNodBal(tsystem.branch(k,2),nb+k) = -1;
        dimNodBal(tsystem.branch(k,3),nb+k) = +1;
        
    elseif (k > (nl-nlz))&&(k <= nl)
        dimDCFlow(k,tsystem.branch(k,2)) = +1;
        dimDCFlow(k,tsystem.branch(k,3)) = -1;
        dimDCFlow(k,nb+k) = 1./(bl(k)*tsystem.baseMVA);
        dimDCFlow(k,nb+ng+nlz+k) = M;
        
        dimNodBal(tsystem.branch(k,2),nb+k) = -1;
        dimNodBal(tsystem.branch(k,3),nb+k) = +1;
        
        dimLnCap(k-(nl-nlz),nb+k) = 1;
        dimLnCap(k-(nl-nlz),nb+ng+nlz+k) = -tsystem.branch(k,9);
    else
        dimDCFlow(k,tsystem.branch(k-nlz,2)) = -1;
        dimDCFlow(k,tsystem.branch(k-nlz,3)) = +1;
        dimDCFlow(k,nb-nlz+k) = -1./(bl(k-nlz)*tsystem.baseMVA);
        dimDCFlow(k,nb+ng+k) = M;
        
        dimLnCap(k-(nl-nlz),nb-nlz+k) = -1;
        dimLnCap(k-(nl-nlz),nb+ng+k) = -tsystem.branch(k-nlz,9);
    end
end
tiempo = toc
dimNodBal = sparse(dimNodBal);
dimDCFlow = sparse(dimDCFlow);
dimLnCap = sparse(dimLnCap);
clear model;
%model.Q = sparse(1:nvar, 1:nvar, [zeros(nb+nl,1); gen(:,14)]);
model.A = [dimNodBal; dimDCFlow; dimLnCap];
%model.obj = [zeros(nb+nl,1); gen(:,13);branch(nl-nlz+1:nl,11)];
model.obj = [zeros(nb+nl+ng,1); tsystem.branch(nl-nlz+1:nl,11)];
% model.objcon = sum(tsystem.gen(:,12));
model.rhs = [dimPLoad; zeros(nl-nlz,1); M*ones(2*nlz,1); zeros(2*nlz,1)];
model.lb = [-inf(swbus-1,1);0;-inf(nb-swbus,1);-tsystem.branch(:,9);
    tsystem.gen(:,6); -inf(nlz,1)];
model.ub = [ inf(swbus-1,1);0; inf(nb-swbus,1); tsystem.branch(:,9);
    tsystem.gen(:,5); inf(nlz,1)];
model.sense = [repmat('=',nb+nl-nlz,1); repmat('<', 4*nlz,1)];
model.vtype = [repmat('C',nb+nl+ng,1); repmat('B',nlz,1)];
model.modelsense = 'min';

result = gurobi(model);

result.x(1:nb) = result.x(1:nb)/pi*180;
vect = [];
if strcmp(result.status, 'OPTIMAL')
    fprintf('Optimal objective: %e\n', result.objval);
    adl = find(result.x(nb+nl+ng+1:nvar) == 1);
    fprintf('The following %2d lines need to be built:\n', length(adl));
    fprintf('FromBus ToBus\n');
    for i = 1: length(adl)
        fprintf('%5d%8d\n', tsystem.branch(nl-nlz+adl(i),2),tsystem.branch(nl-nlz+adl(i),3));
        vect = [vect; tsystem.branch(nl-nlz+adl(i),2),tsystem.branch(nl-nlz+adl(i),3)];
    end
    fprintf('Elapsed time: %e\n', result.runtime);
else
    fprintf('Optimization returned status: %s\n', result.status);
end
%%

end

