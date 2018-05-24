%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--Online CSP--%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%
% 
clc; clear; close all; 
cd ('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project');
addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\online_testing'))
%% Start EEG Lab
addpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\software\\eeglab14_1_1b')
eeglab;

%% Set variables

Nch = 14;           %number of sensors
Nlb = 2;            %number of actions/labels
Tepoc = 3;          %epoc duration in seconds
Tpause = 3;         %pause duration in seconds
fs = 128;           %sample frequency
Nsa = Tepoc * fs;   %number of samples per epoc
Ntr = 20;           %number of trials for training
Nts = 20;           %number of trials for testing
Hd = designfilt('highpassfir','FilterOrder',20,'CutoffFrequency',7, ...
       'DesignMethod','window','Window',{@kaiser,3},'SampleRate',fs);

%% Initialize receiving data
addpath(genpath('C:\\Users\\Tim\\Downloads\\liblsl-Matlab'))
%addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\software\\labstreaminglayer-master\\LSL\\liblsl-Matlab'))
%ReceiveData
lib = lsl_loadlib();
result = lsl_resolve_byprop(lib,'type','EEG');
inlet = lsl_inlet(result{1});

%[ChunkData,Timestamps] = inlet.pull_chunk()
%[SampleData,Timestamp] = inlet.pull_sample(0)

%% Arduino control
ard = arduino;
writeDigitalPin(ard, 'D2', 0);
writeDigitalPin(ard, 'D3', 0);
writeDigitalPin(ard, 'D4', 0);
writeDigitalPin(ard, 'D5', 0);

%% Gather Training Data

Train_data = zeros(Nch,Nsa,Ntr);
Train_label = zeros(1,Ntr);
time =  tic();

for trial = 1:Ntr
    Train_label(1,trial) = randi(Nlb,1);
    writeDigitalPin(ard, ['D' num2str(3+Train_label(1,trial))], 1);
    for sample = 1:Nsa
        data = [];
        while isempty(data) || toc(time)<(1/fs)
            [data,~] = inlet.pull_sample(0);
            time2 = now();
        end
        time = tic;
        Train_data(:,sample,trial) = data(1:Nch)'; 
    end
    writeDigitalPin(ard, ['D' num2str(3+Train_label(1,trial))], 0);
    EEG = pop_importdata('data',Train_data(:,:,trial),'srate',fs); % import data from MATLAB array
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG,0,'setname','eegdata','gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfilt(EEG, 3, 30, [], [0]); % highpass filtering at 1Hz
    %EEG = pop_eegfilt(EEG, 0, 30, [], [0]); % low pass filtering at 20Hz
    %eeglab redraw;
    Train_data(:,:,trial) = EEG.data;
    while toc(time)<Tpause
    end
end


%% Train Model 
% Train feature extraction
[Wn, f_tr, ClassLearn]=TrainCSP01( Train_data, Train_label, 2 );
% Train classifier
Mdl = fitcdiscr(f_tr, Train_label);

%% Start Classifying New Data
% Test new epoc

Epoc_new = zeros(Nch,Nsa);
for trial = 1:Nts
    writeDigitalPin(ard, 'D2', 1);
    for sample = 1:Nsa
        data = [];
        while isempty(data) || toc(time)<(1/fs)
            [data,~] = inlet.pull_sample(0);
        end
        Epoc_new(:,sample) = data(1:Nch)';
        time = tic;
    end
    writeDigitalPin(ard, 'D2', 0);
    EEG = pop_importdata('data',Epoc_new,'srate',fs); % import data from MATLAB array
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG,0,'setname','eegdata','gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfilt(EEG, 3, 30, [], [0]); % highpass filtering at 1Hz
    %EEG = pop_eegfilt(EEG, 0, 30, [], [0]); % low pass filtering at 20Hz
    %eeglab redraw;
    Epoc_new = EEG.data;
    arg_ts  = Wn'* Epoc_new * Epoc_new'* Wn;
    f_ts = log ((diag(arg_ts))/trace(arg_ts));
    Label_out = predict(Mdl,f_ts');
    writeDigitalPin(ard, ['D' num2str(3+Label_out)], 1);
    pause(Tpause);
    writeDigitalPin(ard, ['D' num2str(3+Label_out)], 0);
end


