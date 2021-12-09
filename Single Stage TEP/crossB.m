function [population, fitness, pen] = crossB(population, fitness, pen, r, dim, Xmax, bls_try, tsystem, equipment, voll, inv, betta, fhd)
    indAux = 0;
    counter = 0;
    while pen(r)==0 && counter<bls_try % feasible solution (remove equipment)
        indAux = 1;
        cond = 0;
        while cond == 0
            r_n = randi([1 dim],1,1);
            if population(r,r_n)>0
                cond = 1;
            end
        end
        counter = counter + 1;
        population(r,r_n) = population(r,r_n) - 1;
        
        [~, ~, lshed, ~, ~, suc, ~, ~] = FACOPF(update_system(population(r,:), equipment, tsystem), voll);
        if (~(lshed==0 && counter<bls_try))||(suc ~= 1)
            sv_fit = fitness(r);
            sv_pop = population(r,:);
            sv_pop(r_n) = sv_pop(r_n)+1;
            sv_pen = pen(r); %0
        end
        
        if suc == 1
            fitness(r) = sum(population(r,:).*inv)+betta*lshed;
            pen(r) = lshed;
        else
            population(r,:) = sv_pop;
            fitness(r) = sv_fit;
            pen(r) = sv_pen;
        end
    end
    
    if indAux == 0
       sv_pop = population(r,:);
       sv_fit = fitness(r);
       sv_pen = pen(r); 
    end
    
    counter = 0;
    while pen(r)>0 && counter<bls_try % infeasible solution (add equipment)
        cond = 0;
        while cond == 0
            r_n = randi([1 dim],1,1);
            if population(r,r_n)<Xmax(r_n)
                cond = 1;
            end
            try
                if population(r,:)' == Xmax
                    population(r,:) = sv_pop;
                    fitness(r) = sv_fit;
                    pen(r) = sv_pen;
                    return
                end
            catch
                pause()
            end
        end
        counter = counter + 1;
        population(r,r_n) = population(r,r_n) + 1;
        [~, ~, lshed, ~, ~, suc, ~, ~] = FACOPF(update_system(population(r,:), equipment, tsystem), voll);
        if suc == 1
            fitness(r) = sum(population(r,:).*inv)+betta*lshed;
            pen(r) = lshed;
        else
            fitness(r) = betta^5;
            pen(r) = betta^5;
        end
    end

end

