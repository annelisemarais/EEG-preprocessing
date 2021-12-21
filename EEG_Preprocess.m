%Code : Anne-Lise Marais
%Preprocessing (filtering and artifact rejection) : Anne-Lise Marais or Marie Anquetil or Victoria Dumont w/ Netstation EGI
%Protocol : Anne-Lise Marais

%This code preprocesses the data of an oddball somatosensory protocol for the DECODE research. See https://www.unicaen.fr/projet_de_recherche/decode/
%7 conditions : Std (Standard, all standards stimulations except Fam and Con), Fam (40 first standards stimulations), Con (40 last standards stimulations), StimMoy (Standard stimulation used for comparison), Deviant, PostOm (Standard stimulation right after the omission), Omission (Absence of stimulation)
%Omission last 7200 ms. A stimulation is expected after 3300-3700 ms. From 3700ms its an omission, the the X value is 0 ms into omission
%3 brain regions : ctrl (somatosensory), frtl (frontal), prtl (parietal)
%%
load '...\subjcode_Filtered.mat'
%%
subjcode_Raw = [subjcode_filmff1 subjcode_filmff2];
save '...\subjcode_Raw.mat' 'subjcode_Raw'
%%
%Offset measure
%Because of the recording material and filtering, there is a relative offset for each participant
%Between 630-650 ms.
%The offset has to be measured to get the proper segmentation
%The measure will be taken using the NetStation software segmentation and the raw data
%%
%%Find the index of the first tag in the NS software segmented data
%Load the software segmented data
load '...\subjcode_Segmented.mat'
%Find the measure at the first tag (in the softwar segmentation)
Offset_measure_NS = Fam_Segment_001(:,100)';
%Get the raw data
Offset_measure_Brut = (subjcode_Raw)';
%Find the measure of the first tag in the raw data. Will return the index off the first tag in raw data.
Offset_measure_Idx = find(ismember(Offset_measure_Brut,Offset_measure_NS,'rows'));
%
%Get the Tag time and tag idex from the relative event table from Netstation
subjcode_event=readtable('...\subjcode_Event.xlsx');
subjcode_Relative_Tag_Idx = round(subjcode_event.Tag_time);
subjcode_Tag_Number = round(subjcode_event.Tag_number);
%Correct the relative event table by substracting the offset NS data
Offset_measure = subjcode_Relative_Tag_Idx(1,1) - Offset_measure_Idx(1,1);
subjcode_Tag_Idx = subjcode_Relative_Tag_Idx - Offset_measure ;
save '...\subjcode_Event.mat' 'subjcode_Tag_Idx' 'subjcode_Tag_Number'
clear
%%
load ...\subjcode_Raw.mat
load ...\subjcode_Event.mat
%%
%Segmentation
%%
% Create an index matrix for each condition
Idx_Segment_Fam_subjcode = [];
Idx_Segment_Omi_subjcode = [];
Idx_Segment_Std_subjcode = [];
Idx_Segment_Deviant_subjcode = [];
Idx_Segment_StimMoy_subjcode = [];
Idx_Segment_PostOm_subjcode = [];
Idx_Segment_Con_subjcode = [];

%for every iteration (290 tags), if the number of the tag == x (see Eprime celllist), 
%extract the index of the segment (1000 points for every segments except omission 7200 points)
%Store it in the index matrix
for iteration = 1:(length(subjcode_Tag_Number))
    if subjcode_Tag_Number(iteration,1) == 55
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-3499): ((subjcode_Tag_Idx(iteration,:))+3700)';
        Idx_Segment_Omi_subjcode = [Idx_Segment_Omi_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) < 41
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-99): ((subjcode_Tag_Idx(iteration,:))+900)';
        Idx_Segment_Fam_subjcode = [Idx_Segment_Fam_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) == 51
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-99): ((subjcode_Tag_Idx(iteration,:))+900)';
        Idx_Segment_Std_subjcode = [Idx_Segment_Std_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) == 53
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-99): ((subjcode_Tag_Idx(iteration,:))+900)';
        Idx_Segment_Deviant_subjcode = [Idx_Segment_Deviant_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) == 54
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-99): ((subjcode_Tag_Idx(iteration,:))+900)';
        Idx_Segment_StimMoy_subjcode = [Idx_Segment_StimMoy_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) == 57
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-99): ((subjcode_Tag_Idx(iteration,:))+900)';
        Idx_Segment_PostOm_subjcode = [Idx_Segment_PostOm_subjcode; Idx_Segment_subjcode];
    else
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-99): ((subjcode_Tag_Idx(iteration,:))+900)';
        Idx_Segment_Con_subjcode = [Idx_Segment_Con_subjcode; Idx_Segment_subjcode];
    end
