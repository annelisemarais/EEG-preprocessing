%Code : Anne-Lise Marais
%Preprocessing (filtering and artifact rejection) : Anne-Lise Marais or Marie Anquetil or Victoria Dumont w/ Netstation EGI
%Data acquisition : Marie Anquetil or Anne-Lise Marais or Victoria Dumont
%Protocol : Anne-Lise Marais

%This code preprocesses the data of an oddball somatosensory protocol for the DECODE research. See https://www.unicaen.fr/projet_de_recherche/decode/
%7 conditions : Std (Standard, all standards stimulations except Fam and Con), Fam (40 first standards stimulations), Con (40 last standards stimulations), StimMoy (Standard stimulation used for comparison), Deviant, PostOm (Standard stimulation right after the omission), Omission (Absence of stimulation)
%Omission last 7200 ms. A stimulation is expected after 3300-3700 ms. From 3700ms its an omission, the the X value is 0 ms into omission
%2 brain regions : ctrl (somatosensory), frtl (frontal)
%Children were stimulated either on the right(1) or left(2) arm
%there are 5 groups preprocessed with this code : two years old, four years old typical, four years old
%atypical, six years old typical, six years old atypical
%%
%REPLACE subjectgroup by the name of subgroup

if strlength('subjectgroup') == 12
    disp('replace sub by the name of the group')
    return
end
%%
Folder = dir('...\subjectgroup_preprocess\subjectgroup*') %Get the folder directory
%%
Table = readtable('...\subjectgroup_preprocess\ArmStimulated.xlsx');
if length(Folder) ~= width(Table)
    disp('Complete ArmStimulated.xlsx with new participants')
    return
end
%%
%Get raw data for each children
%%
for i = 1:length(Folder) %For as many folder in the directory
        str = append(Folder(i).name,'_Filtered.mat'); %Get the file name
        File_path = fullfile(Folder(i).folder,Folder(i).name,str); %Create the file path by merging info
        Filtered_data = struct2cell(load(File_path, '*filmff2')); %Load data in cell array
        Raw_data{2,i} = Filtered_data{1,1}; %Save the cell in an array
        Raw_data{1,i} = Folder(i).name; %Put the subject code in the first row
end
%%
%Save raw data
save('...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Raw.mat', 'Raw_data', '-v7.3')
%%
%clear
%load '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Raw.mat'
%%
%Offset measure
%%
%Because of the recording material and filtering, there is a relative offset for each participant
%The offset has to be measured to get the proper segmentation
%The measure will be taken using the NetStation software segmentation and the raw data
%%
Index = {}; %Create an idex cell array
for i = 1:length(Folder) %For as many folders
        str = append(Folder(i).name,'_Segmented.mat'); %Get the file name
        File_path = fullfile(Folder(i).folder,Folder(i).name,str); %Create the file path by merging info
        load(File_path, 'Fam_Segment_001') %load the first segment
        Vector = Fam_Segment_001(:,1); %Get the values of the first segment (software segmentation)
        Matrix = Raw_data{2,i}(:,1:12000); %Get the first 12s of the protocol
        Logic_Matrix = ismember(Matrix,Vector); %Find the vector in the matrix (the first segment in the raw data)
        Logic_Vector = Logic_Matrix(1,:); %Use only the first row of data
        Idx_Value = find(Logic_Vector) + 99;%Get the index of the first segment in the matrix + 99ms to get to the tag
        Index{2,i} = Idx_Value; %Store the idx of the tag of the first segment
        Index{1,i} = Folder(i).name; %Store the name of the subject above the Idx value
end
%%
Events = {}; %Create an Events cell array
for i = 1:length(Folder) %For as many folders
        str = append(Folder(i).name,'_Event.xlsx'); %Get the file name
        File_path = fullfile(Folder(i).folder,Folder(i).name,str); %Create the file path by merging info
        readtable(File_path); %load event from Eprime software
        Tag_Idx = round(ans.Tag_time); %Extract the idx of the tag
        Tag_Number = round(ans.Tag_number); %Extract the number of the tag
        Offset = Tag_Idx(1,1) - Index{2,i}; %Measure the offset
        Tags = Tag_Idx - Offset;% Apply (substract) offset to the tags
        Events{2,i} = Tags; %Store the tags in the events array
        Events{3,i} = Tag_Number; %Store the tags number in the event array
        Events{1,i} = Folder(i).name; %Store the name of the subject above the tags
        %Save for each subject
        str = append(Folder(i).name,'_Tags.mat'); 
        File_path = fullfile(Folder(i).folder,Folder(i).name,str);
        save(File_path, 'Tags')
        str = append(Folder(i).name,'_TagNumber.mat'); 
        File_path = fullfile(Folder(i).folder,Folder(i).name,str);
        save(File_path, 'Tag_Number')
