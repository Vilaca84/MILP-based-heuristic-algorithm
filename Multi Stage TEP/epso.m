function [tempo, xopt, fopt, XOPT, FOPT] = epso(tsystem, equipment, inv, Xmax, Xmin, dim, Ntrials, ger, voll, nsol, fhd, betta, stC, r, ph, df, i_R)

% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021


%% Detailed Outputs
% tempo ------------ time required to solve the problem in each trial
% xopt ------------- best solution in each trial
% fopt ------------- fitness of the best solution in each trial
% XOPT ------------- best solution at each iteration and trial
% FOPT ------------- Fitness of the best solution at each iteration and trial 

%% -------------------------------------------------------------------------------------------------------------
try
    parpool('local', 'IdleTimeout', 120, 'SpmdEnabled', false)
catch
end

disp('Algorithm: Evolutionary Particle Swarm Optimization')

rng default                  

xopt = zeros(dim, Ntrials);  
fopt = zeros(Ntrials,1);     
XOPT = cell(Ntrials, ger);   
FOPT = cell(Ntrials, ger);   


%% Begining of the search procedure

for T = 1:Ntrials
    iter = 1;               % Iteration counter
    STOP = 0;               % Stop flag
    same_best_iter = 0;
    tic
    % Initial Swarm
    swarm = round(Xmin+(Xmax-Xmin).*(rand(dim,nsol)))';
    vel = ((2*rand(dim, nsol)).*(Xmax/2)-(Xmax/2))'; %Velocity of the initial population
        
    % Evaluation of the first swarm
    [fitness,pen] = feval(fhd, swarm, tsystem, equipment, voll, inv, betta, ph, df, i_R);
        
    % Updating the personal best
    pbest = swarm; 
    f_pbest = fitness; 
    
    % Updating the global best
    [f_gbest, index_f] = min(fitness);
    gbest = swarm(index_f,:);
    
    % Storing values of the ith iteration in trial T
    XOPT{T,iter} = gbest;
    FOPT{T,iter} = f_gbest;
    
     %% Weights of replicated population
    wi1 = rand(nsol,r);
    wi2 = rand(nsol,r);
    wi3 = rand(nsol,r);
    wi4 = rand();
        
    vel1 = ((2*rand(dim, nsol)).*(Xmax/2)-(Xmax/2))';
    vmax = 0.5*(Xmax-Xmin);     % Maximum velocity
        
    % Evolutionary procedure
    
    while STOP == 0
        fprintf('Running the iteration %3d from trial %3d\n', iter,T);
        iter = iter + 1;
        
        % Replication Block
        for rep=1:r
            pop{rep}=swarm;
        end
        
        % Mutation block
        wi1 = (0.5+rand-(1./(1+exp(wi1))));
        wi2 = (0.5+rand-(1./(1+exp(wi2))));
        wi3 = (0.5+rand-(1./(1+exp(wi3))));
        wi4 = (0.5+rand-(1./(1+exp(wi4))));
        
        % Update velocity and position
        
        for rep=1:r
            for i=1:nsol
                vel1(i,:) = (vel1(i,:).*wi1(i,rep)*rand + wi2(i,rep)*rand.*(pbest(i,:)-pop{1,rep}(i,:)) + wi3(i,rep)*rand.*(gbest-pop{1,rep}(i,:)));
                % vel1ocity constraints
                vel1(i,vel1(i,:)>vmax') = vmax(vel1(i,:)>vmax');
                vel1(i,vel1(i,:)<-vmax') = -vmax(vel1(i,:)<-vmax');
                % Updating pop{1,rep}
                pop{1,rep}(i,:) = round(pop{1,rep}(i,:) + vel1(i,:));
                % pop{1,rep} constraints
                pop{1,rep}(i,pop{1,rep}(i,:)>Xmax') = Xmax(pop{1,rep}(i,:)>Xmax');
                pop{1,rep}(i,pop{1,rep}(i,:)<Xmin') = Xmin(pop{1,rep}(i,:)<Xmin');
            end
            % Evaluation
            [fitpop{rep},penpop{rep}] = feval(fhd, pop{1,rep}, tsystem, equipment, voll, inv, betta, ph, df, i_R);
        end
                        
        popCell = pop;
        popCell{r+1} = swarm;  
        
        fitCell = fitpop;
        fitCell{r+1} = fitness;
        
        penCell = penpop;
        penCell{r+1} = pen;
        
        [swarm, fitness, pen] = selection_epso(popCell, fitCell, penCell);
        
        % Update the best positions of each particle
        pbest(fitness<f_pbest,:) = swarm(fitness<f_pbest,:);
        f_pbest(fitness<f_pbest) = fitness(fitness<f_pbest);
        
        % Update the global best and its fitness
        conv_opt = 0;
        if min(fitness)<f_gbest
            [f_gbest, index_f] = min(fitness);
            gbest = swarm(index_f,:);
            same_best_iter = 0;
        else
            same_best_iter = same_best_iter + 1;
        end
        
        % Storing values of the ith iteration in trial T
        XOPT{T,iter} = gbest;
        FOPT{T,iter} = f_gbest;
        
        % Stopping criteria
        if iter==ger
            STOP=1;
        end
        if same_best_iter==stC
            STOP=1;
        end
    end
    tempo(T) = toc;
    xopt(:,T) = gbest';
    fopt(T,:) = f_gbest;
end
end
