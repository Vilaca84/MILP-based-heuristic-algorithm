function [cap, dem, lshed, loss, tcost, suc, p_flow, q_flow] = FACOPF(tsystem, voll)
% Any publication resulting from the use of this m-file shall acknowledge
% it by citing the following paper:

% Phillipe Vilaça, Alexandre Street and José Colmenar, 
% A MILP-based heuristic algorithm for transmission expansion planning problems.
% Electric Power Systems Research - Elsevier, 2021


%% Phillipe Vilaça Gomes, Universidad Rey Juan Carlos, Spain. November 2021

    %% Input 
    % cap: Capacity of the test system
    % dem: Demand of the system 
    % lshed: Sum of load shedding  (OPF)
    % loss: Sum of losses (OPF)
    % tcost: Total cost of the system
    % suc: Success
    % p_flow: Active power on the branches
    % q_flow: Reactive power on the branches

    ngen = size(tsystem.gen,1);
    cap = sum(tsystem.gen(:,9));
    tsystem = load2disp(tsystem);
    tam = size(tsystem.gen,1);
    tsystem.gencost(ngen+1:tam,5) = voll;
    
    warning off
    mpopt = mpoption('verbose',0,'out.all',0);
    [res, suc] = runopf (tsystem, mpopt);

    lshed = sum(loadshed(res.gen));
    dem = sum(total_load(tsystem));
    loss = sum(real(get_losses(res)));
    tcost = sum(totcost(res.gencost(1:ngen,:),res.gen(1:ngen,2)));
    p_flow = res.branch(:,14);
    q_flow = res.branch(:,15);
end