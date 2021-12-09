function [tsystem] = update_system(vector, equipment, tsystem)
% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021

nvec = numel(vector);

for i=1:nvec
    if vector(i)~=0
        for j=1:vector(i)
            tsystem.branch(end+1,:)=equipment(i,:);
        end
    end
end

end


