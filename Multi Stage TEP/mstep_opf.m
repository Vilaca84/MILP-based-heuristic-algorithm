function [fit_t,LS_t] = mstep_opf(vector, ph, mat_eqp, tsystem, dem_fac, voll, inv, ir, betta)

equipment = [];
for ano=1:ph
    [equipment, vec_inv] = call4equip(vector, ano, mat_eqp);
    [tsystem] = update_system(equipment, tsystem, dem_fac(ano));
    [~, ~, lshed, ~, ~, suc, ~, ~] = FACOPF(tsystem, voll);
    if suc == 1
        fitness(ano) = betta*lshed + sum(vec_inv.*inv)/(1+ir)^ano;
        LS(ano) = lshed;
    else
        fitness(ano) = betta^5;
        LS(ano) = betta^5;
    end
end
fit_t = sum(fitness);
LS_t = sum(LS);
end

