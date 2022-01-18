%Code : Anne-Lise Marais
%Preprocessing (filtering and artifact rejection) : Anne-Lise Marais or Marie Anquetil or Victoria Dumont w/ Netstation EGI
%Data acquisition : Marie Anquetil or Anne-Lise Marais or Victoria Dumont
%Protocol : Anne-Lise Marais

%This code preprocesses the data of an oddball somatosensory protocol for the DECODE research. See https://www.unicaen.fr/projet_de_recherche/decode/
%7 conditions : Std (Standard, all standards stimulations except Fam and Con), Fam (40 first standards stimulations), Con (40 last standards stimulations), StimMoy (Standard stimulation used for comparison), Deviant, PostOm (Standard stimulation right after the omission), Omission (Absence of stimulation)
%Omission last 7200 ms. A stimulation is expected after 3300-3700 ms. From 3700ms its an omission, the the X value is 0 ms into omission
%3 brain regions : ctrl (somatosensory), frtl (frontal), prtl (parietal)
%%
load 'subjectcode_Filtered.mat'
%%
subjectcode_Raw = [subjectcode_filmff1 subjectcode_filmff2];
save 'subjectcode_Raw.mat' 'subjectcode_Raw'
%%
%Offset measure
%Because of the recording material and filtering, there is a relative offset for each participant
%Between 630-650 ms.
%The offset has to be measured to get the proper segmentation
%The measure will be taken using the NetStation software segmentation and the raw data
%%
%%Find the index of the first tag in the NS software segmented data
%Load the software segmented data
load 'subjectcode_Segmented.mat'
%Find the measure at the first tag (in the softwar segmentation)
Offset_measure_NS = Fam_Segment_001(:,100)';
%Get the raw data
Offset_measure_Brut = (subjectcode_Raw)';
%Find the measure of the first tag in the raw data. Will return the index off the first tag in raw data.
Offset_measure_Idx = find(ismember(Offset_measure_Brut,Offset_measure_NS,'rows'));
%
%Get the Tag time and tag idex from the relative event table
subjectcode_event=readtable('subjectcode_Event.xlsx');
subjectcode_Relative_Tag_Idx = round(subjectcode_event.Tag_time);
subjectcode_Tag_Number = round(subjectcode_event.Tag_number);
%Correct the relative event table by substracting the offset NS data
Offset_measure = subjectcode_Relative_Tag_Idx(1,1) - Offset_measure_Idx(1,1);
subjectcode_Tag_Idx = subjectcode_Relative_Tag_Idx - Offset_measure ;
save 'subjectcode_Event.mat' 'subjectcode_Tag_Idx' 'subjectcode_Tag_Number'
clear
%%
load subjectcode_Raw.mat
load subjectcode_Event.mat
%%
%Segmentation
%%
% Create an index matrix for each condition
Idx_Segment_Fam_subjectcode = [];
Idx_Segment_Omi_subjectcode = [];
Idx_Segment_Std_subjectcode = [];
Idx_Segment_Deviant_subjectcode = [];
Idx_Segment_StimMoy_subjectcode = [];
Idx_Segment_PostOm_subjectcode = [];
Idx_Segment_Con_subjectcode = [];