end
%%
Idx_Segment_Fam_subjcode = Idx_Segment_Fam_subjcode';
Idx_Segment_Omi_subjcode = Idx_Segment_Omi_subjcode';
Idx_Segment_Std_subjcode = Idx_Segment_Std_subjcode';
Idx_Segment_Deviant_subjcode = Idx_Segment_Deviant_subjcode';
Idx_Segment_StimMoy_subjcode = Idx_Segment_StimMoy_subjcode';
Idx_Segment_PostOm_subjcode = Idx_Segment_PostOm_subjcode';
Idx_Segment_Con_subjcode = Idx_Segment_Con_subjcode';
%%
%Get the amplitude (value) for each index.
%Store it in a 3D matrix and reshape it to get data*electrode*segment
Segments_Fam_subjcode = subjcode_Raw(:,Idx_Segment_Fam_subjcode);
Segments_Fam_subjcode = reshape(Segments_Fam_subjcode, 129, 1000, 40);
Segments_Omission_subjcode = subjcode_Raw(:,Idx_Segment_Omi_subjcode);
Segments_Omission_subjcode = reshape(Segments_Omission_subjcode, 129, 7200, 30);
Segments_Std_subjcode = subjcode_Raw(:,Idx_Segment_Std_subjcode);
Segments_Std_subjcode = reshape(Segments_Std_subjcode, 129, 1000, 90);
Segments_Deviant_subjcode = subjcode_Raw(:,Idx_Segment_Deviant_subjcode);
Segments_Deviant_subjcode = reshape(Segments_Deviant_subjcode, 129, 1000, 30);
Segments_StimMoy_subjcode = subjcode_Raw(:,Idx_Segment_StimMoy_subjcode);
Segments_StimMoy_subjcode = reshape(Segments_StimMoy_subjcode, 129, 1000, 30);
Segments_PostOm_subjcode = subjcode_Raw(:,Idx_Segment_PostOm_subjcode);
Segments_PostOm_subjcode = reshape(Segments_PostOm_subjcode, 129, 1000, 30);
Segments_Con_subjcode = subjcode_Raw(:,Idx_Segment_Con_subjcode);
Segments_Con_subjcode = reshape(Segments_Con_subjcode, 129, 1000, 40);
%%
save 'subjcode_Segmented_ML.mat' 'Segments_Con_subjcode' 'Segments_Deviant_subjcode' 'Segments_Fam_subjcode' 'Segments_Omission_subjcode' 'Segments_PostOm_subjcode' 'Segments_Std_subjcode' 'Segments_StimMoy_subjcode'
clear
%%
load ...\subjcode_Segmented_ML.mat
%%
%ARTIFACT DETECTION
%%
%With Netstation
%I do the artifact rejection using Netstation and use the log file output as a logical to reject bad segments
%%
%load the log file 
subjcode_log=readtable('subjcode_log.xlsx')

%Create a logical vector from the log for every condition (true is 1, false is 0)
subjcode_log_Omission = strcmp(string(subjcode_log.SegmentGood([1:30],:)), "true");
subjcode_log_PostOm = strcmp(string(subjcode_log.SegmentGood([31:60],:)), "true");
subjcode_log_Std = strcmp(string(subjcode_log.SegmentGood([61:150],:)), "true");
subjcode_log_Fam = strcmp(string(subjcode_log.SegmentGood([151:190],:)), "true");
subjcode_log_Con = strcmp(string(subjcode_log.SegmentGood([191:230],:)), "true");
subjcode_log_StimMoy = strcmp(string(subjcode_log.SegmentGood([231:260],:)), "true");
subjcode_log_Deviant = strcmp(string(subjcode_log.SegmentGood([261:290],:)), "true");

