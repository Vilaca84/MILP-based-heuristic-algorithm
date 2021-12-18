function [tsystem, inv_dc] = insertEq(tsystem, adl, Xmin, equipment, inv, year, i_R)
inv_dc = [];
if ~isempty(adl)
    dc_sol = zeros(numel(Xmin),1);
    for i=1:size(adl,1)
        I = ismember(equipment(:,1:2),adl(i,:),'rows');
        dc_sol = dc_sol + I;
        clear I
    end
    
    if sum(dc_sol)>0
        aux = find(dc_sol==1);
        tsystem.branch(end+1:end+numel(aux),:) = equipment(aux,:);
    end
    inv_dc = sum(dc_sol.*inv')/((1+i_R)^year);
end


end