%for every i (290 tags), if the number of the tag == x (see Eprime celllist), 
%extract the index of the segment (1000 points for every segments except omission 7200 points)
%Store it in the index matrix
for i = 1:(length(subjectcode_Tag_Number))
    if subjectcode_Tag_Number(i,1) == 55
        Idx_Segment_subjectcode = ((subjectcode_Tag_Idx(i,:))-3499): ((subjectcode_Tag_Idx(i,:))+3700)';
        Idx_Segment_Omi_subjectcode = [Idx_Segment_Omi_subjectcode; Idx_Segment_subjectcode];
    elseif subjectcode_Tag_Number(i,1) < 41
        Idx_Segment_subjectcode = ((subjectcode_Tag_Idx(i,:))-99): ((subjectcode_Tag_Idx(i,:))+900)';
        Idx_Segment_Fam_subjectcode = [Idx_Segment_Fam_subjectcode; Idx_Segment_subjectcode];
    elseif subjectcode_Tag_Number(i,1) == 51
        Idx_Segment_subjectcode = ((subjectcode_Tag_Idx(i,:))-99): ((subjectcode_Tag_Idx(i,:))+900)';
        Idx_Segment_Std_subjectcode = [Idx_Segment_Std_subjectcode; Idx_Segment_subjectcode];
    elseif subjectcode_Tag_Number(i,1) == 53
        Idx_Segment_subjectcode = ((subjectcode_Tag_Idx(i,:))-99): ((subjectcode_Tag_Idx(i,:))+900)';
        Idx_Segment_Deviant_subjectcode = [Idx_Segment_Deviant_subjectcode; Idx_Segment_subjectcode];
    elseif subjectcode_Tag_Number(i,1) == 54
        Idx_Segment_subjectcode = ((subjectcode_Tag_Idx(i,:))-99): ((subjectcode_Tag_Idx(i,:))+900)';
        Idx_Segment_StimMoy_subjectcode = [Idx_Segment_StimMoy_subjectcode; Idx_Segment_subjectcode];
    elseif subjectcode_Tag_Number(i,1) == 57
        Idx_Segment_subjectcode = ((subjectcode_Tag_Idx(i,:))-99): ((subjectcode_Tag_Idx(i,:))+900)';
        Idx_Segment_PostOm_subjectcode = [Idx_Segment_PostOm_subjectcode; Idx_Segment_subjectcode];
    else
        Idx_Segment_subjectcode = ((subjectcode_Tag_Idx(i,:))-99): ((subjectcode_Tag_Idx(i,:))+900)';
        Idx_Segment_Con_subjectcode = [Idx_Segment_Con_subjectcode; Idx_Segment_subjectcode];
    end
end
%%
Idx_Segment_Fam_subjectcode = Idx_Segment_Fam_subjectcode';
Idx_Segment_Omi_subjectcode = Idx_Segment_Omi_subjectcode';
Idx_Segment_Std_subjectcode = Idx_Segment_Std_subjectcode';
Idx_Segment_Deviant_subjectcode = Idx_Segment_Deviant_subjectcode';
Idx_Segment_StimMoy_subjectcode = Idx_Segment_StimMoy_subjectcode';
Idx_Segment_PostOm_subjectcode = Idx_Segment_PostOm_subjectcode';
Idx_Segment_Con_subjectcode = Idx_Segment_Con_subjectcode';
%%
%Get the amplitude (value) for each index.
%Store it in a 3D matrix and reshape it to get data*electrode*segment
Segments_Fam_subjectcode = subjectcode_Raw(:,Idx_Segment_Fam_subjectcode);
Segments_Fam_subjectcode = reshape(Segments_Fam_subjectcode, 129, 1000, 40);
Segments_Fam_subjectcode = Segments_Fam_subjectcode(1:128,:,:);
Segments_Omission_subjectcode = subjectcode_Raw(:,Idx_Segment_Omi_subjectcode);
Segments_Omission_subjectcode = reshape(Segments_Omission_subjectcode, 129, 7200, 30);
Segments_Omission_subjectcode = Segments_Omission_subjectcode(1:128,:,:);
Segments_Std_subjectcode = subjectcode_Raw(:,Idx_Segment_Std_subjectcode);
Segments_Std_subjectcode = reshape(Segments_Std_subjectcode, 129, 1000, 90);
Segments_Std_subjectcode = Segments_Std_subjectcode(1:128,:,:);
Segments_Deviant_subjectcode = subjectcode_Raw(:,Idx_Segment_Deviant_subjectcode);
Segments_Deviant_subjectcode = reshape(Segments_Deviant_subjectcode, 129, 1000, 30);
Segments_Deviant_subjectcode = Segments_Deviant_subjectcode(1:128,:,:);
Segments_StimMoy_subjectcode = subjectcode_Raw(:,Idx_Segment_StimMoy_subjectcode);
Segments_StimMoy_subjectcode = reshape(Segments_StimMoy_subjectcode, 129, 1000, 30);
Segments_StimMoy_subjectcode = Segments_StimMoy_subjectcode(1:128,:,:);
Segments_PostOm_subjectcode = subjectcode_Raw(:,Idx_Segment_PostOm_subjectcode);
Segments_PostOm_subjectcode = reshape(Segments_PostOm_subjectcode, 129, 1000, 30);
Segments_PostOm_subjectcode = Segments_PostOm_subjectcode(1:128,:,:);
Segments_Con_subjectcode = subjectcode_Raw(:,Idx_Segment_Con_subjectcode);
Segments_Con_subjectcode = reshape(Segments_Con_subjectcode, 129, 1000, 40);
Segments_Con_subjectcode = Segments_Con_subjectcode(1:128,:,:);
%%
save 'subjectcode_Segmented_ML.mat' 'Segments_Con_subjectcode' 'Segments_Deviant_subjectcode' 'Segments_Fam_subjectcode' 'Segments_Omission_subjectcode' 'Segments_PostOm_subjectcode' 'Segments_Std_subjectcode' 'Segments_StimMoy_subjectcode'
clear
%%
load subjectcode_Segmented_ML.mat
%%
%ARTIFACT DETECTION
%%
%With Netstation
%I do the artifact rejection using Netstation and use the log file output as a logical to reject bad segments
%%
%load the log file 
subjectcode_log=readtable('subjectcode_log.xlsx')

