%Code : Anne-Lise Marais
%Preprocessing (filtering and artifact rejection) : Anne-Lise Marais or Marie Anquetil or Victoria Dumont w/ Netstation EGI
%Data acquisition : Marie Anquetil or Anne-Lise Marais or Victoria Dumont
%Protocol : Anne-Lise Marais
%This code extracts EEG individuals data from the DECODE protocol (see
%https://www.unicaen.fr/projet_de_recherche/decode/)
%The data are merged and meant together to plot great average per condition
%Also, individual peaks are extracted for statistical analysis
%7 conditions : Std (Standard, all standards stimulations except Fam and Con), 
% Fam (40 first standards stimulations), Con (40 last standards stimulations), 
% StimMoy (Standard stimulation used for comparison), Deviant, 
% PostOm (Standard stimulation right after the omission), Omission (Absence of stimulation)
%Omission last 7200 ms. A stimulation is expected after 3300-3700 ms. 
% From 3700ms its an omission
%2 brain regions : somato (somatosensory), frtl (frontal)
%Functions used : Merge_Indiv.m, Peak_Extract.m, Mean_Indiv.m
%%
%Change 'group' for the name of the group (either Z_M, Z_V, F_P, T_P, F_T,
%_group, S_T or S_N
%%
File = dir('...\group\*.mat') %Get directory
Folder =('...\group'); %Get folder path
%%
[Somato_group_Indiv, Frtl_group_Indiv, Files_name] = Merge_Indiv(File,Folder)
%%
save '...\group_Indiv.mat' Somato_group_Indiv Frtl_group_Indiv
%%
[N140_Somato_group, P500_Frtl_group] = Peak_Extact(Somato_group_Indiv, Frtl_group_Indiv)
%%
N140_Somato_group(1,:) = Files_name; %Add the name of the variables 
P500_Frtl_group(1,:) = Files_name; 
%%
save '...\group_Peaks.mat' N140_Somato_group P500_Frtl_group
%%
[Somato_group, Frtl_group] = Mean_Indiv(Somato_group_Indiv, Frtl_group_Indiv)
%%
Somato_group(1,:) =  Files_name; %Add the name of the variables 
Frtl_group(1,:) = Files_name; 
%%
y = zeros(1,1000);
%Calculate repetition suppression mismatch
RepetitionSuppression_frtl_group  = Frtl_group{2,1}  - Frtl_group{2,3} ;
RepetitionSuppression_somato_group  = Somato_group{2,1}  - Somato_group{2,3} ;
%Calculate Deviant mismatch 
Deviant_mismatch_frtl_group  = Frtl_group{2,2}  - Frtl_group{2,7} ;
Deviant_mismatch_somato_group  = Somato_group{2,2}  - Somato_group{2,7} ;
%Calculate PostOm mismatch
PostOm_mismatch_frtl_group  = Frtl_group{2,5}  - Frtl_group{2,7} ;
PostOm_mismatch_somato_group  = Somato_group{2,5}  - Somato_group{2,7} ;
%%
save '...\group_Visu2.mat'...
    Somato_group Frtl_group RepetitionSuppression_somato_group RepetitionSuppression_frtl_group...
    PostOm_mismatch_somato_group PostOm_mismatch_frtl_group Deviant_mismatch_somato_group...
    Deviant_mismatch_frtl_group y
%%
%clear
%load '...\group_Visu.mat'
%%
%Fam & Con somatosensory
plot(Somato_group{2,3}, 'Color',[0.4660 0.6740 0.1880])
hold on
plot (Somato_group{2,1}, 'Color',[0.4940 0.1840 0.5560])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[-8 -8 6 6], 'black', 'EdgeColor','none', 'FaceAlpha', 0.05) 
text(115, 5.6, 'Stimulation', 'Color', 'black')
title 'Somatosensory repetition suppression of childrenage years old children'
legend 'Familiarization' 'Control'
%%
%Fam & Con frontal
plot(Frtl_group{2,3}, 'Color',[0.4660 0.6740 0.1880])
hold on
plot (Frtl_group{2,1}, 'Color',[0.4940 0.1840 0.5560])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[-8 -8 6 6], 'black', 'EdgeColor','none', 'FaceAlpha', 0.05) 
text(115, 5.6, 'Stimulation', 'Color', 'black')
title 'Frontal repetition suppression of childrenage years old children'
legend 'Familiarization' 'Control'
%%
%RepetitionSuppression somatosensory
plot(y, 'k')
hold on 
plot(RepetitionSuppression_somato_group, 'Color', [0 0.4470 0.7410])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[7.5 7.5 8 8],'blue', 'EdgeColor','none', 'FaceAlpha', 0.1) 
text(110, 7.7, 'Stimulation', 'Color', 'blue')
title 'Somatosensory repetition suppression of childrenage years old children'
%%
%RepetitionSuppression frontal
plot(y, 'k')
hold on 
plot(RepetitionSuppression_frtl_group, 'Color', [0 0.4470 0.7410])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[7.5 7.5 8 8],'blue', 'EdgeColor','none', 'FaceAlpha', 0.1) 
text(110, 7.7, 'Stimulation', 'Color', 'blue')
title 'Frontal repetition suppression of childrenage years old children'
%%
%Deviant mismatch
%%
%StimMoy & Deviant somatosensory
plot(Somato_group{2,7}, 'k')
hold on
plot (Somato_group{2,2}, 'b')
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[-8 -8 6 6], 'black', 'EdgeColor','none', 'FaceAlpha', 0.05) 
text(115, 5.6, 'Stimulation', 'Color', 'black')
title 'Somatosensory deviance of childrenage years old children'
legend 'StimMoy' 'Deviant'
%%
%StimMoy & Deviant frontal
plot(Frtl_group{2,7}, 'k')
hold on
plot (Frtl_group{2,2}, 'b')
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[-8 -8 6 6], 'black', 'EdgeColor','none', 'FaceAlpha', 0.05) 
text(115, 5.6, 'Stimulation', 'Color', 'black')
title 'Frontal deviance of childrenage years old children'
legend 'StimMoy' 'Deviant'
%%
%Deviant_mismatch somatosensory
plot(y, 'k')
hold on 
plot(Deviant_mismatch_somato_group, 'Color', [0 0.4470 0.7410])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[7.5 7.5 8 8],'blue', 'EdgeColor','none', 'FaceAlpha', 0.1) 
text(110, 7.7, 'Stimulation', 'Color', 'blue')
title 'Somatosensory deviant mismatch of childrenage years old children'
%%
%Deviant_mismatch frontal
plot(y, 'k')
hold on 
plot(Deviant_mismatch_frtl_group, 'Color', [0 0.4470 0.7410])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[7.5 7.5 8 8],'blue', 'EdgeColor','none', 'FaceAlpha', 0.1) 
text(110, 7.7, 'Stimulation', 'Color', 'blue')
title 'Frontal deviant mismatch of childrenage years old children'
%%
%PostOm mismatch
%%
%StimMoy & PostOm somatosensory
plot(Somato_group{2,7}, 'k')
hold on
plot (Somato_group{2,5}, 'Color',[0.8500, 0.3250, 0.0980])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[-8 -8 6 6], 'black', 'EdgeColor','none', 'FaceAlpha', 0.05) 
text(115, 5.6, 'Stimulation', 'Color', 'black')
title 'Somatosensory PostOm of childrenage years old children'
legend 'StimMoy' 'PostOm'
%%
%StimMoy & PostOm frontal
plot(Frtl_group{2,7}, 'k')
hold on
plot (Frtl_group{2,5}, 'Color',[0.8500, 0.3250, 0.0980])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[-8 -8 6 6], 'black', 'EdgeColor','none', 'FaceAlpha', 0.05) 
text(115, 5.6, 'Stimulation', 'Color', 'black')
title 'Frontal PostOm of childrenage years old children'
legend 'StimMoy' 'PostOm'
%%
%PostOm_mismatch somatosensory
plot(y, 'k')
hold on 
plot(PostOm_mismatch_somato_group, 'Color', [0 0.4470 0.7410])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[7.5 7.5 8 8],'blue', 'EdgeColor','none', 'FaceAlpha', 0.1) 
text(110, 7.7, 'Stimulation', 'Color', 'blue')
title 'Somatosensory PostOm mismatch of childrenage years old children'
%%
%PostOm_mismatch frontal
plot(y, 'k')
hold on 
plot(PostOm_mismatch_frtl_group, 'Color', [0 0.4470 0.7410])
hold off
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([0,1000])
xticks([0 100 200 240 300 400 500 600 700 800 900 1000])
xticklabels({'-100','0', '100', '140','200','300', '400','500','600','700', '800', '900'})
xlabel('ms')
xtickangle(45)
patch([100 300 300 100],[7.5 7.5 8 8],'blue', 'EdgeColor','none', 'FaceAlpha', 0.1) 
text(110, 7.7, 'Stimulation', 'Color', 'blue')
title 'Frontal PostOm mismatch of childrenage years old children'
%%
%%Omission in somato
plot(Somato_group{2,4}, 'r')
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6])
ylabel('µV')
xlim([899,4700])
xlabel('ms')
xticks([999 1399 1799 2199 2599 2999 3399 3799 4199 4599])
xticklabels({'0' '400' '800' '1200' '1600' '2000' '2400' '2800' '3200' '3600'})
xtickangle(45)
patch([999 1399 1399 999],[-10 -10 10 10],'black', 'EdgeColor','none', 'FaceAlpha', 0.05)
text(999, 5, 'Expecting', 'Color', 'black')
text(999, 5.4, 'Stimulation', 'Color', 'black')
title 'Somatosensory omission of childrenage years old children'
%%
%%Omission in frtl
plot(Frtl_group{2,4}, 'r')
set(gca,'YDir','reverse', 'box', 'off')
ylim([-6,6])
yticks([-6 -5 -4 -3 -2 -1 0 1 2 3 4  5 6])
ylabel('µV')
xlim([899,4700])
xlabel('ms')
xticks([999 1399 1799 2199 2599 2999 3399 3799 4199 4599])
xticklabels({'0' '400' '800' '1200' '1600' '2000' '2400' '2800' '3200' '3600'})
xtickangle(45)
patch([999 1399 1399 999],[-10 -10 10 10],'black', 'EdgeColor','none', 'FaceAlpha', 0.05)
text(999, 5, 'Expecting', 'Color', 'black')
text(999, 5.4, 'Stimulation', 'Color', 'black')
title 'Frontal omission of childrenage years old children'