function [matriz, matinv] = cand_dc(equipment, Xmax, inv)

matriz = [];
matinv = [];
for i=1:numel(Xmax)
    for j=1:Xmax(i)
        matriz = [matriz;equipment(i,:)];
        matinv = [matinv;inv(i)];
    end
end

end

