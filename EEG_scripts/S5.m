clear
close all
clc
%% supplementary cluster-based permutation analysis across subjects
% load data
clear 
subjects = {'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10'};

for ss=1:length(subjects)
    path       = strcat ('/data/WM_2018_Data/',subjects{ss}); 
    cd (path)
   
    load fftall
    one{ss}   = ft_freqdescriptives([],fftone_han);
    four{ss}  = ft_freqdescriptives([],fftfour_han);
    seven{ss} = ft_freqdescriptives([],fftseven_han);   
end
% compute grand average
cfg            = [];
load1          = ft_freqgrandaverage(cfg,one{:});
load4          = ft_freqgrandaverage(cfg,four{:});
load7          = ft_freqgrandaverage(cfg,seven{:});
load1.cfg      = [];
load4.cfg      = [];
load7.cfg      = [];

% plot multiploter 
cfg            = [];
cfg.xlim       = [2 40];
cfg.layout     = '/data/WM_2018_Data/ant128.lay';
figure; ft_multiplotER(cfg, load1,load4,load7);

% compute neighbours for statistics
load ('/data/WM_2018_Data/headmodel_ant/elec_aligned.mat');
cfg                 = [];
cfg.method          = 'distance';
cfg.neighbourdist   = 30;
cfg.elec            = elec_aligned;
cfg.feedback        = 'yes';
neighbours          = ft_prepare_neighbours(cfg);
[a,b]               = match_str(elec_aligned.label,one{1}.label);
labels              = one{1}.label(b,:);

% ensure all data have the same labels
for i=1:length(subjects)
    cfg         = [];
    cfg.channel = labels;
    one{i}      =ft_selectdata(cfg,one{i});
    four{i}     = ft_selectdata(cfg,four{i});
    seven{i}    = ft_selectdata(cfg,seven{i});
end

% test WM load one vs. WM load seven
cfg                  = [];
cfg.frequency        = [2 20];
cfg.method           = 'montecarlo';

cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 1000;
cfg.neighbours       = neighbours;

subj    = 10;

clear design

design  = zeros(1,2*subj);
for i   = 1:subj
  design(1,i) = i;
end
for i   = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design          = design;
cfg.ivar            = 2;
cfg.uvar            = 1;
[stat]              = ft_freqstatistics(cfg, one{:},seven{:});
stat.cfg            = [];

% plot statistics output
cfg                 = [];
cfg.parameter       = 'stat';
cfg.maskparameter   = 'mask';
cfg.zlim            = [-3 3];
cfg.layout          = '/data/WM_2018_Data/ant128.lay';
figure;
ft_multiplotER(cfg,stat);

% compute main effect 
cfg                  = [];
cfg.frequency        = [2 20];
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesFunivariate';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 1;
cfg.clustertail      = 1;
cfg.alpha            = 0.05;
cfg.numrandomization = 1000;
cfg.neighbours       = neighbours;

