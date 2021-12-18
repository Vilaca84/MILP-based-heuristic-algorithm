function [div, Av_f, Std_f, bfit, wfit, EC, fes] = search_analysis(population, fitness, pen)
    %% Statistical analysis for the set of solutions
    % 1) Unique diversity
        [~,ia,~]=unique(population,'rows','stable');
        div = length(ia)*100/size(population,1);
    % 2) Average euclidian distance diversity
        for i=1:size(population,1)
            counter = 0;
            for j=1:size(population,1)
                if i~=j
                    counter = counter + 1;
                    ED(counter) = norm(population(i,:) - population(j,:));
                end
            end
            eucl_d(i) = mean(ED);
        end
        EC = mean(eucl_d);
        
    % 3) Average fitness
        Av_f = mean(fitness);
    % 4) Std fitness
        Std_f = std(fitness);
    % 5) Best fitness
        bfit = min(fitness);
    % 6) Worst fitness
        wfit = max(fitness);
    % 7) Percentage of feasibles
        fes = 100*size(find(pen==0),2)/numel(pen);
end