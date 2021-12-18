function [slt, sut, matriz_i, matriz_s] = MBH(ac_sol, dc_sol, equipment, tsystem, voll, countMAX, pfi, pif, inv, Xmax, Xmin, MBH_trial, ph, df, i_R, betta)
% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar,
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021


% cross_trial: Number of trials to cross the F&I boundary
% iterations: number of

%% 1) Initial solutions
% s1, p1, i1
[i1,p1] = evaluation(ac_sol', tsystem, equipment, voll, inv, betta, ph, df, i_R);
s1 = ac_sol;

% s2, p2, i2
[i2,p2] = evaluation(dc_sol', tsystem, equipment, voll, inv, betta, ph, df, i_R);
s2 = dc_sol;

%% 2) Targets (lt and ut)
sut = s1;
put = p1;
iut = i1;

slt = s2;
plt = p2;
ilt = i2;

%% 3) Iterative procedure (following the algorithm 1 in the paper)
iter = 1;
for kapa = 1:MBH_trial
    s1 = sut;
    p1 = put;
    i1 = iut;
    
    s2 = slt;
    p2 = plt;
    i2 = ilt;
    
    count1 = 0;
    count2 = 0;
    
    % Saving values
    matriz_s{iter} = [s1 s2 slt sut];
    matriz_i(iter,:) = [p1, i1, p2, i2, plt, ilt, put, iut];
    
    while count1<countMAX || count2<countMAX
        iter = iter + 1;
        %------------ Movement towards the search space ---------------------------
        % Lines 4 to 8 in Algorithm 1
        if p1 == 0
            [s1, p1, i1] = f(s1, slt, pfi, 0, equipment, tsystem, voll, Xmax, Xmin, inv, betta, ph, df, i_R);
        else
            [s1, p1, i1] = f(s1, sut, pif, 1, equipment, tsystem, voll, Xmax, Xmin, inv, betta, ph, df, i_R);
        end
        
        % Lines 9 to 13 in Algorithm 1
        if p2 ~= 0
            [s2, p2, i2] = f(s2, sut, pif, 1, equipment, tsystem, voll, Xmax, Xmin, inv, betta, ph, df, i_R);
        else
            [s2, p2, i2] = f(s2, slt, pfi, 0, equipment, tsystem, voll, Xmax, Xmin, inv, betta, ph, df, i_R);
        end
        
        %----------------------- Update the targets -------------------------------
        % Lines 14 to 19 in Algorithm 1
        if i1<iut && p1==0
            sut = s1;
            put = p1;
            iut = i1;
            count1 = 0;
        else
            count1 = count1 + 1;
        end
        
        % Lines 20 to 23 in Algorithm 1
        if p1<plt && p1~=0  && i1<iut
            slt = s1;
            plt = p1;
            ilt = i1;
            count1 = 0;
        end
        
        % Lines 24 to 29 in Algorithm 1
        if p2<plt && p2~=0 && i2<iut
            slt = s2;
            plt = p2;
            ilt = i2;
            count2 = 0;
        else
            count2 = count2 + 1;
        end
        
        % Lines 30 to 34 in Algorithm 1
        if i2<iut && p2==0
            sut = s2;
            put = p2;
            iut = i2;
            count2 = 0;
        end
        
        % Saving values
        matriz_s{iter} = [s1 s2 slt sut];
        matriz_i(iter,:) = [p1, i1, p2, i2, plt, ilt, put, iut];
    end
end

end

