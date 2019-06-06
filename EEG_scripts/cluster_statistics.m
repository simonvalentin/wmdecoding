clear
close all
clc

subjects = {'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10'};

% concatenate data from all sessions for each WM load 
for ss=1:length(subjects)
    path =strcat ('/data/WM_2018_Data/',subjects{ss}); 
    cd (path)
   
    load fftall_1
    fftone_han_s1 = fftone_han;
    fftfour_han_s1 = fftfour_han;
    fftseven_han_s1 = fftseven_han;

    load fftall_2
    fftone_han_s2 = fftone_han;
    fftfour_han_s2 = fftfour_han;
    fftseven_han_s2 = fftseven_han;

    load fftall_3
    fftone_han_s3 = fftone_han;
    fftfour_han_s3 = fftfour_han;
    fftseven_han_s3 = fftseven_han;

    % concatenate trials
    onetrials = [fftone_han_s1.powspctrm;fftone_han_s2.powspctrm;fftone_han_s3.powspctrm];
    fourtrials = [fftfour_han_s1.powspctrm;fftfour_han_s2.powspctrm;fftfour_han_s3.powspctrm];
    seventrials = [fftseven_han_s1.powspctrm;fftseven_han_s2.powspctrm;fftseven_han_s3.powspctrm];

    % concatenate trialinfo used for statistics later
    onetrialinfo = [fftone_han_s1.trialinfo;fftone_han_s2.trialinfo;fftone_han_s3.trialinfo];
    fourtrialinfo = [fftfour_han_s1.trialinfo;fftfour_han_s2.trialinfo;fftfour_han_s3.trialinfo];
    seventrialinfo = [fftseven_han_s1.trialinfo;fftseven_han_s2.trialinfo;fftseven_han_s3.trialinfo];

    % create a structure 'ft_struct' to be filled later
    ft_struct = rmfield(fftone_han_s1,'cumsumcnt');
    ft_struct = rmfield(ft_struct,'cumtapcnt');
    fftone = ft_struct;
    fftone.powspctrm = onetrials;
    fftone.trialinfo = onetrialinfo;
    fftfour = ft_struct;
    fftfour.powspctrm = fourtrials;
    fftfour.trialinfo = fourtrialinfo;
    fftseven = ft_struct;
    fftseven.powspctrm = seventrials;
    fftseven.trialinfo = seventrialinfo;
    
    % structures contain trials across sessions for each WM load condition
    l1{ss} = fftone;
    l4{ss} = fftfour;
    l7{ss} = fftseven;
end

% compute neighbouring electrodes
load ('/wmdecoding/data/headmodel_ant/elec_aligned.mat');
[a,b] = match_str(elec_aligned.label,l1{ss}.label);
labels=l1{ss}.label(b,:);
cfg = [];
cfg.method = 'distance';
cfg.neighbourdist = 40;
cfg.elec = elec_aligned;
cfg.feedback = 'yes';
cfg.channel = labels;
neighbours = ft_prepare_neighbours(cfg);

% run analysis for each subject
for ss = 1:10
    cfg = [];
    cfg.channel = labels;
    l1{ss}=ft_selectdata(cfg,l1{ss});
    l4{ss}=ft_selectdata(cfg,l4{ss});
    l7{ss}=ft_selectdata(cfg,l7{ss});
    
    cfg = [];
    cfg.method = 'montecarlo';
    cfg.frequency = [8 12];
    cfg.avgoverfreq = 'yes';
    cfg.statistic = 'ft_statfun_depsamplesFunivariate';
    cfg.correctm = 'cluster';
    cfg.clusteralpha = 0.05;
    cfg.clusterstatistic = 'maxsum';
    cfg.tail = 1;
    cfg.clustertail = 1;
    cfg.alpha = 0.05;
    cfg.numrandomization = 1000;
    cfg.neighbours = neighbours;
    
    clear design
    ntrials1 = numel(l1{ss}.trialinfo);
    ntrials4 = numel(l4{ss}.trialinfo);
    ntrials7 = numel(l7{ss}.trialinfo);
    ntrl = [ntrials1+ntrials4+ntrials7];
    
        design = zeros(2,ntrl);
            for i = 1:ntrials1
              design(1,i) = i;
            end
            for i = 1:ntrials4
              design(1,ntrials1+i) = i;
            end
            for i = 1:ntrials7
              design(1,ntrials1+ntrials4+i) = i;
            end
        design(2,1:ntrials1) = 1;
        design(2,ntrials1+1:(ntrials1+ntrials4)) = 2;
        design(2,(ntrials1+ntrials4+1):ntrl) = 3;
    
    cfg.design   = design;
    cfg.ivar     = 2;
    cfg.uvar     = 1;
    
    stat{ss} = ft_freqstatistics(cfg, l1{ss},l4{ss},l7{ss});
end

cd ('wmdecoding/data/')
save single_trial_stats stat 