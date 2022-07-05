function [N140_Somato, P500_Frtl] = Peak_Extact(Somato, Frtl)
%Input is the Somatosensory and Frontal matrices containing 1000 timeseries
%* x children obtained from Merge_Indiv.m
%Create cell arrays (one for somato, one for frontal) that will contain 
%value of the peaks for statistical analysis
N140_Somato_F_P = [];
P500_Frtl_F_P = []; 
for i = 1:length(Somato) %for as many variables
    N140 = []; %create a matrix for somato peaks extraction
    P500 = []; %create a matrix for frtl data extraction
        for ii = 1:size(Somato{2,i},2) %for as many children
            Value = min(Somato{2,i}(230:350,ii)); %extract the value of the N140
            N140 = [N140; Value]; %Store it in the matrix
            N140_Somato{2,i} = N140; %Store the matrix in a cell array
            Value = Frtl{2,i}(600:end,ii); %extract the value after 500ms
            P500 = [P500, Value]; %Store it in the matrix
            P500_Frtl{2,i} = P500; %Store matrix in cell array
        end
end
end
 %Output is 2 cell arrays containing 
 %First row : name of the condition
 %Second row Somato : Vectors containing the value the peak at N140 for
 %each children for each condition
 %Second row Frtl : Matrices containing the value from 500 ms post
 %stimulation for each children for each condition