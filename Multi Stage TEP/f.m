function [s_ind, p_ind, i_ind] = f(s_ind, s_tg, p, d, equipment, tsystem, voll, Xmax, Xmin, inv,  betta, ph, df, i_R)

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
        s_ind(gen) = s_ind(gen)-1; % antecipate equipment
        s_ind(s_ind<Xmin) = Xmin(s_ind<Xmin);
    else
        s_ind(gen) = s_ind(gen)+1; % postpone equipment
        s_ind(s_ind>Xmax) = Xmax(s_ind>Xmax);
    end
    [i_ind,p_ind] = evaluation(s_ind', tsystem, equipment, voll, inv, betta, ph, df, i_R);
       
end