%Create a logical vector from the log for every condition (true is 1, false is 0)
subjectcode_log_Omission = strcmp(string(subjectcode_log.SegmentGood([1:30],:)), "true");
subjectcode_log_PostOm = strcmp(string(subjectcode_log.SegmentGood([31:60],:)), "true");
subjectcode_log_Std = strcmp(string(subjectcode_log.SegmentGood([61:150],:)), "true");
subjectcode_log_Fam = strcmp(string(subjectcode_log.SegmentGood([151:190],:)), "true");
subjectcode_log_Con = strcmp(string(subjectcode_log.SegmentGood([191:230],:)), "true");
subjectcode_log_StimMoy = strcmp(string(subjectcode_log.SegmentGood([231:260],:)), "true");
subjectcode_log_Deviant = strcmp(string(subjectcode_log.SegmentGood([261:290],:)), "true");

%Create different matrices for accepted and rejected segments
Segments_AD_Omission_subjectcode = [];
Rejected_Segments_Omission_subjectcode = [];
Segments_AD_PostOm_subjectcode = [];
Rejected_Segments_PostOm_subjectcode = [];
Segments_AD_Std_subjectcode = [];
Rejected_Segments_Std_subjectcode = [];
Segments_AD_Fam_subjectcode = [];
Rejected_Segments_Fam_subjectcode = [];
Segments_AD_Con_subjectcode = [];
Rejected_Segments_Con_subjectcode = [];
Segments_AD_StimMoy_subjectcode = [];
Rejected_Segments_StimMoy_subjectcode = [];
Segments_AD_Deviant_subjectcode = [];
Rejected_Segments_Deviant_subjectcode = [];

%Get the bad channels from the log file per condition
subjectcode_BC_Omission = string(subjectcode_log.BadChannels([1:30],:));
subjectcode_BC_PostOm = string(subjectcode_log.BadChannels([31:60],:));
subjectcode_BC_Std = string(subjectcode_log.BadChannels([61:150],:));
subjectcode_BC_Fam = string(subjectcode_log.BadChannels([151:190],:));
subjectcode_BC_Con = string(subjectcode_log.BadChannels([191:230],:));
subjectcode_BC_StimMoy = string(subjectcode_log.BadChannels([231:260],:));
subjectcode_BC_Deviant = string(subjectcode_log.BadChannels([261:290],:));

%Create matrices for bad channel
Bad_Chan_Con_subjectcode = [];
Bad_Chan_Fam_subjectcode = [];
Bad_Chan_Deviant_subjectcode = [];
Bad_Chan_PostOm_subjectcode = [];
Bad_Chan_Std_subjectcode = [];
Bad_Chan_Omission_subjectcode = [];
Bad_Chan_StimMoy_subjectcode = [];
%%
%For each condition 
%if the logical is 1 (true), store the segment in the good segment matrix
%If the logical is 0 (false), store the segment in the rejected segments matrix



for i = 1:length(subjectcode_log_Omission)
    if subjectcode_log_Omission(i,:) == 1
        Segments_AD_Omission_subjectcode = cat(3,Segments_AD_Omission_subjectcode, Segments_Omission_subjectcode(:,:,i));
        Bad_Chan_Omission_subjectcode = [Bad_Chan_Omission_subjectcode ; subjectcode_BC_Omission(i,:)];
    elseif subjectcode_log_Omission(i,:) == 0
        Rejected_Segments_Omission_subjectcode = cat(3, Rejected_Segments_Omission_subjectcode, Segments_Omission_subjectcode(:,:,i));
    end
