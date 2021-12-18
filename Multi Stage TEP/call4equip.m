function [equipment, vec_inv] = call4equip(vector, ano, mat_eqp)

    aux = find(vector==ano);
    vec_inv = zeros(numel(vector),1);
    vec_inv(aux) = 1;
    equipment = mat_eqp(vec_inv==1,:);
end

