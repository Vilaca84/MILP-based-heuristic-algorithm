function [tsystem, equipment, Xmin, n_max, inv] = RTS24Data()
% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021


disp('Test System: RTS-24-bus')

tsystem = case24_ieee_rts;
    
    tsystem.bus(:,3:4) = 3.*tsystem.bus(:,3:4);
    tsystem.bus(1,2) = 3;
    tsystem.bus(13,2) = 2;
    
    tsystem.gen(:,9) = 3.*tsystem.gen(:,9);
    tsystem.gen(:,10) = 0;
    
    tsystem.gen(:,4:5) = 3.*tsystem.gen(:,4:5);
    
    tsystem.branch(:,6) = tsystem.branch(:,8);
    
    [Au,~,ic] = unique(tsystem.branch, 'rows', 'stable');
    Counts = accumarray(ic, 1);
    Out = [Counts Au];
    
    equipment = Out(:,2:end);
    equipment(:,11) = 1;
    
    n = 3;
    
    n_max = n-(Out(:,1).*Out(:,12));
        
    inv = [3    55    22    35    33    50    33    31    50    27    23 ...
        50    16    16    43    43    50    50    50    50    66    58 ...
        66   134    62   120    54    86    24    68    72    36    32 ...
        114    20   146    36    55    84    30    94];
    
    Xmin = zeros(numel(n_max),1);
end

