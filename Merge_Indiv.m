function [Somato, Frtl, Files_name] = Merge_Indiv(File,Folder)
%Inputs are the %dir (directory) to the files the path to the folder
% containing data per group
%Example : File = dir('...\group\*.mat');
%Folder =('...\group');
Somato = []; %Create matrices for somatosensory and frontal data
Frtl = [];
Files_name = [];
for i = 1:length(File) %For as many files in the directory
    File_name = File(i).name; %Get the file name
    Files_name{1,i} = File_name; %save Files name
    fullFileName = fullfile(Folder, File_name); %Combine path + file name
    Struct_Variable = load(fullFileName); %Load the file
    Var_name = fieldnames(Struct_Variable); %Extract the variables name
    Data = struct2cell(Struct_Variable); %Convert data to cell array
    Somato{1,i} = File_name; %Create a cell array containing the file name for somato
    Frtl{1,i} = File_name;%and frtl
    Matrix_somato = []; %Create matrices that will temporarily contain data
    Matrix_frtl = [];
    for ii = 1 : length(Var_name) %For as many variables in the file
        if contains(Var_name{ii,:},'somato') == 1 %If the variable name contains somato
            Matrix_somato = cat(2, Matrix_somato, Data{ii,1}); %Store it in the somato matrix
            Somato{2,i} = Matrix_somato; %Store the matrix in the cell array under the corresponding file name
        else %Similar for frontal data with frontal matrices
            Matrix_frtl = cat(2, Matrix_frtl, Data{ii,1});
            Frtl{2,i} = Matrix_frtl; 
        end
    end
end
%Output is 2 cell arrays, one for somato data, one for frtl data. The
%arrays contain:
% First row : name of the conditions
% Second row : 1000 timeseries * X children matrix for each condition.
end