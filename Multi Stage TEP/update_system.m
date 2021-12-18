function [tsystem] = update_system(vector, equipment, tsystem, ph, df, year)
% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021


aux = find(vector<=year & vector~=0);
if ~isempty(aux)
    tsystem.branch(end+1:end+numel(aux),:) = equipment(aux,:);
end

factor = ((sum(tsystem.bus(:,3))/(1+df)^ph)*(1+df)^year)/sum(tsystem.bus(:,3));

tsystem.bus(:,3) = tsystem.bus(:,3).*factor;
tsystem.bus(:,4) = tsystem.bus(:,4).*factor;

end


