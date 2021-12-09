function [fitness,LS] = evaluation(population, tsystem, equipment, voll, inv, betta)
% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021
    
parfor i=1:size(population,1)
        [tsystem2] = update_system(population(i,:), equipment, tsystem);
        [~, ~, lshed, ~, ~, suc, ~, ~] = FACOPF(tsystem2, voll);
        if suc == 1
            fitness(i) = sum(population(i,:).*inv)+betta*lshed;
            LS(i) = lshed;
        else
            fitness(i) = betta^5;
            LS(i) = betta^5;
        end
end

