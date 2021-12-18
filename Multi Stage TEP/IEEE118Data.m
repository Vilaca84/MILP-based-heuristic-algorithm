function [tsystem, equipment, Xmin, Xmax, inv] = IEEE118Data(ph)
    
    disp('Test System: IEEE-118-bus (Multi-Stage TEP)')
    
    tsystem = case118;
    tsystem.gen(:,10) = 0;
    tsystem.branch(:,6) = 0.7*tsystem.branch(:,6);
    
    matriz =   [3	5	8.73	120
                8	5	8.17	200
                8	9	16.43	200
                30	17	21.22	200
                8	30	8.67	120
                26	30	11.22	200
                55	56	14.66	120
                38	65	13.74	200
                77	78	8.97	120
                83	85	10.65	120
                85	86	22.77	200
                65	68	18.41	200
                38	37	19.24	200
                103	110	15.7	120
                110	112	18.71	120
                17	113	17.54	120
                12	117	3.18	120];
    vec1 = [];
    aux = [];
    for i=1:size(matriz,1)
        vec1 = matriz(i,1:2);
        aux = find(ismember(tsystem.branch(:,1:2),vec1,'rows')==1);
        if ~isempty(aux)
            equipment(i,:) = tsystem.branch(aux(1),:);
        end
        vec1 = [];
        aux = [];
    end
    
    equipment(:,6) = matriz(:,4);
    inv = matriz(:,3)';
    n_max = ones(numel(inv),1).*ph;
    Xmin = zeros(numel(n_max),1);
    
    % Considering maximum of 3 add per candidate circuit
    n_add = 1;
    equipment = repmat(equipment,n_add,1);
    Xmax = repmat(n_max,n_add,1);
    Xmin = repmat(Xmin,n_add,1);
    inv = repmat(inv,1,n_add);
    
end

