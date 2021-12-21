%Code : Anne-Lise Marais
%Preprocessing (filtering and artifact rejection) : Anne-Lise Marais or Marie Anquetil or Victoria Dumont w/ Netstation EGI
%Data acquisition : Marie Anquetil or Anne-Lise Marais or Victoria Dumont
%Protocol : Anne-Lise Marais

%This code preprocesses the data of an oddball somatosensory protocol for the DECODE research. See https://www.unicaen.fr/projet_de_recherche/decode/
%7 conditions : Std (Standard, all standards stimulations except Fam and Con), Fam (40 first standards stimulations), Con (40 last standards stimulations), StimMoy (Standard stimulation used for comparison), Deviant, PostOm (Standard stimulation right after the omission), Omission (Absence of stimulation)
%Omission last 7200 ms. A stimulation is expected after 3300-3700 ms. From 3700ms its an omission, the the X value is 0 ms into omission
%3 brain regions : ctrl (somatosensory), frtl (frontal), prtl (parietal)
%%
load 'subjcode_Filtered.mat'
%%
%Normalization (x-m)/s

subjcode_normalized = zscore(subjcode_filmff2);
subjcode_normalized = round(subjcode_normalized,6);
%%
%Segmentation
%%
%Get the tag index and tag number
subjcode_event=readtable('subjcode_Relative_event_list_2.xlsx')
subjcode_Tag_Idx = round(subjcode_event.Tag_time);
subjcode_Tag_Number = round(subjcode_event.Tag_number);
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
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-3519): ((subjcode_Tag_Idx(iteration,:))+3680)';
        Idx_Segment_Omi_subjcode = [Idx_Segment_Omi_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) < 41
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-119): ((subjcode_Tag_Idx(iteration,:))+880)';
        Idx_Segment_Fam_subjcode = [Idx_Segment_Fam_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) == 51
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-119): ((subjcode_Tag_Idx(iteration,:))+880)';
        Idx_Segment_Std_subjcode = [Idx_Segment_Std_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) == 53
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-119): ((subjcode_Tag_Idx(iteration,:))+880)';
        Idx_Segment_Deviant_subjcode = [Idx_Segment_Deviant_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) == 54
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-119): ((subjcode_Tag_Idx(iteration,:))+880)';
        Idx_Segment_StimMoy_subjcode = [Idx_Segment_StimMoy_subjcode; Idx_Segment_subjcode];
    elseif subjcode_Tag_Number(iteration,1) == 57
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-119): ((subjcode_Tag_Idx(iteration,:))+880)';
        Idx_Segment_PostOm_subjcode = [Idx_Segment_PostOm_subjcode; Idx_Segment_subjcode];
    else
        Idx_Segment_subjcode = ((subjcode_Tag_Idx(iteration,:))-119): ((subjcode_Tag_Idx(iteration,:))+880)';
        Idx_Segment_Con_subjcode = [Idx_Segment_Con_subjcode; Idx_Segment_subjcode];
    end
