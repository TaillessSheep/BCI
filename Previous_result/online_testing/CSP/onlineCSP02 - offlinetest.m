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
Ntr = 4;            %number of trials per span
Nspan = 6;         %number of spans

%% Initialize receiving data
addpath(genpath('C:\\Users\\Tim\\Downloads\\liblsl-Matlab'))
%addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\software\\labstreaminglayer-master\\LSL\\liblsl-Matlab'))
%ReceiveData
lib = lsl_loadlib();
result = lsl_resolve_byprop(lib,'type','EEG');
inlet = lsl_inlet(result{1});

%[ChunkData,Timestamps] = inlet.pull_chunk()
%[SampleData,Timestamp] = inlet.pull_sample(0)


%% Import data

addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\offline_testing\\hand_foot\\Raw_Data'))
addpath('C:\\Users\\Tim\\Downloads\\Apps\\MATLAB Importer')
filename = {'TM_LR.xdf'};
k = 1;
streams = load_xdf(filename{k});    %import file from LSL
EEG_stream = cell2mat(streams(1,1));
Label_stream = cell2mat(streams(1,2));
EEG_time_series = EEG_stream.time_series(1:Nch,:);
EEG_time_stamps = EEG_stream.time_stamps;
Label_data = Label_stream.time_series;
Label_time_series = Label_stream.time_stamps;
Num_trials = length(Label_data);
fs = EEG_stream.info.effective_srate; %effective sample rate of data
%% Arrange epocs
%%% --> compile data into tensor with structure Data=[channels,values,trials]

Nsa = round(fs * Tepoc);
Epoc_data= zeros(Nch,Nsa,Num_trials);

for i = 1:Num_trials
    [c, start] = min(abs(EEG_time_stamps-Label_time_series(i)));
    Epoc_data(:,:,i) = EEG_time_series(1:Nch,start:start+Nsa-1);
end  
%% Arduino control
ard = arduino;%('com6','nano');
writeDigitalPin(ard, 'D2', 0);
writeDigitalPin(ard, 'D3', 0);
writeDigitalPin(ard, 'D4', 0);
writeDigitalPin(ard, 'D5', 0);

%value = readDigitalPin(ard,'D12');

%% Run experiment

%Epoc_data = zeros(Nch,Nsa,Ntr*Nspan);
%Epoc_label_True = zeros(1,Ntr*Nspan);
Epoc_label_True = double(Label_data);
Epoc_label_Mdl = zeros(1,Ntr*Nspan);
Epoc_label_Mdls = zeros(Ntr,Ntr*Nspan);
% Model_record = zeros(Nspan,Nspan);      % (scoreMdl, scoreMdl2, replace) X spans
time =  tic();
Models=cell(Nspan,2);

for trial = 1:Ntr*Nspan
    writeDigitalPin(ard, 'D5', 1);
    writeDigitalPin(ard, 'D6', 1);
    while Epoc_label_True(1,trial)==0
        if readDigitalPin(ard,'D9') == 1
            Epoc_label_True(1,trial)= 1;
        elseif readDigitalPin(ard,'D10') ==1
            Epoc_label_True(1,trial)= 2;
        end
    end
    writeDigitalPin(ard, 'D5', 0);
    writeDigitalPin(ard, 'D6', 0);
    for i = 1:1
        writeDigitalPin(ard, 'D2', 1);
        pause(0.1);
        writeDigitalPin(ard, 'D2', 0);
        pause(0.1);
    end
    writeDigitalPin(ard, 'D2', 1);
    for sample = 1:Nsa
        data = [];
        while isempty(data) || toc(time)<(1/fs)
            [data,~] = inlet.pull_sample(0);
        end
        time = tic;
        Epoc_data(:,sample,trial) = data(1:Nch)'; 
    end
    writeDigitalPin(ard, 'D2', 0);
    EEG = pop_importdata('data',Epoc_data(:,:,trial),'srate',fs,'nbchan',Nch,'pnts',Nsa); % import data from MATLAB array
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG,0,'setname','eegdata','gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfilt(EEG, 3, 30, [], [0]); % highpass filtering at 1Hz
    %EEG = pop_eegfilt(EEG, 0, 30, [], [0]); % low pass filtering at 20Hz
    %eeglab redraw;
    Epoc_data(:,:,trial) = EEG.data;
    if trial > Ntr
        arg_ts  = MdlWn'* Epoc_data(:,:,trial) * Epoc_data(:,:,trial)'* MdlWn;
        f_ts = log ((diag(arg_ts))/trace(arg_ts));
        Epoc_label_Mdl(1,trial) = predict(Mdl,f_ts');
        writeDigitalPin(ard, ['D' num2str(4+Epoc_label_Mdl(1,trial))], 1);
        time = tic;
        for i = 1:floor((trial-1)/Ntr)
            arg_ts  = Models{i,2}'* Epoc_data(:,:,trial) * Epoc_data(:,:,trial)'* Models{i,2};
            f_ts = log ((diag(arg_ts))/trace(arg_ts));
            Epoc_label_Mdls(i,trial) = predict(Models{i,1},f_ts');
        end
    end
    if mod(trial,Ntr) == 0
        % Train feature extraction
        [Wn, f_tr, ClassLearn]=TrainCSP01( Epoc_data(:,:,1:trial), Epoc_label_True(1,1:trial), 1 );
        % Train classifier
        Models{trial/Ntr,1} = fitcdiscr(f_tr, Epoc_label_True(1,1:trial));
        Models{trial/Ntr,2} = Wn;

        
        if trial == Ntr
            Mdl = Models{trial/Ntr,1};
            MdlWn = Models{trial/Ntr,2};
        elseif trial > Ntr
            Mdl_score = 0;
            Mdl2_score = 0;
            for i = trial-Ntr+1:trial
                if Epoc_label_Mdl(1,i) == Epoc_label_True(1,i)
                    Mdl_score = Mdl_score +1;
                end
                if Epoc_label_Mdls((trial/Ntr)-1,i) == Epoc_label_True(1,i)
                    Mdl2_score = Mdl2_score +1;
                end
            end
%             Model_record(1,trial/Ntr)=Mdl_score/Ntr;
%             Model_record(2,trial/Ntr)=Mdl2_score/Ntr;
            if Mdl2_score > Mdl_score
                Mdl = Models{(trial/Ntr)-1,1};
                MdlWn = Models{(trial/Ntr)-1,2};
            end   
        end
    end

    while toc(time) < Tpause
    end
    writeDigitalPin(ard, ['D' num2str(4+Epoc_label_Mdl(1,trial))], 0);
    Epoc_label_Mdls
%     Model_record
%     while toc(time)<Tpause
%     end
end

Mdl_scores = zeros(2,Nspan+1);
for trial = 1:Ntr*Nspan
    for model = 1:Nspan-1
        if Epoc_label_Mdls(model,trial) == Epoc_label_True(1,trial)
            Mdl_scores(1,model) = Mdl_scores(1,model)+1;
        end
        if Epoc_label_Mdls(model,trial) > 0
            Mdl_scores(2,model) = Mdl_scores(2,model)+1;
        end
    end
    if Epoc_label_Mdl(1,trial) == Epoc_label_True(1,trial)
        Mdl_scores(1,Nspan+1) = Mdl_scores(1,Nspan+1)+1;
    end
    if Epoc_label_Mdl(1,trial) > 0
        Mdl_scores(2,Nspan+1) = Mdl_scores(2,Nspan+1)+1;
    end
end
Mdl_scores(1,:) = 100*(Mdl_scores(1,:)./Mdl_scores(2,:))

