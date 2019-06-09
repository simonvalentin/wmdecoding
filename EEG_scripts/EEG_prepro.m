clear
close all
clc

% the variable "subjects" contains the list of subject-specific directories
subjects = {'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10'};
pathname = '../data_raw/'; % full path to raw data 


% Read in EEG data from all three recording sessions per subject and run ICA 
session_number = {'1' '2' '3'}
for ii = 1:length(session_number)
    
        for i = 1:length(subjects)
            
            if i == 1 & ii == 1 % session 1 for subject 1 is read in seperately
                continue
            end 
            
            datapath = strcat(pathname, subjects{i});
            cd (datapath)
            keep session_number subjects i ii datapath pathname
            datasetS1 = strcat(subjects{i},'_session1.cnt');
            datasetS2 = strcat(subjects{i},'_session2.cnt');
            datasetS3 = strcat(subjects{i},'_session3.cnt');

            % Extract retention period; demean and remove linear trend for each subject

            % Trials with WM load 1 
            cfg = [];
            cfg.dataset = eval(strcat('datasetS',session_number{ii}));
            cfg.trialdef.eventtype = 'trigger';
            cfg.trialdef.eventvalue = 13;
            cfg.trialdef.prestim = 2; 
            cfg.trialdef.poststim = 3; 
            cfg = ft_definetrial(cfg); 
            cfg.demean = 'yes';
            cfg.detrend = 'yes';
            data1 = ft_preprocessing(cfg);

            % Remove training trials from data
            cfg = [];
            cfg.trials = [numel(data1.trial)-107:numel(data1.trial)];
            data1 = ft_redefinetrial(cfg,data1);
            
            % Trials with WM load 4
            cfg = [];
            cfg.dataset = eval(strcat('datasetS',session_number{ii}));
            cfg.trialdef.eventtype = 'trigger';
            cfg.trialdef.eventvalue = 43;
            cfg.trialdef.prestim = 2;
            cfg.trialdef.poststim = 3;
            cfg=ft_definetrial(cfg);
            cfg.demean = 'yes';
            cfg.detrend = 'yes';
            data4 = ft_preprocessing(cfg);

            % Remove training trials from data
            cfg = [];
            cfg.trials = [numel(data4.trial)-107:numel(data4.trial)];
            data4 = ft_redefinetrial(cfg,data4);

            % Trials with WM load 7 
            cfg = [];
            cfg.dataset = eval(strcat('datasetS',session_number{ii}));
            cfg.trialdef.eventtype = 'trigger';
            cfg.trialdef.eventvalue = 73;
            cfg.trialdef.prestim = 2;
            cfg.trialdef.poststim = 3; 
            cfg = ft_definetrial(cfg); 
            cfg.demean = 'yes';
            cfg.detrend = 'yes';
            data7 = ft_preprocessing(cfg);

            % Remove training trials from data
            cfg = [];
            cfg.trials = [numel(data7.trial)-107:numel(data7.trial)];  % remove training trials
            data7 = ft_redefinetrial(cfg,data7);
            
            % concatenate data from all WM load conditions 
            data = ft_appenddata([],data1,data4,data7);
            
            % filter all data and remove line noise
            cfg = [];
            cfg.dftfilter = 'yes';
            cfg.dftreplace = 'neighbour';
            data = ft_preprocessing(cfg,data);
            cfg = [];
            cfg.bpfilter = 'yes';
            cfg.bpfreq = [1 45];
            cfg.bpfilttype = 'firws';
            datafilt = ft_preprocessing(cfg,data);
            
            % downsample the data to 120 Hz prior to ICA 
            cfg = [];
            cfg.resamplefs = 120;
            cfg.detrend = 'no';
            datads = ft_resampledata(cfg, datafilt);

            % perform the ICA
            cfg = [];
            cfg.method = 'runica';
            cfg.runica.pca = numel(data.label)-1;
            cfg.runica.maxsteps = 50;
            comp = ft_componentanalysis(cfg, datads);
            cfg = [];
            cfg.unmixing = comp.unmixing;
            cfg.topolabel = comp.topolabel;
            comp = ft_componentanalysis(cfg, data);
            
            % Select components to reject
            cfg = [];
            cfg.channel = [1:5]; % components to be plotted
            cfg.viewmode = 'component';
            cfg.compscale = 'local';
            cfg.layout = '../ant128.lay';
            ft_databrowser(cfg, comp);
            comps2reject = [ ] % input('Please enter comps:');
            comp.compreject = comps2reject;
            
            close all
            cfg = [];
            cfg.component = comps2reject;
            dataica = ft_rejectcomponent(cfg, comp);
            dataica.trialinfo = data.trialinfo;
            
            datapath_new = strcat('../../data/', subjects{i});
            cd (datapath_new)
            save(['dataicaS' session_number{ii} '.mat'],'dataica')
        end;
end;

