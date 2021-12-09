function [out] = randomsort(d, s_tg, s_ind, rho, Xmax, Xmin)

if d==1 % infeasible to feasible
    % probabilities to choose an equipment to add in the infeasible solution
    p = ones(1,numel(s_ind));
    p(s_ind==Xmax) = 0;    
    
    % probalibities to choose an equipment in the target (feasible) solution
    pt = ones(1,numel(s_tg)).*rho;
    pt(s_tg==0) = 0;
    pt(s_ind==Xmax) = 0;   
else % feasible to infeasible
    % probabilities to choose an equipment to remove in the feasible solution
    p = ones(1,numel(s_ind));
    p(s_ind==Xmin) = 0; 
    
    % probalibities to choose an equipment in the target (infeasible) solution
    pt = ones(1,numel(s_tg)).*rho;
    pt(s_tg>s_ind) = 0;
    pt(s_ind==Xmin) = 0;
end
p(pt~=0) = pt(pt~=0);
p = p./sum(p);
out = randsrc(1,1,[1:numel(p);p]);

end