end
for i = 1:length(subjectcode_log_PostOm)
    if subjectcode_log_PostOm(i,:) == 1
        Segments_AD_PostOm_subjectcode = cat(3,Segments_AD_PostOm_subjectcode, Segments_PostOm_subjectcode(:,:,i));
        Bad_Chan_PostOm_subjectcode = [Bad_Chan_PostOm_subjectcode ; subjectcode_BC_PostOm(i,:)];
    else 
        Rejected_Segments_PostOm_subjectcode = cat(3, Rejected_Segments_PostOm_subjectcode, Segments_PostOm_subjectcode(:,:,i));
    end
end
for i = 1:length(subjectcode_log_Std)
    if subjectcode_log_Std(i,:) == 1
        Segments_AD_Std_subjectcode = cat(3,Segments_AD_Std_subjectcode, Segments_Std_subjectcode(:,:,i));
        Bad_Chan_Std_subjectcode = [Bad_Chan_Std_subjectcode ; subjectcode_BC_Std(i,:)];
    else 
        Rejected_Segments_Std_subjectcode = cat(3, Rejected_Segments_Std_subjectcode, Segments_Std_subjectcode(:,:,i));
    end
end
for i = 1:length(subjectcode_log_Fam)
    if subjectcode_log_Fam(i,:) == 1
        Segments_AD_Fam_subjectcode = cat(3,Segments_AD_Fam_subjectcode, Segments_Fam_subjectcode(:,:,i));
        Bad_Chan_Fam_subjectcode = [Bad_Chan_Fam_subjectcode ; subjectcode_BC_Fam(i,:)];
    else 
        Rejected_Segments_Fam_subjectcode = cat(3, Rejected_Segments_Fam_subjectcode, Segments_Fam_subjectcode(:,:,i));
    end
    if i == 20
        Size_Fam_20_subjectcode = size(Segments_AD_Fam_subjectcode,3);
    end
end
Size_Fam_40_subjectcode = size(Segments_AD_Fam_subjectcode,3) - Size_Fam_20_subjectcode;
for i = 1:length(subjectcode_log_Con)
    if subjectcode_log_Con(i,:) == 1
        Segments_AD_Con_subjectcode = cat(3,Segments_AD_Con_subjectcode, Segments_Con_subjectcode(:,:,i));
        Bad_Chan_Con_subjectcode = [Bad_Chan_Con_subjectcode ; subjectcode_BC_Con(i,:)];
    else 
        Rejected_Segments_Con_subjectcode = cat(3, Rejected_Segments_Con_subjectcode, Segments_Con_subjectcode(:,:,i));
    end       
    if i == 20
        Size_Con_20_subjectcode = size(Segments_AD_Con_subjectcode,3);
    end
end
Size_Con_40_subjectcode = size(Segments_AD_Con_subjectcode,3) - Size_Con_20_subjectcode;
for i = 1:length(subjectcode_log_StimMoy)
    if subjectcode_log_StimMoy(i,:) == 1
        Segments_AD_StimMoy_subjectcode = cat(3,Segments_AD_StimMoy_subjectcode, Segments_StimMoy_subjectcode(:,:,i));
        Bad_Chan_StimMoy_subjectcode = [Bad_Chan_StimMoy_subjectcode ; subjectcode_BC_StimMoy(i,:)];
    else 
        Rejected_Segments_StimMoy_subjectcode = cat(3, Rejected_Segments_StimMoy_subjectcode, Segments_StimMoy_subjectcode(:,:,i));
    end
end
for i = 1:length(subjectcode_log_Deviant)
    if subjectcode_log_Deviant(i,:) == 1
        Segments_AD_Deviant_subjectcode = cat(3,Segments_AD_Deviant_subjectcode, Segments_Deviant_subjectcode(:,:,i));
        Bad_Chan_Deviant_subjectcode = [Bad_Chan_Deviant_subjectcode ; subjectcode_BC_Deviant(i,:)];
    else 
        Rejected_Segments_Deviant_subjectcode = cat(3, Rejected_Segments_Deviant_subjectcode, Segments_Deviant_subjectcode(:,:,i));
    end
end
%%
%Without netstation
%Make Matlab learn what an artifact is and automatically reject it
%%

save 'subjectcode_Good_Segments.mat' Segments_AD_* 
save 'subjectcode_Bad_Segments.mat' Rejected_*
save 'subjectcode_RS_Fam_Con.mat' 'Size_Con_20_subjectcode' 'Size_Con_40_subjectcode' 'Size_Fam_20_subjectcode' 'Size_Fam_40_subjectcode'
save 'subjectcode_Bad_Channels.mat' Bad_Chan_* 
clear
%%
load subjectcode_Good_Segments.mat
load subjectcode_Bad_Channels.mat
%%
%RE REFERENCING TO AVERAGE (each data point is substracted by the average of the electrode)
%%
RR_Con_subjectcode = []; %create a matrix to get the output

