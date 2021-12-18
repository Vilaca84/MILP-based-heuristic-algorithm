function [swarm, fitness, pen] = selection_epso(popCell, fitCell, penCell)
% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021
        
[~,b] = size(popCell);
vecFit = [];
vecPen = [];

for i=1:b
    vecFit = [vecFit;fitCell{1,i}];
    vecPen = [vecPen;penCell{1,i}];
end

[~,a] = size(vecFit);

for i=1:a
    [x1,y1] = sort(vecFit(:,i));
    fitness(1,i) = x1(1);
    pen(1,i) = vecPen(y1(1),i);
    swarm(i,:) = popCell{1,y1(1)}(i,:);
end

end