%% Read in data for S01 from 1st session 
% data from 1st session is stored in two seperate data files that are
% concatinated here

clear
close all
clc

datapath = '../data_raw/S01';
cd (datapath)

datasetS1_1 = 'S01_session1.cnt';
datasetS1_2 = 'S01_session1_2.cnt';

% Trials with WM load 1 
cfg = [];
cfg.dataset = datasetS1_1;
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 13;
cfg.trialdef.prestim = 2; 
cfg.trialdef.poststim = 3; 
cfg = ft_definetrial(cfg); 
cfg.demean = 'yes';
cfg.detrend = 'yes';
data1_1 = ft_preprocessing(cfg);

cfg = [];
cfg.dataset = datasetS1_2;
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 13;
cfg.trialdef.prestim = 2; 
cfg.trialdef.poststim = 3; 
cfg = ft_definetrial(cfg); 
cfg.demean = 'yes';
cfg.detrend = 'yes';
data1_2 = ft_preprocessing(cfg);

cfg = [];
cfg.keepsampleinfo = 'no';
data1 = ft_appenddata(cfg, data1_1, data1_2); 

% Remove training trials from data
cfg = [];
cfg.trials = [numel(data1.trial)-107:numel(data1.trial)];
data1 = ft_redefinetrial(cfg,data1);
            
% Trials with WM load 4
cfg = [];
cfg.dataset = datasetS1_1;
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 43;
cfg.trialdef.prestim = 2;
cfg.trialdef.poststim = 3;
cfg=ft_definetrial(cfg);
cfg.demean = 'yes';
cfg.detrend = 'yes';
data4_1 = ft_preprocessing(cfg);

cfg = [];
cfg.dataset = datasetS1_2;
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 43;
cfg.trialdef.prestim = 2;
cfg.trialdef.poststim = 3;
cfg=ft_definetrial(cfg);
cfg.demean = 'yes';
cfg.detrend = 'yes';
data4_2 = ft_preprocessing(cfg);

cfg = [];
cfg.keepsampleinfo = 'no';
data4 = ft_appenddata(cfg, data4_1, data4_2); 

% Remove training trials from data
cfg = [];
cfg.trials = [numel(data4.trial)-107:numel(data4.trial)];
data4 = ft_redefinetrial(cfg,data4);

% Trials with WM load 7 
cfg = [];
cfg.dataset = datasetS1_1;
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 73;
cfg.trialdef.prestim = 2;
cfg.trialdef.poststim = 3; 
cfg = ft_definetrial(cfg); 
cfg.demean = 'yes';
cfg.detrend = 'yes';
data7_1 = ft_preprocessing(cfg);

cfg = [];
cfg.dataset = datasetS1_2;
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = 73;
cfg.trialdef.prestim = 2;
cfg.trialdef.poststim = 3; 
cfg = ft_definetrial(cfg); 
cfg.demean = 'yes';
cfg.detrend = 'yes';
data7_2 = ft_preprocessing(cfg);

cfg = [];
cfg.keepsampleinfo = 'no';
data7 = ft_appenddata(cfg, data7_1, data7_2); 

% Remove training trials from data
cfg = [];
cfg.trials = [numel(data7.trial)-107:numel(data7.trial)];  % remove training trials
data7 = ft_redefinetrial(cfg,data7);
            
% concatenate data from all WM load conditions 
data = ft_appenddata([],data1,data4,data7);
            
% filter all data and remove line noise
cfg = [];
cfg.dftfilter = 'yes';
cfg.dftreplace = 'neighbour';
data = ft_preprocessing(cfg,data);
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [1 45];
cfg.bpfilttype = 'firws';
datafilt = ft_preprocessing(cfg,data);
            
% downsample the data to 120 Hz prior to ICA 
cfg = [];
cfg.resamplefs = 120;
cfg.detrend = 'no';
datads = ft_resampledata(cfg, datafilt);

% perform the ICA
cfg = [];
cfg.method = 'runica';
cfg.runica.pca = numel(data.label)-1;
cfg.runica.maxsteps = 50;
comp = ft_componentanalysis(cfg, datads);
cfg = [];
cfg.unmixing = comp.unmixing;
cfg.topolabel = comp.topolabel;
comp = ft_componentanalysis(cfg, data);
            
% Select components to reject
cfg = [];
cfg.channel = [1:5]; % components to be plotted
cfg.viewmode = 'component';
cfg.compscale = 'local';
cfg.layout = '../ant128.lay';
ft_databrowser(cfg, comp);
comps2reject = input('Please enter comps:');
comp.compreject = comps2reject;
            
close all
cfg = [];
cfg.component = comps2reject;
dataica = ft_rejectcomponent(cfg, comp);
dataica.trialinfo = data.trialinfo;

datapath_new = '../../data/S01';
cd (datapath_new)
save dataicaS1 dataica
%% perform frequency analysis for every subject and session 

clear 
% the variable "subjects" contains the list of subject-specific directories
subjects = {'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10'};

for ss = 1:length(subjects)
    path = strcat ('/wmdecoding/data/',subjects{ss}); 
    cd (path)
    keep subjects ss path
    
    load dataicaS1
    data1 = dataica;
    load dataicaS2
    data2 = dataica;
    load dataicaS3
    data3 = dataica;
    
    % determine indices of conditions and compute freq domain representation
    ind1 = find(data1.trialinfo == 13);
    ind4 = find(data1.trialinfo == 43);
    ind7 = find(data1.trialinfo == 73);

    % cut retention period
    cfg = [];
    cfg.toilim = [0 3];
    datcut = ft_redefinetrial(cfg,data1);

    % compute frequency analysis with single hanning taper
    cfg = [];
    cfg.output = 'pow';
    cfg.method = 'mtmfft';
    cfg.taper = 'hanning';
    cfg.foi = [1:1:40];           
    cfg.keeptrials = 'yes';
    cfg.trials = ind1;
    fftone_han = ft_freqanalysis(cfg, datcut);
    cfg.trials = ind4;
    fftfour_han = ft_freqanalysis(cfg, datcut);
    cfg.trials = ind7;
    fftseven_han = ft_freqanalysis(cfg, datcut);
    save fftall_1 fftone_han fftfour_han fftseven_han

    % determine indices of conditions and compute freq domain representation
    ind1 = find(data2.trialinfo == 13);
    ind4 = find(data2.trialinfo == 43);
    ind7 = find(data2.trialinfo == 73);

    % cut retention period
    cfg = [];
    cfg.toilim = [0 3];
    datcut = ft_redefinetrial(cfg,data2);

    % compute frequency analysis with single hanning taper
    cfg = [];
    cfg.output = 'pow';
    cfg.method = 'mtmfft';
    cfg.taper = 'hanning';
    cfg.foi = [1:1:40];           
    cfg.keeptrials = 'yes';
    cfg.trials       = ind1;
    fftone_han = ft_freqanalysis(cfg, datcut);
    cfg.trials       = ind4;
    fftfour_han = ft_freqanalysis(cfg, datcut);
    cfg.trials       = ind7;
    fftseven_han = ft_freqanalysis(cfg, datcut);
    save fftall_2 fftone_han fftfour_han fftseven_han

    % determine indices of conditions and compute freq domain representation
    ind1 = find(data3.trialinfo == 13);
    ind4 = find(data3.trialinfo == 43);
    ind7 = find(data3.trialinfo == 73);

    % cut retention period
    cfg = [];
    cfg.toilim = [0 3];
    datcut = ft_redefinetrial(cfg,data3);

    % compute frequency analysis with single hanning taper
    cfg              = [];
    cfg.output       = 'pow';
    cfg.method       = 'mtmfft';
    cfg.taper        = 'hanning';
    cfg.foi = [1:1:40];           
    cfg.keeptrials = 'yes';
    cfg.trials       = ind1;
    fftone_han = ft_freqanalysis(cfg, datcut);
    cfg.trials       = ind4;
    fftfour_han = ft_freqanalysis(cfg, datcut);
    cfg.trials       = ind7;
    fftseven_han = ft_freqanalysis(cfg, datcut);
    save fftall_3 fftone_han fftfour_han fftseven_han
end

%% perform frequency analysis for every subject over all three sessions

clear 
% the variable "subjects" contains the list of subject-specific directories
subjects = {'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10'};

for ss = 1:length(subjects)
    path = strcat ('/wmdecoding/data/',subjects{ss}); 
    cd (path)
    keep subjects ss path
    
    load dataicaS1
    data1 = dataica;
    load dataicaS2
    data2 = dataica;
    load dataicaS3
    data3 = dataica;
    
    % concatinate over sessions
    cfg = [];
    data_all = ft_appenddata(cfg, data1, data2, data3);
    
    % determine indices of conditions and compute freq domain representation
    ind1 = find(data_all.trialinfo == 13);
    ind4 = find(data_all.trialinfo == 43);
    ind7 = find(data_all.trialinfo == 73);

    % cut retention period
    cfg = [];
    cfg.toilim = [0 3];
    datcut = ft_redefinetrial(cfg,data_all);

    % compute frequency analysis with single hanning taper
    cfg = [];
    cfg.output = 'pow';
    cfg.method = 'mtmfft';
    cfg.taper = 'hanning';
    cfg.foi = [1:1:40];           
    cfg.keeptrials = 'yes';
    cfg.trials = ind1;
    fftone_han = ft_freqanalysis(cfg, datcut);
    cfg.trials = ind4;
    fftfour_han = ft_freqanalysis(cfg, datcut);
    cfg.trials = ind7;
    fftseven_han = ft_freqanalysis(cfg, datcut);
    save fftall fftone_han fftfour_han fftseven_han
end