end
%%
%Get the amplitude (value) for each index.
%Store it in a 3D matrix and reshape it to get data*electrode*segment
Segments_Fam_subjcode = subjcode_normalized(:,Idx_Segment_Fam_subjcode);
Segments_Fam_subjcode = permute(reshape(Segments_Fam_subjcode, 1000, 40, 129), [1 3 2]);
Segments_Omission_subjcode = subjcode_normalized(:,Idx_Segment_Omi_subjcode);
Segments_Omission_subjcode = permute(reshape(Segments_Omission_subjcode, 7200, 30, 129), [1 3 2]);
Segments_Std_subjcode = subjcode_normalized(:,Idx_Segment_Std_subjcode);
Segments_Std_subjcode = permute(reshape(Segments_Std_subjcode, 1000, 90, 129), [1 3 2]);
Segments_Deviant_subjcode = subjcode_normalized(:,Idx_Segment_Deviant_subjcode);
Segments_Deviant_subjcode = permute(reshape(Segments_Deviant_subjcode, 1000, 30, 129), [1 3 2]);
Segments_StimMoy_subjcode = subjcode_normalized(:,Idx_Segment_StimMoy_subjcode);
Segments_StimMoy_subjcode = permute(reshape(Segments_StimMoy_subjcode, 1000, 30, 129), [1 3 2]);
Segments_PostOm_subjcode = subjcode_normalized(:,Idx_Segment_PostOm_subjcode);
Segments_PostOm_subjcode = permute(reshape(Segments_PostOm_subjcode, 1000, 30, 129), [1 3 2]);
Segments_Con_subjcode = subjcode_normalized(:,Idx_Segment_Con_subjcode);
Segments_Con_subjcode = permute(reshape(Segments_Con_subjcode, 1000, 40, 129), [1 3 2]);
%%
save 'subjcode_Seg.mat' 'Segments_Con_subjcode' 'Segments_Deviant_subjcode' 'Segments_Fam_subjcode' 'Segments_Omission_subjcode' 'Segments_PostOm_subjcode' 'Segments_Std_subjcode' 'Segments_StimMoy_subjcode'
clear
%%
load subjcode_Seg.mat
%%
%ARTIFACT DETECTION
%%
%Hand made (I check every segment one by one, error risk +++)
%%
%Segments_Con_AD_subjcode = [Segments_Con_subjcode(:,:,[2 3 4 5 6 7 9 11 12 13 19 20 23 24 25 26 27 28 29 30 32 34 35 39 40])];
%Rejected_Segment_Con_subjcode = [Segments_Con_subjcode(:,:,[1 8 10 14 15 16 17 18 21 22 31 33 36 37 38])];
%Segments_Deviant_AD_subjcode = [Segments_Deviant_subjcode(:,:,[1 2 4 5 6 9 10 11 15 19 20 22 24 25 26 28 29])];
%Rejected_Segment_Deviant_subjcode = [Segments_Deviant_subjcode(:,:,[3 7 8 12 13 14 16 17 18 21 23 27 30])];
%Segments_Fam_AD_subjcode = [Segments_Fam_subjcode(:,:,[1 2 3 4 6 7 9 11 12 13 14 15 17 18 19 20 21 22 23 25 26 27 28 31 32 35 37])];
%Rejected_Segment_Fam_subjcode = [Segments_Fam_subjcode(:,:,[5 8 10 16 24 29 30 33 34 36 38 39 40])];
%Segments_Omission_AD_subjcode = [Segments_Omission_subjcode(:,:,[1 4 5 6 9 10 14 15 16 19 20 21 23 24 26 27 28])];
%Rejected_Segment_Omission_subjcode = [Segments_Omission_subjcode(:,:,[2 3 7 8 11 12 13 17 18 22 25 29 30])];
%Segments_PostOm_AD_subjcode = [Segments_PostOm_subjcode(:,:,[1 2 4 5 6 8 9 10 12 14 15 16 18 19 20 21 23 24 26 27 28 30])];
%Rejected_Segment_PostOm_subjcode = [Segments_PostOm_subjcode(:,:,[3 7 11 13 17 22 25 29])];
%Segments_Std_AD_subjcode = [Segments_Std_subjcode(:,:,[3 4 5 6 9 10 11 12 13 14 15 17 20 21 22 23 24 26 27 28 29 30 31 33 35 36 40 41 42 43 44 47 48 49 52 54 56 57 59 62 63 65 66 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90])];
%Rejected_Segment_Std_subjcode = [Segments_Std_subjcode(:,:,[1 2 7 8 16 18 19 25 32 34 37 38 39 45 46 50 51 53 55 58 60 61 64 67])];

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
%plot(Segments_Con_subjcode(:,3:47,18))
%ylim([-5,5])
%ylabel('µV')
%xlim([0,1000])
%xticks([0 100 120 150 180 200 240 300 400 500 600 700 800 900 1000])
%xticklabels({'-100','0','20', '50', '80','100', '140','200','300', '400','500','600','700', '800', '900'})
%xlabel('ms')
%set(gca,'YDir','reverse')
%%
%Rejected_Segment_Fam_subjcode = [];
%Rejected_Segment_Omi_subjcode = [];
%Rejected_Segment_Std_subjcode = [];
%Rejected_Segment_Deviant_subjcode = [];
%Rejected_Segment_StimMoy_subjcode = [];
%Rejected_Segment_PostOm_subjcode = [];
%Rejected_Segment_Con_subjcode = [];

%Il faut sortir une loop 3D pas une 2D !!

%for i = 1:(size(Segments_Con_subjcode,3))
%    if Segments_Con_subjcode(:,:, i) > 6
%        Rejected_Segment_Con_subjcode = [Rejected_Segment_Con_subjcode; Segments_Con_subjcode]
%    elseif Segments_Con_subjcode(:,:, i) < -6
%        Rejected_Segment_Con_subjcode = [Rejected_Segment_Con_subjcode; Segments_Con_subjcode]
%    else
%        Segments_Con_subjcode = Segments_Con_subjcode
%    end
%end
%%
save 'subjcode_Good_Segments.mat' Segments_AD_*
save 'subjcode_Bad_Segments.mat' Rejected_*
clear
%%
load subjcode_Good_Segments.mat
%%
%RE REFERENCING TO AVERAGE (each data point is substracted by the average of the electrode)
%%
%Average_reference_Con_subjcode = mean2(Segments_AD_Con_subjcode);
%Average_reference_Fam_subjcode = mean2(Segments_AD_Fam_subjcode);
%Average_reference_Deviant_subjcode = mean2(Segments_AD_Deviant_subjcode);
%Average_reference_Std_subjcode = mean2(Segments_AD_Std_subjcode);
%Average_reference_StimMoy_subjcode = mean2(Segments_AD_StimMoy_subjcode);
%Average_reference_PostOm_subjcode = mean2(Segments_AD_PostOm_subjcode);
%Average_reference_Omission_subjcode = mean2(Segments_AD_Omission_subjcode);