%Create different matrices for accepted and rejected segments
Segments_AD_Omission_subjcode = [];
Rejected_Segments_Omission_subjcode = [];
Segments_AD_PostOm_subjcode = [];
Rejected_Segments_PostOm_subjcode = [];
Segments_AD_Std_subjcode = [];
Rejected_Segments_Std_subjcode = [];
Segments_AD_Fam_subjcode = [];
Rejected_Segments_Fam_subjcode = [];
Segments_AD_Con_subjcode = [];
Rejected_Segments_Con_subjcode = [];
Segments_AD_StimMoy_subjcode = [];
Rejected_Segments_StimMoy_subjcode = [];
Segments_AD_Deviant_subjcode = [];
Rejected_Segments_Deviant_subjcode = [];
%%
%For each condition 
%if the logical is 1 (true), store the segment in the good segment matrix
%If the logical is 0 (false), store the segment in the rejected segments matrix

for i = 1:length(subjcode_log_Omission)
    if subjcode_log_Omission(i,:) == 1
        Segments_AD_Omission_subjcode = cat(3,Segments_AD_Omission_subjcode, Segments_Omission_subjcode(:,:,i));
    elseif subjcode_log_Omission(i,:) == 0
        Rejected_Segments_Omission_subjcode = cat(3, Rejected_Segments_Omission_subjcode, Segments_Omission_subjcode(:,:,i));
    end
end
for i = 1:length(subjcode_log_PostOm)
    if subjcode_log_PostOm(i,:) == 1
        Segments_AD_PostOm_subjcode = cat(3,Segments_AD_PostOm_subjcode, Segments_PostOm_subjcode(:,:,i));
    else 
        Rejected_Segments_PostOm_subjcode = cat(3, Rejected_Segments_PostOm_subjcode, Segments_PostOm_subjcode(:,:,i));
    end
end
for i = 1:length(subjcode_log_Std)
    if subjcode_log_Std(i,:) == 1
        Segments_AD_Std_subjcode = cat(3,Segments_AD_Std_subjcode, Segments_Std_subjcode(:,:,i));
    else 
        Rejected_Segments_Std_subjcode = cat(3, Rejected_Segments_Std_subjcode, Segments_Std_subjcode(:,:,i));
    end
end
for i = 1:length(subjcode_log_Fam)
    if subjcode_log_Fam(i,:) == 1
        Segments_AD_Fam_subjcode = cat(3,Segments_AD_Fam_subjcode, Segments_Fam_subjcode(:,:,i));
    else 
        Rejected_Segments_Fam_subjcode = cat(3, Rejected_Segments_Fam_subjcode, Segments_Fam_subjcode(:,:,i));
    end
end
for i = 1:length(subjcode_log_Con)
    if subjcode_log_Con(i,:) == 1
        Segments_AD_Con_subjcode = cat(3,Segments_AD_Con_subjcode, Segments_Con_subjcode(:,:,i));
    else 
        Rejected_Segments_Con_subjcode = cat(3, Rejected_Segments_Con_subjcode, Segments_Con_subjcode(:,:,i));
    end
end
for i = 1:length(subjcode_log_StimMoy)
    if subjcode_log_StimMoy(i,:) == 1
        Segments_AD_StimMoy_subjcode = cat(3,Segments_AD_StimMoy_subjcode, Segments_StimMoy_subjcode(:,:,i));
    else 
        Rejected_Segments_StimMoy_subjcode = cat(3, Rejected_Segments_StimMoy_subjcode, Segments_StimMoy_subjcode(:,:,i));
    end
end
for i = 1:length(subjcode_log_Deviant)
    if subjcode_log_Deviant(i,:) == 1
        Segments_AD_Deviant_subjcode = cat(3,Segments_AD_Deviant_subjcode, Segments_Deviant_subjcode(:,:,i));
    else 
        Rejected_Segments_Deviant_subjcode = cat(3, Rejected_Segments_Deviant_subjcode, Segments_Deviant_subjcode(:,:,i));
    end