for i = 1:length(Bad_Chan_Con_subjectcode) %for each segment
    str = Bad_Chan_Con_subjectcode(i,:); %extract the bad chan of segment i as string
    nb = sscanf(str,'%f, '); %convert string to double
    Seg_Con_less_BC = Segments_AD_Con_subjectcode(:,:,i); %select the i matrix of the condition
    Seg_Con_less_BC([nb],:,:) = []; %remove the bad channels from the i matrix
    mean_RR_Con_subjectcode = mean(Seg_Con_less_BC,1); %mean the average activation of the electrodes (without the BC)
    RR_seg_Con_subjectcode = Segments_AD_Con_subjectcode(:,:,i) - mean_RR_Con_subjectcode; %substract mean activation from the matrix for segment i
    RR_Con_subjectcode = cat(3, RR_Con_subjectcode , RR_seg_Con_subjectcode); %store the result in matrix
end

RR_Fam_subjectcode = [];

for i = 1:length(Bad_Chan_Fam_subjectcode)
    str = Bad_Chan_Fam_subjectcode(i,:);
    nb = sscanf(str,'%f, ');
    Seg_Fam_less_BC = Segments_AD_Fam_subjectcode(:,:,i);
    Seg_Fam_less_BC([nb],:,:) = [];
    mean_RR_Fam_subjectcode = mean(Seg_Fam_less_BC,1);
    RR_seg_Fam_subjectcode = Segments_AD_Fam_subjectcode(:,:,i) - mean_RR_Fam_subjectcode;
    RR_Fam_subjectcode = cat(3, RR_Fam_subjectcode , RR_seg_Fam_subjectcode);
end

RR_Omission_subjectcode = [];

for i = 1:length(Bad_Chan_Omission_subjectcode)
    str = Bad_Chan_Omission_subjectcode(i,:);
    nb = sscanf(str,'%f, ');
    Seg_Omission_less_BC = Segments_AD_Omission_subjectcode(:,:,i);
    Seg_Omission_less_BC([nb],:,:) = [];
    mean_RR_Omission_subjectcode = mean(Seg_Omission_less_BC,1);
    RR_seg_Omission_subjectcode = Segments_AD_Omission_subjectcode(:,:,i) - mean_RR_Omission_subjectcode;
    RR_Omission_subjectcode = cat(3, RR_Omission_subjectcode , RR_seg_Omission_subjectcode);
end

RR_Deviant_subjectcode = [];

for i = 1:length(Bad_Chan_Deviant_subjectcode)
    str = Bad_Chan_Deviant_subjectcode(i,:);
    nb = sscanf(str,'%f, ');
    Seg_Deviant_less_BC = Segments_AD_Deviant_subjectcode(:,:,i);
    Seg_Deviant_less_BC([nb],:,:) = [];
    mean_RR_Deviant_subjectcode = mean(Seg_Deviant_less_BC,1);
    RR_seg_Deviant_subjectcode = Segments_AD_Deviant_subjectcode(:,:,i) - mean_RR_Deviant_subjectcode;
    RR_Deviant_subjectcode = cat(3, RR_Deviant_subjectcode , RR_seg_Deviant_subjectcode);
end

RR_StimMoy_subjectcode = [];

for i = 1:length(Bad_Chan_StimMoy_subjectcode)
    str = Bad_Chan_StimMoy_subjectcode(i,:);
    nb = sscanf(str,'%f, ');
    Seg_StimMoy_less_BC = Segments_AD_StimMoy_subjectcode(:,:,i);
    Seg_StimMoy_less_BC([nb],:,:) = [];
    mean_RR_StimMoy_subjectcode = mean(Seg_StimMoy_less_BC,1);
    RR_seg_StimMoy_subjectcode = Segments_AD_StimMoy_subjectcode(:,:,i) - mean_RR_StimMoy_subjectcode;
    RR_StimMoy_subjectcode = cat(3, RR_StimMoy_subjectcode , RR_seg_StimMoy_subjectcode);
end

RR_PostOm_subjectcode = [];

