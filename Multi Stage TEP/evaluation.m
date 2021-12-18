function [fitness,LS] = evaluation(population, tsystem, equipment, voll, inv, betta, ph, df, i_R)
% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar,
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021

for i=1:size(population,1)
    for j=1:ph
        [~, ~, lshed, ~, ~, suc, ~, ~] = FACOPF(update_system(population(i,:), equipment, tsystem, ph, df, j), voll);
        [fitness(i,j),LS(i,j)] = ms_TEP(inv,population(i,:),j, i_R, lshed, suc, betta);
    end
end

fitness = sum(fitness');
LS = sum(LS');