end
%%
%Without netstation
%Make Matlab learn what an artifact is and automatically reject it
%%
save 'subjcode_Good_Segments.mat' Segments_AD_*
save 'subjcode_Bad_Segments.mat' Rejected_*
clear
%%
load subjcode_Good_Segments.mat
%%
%RE REFERENCING TO AVERAGE (each data point is substracted by the average of the electrode)
%%
mean_RR_Con_subjcode = mean(Segments_AD_Con_subjcode(1:128,:,:));
RR_Con_subjcode = Segments_AD_Con_subjcode - mean_RR_Con_subjcode;
mean_RR_Fam_subjcode = mean(Segments_AD_Fam_subjcode(1:128,:,:));
RR_Fam_subjcode = Segments_AD_Fam_subjcode - mean_RR_Fam_subjcode;
mean_RR_Deviant_subjcode = mean(Segments_AD_Deviant_subjcode(1:128,:,:));
RR_Deviant_subjcode = Segments_AD_Deviant_subjcode - mean_RR_Deviant_subjcode;
mean_RR_Omission_subjcode = mean(Segments_AD_Omission_subjcode(1:128,:,:));
RR_Omission_subjcode = Segments_AD_Omission_subjcode - mean_RR_Omission_subjcode;
mean_RR_PostOm_subjcode = mean(Segments_AD_PostOm_subjcode(1:128,:,:));
RR_PostOm_subjcode = Segments_AD_PostOm_subjcode - mean_RR_PostOm_subjcode;
mean_RR_Std_subjcode = mean(Segments_AD_Std_subjcode(1:128,:,:));
RR_Std_subjcode = Segments_AD_Std_subjcode - mean_RR_Std_subjcode;
mean_RR_StimMoy_subjcode = mean(Segments_AD_StimMoy_subjcode(1:128,:,:));
RR_StimMoy_subjcode = Segments_AD_StimMoy_subjcode - mean_RR_StimMoy_subjcode;
%%
%BASELINE CORRECTION
%For each channel, the average of all the samples within the baseline interval (100ms) 
%is subtracted from every sample in the segment
%%
mean_Baseline_Con_subjcode = mean(RR_Con_subjcode(:,1:99,:),2);
Con_3D_subjcode = RR_Con_subjcode - mean_Baseline_Con_subjcode;
mean_Baseline_StimMoy_subjcode = mean(RR_StimMoy_subjcode(:,1:99,:),2); 
StimMoy_3D_subjcode = RR_StimMoy_subjcode - mean_Baseline_StimMoy_subjcode;
mean_Baseline_Std_subjcode = mean(RR_Std_subjcode(:,1:99,:),2); 
Std_3D_subjcode = RR_Std_subjcode - mean_Baseline_Std_subjcode;
mean_Baseline_PostOm_subjcode = mean(RR_PostOm_subjcode(:,1:99,:),2); 
PostOm_3D_subjcode = RR_PostOm_subjcode - mean_Baseline_PostOm_subjcode;
mean_Baseline_Omission_subjcode = mean(RR_Omission_subjcode(:,1:99,:),2); 
Omission_3D_subjcode = RR_Omission_subjcode - mean_Baseline_Omission_subjcode;
mean_Baseline_Fam_subjcode = mean(RR_Fam_subjcode(:,1:99,:),2); 
Fam_3D_subjcode = RR_Fam_subjcode - mean_Baseline_Fam_subjcode;
mean_Baseline_Deviant_subjcode = mean(RR_Deviant_subjcode(:,1:99,:),2); 
Deviant_3D_subjcode = RR_Deviant_subjcode - mean_Baseline_Deviant_subjcode;

%%
save subjcode_3D_data_ML 'Con_3D_subjcode' 'StimMoy_3D_subjcode' 'Fam_3D_subjcode' 'Std_3D_subjcode' 'PostOm_3D_subjcode' 'Omission_3D_subjcode' 'Deviant_3D_subjcode'
clear