subj = 10;
clear design
design = zeros(1,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
for i = 1:subj
  design(1,2*subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;
design(2,2*subj+1:3*subj) = 3;
cfg.design = design;
cfg.uvar = 1;
cfg.ivar = 2;
[stat] = ft_freqstatistics(cfg, one{:},four{:},seven{:});
stat.cfg = [];

% plot statistics output
cfg = [];
cfg.parameter = 'stat';
cfg.maskparameter = 'mask';
cfg.layout = '/data/WM_2018_Data/ant128.lay';
figure;
ft_multiplotER(cfg,stat);

%% Plotting Figure S5A
clear
%load fft data and concatinate over sessions 
subjects = {'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10'};
for ss=1:length(subjects)
    path =strcat ('/wmdecoding/data/',subjects{ss}); 
    cd (path)
   
    load fftall_1
    tmp = ft_freqdescriptives([],fftone_han);
    tmp.cfg = [];
    one1{ss} = tmp;
    tmp = ft_freqdescriptives([],fftfour_han);
    tmp.cfg = [];
    four1{ss} = tmp;
    tmp = ft_freqdescriptives([],fftseven_han);
    tmp.cfg = [];
    seven1{ss} = tmp;
    
    load fftall_2
    tmp = ft_freqdescriptives([],fftone_han);
    tmp.cfg = [];
    one2{ss} = tmp;
    tmp = ft_freqdescriptives([],fftfour_han);
    tmp.cfg = [];
    four2{ss} = tmp;
    tmp = ft_freqdescriptives([],fftseven_han);
    tmp.cfg = [];
    seven2{ss} = tmp;
    
    load fftall_3
    tmp = ft_freqdescriptives([],fftone_han);
    tmp.cfg = [];
    one3{ss} = tmp;
    tmp = ft_freqdescriptives([],fftfour_han);
    tmp.cfg = [];
    four3{ss} = tmp;
    tmp = ft_freqdescriptives([],fftseven_han);
    tmp.cfg = [];
    seven3{ss} = tmp;
end

% create structures containing frequency grand average over all three sessions for each WM load 
cfg = [];
load1_all = ft_freqgrandaverage(cfg,one1{:},one2{:},one3{:});
load4_all = ft_freqgrandaverage(cfg,four1{:},four2{:},four3{:});
load7_all = ft_freqgrandaverage(cfg,seven1{:},seven2{:},seven3{:});

% Select data for each WM load from occipital electrodes 
cfg = [];
cfg.channel = {'Z14','Z13','Z12','Z11','Z10','L12','L11','L10','R12','R11','R10' }
load1_occipi = ft_selectdata(cfg,load1_all);

cfg = [];
cfg.channel = {'Z14','Z13','Z12','Z11','Z10','L12','L11','L10','R12','R11','R10' }
load4_occipi = ft_selectdata(cfg,load4_all);

cfg = [];
cfg.channel = {'Z14','Z13','Z12','Z11','Z10','L12','L11','L10','R12','R11','R10' }
load7_occipi = ft_selectdata(cfg,load7_all);

% plot power spectra for load condition and occipital electrodes using the boundedline function 
% https://de.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m
addpath ('/myfuncs/boundedline_20130130/') 


x = [1:40];
y1 = mean(load1_occipi.powspctrm,1);
y2 = mean(load4_occipi.powspctrm,1);
y3 = mean(load7_occipi.powspctrm,1);
e1 = std(y1)/sqrt(length(y1))
e2 = std(y2)/sqrt(length(y2))
e3 = std(y3)/sqrt(length(y3))
map = [0.2902 0.4784 0.7176; 1 0.8980 0.2353; 0.7176 0.2902 0.3843]

l = boundedline(x, y1, e1, x, y2, e2, x, y3, e3, 'alpha')
set(l, {'color'}, num2cell(map,2));
l = legend(l, {'load 1','load 4','load 7'},'FontSize',20);
xlabel('Frequency [Hz]');
ylabel('Power [a.u.]');
set(gca,'FontSize',24)
set(gcf,'renderer','Painters','Units', 'inches', 'Position',  [1, 1, 8, 6], 'FontType', 'Arial')
axis([0 40 -1 7])
xticks([0:5:40])
yticks([1:6])

%% Plotting Figure S5B

% plot topographies for frequency bands and load condition 
freq_groups = [21 40;
    13 20;
    8 12;
    5 7;
    1 4]

% Gridwise define positions of subplots within multiplot 
pos_load1 = [2 7 12 17 22]
pos_load4 = [3 8 13 18 23]
pos_load7 = [4 9 14 19 24]

figure;
for i=1:5
    cfg = [];                                           
    cfg.layout = '/data/WM_2018_Data/ant128.lay';           
    cfg.parameter = 'powspctrm';
    cfg.xlim = freq_groups(i,:);
    cfg.zlim = [0 2];
    cfg.style  = 'fill';
    cfg.comment = 'no';
    cfg.marker  = 'off';
    cfg.interactive = 'no';
    subplot(5,5,pos_load1(i)); 
    ft_topoplotER(cfg,load1_all);
end
hold on

for i=1:5
    cfg = [];                                           
    cfg.layout = '/data/WM_2018_Data/ant128.lay';           
    cfg.parameter = 'powspctrm';
    cfg.zlim = [0 2];
    cfg.xlim = freq_groups(i,:);
    cfg.style  = 'fill';
    cfg.comment = 'no';
    cfg.marker  = 'off';
    cfg.interactive = 'no';
    subplot(5,5,pos_load4(i)); 
    ft_topoplotER(cfg,load4_all); 
end
hold on

for i=1:5
    cfg = [];                                           
    cfg.layout = '/data/WM_2018_Data/ant128.lay';           
    cfg.parameter = 'powspctrm';
    cfg.zlim = [0 2];
    cfg.xlim = freq_groups(i,:);
    cfg.style  = 'fill';
    cfg.comment = 'no';
    cfg.marker  = 'off';
    cfg.interactive = 'no';  
    subplot(5,5,pos_load7(i)); 
    ft_topoplotER(cfg,load7_all); 
end
hold on 

% Create subplot titles
subplot(5,5,22);
title('load 1', 'Units', 'normalized', 'Position', [0.5, -0.3, 0], 'FontSize', 17, 'fontweight', 'normal');
hold on 

subplot(5,5,23);
title('load 4', 'Units', 'normalized', 'Position', [0.51, -0.3, 0], 'FontSize', 17, 'fontweight', 'normal');
hold on 

subplot(5,5,24);
title('load 7', 'Units', 'normalized', 'Position', [0.55, -0.3, 0], 'FontSize', 17, 'fontweight', 'normal');
hold on 

subplot(5,5,1);
text(0.25,0.5,'20 - 40 Hz', 'FontSize', 17); axis off
hold on 

subplot(5,5,6);
text(0.26,0.5,'13 - 20 Hz', 'FontSize', 17); axis off
hold on 

subplot(5,5,11);
text(0.38,0.5,'8 - 12 Hz', 'FontSize', 17); axis off
hold on 

subplot(5,5,16);
text(0.38,0.5,'5 - 7 Hz', 'FontSize', 17); axis off
hold on 

subplot(5,5,21);
text(0.38,0.5,'1 - 4 Hz', 'FontSize', 17); axis off

set(gca,'FontSize',20)
set(gcf,'renderer','Painters', 'Units', 'inches', 'Position',  [1, 1, 7, 9])
t = colorbar('Position', [0.8 0.45 0.02 0.15], 'FontSize', 16)
ylabel(t, 'Power [a.u.]')

ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap