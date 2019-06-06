%% Load data per session
% For reshaping: order tensor to (trials, freqs, roi/elec)

clear 
clc
subjects = {'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09' 'S10'};

for ss=1:length(subjects)
    path = strcat ('/wmdecoding/data/',subjects{ss}); 
    cd (path)
    keep subjects ss path
    
    load dataicaS1
    datas1 = dataica;
    
    load dataicaS2
    datas2 = dataica;
    
    load dataicaS3
    datas3 = dataica;
    
    clear dataica
    data = ft_appenddata([],datas1,datas2,datas3);
    
    path = strcat('/home/simonv/Documents/WM2018/data/',subjects{ss});
    cd(path)
    
    num_trials = size(data.trialinfo);
    num_trials = num_trials(1,1)
    freqgroups = {[1 4],[5 7],[8 12], [13 20], [21 40]};
    

% Determine indices of conditions and compute freq domain representation
    ind1 = find(data.trialinfo == 13);
    ind4 = find(data.trialinfo == 43);
    ind7 = find(data.trialinfo == 73);

    % cut retention period
    cfg = [];
    cfg.toilim = [0 3];
    datcut = ft_redefinetrial(cfg,data);
    
    % Compute freq analyis using single hanning taper
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

    %% initialize channel groups
    leftocci_roi = { 'L13', 'L14', 'LL10', 'LL11', 'LL12', 'LL13' , 'LC7', 'LD6' , 'LD7', 'LE3', 'LE4'};
    rightocci_roi = { 'R13', 'R14', 'RR10', 'RR11', 'RR12', 'RR13' , 'RC7', 'RD6' , 'RD7', 'RE3', 'RE4'};
    leftcentral_roi = {'LL6', 'LL7', 'LL8', 'LL9', 'LA3', 'LA4', 'LA5', 'LB3', 'LB4', 'LB5', 'LB6', 'LC4', 'LC5', 'LC6', 'LD4', 'LD5'};
    rightcentral_roi = {'RR6', 'RR7', 'RR8', 'RR9', 'RA3', 'RA4', 'RA5', 'RB3', 'RB4', 'RB5', 'RB6', 'RC4', 'RC5', 'RC6', 'RD4', 'RD5'};
    leftfrontal_roi = {'LL1', 'LL2', 'LL3', 'LL4', 'LL5', 'LA1', 'LA2', 'LB1','LB2', 'LC1', 'LC2', 'LC3', 'LD1', 'LD2', 'LD3'};
    rightfrontal_roi = {'RR1', 'RR2', 'RR3', 'RR4', 'RR5', 'RA1', 'RA2', 'RB1','RB2', 'RC1', 'RC2', 'RC3', 'RD1', 'RD2', 'RD3'};
    frontocentral_roi = {'Z1','Z2', 'Z3', 'Z4', 'Z5', 'L1', 'L2', 'L3' , 'L4', 'L5', 'R1', 'R2', 'R3', 'R4', 'R5'};
    central_roi = {'Z6' , 'Z7', 'Z8', 'Z9', 'L6', 'L7', 'L8', 'L9', 'R6', 'R7', 'R8', 'R9'};
    occicentral_roi = {'Z10', 'Z11', 'Z12', 'Z13', 'Z14', 'L10', 'L11', 'L12', 'R10', 'R11', 'R12'};
    roi = {leftocci_roi, rightocci_roi, leftcentral_roi, rightcentral_roi, leftfrontal_roi, rightfrontal_roi, frontocentral_roi, central_roi, occicentral_roi};
   
    roi_unique = horzcat(roi{:});
    labels = fftone_han.label;
    setdiff(labels,roi_unique)

    %% ROI and all freqs
    % initialise tensor
    num_roi = size(roi);
    num_roi = num_roi(1,2);
    num_freqs = 40;
    datx = nan(num_trials, num_freqs, num_roi);
    
    for i=1:length(roi)
        clear pow y
        
        cfg = [];
        cfg.channel     = roi{i};
        cfg.avgoverchan = 'yes';
        
        fftone_roi      = ft_selectdata(cfg,fftone_han);
        fftfour_roi     = ft_selectdata(cfg,fftfour_han);
        fftseven_roi    = ft_selectdata(cfg,fftseven_han);
        
        % Define label vector
        y = nan((numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)+numel(fftseven_han.trialinfo)),1);
        y(1:numel(fftone_han.trialinfo))= 0;
        y(1+numel(fftone_han.trialinfo): (numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)))= 1;
        y(1+(numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)): numel(y))= 2;
        
        pow1 = squeeze(fftone_roi.powspctrm);
        pow4 = squeeze(fftfour_roi.powspctrm);
        pow7 = squeeze(fftseven_roi.powspctrm);
        pow = [pow1;pow4;pow7];
        
        datx(:,:,i) = pow;
    end
    
    X = reshape(datx,[num_trials num_freqs*num_roi]);
    save Xroi_allfreq X y

    %% ROI and binned freqs
    num_freqs = size(freqgroups);
    num_freqs = num_freqs(1,2);
    
    num_roi = size(roi);
    num_roi = num_roi(1,2);
    
    clear pow y datx X tmpdat
    datx = nan(num_trials, num_freqs, num_roi);
    
    for f=1:length(freqgroups)
        for i=1:length(roi)
            cfg = [];
            cfg.channel     = roi{i};
            cfg.avgoverchan = 'yes';
            cfg.frequency   = freqgroups{f};
            cfg.avgoverfreq = 'yes';
            
            fftone_roi      = ft_selectdata(cfg,fftone_han);
            fftfour_roi     = ft_selectdata(cfg,fftfour_han);
            fftseven_roi    = ft_selectdata(cfg,fftseven_han);
            
            y = nan((numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)+numel(fftseven_han.trialinfo)),1);
            y(1:numel(fftone_han.trialinfo))= 0;
            y(1+numel(fftone_han.trialinfo): (numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)))= 1;
            y(1+(numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)): numel(y))= 2;
            
            pow1 = squeeze(fftone_roi.powspctrm);
            pow4 = squeeze(fftfour_roi.powspctrm);
            pow7 = squeeze(fftseven_roi.powspctrm);
            pow = [pow1;pow4;pow7];
            datx(:,f,i) = pow;
        end
    end

    X = reshape(datx,[num_trials num_freqs*num_roi]);
    save Xroi_binfreq X y

    %% select data all electrodes and all freqs
    clear X y pow
    
    allfreq = ft_appendfreq([],fftone_han,fftfour_han,fftseven_han);
    num_freqs = size(allfreq.powspctrm);
    num_freqs = num_freqs(1,3);
    
    num_roi = size(roi_unique);
    num_roi = num_roi(1,2);
    
    y = nan((numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)+numel(fftseven_han.trialinfo)),1);
    y(1:numel(fftone_han.trialinfo))= 0;
    y(1+numel(fftone_han.trialinfo): (numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)))= 1;
    y(1+(numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)): numel(y))= 2;
    
    cfg = [];
    cfg.channel = {'all', '-Lm', '-Rm', '-LE1', '-RE1','-LE2', '-RE2'};
    pow = ft_selectdata(cfg,allfreq);
    datx = pow.powspctrm;
    
    datx = permute(datx, [1 3 2]);
    X = reshape(datx,[num_trials num_freqs*num_roi]);
    save Xallelecs_allfreq X y

    %% select data all electrodes and binned freqs
    clear X y pow
    allfreq = ft_appendfreq([],fftone_han,fftfour_han,fftseven_han);
    
    num_freqs = size(freqgroups);
    num_freqs = num_freqs(1,2);
 
    num_roi = size(roi_unique);
    num_roi = num_roi(1,2);
    datx = nan(num_trials, num_freqs, num_roi);
    
    y = nan((numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)+numel(fftseven_han.trialinfo)),1);
    y(1:numel(fftone_han.trialinfo))= 0;
    y(1+numel(fftone_han.trialinfo): (numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)))= 1;
    y(1+(numel(fftone_han.trialinfo)+numel(fftfour_han.trialinfo)): numel(y))= 2;

    for f=1:length(freqgroups)
            cfg = [];
            cfg.frequency   = freqgroups{f};
            cfg.avgoverfreq = 'yes';
            cfg.channel = {'all', '-Lm', '-Rm', '-LE1', '-RE1','-LE2', '-RE2'};
            pow = ft_selectdata(cfg,allfreq);
            datx(:,f,:) = pow.powspctrm;
    end

    X = reshape(datx,[num_trials num_freqs*num_roi]);
    save Xallelecs_binfreq X y
    
end