for i = 1:length(Bad_Chan_PostOm_subjectcode)
    str = Bad_Chan_PostOm_subjectcode(i,:);
    nb = sscanf(str,'%f, ');
    Seg_PostOm_less_BC = Segments_AD_PostOm_subjectcode(:,:,i);
    Seg_PostOm_less_BC([nb],:,:) = [];
    mean_RR_PostOm_subjectcode = mean(Seg_PostOm_less_BC,1);
    RR_seg_PostOm_subjectcode = Segments_AD_PostOm_subjectcode(:,:,i) - mean_RR_PostOm_subjectcode;
    RR_PostOm_subjectcode = cat(3, RR_PostOm_subjectcode , RR_seg_PostOm_subjectcode);
end

RR_Std_subjectcode = [];

for i = 1:length(Bad_Chan_Std_subjectcode)
    str = Bad_Chan_Std_subjectcode(i,:);
    nb = sscanf(str,'%f, ');
    Seg_Std_less_BC = Segments_AD_Std_subjectcode(:,:,i);
    Seg_Std_less_BC([nb],:,:) = [];
    mean_RR_Std_subjectcode = mean(Seg_Std_less_BC,1);
    RR_seg_Std_subjectcode = Segments_AD_Std_subjectcode(:,:,i) - mean_RR_Std_subjectcode;
    RR_Std_subjectcode = cat(3, RR_Std_subjectcode , RR_seg_Std_subjectcode);
end
%%
save 'subjectcode_RR' 'RR_Std_subjectcode' 'RR_Con_subjectcode' 'RR_Fam_subjectcode' 'RR_Omission_subjectcode' 'RR_PostOm_subjectcode' 'RR_Deviant_subjectcode' 'RR_StimMoy_subjectcode'
clear
load 'subjectcode_RR'
%%
%BASELINE CORRECTION
%For each channel, the average of all the samples within the baseline interval (100ms) 
%is subtracted from every sample in the segment
%%
mean_Baseline_Con_subjectcode = mean(RR_Con_subjectcode(:,1:99,:),2);
Con_3D_subjectcode = RR_Con_subjectcode - mean_Baseline_Con_subjectcode;
mean_Baseline_StimMoy_subjectcode = mean(RR_StimMoy_subjectcode(:,1:99,:),2); 
StimMoy_3D_subjectcode = RR_StimMoy_subjectcode - mean_Baseline_StimMoy_subjectcode;
mean_Baseline_Std_subjectcode = mean(RR_Std_subjectcode(:,1:99,:),2); 
Std_3D_subjectcode = RR_Std_subjectcode - mean_Baseline_Std_subjectcode;
mean_Baseline_PostOm_subjectcode = mean(RR_PostOm_subjectcode(:,1:99,:),2); 
PostOm_3D_subjectcode = RR_PostOm_subjectcode - mean_Baseline_PostOm_subjectcode;
mean_Baseline_Omission_subjectcode = mean(RR_Omission_subjectcode(:,1:99,:),2); 
Omission_3D_subjectcode = RR_Omission_subjectcode - mean_Baseline_Omission_subjectcode;
mean_Baseline_Fam_subjectcode = mean(RR_Fam_subjectcode(:,1:99,:),2); 
Fam_3D_subjectcode = RR_Fam_subjectcode - mean_Baseline_Fam_subjectcode;
mean_Baseline_Deviant_subjectcode = mean(RR_Deviant_subjectcode(:,1:99,:),2); 
Deviant_3D_subjectcode = RR_Deviant_subjectcode - mean_Baseline_Deviant_subjectcode;
%%
N_Con_subjectcode = size(Con_3D_subjectcode,3);
N_Fam_subjectcode = size(Fam_3D_subjectcode,3);
N_Deviant_subjectcode = size(Deviant_3D_subjectcode,3);
N_Omission_subjectcode = size(Omission_3D_subjectcode,3);
N_Std_subjectcode = size(Std_3D_subjectcode,3);
N_PostOm_subjectcode = size(PostOm_3D_subjectcode,3);
N_StimMoy_subjectcode = size(StimMoy_3D_subjectcode,3);
%%
save subjectcode_Nb_segment_per_condition 'N_Con_subjectcode' 'N_Fam_subjectcode' 'N_Deviant_subjectcode' 'N_Omission_subjectcode' 'N_PostOm_subjectcode' 'N_Std_subjectcode' 'N_StimMoy_subjectcode'
save subjectcode_3D_data_ML 'Con_3D_subjectcode' 'StimMoy_3D_subjectcode' 'Fam_3D_subjectcode' 'Std_3D_subjectcode' 'PostOm_3D_subjectcode' 'Omission_3D_subjectcode' 'Deviant_3D_subjectcode'
clear