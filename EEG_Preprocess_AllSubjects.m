clear
%%
Folder = dir('...\sub*') %Get the folder directory
%%
Table = readtable('...\ArmStimulated.xlsx'); %Get info about arm stimulated
if length(Folder) ~= width(Table) %if there is not the same number of data and arm stimulatated
    disp('Complete ArmStimulated.xlsx with new participants') %Complete missing info
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
save('...\sub_Raw.mat', 'Raw_data', '-v7.3')
%%
%clear
%load '...\sub_Raw.mat'
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
save '...\sub_Events.mat' 'Events'
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
save '...\sub_Idx_Segmentation.mat' 'Idx_Segmentation'
%%
Segmentation = {}; %Create a cell array
for i = 1 : length(Idx_Segmentation) %for as many subjects
    Matrix = []; %create a matrix
    for ii = 1:length(Idx_Segmentation{2,i}) %For as many events
        Segment = Raw_data{2,i}(:,Idx_Segmentation{2,i}{1,ii}); %Extract the segment from the raw data
        Matrix{1,ii} =  Segment; %Strore the segment in the matrix
    end
    Segmentation{2,i} = Matrix; %Save the matrix for each subject
    Segmentation{2,i}{1,1} = reshape(Segmentation{2,i}{1,1}, 129, 1000, []); %rechape the segment to get 129 lectrodes, 1000 time series, X segments
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
save('...\sub_Segmentation.mat', 'Segmentation', '-v7.3')
%%
%ARTIFACT DETECTION
%%
%clear
%load '...\sub_Segmentation.mat'
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
save '...\sub_Log.mat' 'AD'
%%
%clear
%load '...\sub_Log.mat'
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
            Good_Segment = Segmentation{2,i}{1,ii}(:,:,Good_Segment_Nb); %Keep only good segment
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
save('...\sub_AD.mat', 'Artifact_Free', '-v7.3')
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
save('...\sub_Rereferenced.mat', 'Rereferenced', '-v7.3')
%%
%clear
%load '...\sub_Rereferenced.mat'
%%
%BASELINE CORRECTION
%%
Corrected = {};
for i = 1:length(Rereferenced)%For as many subjects
    str = append(Folder(i).name,'_Corrected.mat'); %Get the file name
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);%Get the file path
    for ii = 1:length(Rereferenced{2,i})%For as many conditions
       Matrix = [];%Create a matrix
        for iii = 1:size(Rereferenced{2,i}{1,ii},3) %For as many segment in condition ii
                   if size(Rereferenced{2,i}{1,ii},2) == 4700 %If the segment is an omission
                       Baseline = mean(Rereferenced{2,i}{1,ii}(:,899:999,iii),2);%Get baseline just before the omission
                       Epoch_corrected = Rereferenced{2,i}{1,ii}(:,:,iii) - Baseline; %Correct the segment
                       Matrix = cat(3, Matrix, Epoch_corrected);%Put segment in matrix
                   else 
                       Baseline = mean(Rereferenced{2,i}{1,ii}(:,1:99,iii),2);%Get the baseline
                       Epoch_corrected = Rereferenced{2,i}{1,ii}(:,:,iii) - Baseline; %correct the segment
                       Matrix = cat(3, Matrix, Epoch_corrected);%Put segment in matrix
                   end
        end
        Corrected{2,i}{1,ii} = Matrix; %Save Matrix in cell array
        Corrected{1,i} = Folder(i).name;
    end
    %Save individually
    Corrected_data = Corrected{2,i};
    save(File_path, 'Corrected_data')
end
%%
save('...\sub_Baseline_Corrected.mat', 'Corrected', '-v7.3')
%%
%number of epochs
%%
NumberEpochs = {}; %Create a cell array
for i =1:length(Corrected) %For as many subjects
    for ii = 1:length(Corrected{2,i})%For as many conditions
        Size = size(Corrected{2,i}{1,ii},3);%Get the number of epoch for condition ii
        NumberEpochs{2,i}{1,ii} = Size;%Put the save in celle array
    end
    %save individually
    NumberEpochs{1,i} = Folder(i).name;
    Nb_Epochs = NumberEpochs{2,i};
    str = append(Folder(i).name,'_NbEpochs.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Nb_Epochs');
end
%Make the total of all subject
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
save '...\sub_Total_Epochs.mat' ...
    TotalCon TotalDev TotalFam TotalOmi TotalPOm TotalStd TotalMoy 
%%
disp('Preprocessed with success')
%%
clearvars -except Corrected Folder
%%
%MEAN EPOCHS
%%
sub_2D = {}; %Create a celle array
for i =1:length(Corrected) %For as many subjects
    for ii = 1:length(Corrected{2,i}) %for as many conditions
        Epoch_mean = mean(Corrected{2,i}{1,ii},3); %mean epochs to get 129electrodes*1000timeseries
        sub_2D{2,i}{1,ii} = Epoch_mean;%Save condition
    end
    %save for all and individually
    sub_2D{1,i} = Folder(i).name;
    Data2D = sub_2D{2,i};
    str = append(Folder(i).name,'_2D_Data.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Data2D');
end
%%
subj_name = sub_2D(1,:)'; %get subjects name
%%
save '...\sub_2D.mat' sub_2D
%%
%ARM STIMULATED
%%
Arm_stimulated = {};

%load the excel sheet containing the arm stimulated
str = append('ArmStimulated.xlsx');
File_path = fullfile(Folder(1).folder,str);
%Table to cell array
Arm = readcell(File_path);
%

