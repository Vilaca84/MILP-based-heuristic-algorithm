function [population, fitness, pen] = MILP_exact_heuristic(ac_sol, dc_solfitness, pen, bls_n, bls_try, tsystem, equipment, inv, Xmax, dim, voll, fhd, betta)
    bls_p = [];
    for i=1:bls_n
        cond = 0;
        while cond == 0
            r = randi([1 numel(fitness)],1,1);
            if ~any(bls_p(:) == r)
                cond = 1;
            end
        end
        bls_p = [bls_p r];
        
        old_p = population(r,:);
        old_f = fitness(r);
        old_n = pen(r);
        
        data_pop = zeros(bls_try, dim);
        data_f = zeros(1, bls_try);
        data_p = zeros(1, bls_try);
        
        for kappa=1:bls_try
            [population, fitness, pen] = crossB(population, fitness, pen, r, dim, Xmax, bls_try, tsystem, equipment, voll, inv, betta, fhd);
            data_pop(kappa,:) = population(r,:);
            data_f(kappa) = fitness(r);
            data_p(kappa) = pen(r);
        end
        data_pop = [old_p;data_pop];
        data_f = [old_f data_f];
        data_p = [old_n data_p];
        
        [~,b1] = sort(data_f);
        population(r,:) = data_pop(b1(1),:);
        fitness(r) = data_f(b1(1));
        pen(r) = data_p(b1(1));
    end
end

