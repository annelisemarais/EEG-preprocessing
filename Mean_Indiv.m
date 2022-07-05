function [Mean_Somato, Mean_Frtl] = Mean_Indiv(Somato, Frtl)
%Input are Somato and Frontal cell array from Merge_Indiv.m
for i = 1:length(Somato) %For as many condition
    Mean_Somato{2,i} = mean(Somato{2,i},2); %Mean children to get the Great mean for each condition
    Mean_Frtl{2,i} = mean(Frtl{2,i},2); %Mean children to get the Great mean for each condition
end
%Output is 2 cell arrays containing:
%First row : name of the condition
%Second row : Vectors of 1000 timeseries (Great mean)