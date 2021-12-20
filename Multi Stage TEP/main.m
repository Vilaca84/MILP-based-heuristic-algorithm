% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar,
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021

%% 1) initialization

clear all
close all
clc
 
 %% 2) AC-TEP Model - Solver:EPSO
 
 ger = 100;            % Max number of iterations (generations)
 stC = 30;             % Max number of iterations withou any improvment in the best solution
 nsol = 50;            % Number of solutions (individuals)
 Ntrials = 10;         % Number of trials
 voll = 5000;          % Value Of Lost Load
 r = 3;                % Replication parameter
 fhd = @evaluation;    % Fitness function
 betta = 10^5;         % Penalization factor for Power Not Supplied(PNS)
 ph = 10;              % Planning horizon (investment is considered as annual)
 df = 0.03;            % Demand Factor (%)
 i_R = 0.05;           % Interest rate (%)
 
 [tsystem, equipment, Xmin, Xmax, inv] = IEEE118Data(ph); % Test System: IEEE 118 bus
 [tempo, xopt, fopt, XOPT, FOPT] = epso(tsystem, equipment, inv, Xmax, Xmin, numel(Xmax), Ntrials, ger, voll, nsol, fhd, betta, stC, r, ph, df, i_R);

%% 3) DC-TP Model - Gurobi
[tsystem, equipment, Xmin, Xmax, inv] = IEEE118Data(ph); % Test System: IEEE 118 bus
res_dc = [];
for i=1:ph
    [tsystem_DC] = System_TEP_DC(tsystem, equipment, inv, i, df, ph);
    [~,adl] = MILP_TEP(tsystem_DC,0.32);
    [tsystem, inv_dc] = insertEq(tsystem, adl, Xmin, equipment, inv, i, i_R);
    if ~isempty(adl)
        for j=1:size(adl,1)
            res_dc = [res_dc; adl(j,:) inv_dc i];
        end
    end
    clear ad1 result
end

dc_sol = zeros(numel(Xmin),1);
for i=1:size(res_dc,1)
    I = ismember(equipment(:,1:2),res_dc(i,1:2),'rows');
    dc_sol(I==1) = res_dc(i, 4);
    clear I
end

%% 4) MILP-based Heuristic algorithm
countMAX = 20;
pfi = 5;
pif = 10;
MBH_trial = 50;


for i=1:Ntrials
    fprintf('Running the trial %3d from trial %3d\n', i,Ntrials);
    [slt(:,i), sut(:,i), matriz_i{i}, matriz_s{i}] = MBH(xopt(:,i), dc_sol, equipment, tsystem, voll, countMAX, pfi, pif, inv, Xmax, Xmin, MBH_trial, ph, df, i_R, betta);
end