%Segments_Ref_Con_subjcode = Segments_AD_Con_subjcode - Average_reference_Con_subjcode;
%Segments_Ref_Fam_subjcode = Segments_AD_Fam_subjcode - Average_reference_Fam_subjcode;
%Segments_Ref_Deviant_subjcode = Segments_AD_Deviant_subjcode - Average_reference_Deviant_subjcode;
%Segments_Ref_Std_subjcode = Segments_AD_Std_subjcode - Average_reference_Std_subjcode;
%Segments_Ref_StimMoy_subjcode = Segments_AD_StimMoy_subjcode - Average_reference_StimMoy_subjcode;
%Segments_Ref_PostOm_subjcode = Segments_AD_PostOm_subjcode - Average_reference_PostOm_subjcode;
%Segments_Ref_Omission_subjcode = Segments_AD_Omission_subjcode - Average_reference_Omission_subjcode;
%%
%BASELINE CORRECTION
%For each channel, the average of all the samples within the baseline interval (100ms) 
%is subtracted from every sample in the segment
%%
Con_3D_subjcode = [];
Fam_3D_subjcode = [];
Deviant_3D_subjcode = [];
Std_3D_subjcode = [];
PostOm_3D_subjcode = [];
StimMoy_3D_subjcode = [];
Omission_3D_subjcode = [];

for i = 1:(size(Segments_Ref_Con_subjcode,3))
    Segment_Con_Bas_subjcode = Segments_Ref_Con_subjcode(:,:,i) - mean(Segments_Ref_Con_subjcode(1:100,:,i));
    Con_3D_subjcode = cat(3,Con_3D_subjcode, Segment_Con_Bas_subjcode);
end

for i = 1:(size(Segments_Ref_Fam_subjcode,3))
    Segment_Fam_Bas_subjcode = Segments_Ref_Fam_subjcode(:,:,i) - mean(Segments_Ref_Fam_subjcode(1:100,:,i));
    Fam_3D_subjcode = cat(3,Fam_3D_subjcode, Segment_Fam_Bas_subjcode);
end

for i = 1:(size(Segments_Ref_Deviant_subjcode,3))
    Segment_Deviant_Bas_subjcode = Segments_Ref_Deviant_subjcode(:,:,i) - mean(Segments_Ref_Deviant_subjcode(1:100,:,i));
    Deviant_3D_subjcode = cat(3,Deviant_3D_subjcode, Segment_Deviant_Bas_subjcode);
end

for i = 1:(size(Segments_Ref_Std_subjcode,3))
    Segment_Std_Bas_subjcode = Segments_Ref_Std_subjcode(:,:,i) - mean(Segments_Ref_Std_subjcode(1:100,:,i));
    Std_3D_subjcode = cat(3,Std_3D_subjcode, Segment_Std_Bas_subjcode);
end

for i = 1:(size(Segments_Ref_PostOm_subjcode,3))
    Segment_PostOm_Bas_subjcode = Segments_Ref_PostOm_subjcode(:,:,i) - mean(Segments_Ref_PostOm_subjcode(1:100,:,i));
    PostOm_3D_subjcode = cat(3,PostOm_3D_subjcode, Segment_PostOm_Bas_subjcode);
end

for i = 1:(size(Segments_Ref_StimMoy_subjcode,3))
    Segment_StimMoy_Bas_subjcode = Segments_Ref_StimMoy_subjcode(:,:,i) - mean(Segments_Ref_StimMoy_subjcode(1:100,:,i));
    StimMoy_3D_subjcode = cat(3,StimMoy_3D_subjcode, Segment_StimMoy_Bas_subjcode);
end

for i = 1:(size(Segments_Ref_Omission_subjcode,3))
    Segment_Omission_Bas_subjcode = Segments_Ref_Omission_subjcode(:,:,i) - mean(Segments_Ref_Omission_subjcode(1:100,:,i));
    Omission_3D_subjcode = cat(3,Omission_3D_subjcode, Segment_Omission_Bas_subjcode);
end
%%
Con_3D_subjcode = permute(Con_3D_subjcode, [2 1 3]);
Fam_3D_subjcode = permute(Fam_3D_subjcode, [2 1 3]);
Deviant_3D_subjcode = permute(Deviant_3D_subjcode, [2 1 3]);
Std_3D_subjcode = permute(Std_3D_subjcode, [2 1 3]);
PostOm_3D_subjcode = permute(PostOm_3D_subjcode, [2 1 3]);
StimMoy_3D_subjcode = permute(StimMoy_3D_subjcode, [2 1 3]);
Omission_3D_subjcode = permute(Omission_3D_subjcode, [2 1 3]);
save '3D_data_subjcode_2' Con_3D_subjcode Fam_3D_subjcode Deviant_3D_subjcode Std_3D_subjcode PostOm_3D_subjcode StimMoy_3D_subjcode Omission_3D_subjcode
%%
clear