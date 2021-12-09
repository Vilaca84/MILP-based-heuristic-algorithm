function [s_ind, p_ind, i_ind] = f(s_ind, s_tg, p, d, equipment, tsystem, voll, Xmax, Xmin, inv)

% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021


%% Imput parameters:
% s_ind -> solution to move
% s_tg -> solution target
% p -> probability 
% d -> direction (0: f to i, 1: i to f)

    gen = randomsort(d, s_tg, s_ind, p, Xmax, Xmin);
    if d==1 % infeasible to feasible
        s_ind(gen) = s_ind(gen)+1; % add equipment
    else
        s_ind(gen) = s_ind(gen)-1; % remove equipment
    end
    [~, ~, p_ind, ~, ~, ~, ~, ~] = FACOPF(update_system(s_ind', equipment, tsystem), voll);
    i_ind = sum(s_ind'.*inv);
       
end
