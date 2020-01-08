clear
close all
clc

% Define ROIs over electrodes
leftocci_roi      = { 'L13', 'L14', 'LL10', 'LL11', 'LL12', 'LL13' , 'LC7', 'LD6' , 'LD7', 'LE3', 'LE4'};
rightocci_roi     = { 'R13', 'R14', 'RR10', 'RR11', 'RR12', 'RR13' , 'RC7', 'RD6' , 'RD7', 'RE3', 'RE4'};
leftcentral_roi   = {'LL6', 'LL7', 'LL8', 'LL9', 'LA3', 'LA4', 'LA5', 'LB3', 'LB4', 'LB5', 'LB6', 'LC4', 'LC5', 'LC6', 'LD4', 'LD5'};
rightcentral_roi  = {'RR6', 'RR7', 'RR8', 'RR9', 'RA3', 'RA4', 'RA5', 'RB3', 'RB4', 'RB5', 'RB6', 'RC4', 'RC5', 'RC6', 'RD4', 'RD5'};
leftfrontal_roi   = {'LL1', 'LL2', 'LL3', 'LL4', 'LL5', 'LA1', 'LA2', 'LB1','LB2', 'LC1', 'LC2', 'LC3', 'LD1', 'LD2', 'LD3' };
rightfrontal_roi  = {'RR1', 'RR2', 'RR3', 'RR4', 'RR5', 'RA1', 'RA2', 'RB1','RB2', 'RC1', 'RC2', 'RC3', 'RD1', 'RD2', 'RD3' };
frontocentral_roi = {'Z1','Z2', 'Z3', 'Z4', 'Z5' , 'L1' , 'L2' , 'L3' , 'L4' , 'L5', 'R1' , 'R2' , 'R3' , 'R4' , 'R5' };
central_roi = {'Z6' , 'Z7' , 'Z8' , 'Z9' , 'L6' , 'L7' , 'L8' , 'L9' , 'R6' , 'R7' , 'R8' , 'R9' };
occicentral_roi = {'Z10' , 'Z11' , 'Z12' , 'Z13' , 'Z14' , 'L10' , 'L11' , 'L12' , 'R10' , 'R11' , 'R12' };

% load some fieldtrip structure (to be substituted with MR values later)
% this is necessary as the ft_topoplotER function expects a fieldtrip structure as input 
load ('/wmdecoding/data/S01/fftall.mat');

%% select data 'tmpfft' that will be substituted with MR values
cfg = [];
cfg.avgoverfreq = 'yes';
tmpfft=ft_selectdata(cfg,fftone_han);
tmpfft = ft_freqdescriptives([],tmpfft);
tmpfft.powspctrm=nan(128,1)

% load and substitute 'tmpfft' with  MR values 
load('/wmdecoding/data/mr_roi.mat')

groups = {leftocci_roi,rightocci_roi,leftcentral_roi,rightcentral_roi,leftfrontal_roi...
          rightfrontal_roi,frontocentral_roi,central_roi,occicentral_roi};

mr = mr*100

for subj = 1:10 % subjects
    
    for  j = 1:9    % ROIs
        ind = ismember(tmpfft.label,groups{j});
        ind = find(ind == 1);
        tmpfft.powspctrm(ind) = mr(subj,j);
    end

    tmp{subj} = tmpfft;
end

% Plotting of Figure 3B
pos = [1 2 3 4 5 7 8 9 10 11] % defines position within multiplot
number = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'} % subject indices

figure;
set(gca, 'FontName', 'Arial')
set(gcf,'renderer','Painters', 'Position',  [100, 100, 1300, 500])
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path

colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
for i=1:10
cfg = [];
cfg.layout = '/wmdecoding/data/ant128.lay';
cfg.style  = 'fill';
cfg.comment = 'no';
cfg.marker  = 'off';
cfg.zlim    = [-0.015 0.015];
cfg.gridscale = 300;
subplot(2,6,pos(i)); ft_topoplotER(cfg,tmp{i});
title(strcat('Subj. #', number(i)), 'Units', 'normalized', 'Position', [0.5, 1.1, 0], 'FontSize', 18, 'fontweight', 'normal');
end
t = colorbar('Position', [0.8 0.35 0.015 0.33], 'FontSize', 16)
ylabel(t, 'MR [%]')