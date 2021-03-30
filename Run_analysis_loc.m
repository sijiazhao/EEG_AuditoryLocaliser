%% A fieldtrip script to run preprocessing on localiser
% Sijia Zhao
clc;clear;close all;
% addpath(genpath('E:\Sijia\Toolboxes\fieldtrip-20170813')); % Please add the fieldtrip toolbox

filename = 'data_loc.bdf'; % Please download the example data from https://osf.io/b7dz2/

%% Define trial (has to be done before ft_preprocessing
hdr = ft_read_header(filename);
cfg = [];
cfg.dataset =  filename; % your filename with file extension;
cfg.trialdef.eventtype  = 'STATUS'; % Status notation maybe Biosemi's  tigger name
cfg.trialdef.eventvalue = 61; % your event value
cfg.trialdef.prestim    = 0.1;  % before stimulation (sec), only use positive value
cfg.trialdef.poststim   = 0.25; % after stimulation (sec) , only use positive value
cfg = ft_definetrial(cfg);

%% Jump Removal -- before all filters
cfg.continuous = 'yes';
cfg.artfctdef.jump.channel='EEG';
[cfg, artifact] = ft_artifact_jump(cfg);

%% Apply filters
cfg.hpfilter = 'yes';
cfg.hpfreq = 0.1;
cfg.hpfiltdir = 'twopass';
cfg.hpfiltord = 4;
cfg.continuous = 'yes';
cfg.channel = 'EEG';

cfg.lpfilter = 'yes';
cfg.lpfreq = 30;
cfg.lpfiltdir = 'twopass';
cfg.lpfiltord = 5;

data  = ft_preprocessing(cfg);

%% Downsample to 256Hz
cfg = [];
cfg.resamplefs = 256;
data = ft_resampledata(cfg,data);

%% baseline correction
cfg = [];
cfg.baseline = [-0.1 0];
data = ft_timelockbaseline(cfg,data);

%% average across trials
cfg = [];
cfg.trials = 'all';
cfg.covariance         = 'no';
cfg.covariancewindow   = 'all';
cfg.keeptrials         = 'yes';
cfg.removemean         = 'no';
cfg.vartrllength       = 0;
timelock = ft_timelockanalysis(cfg,data);

cfg = [];
cfg.parameter = 'avg';
avg = ft_timelockgrandaverage(cfg,data);

%% Convert the label names
avg.label = convertBiosemiLabelName(avg.label);

%% Plot ERP
figure(1);clf;
subplot(1,2,1);
plot(avg.time,avg.avg);

%% Topography
subplot(1,2,2);
cfg = [];
cfg.parameter = 'avg';
cfg.layout = 'biosemi64.lay';
cfg.xlim            = [.08 .12];
% cfg.zlim            = [-.5 .5];
cfg.marker          = 'on';
cfg.interactive     = 'no';
cfg.comment         = 'no';
cfg.colorbar        = 'no';
cfg.highlight       = 'off';
cfg.highlightcolor  = 'k';
cfg.highlightsymbol = '.';
cfg.highlightsize   = 20;
cfg.markersymbol    = '.';
cfg.markersize      = 3;
ft_topoplotER(cfg,avg);