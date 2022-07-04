function [Somato, Frtl] = Indiv2group(File,Folder)
%Input is the file
Somato = []; %Create matrices for somatosensory and frontal data
Frtl = [];
for i = 1:length(File) %For as many files in the directory
File_name = File(i).name; %Get the file name
    fullFileName = fullfile(Folder, File_name); %Combine path + file name
    Struct_Variable = load(fullFileName); %Load the file
    Var_name = fieldnames(Struct_Variable); %Extract the variables name
    Data = struct2cell(Struct_Variable); %Convert data to cell array
    Somato{1,i} = File_name; %Create a cell array containing the file name for somato
    Frtl{1,i} = File_name;%and frtl
    Matrix_somato = []; %Create a matrix that will contain data
    Matrix_frtl = [];
    for ii = 1 : length(Var_name) %For as many variables
        if contains(Var_name{ii,:},'somato') == 1 %If the variable name contains somato
            Matrix_somato = cat(2, Matrix_somato, Data{ii,1}); %Store it in the somato matrix
            Somato{2,i} = Matrix_somato; %Store the matrix in the cell array under the corresponding file name
        else %Do same if variable name contains frtl
            Matrix_frtl = cat(2, Matrix_frtl, Data{ii,1});
            Frtl{2,i} = Matrix_frtl; 
        end
    end
    Somato{2,i} = mean(Somato{2,i},2); %Mean to get the Great mean for each condition
    Frtl{2,i} = mean(Frtl{2,i},2); %Mean to get the Great mean for each condition
end
%Output is 2 cell arrays, one for somato data, one for frtl data. The
%arrays contain in the fisrt row the name  of the condition, in the second
%row a 1000 timeseries vector for each condition.
end