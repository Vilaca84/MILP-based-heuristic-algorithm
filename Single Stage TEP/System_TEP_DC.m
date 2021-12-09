function [tsystem] = System_TEP_DC(tsystem, equipment, inv, Xmax)
    
    % Candidate
    equipment(:,11) = 0;
    [equipment, inv] = cand_dc(equipment, Xmax, inv);
    % Buses
    aux1 = tsystem.bus(:,3:4);
    tsystem.bus(:,3:4) = [];
    tsystem.bus(find(tsystem.bus(:,2)==3),2) = 0;
    
    % Branches
    aux3 = tsystem.branch(tsystem.branch(:,11)==0,:);
    tsystem.branch = tsystem.branch(tsystem.branch(:,11)==1,:);
    br_1 = [1:(size(tsystem.branch,1)+size(equipment,1))]';
    br_2345 = [tsystem.branch(:,1:4);equipment(:,1:4)];
    br_6 = zeros(numel(br_1),1);
    br_7 = [tsystem.branch(:,5);equipment(:,5)];
    br_8 = [tsystem.branch(:,9);equipment(:,9)];
    br_910 = [tsystem.branch(:,6:7);equipment(:,6:7)];
    br_11 = br_6;
    br_11(size(tsystem.branch,1)+1:end) = inv;
    br_12 = [tsystem.branch(:,11);equipment(:,11)];
    br_13 = ones(numel(br_1),1).*3;
%     br_13(ismember(br_2345(:,1:2), aux3(:,1:2), 'rows')) = 0;
    tsystem.branch = [br_1 br_2345 br_6 br_7 br_8 br_910 br_11 br_12 br_13];
    
    % Generator data
    gen_1 = [1:size(tsystem.gen,1)]';
    gen_234 = tsystem.gen(:,1:3);
    gen_56 = tsystem.gen(:,9:10);
    gen_78 = tsystem.gen(:,4:5);
    gen_91011 = tsystem.gen(:,6:8);
    gen_12 = tsystem.gencost(:,7);
    gen_13 = tsystem.gencost(:,6);
    gen_14 = tsystem.gencost(:,5);
    gen_15161718 = ones(size(tsystem.gen,1),1).*[9999	9999	1	1];
    
    tsystem.gen = [gen_1 gen_234 gen_56 gen_78 gen_91011 gen_12 gen_13 gen_14 gen_15161718];
    
    % load data
    ld_1 = tsystem.bus(:,1);
    tsystem.load = [ld_1 aux1];
    tsystem.load = tsystem.load((tsystem.load(:,2)~=0 & tsystem.load(:,3)~=0),:);
    aux4 = [1:size(tsystem.load,1)]';
    tsystem.load = [aux4 tsystem.load];
    
   
end

