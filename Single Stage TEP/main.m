% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vila?a, Alexandre Street and Jos? Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vila?a Gomes, Universidad Rey Juan Carlos, Spain. November 2021

%% 1) initialization

clear all
close all
clc

[tsystem, equipment, Xmin, Xmax, inv] = RTS24Data(); % Test System: RTS 24 bus

%% 2) AC-TEP Model - Solver:EPSO

ger = 100;            % Max number of iterations (generations)
stC = 30;             % Max number of iterations withou any improvment in the best solution
nsol = 50;            % Number of solutions (individuals)
Ntrials = 10;         % Number of trials
voll = 5000;          % Value Of Lost Load
r = 3;                % Replication parameter
fhd = @evaluation;    % Fitness function
betta = 10^5;         % Penalization factor for Power Not Supplied(PNS)

% [tempo, xopt, fopt, XOPT, FOPT] = epso(tsystem, equipment, inv, Xmax, Xmin, numel(Xmax), Ntrials, ger, voll, nsol, fhd, betta, stC, r);
load('MBH_Algorithm_Results.mat')
%% 3) DC-TP Model - Gurobi

[tsystem_DC] = System_TEP_DC(tsystem, equipment, inv, Xmax); % Test System: RTS 24 bus
[result,adl] = MILP_TEP(tsystem_DC,0.32);

dc_sol = zeros(numel(Xmin),1);
for i=1:size(adl,1)
    I = ismember(equipment(:,1:2),adl(i,:),'rows');
    dc_sol = dc_sol + I;
    clear I
end

%% 4) MILP-based Heuristic algorithm
countMAX = 20;
pfi = 5;
pif = 10;
MBH_trial = 50;


for i=1:Ntrials
    fprintf('Running the trial %3d from trial %3d\n', i,Ntrials);
    [slt(:,i), sut(:,i), matriz_i{i}, matriz_s{i}] = MBH(xopt(:,i), dc_sol, equipment, tsystem, voll, countMAX, pfi, pif, inv, Xmax, Xmin, MBH_trial);
end

save('MBH_Algorithm_Results')

%% 5) Results analysis

load 'MBH_Algorithm_Results'

[~, ~, p_dc, ~, ~, ~, ~, ~] = FACOPF(update_system(dc_sol', equipment, tsystem), voll);
i_dc = sum(dc_sol'.*inv);

for i=1:Ntrials
    res(i,:) = [fopt(i) matriz_i{1,i}(end,8) i_dc p_dc matriz_i{1,i}(end,6) matriz_i{1,i}(end,5)];
end

imp_ac = 100*((res(:,1)-res(:,2))./res(:,1)); % Improvement in each trial
av_imp_ac = mean(imp_ac); % average improvement

graf_bar = [res(:,3) res(:,2) res(:,5) res(:,1)];
figure
bar3(graf_bar)
legend('Initial DC', 'Final AC', 'Final DC', 'Initial AC')

gap_o = res(:,1)-res(:,3);
gap_f = abs(res(:,2)-res(:,5));

gap = [gap_o gap_f];
figure
barh(gap)
legend('Initial gap', 'Final gap')