for i = 1:length(Folder) %Get the electrodes corresponding to the stimulated arm
    for ii = 1:length(Arm)
        if strcmp(Folder(i).name,Arm(1,ii))
            Arm_stimulated{2,i} = cell2mat(Arm(2,ii));
            Arm_stimulated{4,i} = [5, 6, 7, 12, 13, 106, 112];
            if Arm_stimulated{2,i} == 1
               Arm_stimulated{3,i} = [28, 29, 35, 36, 41, 42, 47];
            else
               Arm_stimulated{3,i} = [93, 98, 103, 104, 110, 111, 117];
            end
        end
    end
    %Some particpants need additional electrode removal
    %e.g. if participant 24 needs electrode 36 removed from analysis
%     if i == 24
%        Arm_stimulated{3,i} =  [28, 29, 35, 41, 42, 47];
%     end
%Save
    Arm_stimulated{1,i} = Folder(i).name;
    ArmElectrodes = Arm_stimulated(:,i);
    str = append(Folder(i).name,'_Arm.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'ArmElectrodes');
end
%%
save '...\sub_Arm.mat' Arm_stimulated
%%
%SINGLE AD
%%
for i = 1:length(Corrected) %For as many subjects
    Hand_AD = {};%Create a cell array
    for ii = 1:length(Corrected{2,i})%For as many conditions
        Somato = Corrected{2,i}{1,ii}(Arm_stimulated{3,i},:,:);%Keep only electrodes for somatosensory analysis
        Frontal = Corrected{2,i}{1,ii}(Arm_stimulated{4,i},:,:);%Same for frontal analysis
        Hand_AD{1,ii} = Somato;
        Hand_AD{2,ii} = Frontal;
    end
    %Save individually
    str = append(Folder(i).name,'_HandAD.mat'); 
    File_path = fullfile(Folder(i).folder,Folder(i).name,str);
    save(File_path, 'Hand_AD');
end
%%
%Get data per condition
%%
%Create condition matrices
sub_Fam = [];
sub_Con = [];
sub_Omi = [];
sub_POm = [];
sub_Std = [];
sub_Moy = [];
sub_Dev = [];

for i = 1 :length(sub_2D) %For as many subjects
        sub_Con = cat(3, sub_Con, sub_2D{2,i}{1,1}); %Get all "Control' condition in one matrix, repeat for each condition
        sub_Dev = cat(3, sub_Dev, sub_2D{2,i}{1,2});
        sub_Fam = cat(3,sub_Fam, sub_2D{2,i}{1,3});
        sub_Omi = cat(3, sub_Omi, sub_2D{2,i}{1,4});
        sub_POm = cat(3, sub_POm, sub_2D{2,i}{1,5});
        sub_Std = cat(3,sub_Std, sub_2D{2,i}{1,6});
        sub_Moy = cat(3,sub_Moy, sub_2D{2,i}{1,7});
end

Conditions_AllElectrodes = {};
Conditions_AllElectrodes{1,1} = sub_Con;
Conditions_AllElectrodes{1,2} = sub_Dev;
Conditions_AllElectrodes{1,3} = sub_Fam;
Conditions_AllElectrodes{1,4} = sub_Omi;
Conditions_AllElectrodes{1,5} = sub_POm;
Conditions_AllElectrodes{1,6} = sub_Std;
Conditions_AllElectrodes{1,7} = sub_Moy;
%%
save '...\sub_Conditions_AllElectrodes.mat' Conditions_AllElectrodes
%%
Conditions_Stats_sub = {};%Create a cell array
for i = 1:length(Conditions_AllElectrodes) %For as many conditions
    for ii = 1:size(Arm_stimulated,2) %For as many subjects
        Somato = permute(mean(Conditions_AllElectrodes{1,i}(Arm_stimulated{3,ii},:,:),1),[3,2,1]); %mean somato electrodes
        Frtl = permute(mean(Conditions_AllElectrodes{1,i}(Arm_stimulated{4,ii},:,:),1),[3,2,1]);%mean frontal electrode
        Conditions_Stats_sub{1,i} = Somato; %X subjects*1000 time series
        Conditions_Stats_sub{2,i} = Frtl;
    end
end 

Conditions_Stats_sub{1,8} = 'Somato';
Conditions_Stats_sub{2,8} = 'Frtl';
Conditions_Stats_sub{3,1} = 'Control';
Conditions_Stats_sub{3,2} = 'Deviant';
Conditions_Stats_sub{3,3} = 'Familiarization';
Conditions_Stats_sub{3,4} = 'Omission';
Conditions_Stats_sub{3,5} = 'PostOm';
Conditions_Stats_sub{3,6} = 'Standard';
Conditions_Stats_sub{3,7} = 'StimMoy';
%%
save '...\sub_Conditions_Stats.mat' Conditions_Stats_sub
%%
Conditions_Visu_sub = {};%create a cell array
for i = 1:length(Conditions_Stats_sub) %for as many conditions
    Somato = mean(Conditions_Stats_sub{1,i},1);%mean subjects
    Frtl = mean(Conditions_Stats_sub{2,i},1);
    Conditions_Visu_sub{1,i} = Somato;%1000 time series vector
    Conditions_Visu_sub{2,i} = Frtl;
end 
Conditions_Visu_sub{1,8} = 'Somato';
Conditions_Visu_sub{2,8} = 'Frtl';
Conditions_Visu_sub{3,1} = 'Control';
Conditions_Visu_sub{3,2} = 'Deviant';
Conditions_Visu_sub{3,3} = 'Familiarization';
Conditions_Visu_sub{3,4} = 'Omission';
Conditions_Visu_sub{3,5} = 'PostOm';
Conditions_Visu_sub{3,6} = 'Standard';
Conditions_Visu_sub{3,7} = 'StimMoy';
%%
save '...\sub_Conditions_Visu.mat' Conditions_Visu_sub
%%
disp('Visu done with sucess')
clearvars -except Conditions_Visu_sub Conditions_Stats_sub