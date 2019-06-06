clear
close all
clc

% load analysis results from cluster based permutation statistics
cd ('/wmdecoding/data/')
load single_trial_stats

%% Figure 3A
figure;
set(gca, 'FontName', 'Arial')
set(gcf,'renderer','Painters', 'Position',  [100, 100, 1300, 500])
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
for ss = 1:10
	cfg = [];
	cfg.parameter = 'stat';
	cfg.marker    = 'off';
	cfg.style  = 'fill';
	cfg.comment = 'no';
	cfg.marker  = 'off';
	cfg.highlight = 'on';
	cfg.highlightchannel = stat{ss}.label(find(stat{ss}.mask==1));
	cfg.highlightcolor = [0 0 0];
	cfg.zlim      = 'maxabs';
	cfg.layout = '/wmdecoding/data/ant128.lay';
	subplot(2,5,ss);ft_topoplotER(cfg,stat{ss});
end
hold on 

% Create subplot titles indicating individual subjects 
subplot(2,5,1);
cb1 = colorbar('FontSize',15); 
set(cb1,'position',[.261 .59 .01 .3])
title(cb1, 'F')
title('Subj. #1', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
hold on

subplot(2,5,2);
cb2 = colorbar('FontSize',15); 
set(cb2,'position',[.423 .59 .01 .3])
title(cb2, 'F')
title('Subj. #2', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
hold on

subplot(2,5,3);
cb3 = colorbar('FontSize',15); 
set(cb3,'position',[.585 .59 .01 .3])
title(cb3, 'F')
title('Subj. #3', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
hold on

subplot(2,5,4);
cb4 = colorbar('FontSize',15); 
set(cb4,'position',[.747 .59 .01 .3])
title(cb4, 'F')
title('Subj. #4', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
hold on

subplot(2,5,5);
cb5 = colorbar('FontSize',15); 
set(cb5,'position',[.909 .59 .01 .3])
title(cb5, 'F')
title('Subj. #5', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
hold on

subplot(2,5,6);
cb6 = colorbar('FontSize',15); 
set(cb6,'position',[.261 .11 .01 .3])
title(cb6, 'F')
title('Subj. #6', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
hold on

subplot(2,5,7);
cb7 = colorbar('FontSize',15); 
set(cb7,'position',[.423 .11 .01 .3])
title(cb7, 'F')
title('Subj. #7', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
hold on

subplot(2,5,8);
cb8 = colorbar('FontSize',15); 
set(cb8,'position',[.585 .11 .01 .3])
title(cb8, 'F')
title('Subj. #8', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
hold on

subplot(2,5,9);
cb9 = colorbar('FontSize',15); 
set(cb9,'position',[.747 .11 .01 .3])
title(cb9, 'F')
title('Subj. #9', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
hold on

subplot(2,5,10);
cb10 = colorbar('FontSize',15); 
set(cb10,'position',[.909 .11 .01 .3])
title('Subj. #10', 'Units', 'normalized','FontSize', 13, 'fontweight', 'normal')
title(cb10, 'F')

%% Figure 3B
% To plot Powerspectra the boundedline function is used / must be loaded
% https://de.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m
addpath ('/myfuncs/boundedline_20130130/') 

% Load individual power spectra over sessions
subjects = {'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10'};

for ss=1:length(subjects)
    path =strcat ('/wmdecoding/data/',subjects{ss}); 
    cd (path)
    load fftall
    tmp = ft_freqdescriptives([],fftone_han);
    tmp.cfg = [];
    one{ss} = tmp;
    tmp = ft_freqdescriptives([],fftfour_han);
    tmp.cfg = [];
    four{ss} = tmp;
    tmp = ft_freqdescriptives([],fftseven_han);
    tmp.cfg = [];
    seven{ss} = tmp;
end

% Plotting
subjects = {'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10'};

figure;
number = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'} % subject indices

% As no cluster was found for Subj #9, power spectra are computed over electrodes selected from Subj #7:
stat{9}.mask = stat{7}.mask; 

for ss=1:10
	cfg = [];
	cfg.channel = stat{ss}.label(find(stat{ss}.mask==1));
	load_one = ft_selectdata(cfg,one{ss});

	cfg = [];
	cfg.channel = stat{ss}.label(find(stat{ss}.mask==1));
	load_four = ft_selectdata(cfg,four{ss});

	cfg = [];
	cfg.channel = stat{ss}.label(find(stat{ss}.mask==1));
	load_seven = ft_selectdata(cfg,seven{ss});

	x = [1:40];
	y1 = mean(load_one.powspctrm,1);
	y2 = mean(load_four.powspctrm,1);
	y3 = mean(load_seven.powspctrm,1);
	e1 = 0 
	e2 = 0 
	e3 = 0 
	map = [0.2902 0.4784 0.7176; 1 0.8980 0.2353; 0.7176 0.2902 0.3843]

	subplot(2,5,ss);l = boundedline(x, y1, e1, x, y2, e2, x, y3, e3, 'alpha')
	set(l, {'color'}, num2cell(map,2));
	l = legend(l, {'load 1','load 4','load 7'}, 'FontSize', 14);
	xlabel('Frequency [Hz]', 'FontSize', 16);
	ylabel('Power [a.u.]', 'FontSize', 16);
	title(strcat('Subj. #', number(ss)),'Units', 'normalized', 'FontSize', 13, 'fontweight', 'normal')
	ax = gca;
	ax.FontSize = 14; 
	set(gcf,'renderer','Painters')
	xlim([2 40])
	xticks([0:5:40])       
end