end
%%
%Save all subjects events
save '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Events.mat' 'Events'
%%
Idx_Segmentation = {}; %Create an Idx_Segmentation cell array
for i = 1:length(Events) %For ar many subjects
    Matrix_Omi = []; %Create a matrix for each condition
    Matrix_Fam = [];
    Matrix_Std = [];
    Matrix_Deviant = [];
    Matrix_Con = [];
    Matrix_StimMoy = [];
    Matrix_PostOm = [];
    for ii = 1:length(Events{3,i}) %For as many events
            if Events{3,i}(ii,1) == 55 %if the code of the segment is 55 (omission)
                Segment = ((Events{2,i}(ii,1))-1199: (Events{2,i}(ii,1))+3500)'; %Create an index vector following the length of the epoch
                Matrix_Omi = [Matrix_Omi, Segment]; %Store the index vector in an omission matrix
                %Repeat for every condition
            elseif Events{3,i}(ii,1) < 41 
                Segment = ((Events{2,i}(ii,1))-99: (Events{2,i}(ii,1))+900)';
                Matrix_Fam = [Matrix_Fam, Segment];
            elseif Events{3,i}(ii,1) == 51
                Segment = ((Events{2,i}(ii,1))-99: (Events{2,i}(ii,1))+900)';
                Matrix_Std = [Matrix_Std, Segment];
            elseif Events{3,i}(ii,1) == 53
                Segment = ((Events{2,i}(ii,1))-99: (Events{2,i}(ii,1))+900)';
                Matrix_Deviant = [Matrix_Deviant, Segment];
            elseif Events{3,i}(ii,1) == 54
                Segment = ((Events{2,i}(ii,1))-99: (Events{2,i}(ii,1))+900)';
                Matrix_StimMoy = [Matrix_StimMoy, Segment];
            elseif Events{3,i}(ii,1) == 57
                Segment = ((Events{2,i}(ii,1))-99: (Events{2,i}(ii,1))+900)';
                Matrix_PostOm = [Matrix_PostOm, Segment];
            elseif Events{3,i}(ii,1) > 149
                Segment = ((Events{2,i}(ii,1))-99: (Events{2,i}(ii,1))+900)';
                Matrix_Con = [Matrix_Con, Segment];
            end
    end
    Idx_Segmentation{2,i}{1,1} = Matrix_Con; %Store the matrices in the Idx_Segmentation cell array
    Idx_Segmentation{2,i}{1,2} = Matrix_Deviant;
    Idx_Segmentation{2,i}{1,3} = Matrix_Fam;
    Idx_Segmentation{2,i}{1,4} = Matrix_Omi;
    Idx_Segmentation{2,i}{1,5} = Matrix_PostOm;
    Idx_Segmentation{2,i}{1,6} = Matrix_Std;
    Idx_Segmentation{2,i}{1,7} = Matrix_StimMoy;
    Idx_Segmentation{1,i} = Events{1,i};
    %Save for each subject individually
    Index_Segmentation = Idx_Segmentation{2,i};
    str = append(Folder(i).name,'_IdxSegmentation.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Index_Segmentation');
end
%%
save '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Idx_Segmentation.mat' 'Idx_Segmentation'
%%
Segmentation = {};
for i = 1 : length(Idx_Segmentation)
    Matrix = [];
    for ii = 1:length(Idx_Segmentation{2,i})
        Segment = Raw_data{2,i}(:,Idx_Segmentation{2,i}{1,ii});
        Matrix{1,ii} =  Segment;
    end
    Segmentation{2,i} = Matrix;
    Segmentation{2,i}{1,1} = reshape(Segmentation{2,i}{1,1}, 129, 1000, []);
    Segmentation{2,i}{1,2} = reshape(Segmentation{2,i}{1,2}, 129, 1000, []);
    Segmentation{2,i}{1,3} = reshape(Segmentation{2,i}{1,3}, 129, 1000, []);
    Segmentation{2,i}{1,4} = reshape(Segmentation{2,i}{1,4}, 129, 4700, []);
    Segmentation{2,i}{1,5} = reshape(Segmentation{2,i}{1,5}, 129, 1000, []);
    Segmentation{2,i}{1,6} = reshape(Segmentation{2,i}{1,6}, 129, 1000, []);
    Segmentation{2,i}{1,7} = reshape(Segmentation{2,i}{1,7}, 129, 1000, []);
    Segmentation{1,i} = Folder(i).name; %Store the name of the subject above the segments
    %Save for each subject individually
    Epochs = Segmentation{2,i};
    str = append(Folder(i).name,'_Segmentation.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Epochs');
