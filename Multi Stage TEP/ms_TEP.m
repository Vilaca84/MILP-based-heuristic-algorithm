function [fitness,LS] = ms_TEP(inv,vector,j, i_R, lshed, suc, betta)

        vec = zeros(numel(vector),1);
        vec(vector==j)=1;

        if suc == 1
            fitness = (sum(vec.*inv')+betta*lshed)/((1+i_R)^j);
            LS = lshed;
        else
            fitness = (betta^5)/((1+i_R)^j);
            LS = betta^5;
        end

end