end
%%
save('...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Segmentation.mat', 'Segmentation', '-v7.3')
%%
%ARTIFACT DETECTION
%%
%clear
%load '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Segmentation.mat'
%%
Log_cell = {}; 
Log_info = {};

for i = 1:length(Folder) %For as many participants
    Log_cell = {}; %Create a cell array that will hold the cells
    str = append(Folder(i).name,'_log.xlsx'); %create the path to the log information
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    Log = readtable(File_path, 'Format', 'auto'); %load the log
    
    ADSegment = strcmp((string(Log.SegmentGood)), "true"); %logical 1 if the epoch has no artifact
    for ii = 1:length(ADSegment) %for as many epochs
        if ADSegment(ii,:) == 1 %if the epoch contains no artifact
            Row = table2cell(Log(ii,:)); %extract the information of the epoch
            Log_cell(ii,:) = Row; %Save it in a cell
        end
    end
    Log_cell = Log_cell(~cellfun(@isempty, Log_cell(:,1)), :); %Take any empty row
    Log_info{1,i} = Log_cell; %Save the log informations in a cell for every particpant
    %Save for each paricipant individually
    str = append(Folder(i).name,'_LogInfo.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Log_cell');
end
%%
AD = {}; %Create an artifact detection matrix

for i = 1:length(Folder) %For as many participants
    %Create a matrix for each condition
    Con = [];
    Deviant = [];
    Fam = [];
    Omission = [];
    PostOm = [];
    Std = [];
    StimMoy = [];
    for ii = 1 : length(Log_info{1,i}) %For as many epochs for the participant
        if strcmp(Log_info{1,i}(ii,1),'Con') == 1 %if the epoch is legend 'Con'
            Con = [Con ; Log_info{1,i}(ii,:);]; %Save it in the Con matrix
            %Repeat for every condition
        elseif strcmp(Log_info{1,i}(ii,1),'Deviant') == 1
            Deviant = [Deviant ; Log_info{1,i}(ii,:);];
        elseif strcmp(Log_info{1,i}(ii,1),'Fam') == 1
            Fam = [Fam ; Log_info{1,i}(ii,:);];
        elseif strcmp(Log_info{1,i}(ii,1),'Omission') == 1
            Omission = [Omission ; Log_info{1,i}(ii,:);];
        elseif strcmp(Log_info{1,i}(ii,1),'PostOm') == 1
            PostOm = [PostOm ; Log_info{1,i}(ii,:);];
        elseif strcmp(Log_info{1,i}(ii,1),'Std') == 1
            Std = [Std ; Log_info{1,i}(ii,:);];
        elseif strcmp(Log_info{1,i}(ii,1),'StimMoy') == 1
            StimMoy = [StimMoy ; Log_info{1,i}(ii,:);];
        end
        %Save the matrices in the artifact detection cell array
    AD{2,i}{1,1} = Con;
    AD{2,i}{1,2} = Deviant;
    AD{2,i}{1,3} = Fam;
    AD{2,i}{1,4} = Omission;
    AD{2,i}{1,5} = PostOm;
    AD{2,i}{1,6} = Std;
    AD{2,i}{1,7} = StimMoy;
    AD{1,i} = Folder(i).name;
    end
    %save for each subject individually
    AD_Log = AD{2,i};
    str = append(Folder(i).name,'_Log.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'AD_Log');
end
%%
save '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Log.mat' 'AD'
%%
%clear
%load '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Log.mat'
%%
Artifact_Free = {};
for i = 1:length(AD) %For as many subjects
    for ii = 1: length(AD{2,i}) %For as many condition
        Matrix = [];
        for iii = 1:size((AD{2,i}{1,ii}),1) %For as many epochs
            Good_Segment_Nb = cell2mat(AD{2,i}{1,ii}(iii,2)); %Transform cell to array
            %Sometimes the integer is taken as char, transform it back to
            %integer in if -> DEBUG TO DO
            if isa(Good_Segment_Nb,'char') == 1
                Good_Segment_Nb = str2num(Good_Segment_Nb);
            end
            Good_Segment = Segmentation{2,i}{1,ii}(:,:,Good_Segment_Nb);
            Matrix = cat(3, Matrix, Good_Segment);
        end
         Artifact_Free{2,i}{1,ii} = Matrix;
    end
    Artifact_Free{1,i}= Folder(i).name;
    %Save for each subject individually
    ArtifactDetection = Artifact_Free{2,i};
    str = append(Folder(i).name,'_ArtifactDetection.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'ArtifactDetection');
end
%%
save('...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_AD.mat', 'Artifact_Free', '-v7.3')
%%
%REREFERENCING to scalp average
%Re-referencing is achieved by creating an average of all scalp
%channels and subtracting the resulting signal from each channel.
%For each epoch, substract the mean electrode activation at time T to all
%electrodes, without taking bad channels (BC) into account
%%
BC_Free = Artifact_Free; %Copy data that will drop BC
Rereferenced = {}; %Create a cell array
for i = 1:length(AD) %for as many children
    for ii = 1:length(AD{2,i}) %for as many condition
        Matrix = []; %Create a matrix that will hold the data
        for iii = 1 : size(AD{2,i}{1,ii},1) %For as many epochs
            BC_cell = cell2mat(AD{2,i}{1,ii}(iii,6)); %Get the bad channel per epoch
            BC_nb = sscanf(BC_cell,'%f, '); %string to number
            BC = [BC_nb;129]; %add channel 129
            BC_Free{2,i}{1,ii}(BC,:,iii) = NaN; %Replace all bad channel with NaN
            Epoch = BC_Free{2,i}{1,ii}(:,:,iii); %Extract the epoch replaced with NaNs
            Ref = mean(Epoch,1, 'omitnan'); %mean the electrodes of the epoch to get mean activation per timeseries, omiting bad channels
            Epoch_AD = Artifact_Free{2,i}{1,ii}(:,:,iii); %Get the epoch without NaN
            Epoch_Ref = Epoch_AD - Ref; %substract the reference from the epoch without NaN
            Matrix = cat(3, Matrix,Epoch_Ref); %concatenante epochs
        end
        Rereferenced{2,i}{1,ii} = Matrix; %Save Matrix in cell array
        Rereferenced{1,i} = Folder(i).name;
    end
    ReferencedData = Rereferenced{2,i};
    str = append(Folder(i).name,'_Rereferenced.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'ReferencedData');
end
%%
save('...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Rereferenced.mat', 'Rereferenced', '-v7.3')
%%
%clear
%load '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Rereferenced.mat'
%%
%BASELINE CORRECTION
%%
Corrected = {};
for i = 1:length(Rereferenced)
    str = append(Folder(i).name,'_Corrected.mat'); %Get the file name
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    for ii = 1:length(Rereferenced{2,i})
       Matrix = [];
        for iii = 1:size(Rereferenced{2,i}{1,ii},3)
                   if size(Rereferenced{2,i}{1,ii},2) == 4700
                       Baseline = mean(Rereferenced{2,i}{1,ii}(:,899:999,iii),2);
                       Epoch_corrected = Rereferenced{2,i}{1,ii}(:,:,iii) - Baseline;
                       Matrix = cat(3, Matrix, Epoch_corrected);
                   else
                       Baseline = mean(Rereferenced{2,i}{1,ii}(:,1:99,iii),2);
                       Epoch_corrected = Rereferenced{2,i}{1,ii}(:,:,iii) - Baseline;
                       Matrix = cat(3, Matrix, Epoch_corrected);
                   end
        end
        Corrected{2,i}{1,ii} = Matrix; %Save Matrix in cell array
        Corrected{1,i} = Folder(i).name;
    end
    Corrected_data = Corrected{2,i};
    save(File_path, 'Corrected_data')
end
%%
save('...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Baseline_Corrected.mat', 'Corrected', '-v7.3')
%%
%number of epochs
%%
NumberEpochs = {};
for i =1:length(Corrected)
    for ii = 1:length(Corrected{2,i})
        Size = size(Corrected{2,i}{1,ii},3);
        NumberEpochs{2,i}{1,ii} = Size;
    end
    NumberEpochs{1,i} = Folder(i).name;
    Nb_Epochs = NumberEpochs{2,i};
    str = append(Folder(i).name,'_NbEpochs.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Nb_Epochs');
end

TotalEpochs = {};
TotalCon = 0;
TotalDev = 0;
TotalFam = 0;
TotalOmi = 0;
TotalPOm = 0;
TotalStd = 0;
TotalMoy = 0;
for i = 1:length(NumberEpochs)
    TotalCon = TotalCon + NumberEpochs{2,i}{1,1};
    TotalDev = TotalDev + NumberEpochs{2,i}{1,2};
    TotalFam = TotalFam + NumberEpochs{2,i}{1,3};
    TotalOmi = TotalOmi + NumberEpochs{2,i}{1,4};
    TotalPOm = TotalPOm + NumberEpochs{2,i}{1,5};
    TotalStd = TotalStd + NumberEpochs{2,i}{1,6};
    TotalMoy = TotalMoy + NumberEpochs{2,i}{1,7};
end
%%
save '...\subjectgroup_preprocess\Results_subjectgroup\F_subjectgroupotal_Epochs.mat' ...
    TotalCon TotalDev TotalFam TotalOmi TotalPOm TotalStd TotalMoy 
%%
disp('Preprocessed with success')
%%
clearvars -except Corrected Folder
%%
%Invert data from participant with left stimulation
%%
Reversed_data = Corrected;

%load the excel sheet containing the arm stimulated
str = append('ArmStimulated.xlsx');
File_path = fullfile(Folder(1).folder,str);
%Table to cell array
Arm = readcell(File_path);
%
reverse_electrode = readcell('...\reverse_electrode.xlsx');

matrix = [];


for i = 1:length(Folder) %for as many participants
    for ii = 1:length(Arm) %for as many arm stimulated
        if strcmp(Folder(i).name,Arm(1,ii)) %if subject code matches
            if Arm{2,ii} == 2 %if arm stimulated is left
                for j = 1:length(Reversed_data{2,i}) %for as many condition
                    matrix  = Reversed_data{2,i}{1,j}; %extract the data
                    inverted_matrix = [];
                    for k = 1:length(reverse_electrode) %for as many electrodes
                        inverted_matrix(reverse_electrode{k,2},:,:) = matrix(reverse_electrode{k,1},:,:); %reverse data
                    end
                    Reversed_data{2,i}{1,j} = inverted_matrix;
                end
            end
        end
    end         
    Reverse = Reversed_data(:,i);
    str = append(Folder(i).name,'_Reverse.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Reverse');
end
save '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Reverse.mat' 'Reversed_data'
%%
%MEAN EPOCHS
%%
subjectgroup_2D = {};
for i =1:length(Reversed_data)
    for ii = 1:length(Reversed_data{2,i})
        Epoch_mean = mean(Reversed_data{2,i}{1,ii},3);
        subjectgroup_2D{2,i}{1,ii} = Epoch_mean;
    end
    subjectgroup_2D{1,i} = Folder(i).name;
    Data2D = subjectgroup_2D{2,i};
    str = append(Folder(i).name,'_2D_Data.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Data2D');
end

subj_name = subjectgroup_2D(1,:)';
%%
save '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_2D.mat' subjectgroup_2D
%%
%SINGLE AD
%%
for i = 1:length(Reversed_data)
    Hand_AD = {};
    for ii = 1:length(Reversed_data{2,i})
        Somato = Reversed_data{2,i}{1,ii}([29,29,35,36,41,42,47,52],:,:);
        Frontal = Reversed_data{2,i}{1,ii}([5,6,7,12,13,106,112,129],:,:);
        Hand_AD{1,ii} = Somato;
        Hand_AD{2,ii} = Frontal;
    end
    str = append(Folder(i).name,'_HandAD.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Hand_AD');
end
%%
%129*1000*nb_of_subjects
%%
subjectgroup_Fam = [];
subjectgroup_Con = [];
subjectgroup_Omi = [];
subjectgroup_POm = [];
subjectgroup_Std = [];
subjectgroup_Moy = [];
subjectgroup_Dev = [];

for i = 1 :length(subjectgroup_2D)
        subjectgroup_Con = cat(3, subjectgroup_Con, subjectgroup_2D{2,i}{1,1});
        subjectgroup_Dev = cat(3, subjectgroup_Dev, subjectgroup_2D{2,i}{1,2});
        subjectgroup_Fam = cat(3,subjectgroup_Fam, subjectgroup_2D{2,i}{1,3});
        subjectgroup_Omi = cat(3, subjectgroup_Omi, subjectgroup_2D{2,i}{1,4});
        subjectgroup_POm = cat(3, subjectgroup_POm, subjectgroup_2D{2,i}{1,5});
        subjectgroup_Std = cat(3,subjectgroup_Std, subjectgroup_2D{2,i}{1,6});
        subjectgroup_Moy = cat(3,subjectgroup_Moy, subjectgroup_2D{2,i}{1,7});
end

Conditions_AllElectrodes = {};
Conditions_AllElectrodes{1,1} = subjectgroup_Con;
Conditions_AllElectrodes{1,2} = subjectgroup_Dev;
Conditions_AllElectrodes{1,3} = subjectgroup_Fam;
Conditions_AllElectrodes{1,4} = subjectgroup_Omi;
Conditions_AllElectrodes{1,5} = subjectgroup_POm;
Conditions_AllElectrodes{1,6} = subjectgroup_Std;
Conditions_AllElectrodes{1,7} = subjectgroup_Moy;
%%
%Get behavioral data
%%
Behavioral_data = readtable('...\Tests_psycho_CR.xlsx');
PsychoEval = [];

for ii = 1:length(subj_name)
    for i = 1:size(Behavioral_data,1)
        if strcmp(Behavioral_data{i,1},subj_name(ii,1)) == 1
            PsychoEval = [PsychoEval; Behavioral_data(i,:)];
        end
    end
end

if strcmp(PsychoEval{1,1},subj_name(1,1)) == 1
    Conditions_AllElectrodes{1,8} = PsychoEval;
else
    disp('Problem with subject order, behavioral row doesnt match EEG row')
    return
end
%%
save '...\subjectgroup_preprocess\Results_subjectgroup\PsychoEval_FP.mat' 'PsychoEval'
save '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Conditions_AllElectrodes.mat' Conditions_AllElectrodes
%%
Conditions_Stats_subjectgroup = {};
for i = 1:length(Conditions_AllElectrodes)-1
        Somato = permute(mean(Conditions_AllElectrodes{1,i}([28,29,35,36,41,42,47,52],:,:),1),[3,2,1]);
        Frtl = permute(mean(Conditions_AllElectrodes{1,i}([5,6,7,12,13,106,112,129],:,:),1),[3,2,1]);
        Conditions_Stats_subjectgroup{1,i} = Somato;
        Conditions_Stats_subjectgroup{2,i} = Frtl;
end 

Conditions_Stats_subjectgroup{1,8} = 'Somato';
Conditions_Stats_subjectgroup{2,8} = 'Frtl';
Conditions_Stats_subjectgroup{3,1} = 'Control';
Conditions_Stats_subjectgroup{3,2} = 'Deviant';
Conditions_Stats_subjectgroup{3,3} = 'Familiarization';
Conditions_Stats_subjectgroup{3,4} = 'Omission';
Conditions_Stats_subjectgroup{3,5} = 'PostOm';
Conditions_Stats_subjectgroup{3,6} = 'Standard';
Conditions_Stats_subjectgroup{3,7} = 'StimMoy';
Conditions_Stats_subjectgroup{3,8} = PsychoEval;
%%
save '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Conditions_Stats.mat' Conditions_Stats_subjectgroup
save '...\All_Results\subjectgroup_Conditions_Stats.mat' Conditions_Stats_subjectgroup
%%
Conditions_Visu_subjectgroup = {};
for i = 1:length(Conditions_Stats_subjectgroup)
    Somato = mean(Conditions_Stats_subjectgroup{1,i},1);
    Frtl = mean(Conditions_Stats_subjectgroup{2,i},1);
    Conditions_Visu_subjectgroup{1,i} = Somato;
    Conditions_Visu_subjectgroup{2,i} = Frtl;
end 
Conditions_Visu_subjectgroup{1,8} = 'Somato';
Conditions_Visu_subjectgroup{2,8} = 'Frtl';
Conditions_Visu_subjectgroup{3,1} = 'Control';
Conditions_Visu_subjectgroup{3,2} = 'Deviant';
Conditions_Visu_subjectgroup{3,3} = 'Familiarization';
Conditions_Visu_subjectgroup{3,4} = 'Omission';
Conditions_Visu_subjectgroup{3,5} = 'PostOm';
Conditions_Visu_subjectgroup{3,6} = 'Standard';
Conditions_Visu_subjectgroup{3,7} = 'StimMoy';
%%
save '...\subjectgroup_preprocess\Results_subjectgroup\subjectgroup_Conditions_Visu.mat' Conditions_Visu_subjectgroup
%%
disp('Visu done with sucess')
clearvars -except Conditions_Visu_subjectgroup Conditions_Stats_subjectgroup