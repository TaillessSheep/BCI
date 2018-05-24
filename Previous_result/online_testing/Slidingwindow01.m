%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--Online CSP--%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%
% 
clc; clear; close all; 
cd ('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project');
addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\online_testing'))

%% Set variables

Nch = 14;           %number of sensors
Nlb = 2;            %number of actions/labels
Tepoc = 3;          %epoc duration in seconds
Tdelay = 1;         %delay recording
fs = 128;           %sample frequency
Nsa = floor(Tepoc * fs);    %number of samples per epoc
Ntr_min = 6;                %number of before first model
score_threshold = 0.7;
Passband = [0.5 35];
[Filt_B,Filt_A] = butter(3,Passband/(fs/2));


% [Filt_B,Filt_A] = butter(2,[0.35 0.36]);

% windowSize = 50; 
% Filt_B = (1/windowSize)*ones(1,windowSize);
% Filt_A = 1;
% load('butterworth2-32 100.mat');
% [Filt_B, Filt_A] = sos2tf(SOS);


TimeAxis = [0:Nsa-1]/fs;
% F1 = figure;
% F2 = figure;
% F3 = figure;
% F4 = figure;

%% Initialize receiving data
addpath(genpath('C:\\Users\\Tim\\Downloads\\liblsl-Matlab'))
%addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\software\\labstreaminglayer-master\\LSL\\liblsl-Matlab'))
%ReceiveData
lib = lsl_loadlib();
result = lsl_resolve_byprop(lib,'type','EEG');
EEG_inlet = lsl_inlet(result{1});
% result = lsl_resolve_byprop(lib,'type','Marker');
% Keyb_inlet = lsl_inlet(result{1});

%[ChunkData,Timestamps] = inlet.pull_chunk()
%[SampleData,Timestamp] = inlet.pull_sample(0)

%% Arduino control
ard = arduino('com3','nano');
button = struct('rest',{'d2'},'forward',{'d4'},'back',{'d7'},'left',{'d8'},'right',{'d12'});
buttons=fieldnames(button);
led=struct('rest',{'d5'},'forward',{'d6'},'back',{'d9'},'left',{'d10'},'right',{'d11'},'record',{'d3'});
leds=fieldnames(led);

for pin = fieldnames(led)'
    configurePin(ard, eval(['led.' pin{1}]), 'PWM');
    writeDigitalPin(ard, eval(['led.' pin{1}]), 0);
end
% writeDigitalPin(ard, led.record, 1);

for pin = fieldnames(button)'
    configurePin(ard, eval(['button.' pin{1}]), 'DigitalInput');
end


% writePWMDutyCycle(ard,led.forward,0.13);
% writeDigitalPin(ard, led.record, 0);

%value = readDigitalPin(ard,'D12');

%% Run experiment

running = 1;
% Filt_state=filtic(Filt_B,Filt_A,zeros(1,Nsa),zeros(1,Nsa));%zeros(200,46144);%max(length(Filt_A),length(Filt_B))-1,Nch);
EEG_window = zeros(Nch,Nsa);
EEG_window_filt = zeros(Nch,Nsa);
Firstrun=1;
Mdl = [];
Label_tr = [];
Data_tr = [];
Ntr = 0;
State_tr=0;

% load('TM_LR_CSP_LDA_model.mat');

while running == 1
    if State_tr==0
        if readDigitalPin(ard,button.left) == 1
            Label_tr = [Label_tr 1];
            time_tr = tic;
            State_tr=1;
            writeDigitalPin(ard, led.record, 1);
        elseif readDigitalPin(ard,button.right) ==1
            Label_tr = [Label_tr 2];
            time_tr = tic;
            State_tr=1;
            writeDigitalPin(ard, led.record, 1);
        end
    end
    if State_tr == 1 && toc(time_tr)>(Tepoc+Tdelay)
        Ntr = Ntr+1;
        Data_tr(:,:,Ntr) = EEG_window_filt;
        State_tr = 0;
        writeDigitalPin(ard, led.record, 0);
        if length(Label_tr)>=Ntr_min
            % Train feature extraction
            [Wn, f_tr, ClassLearn]=TrainCSP01( Data_tr, Label_tr, 2 );
            % Train classifier
            Mdl = fitcdiscr(f_tr, Label_tr);

%             figure;
%             hold off
%             for i = 1:Ntr
%                 if Label_tr(1,i) == 1
%                     plot3(f_tr(i,1), f_tr(i,2), f_tr(i,3), 'b.');
%                 elseif Label_tr(1,i) == 2
%                     plot3(f_tr(i,1), f_tr(i,2), f_tr(i,3), 'r.');
%                 end
%                 hold on
%             end
        end
    end
    
    % get chunk
    EEG_ChunkData = [];
    while isempty(EEG_ChunkData)
        [EEG_ChunkData,EEG_Timestamps] = EEG_inlet.pull_chunk();
    end
    [~,Nsa_in]=size(EEG_ChunkData);
    % filter
    if Firstrun==1
        [EEG_ChunkData_filt,Filt_state] = filter(Filt_B, Filt_A, EEG_ChunkData(1:Nch,:),[],2);
        Firstrun=0;
    else
        [EEG_ChunkData_filt,Filt_state] = filter(Filt_B, Filt_A, EEG_ChunkData(1:Nch,:),Filt_state,2);
    end
    % update sliding window
    if Nsa_in < Nsa
        EEG_window = [EEG_window(:,Nsa_in+1 : Nsa), EEG_ChunkData(1:Nch,:)];
        EEG_window_filt = [EEG_window_filt(:,Nsa_in+1 : Nsa), EEG_ChunkData_filt(1:Nch,:)];
    elseif Nsa_in > Nsa
        EEG_window(:,:) = EEG_ChunkData(1:Nch, Nsa_in - Nsa + 1:Nsa_in);
        EEG_window_filt(:,:) = EEG_ChunkData_filt(1:Nch, Nsa_in - Nsa + 1:Nsa_in);
    end
    
%     figure(F1);
%     plot(TimeAxis,EEG_window(1,:));
%     figure(F2);
%     plot(TimeAxis,EEG_window_filt(1,:));
%     figure(F3);
%     spectrogram(EEG_window_filt(1,:),100,80,100,fs,'yaxis');
%     figure(F4)	
%     rawFFT=zeros(size(EEG_window));
%     for ch = 1:Nch
%         rawFFT(ch,:) = abs(fft(EEG_window_filt(ch,:)))/Nsa;
%     end
% 
%     FreqAxis = fs*(0:Nsa-1)/Nsa;
%     plot(FreqAxis(1:Nsa/2),rawFFT(1:Nsa/2));
%     title(['Spectrum of Raw Vs Filtered ch ' num2str(ch)])
%     xlabel('f (Hz)')
%     ylabel('uV')
%     hold off
%     pause(0.1);
%     % run current model
%     % display classification output
    if ~isempty(Mdl)
        % evaluate model over window
        arg_ts  = Wn'* EEG_window_filt(:,:) * EEG_window_filt(:,:)'* Wn;
        f_ts = log ((diag(arg_ts))/trace(arg_ts));
        [Out_label, Out_score] = predict(Mdl,f_ts');
        % display classification
        hold off
        for i = 1:Ntr
            if Label_tr(1,i) == 1
                plot(f_tr(i,1), f_tr(i,4), 'b.');
            elseif Label_tr(1,i) == 2
                plot(f_tr(i,1), f_tr(i,4), 'r.');
            end
            hold on
        end
        plot(f_ts(1,1), f_ts(4,1), 'g.');
        Out_label
        Out_score
        writePWMDutyCycle(ard,led.left,Out_score(1,1));
        writePWMDutyCycle(ard,led.right,Out_score(1,2));
%         if Out_score(1,1) > score_threshold
%             writeDigitalPin(ard, led.left, 1);
%             writeDigitalPin(ard, led.right, 0);
%         elseif Out_score(1,2) > score_threshold
%             writeDigitalPin(ard, led.left, 0);
%             writeDigitalPin(ard, led.right, 1);
%         else
%             writeDigitalPin(ard, led.left, 0);
%             writeDigitalPin(ard, led.right, 0);
%         end
        pause(0.1);
    end
end


% 
% 
% Epoc_data = zeros(Nch,Nsa,Ntr*Nspan);
% Epoc_label_True = zeros(1,Ntr*Nspan);
% Epoc_label_Mdl = zeros(1,Ntr*Nspan);
% Epoc_label_Mdls = zeros(Ntr,Ntr*Nspan);
% % Model_record = zeros(Nspan,Nspan);      % (scoreMdl, scoreMdl2, replace) X spans
% time =  tic();
% Models=cell(Nspan,2);
% 
% Epoc_data_reaction = zeros(Nch,Nsa,Ntr*Nspan);
% Epoc_label_reaction = zeros(1,Ntr*Nspan);
% 
% for trial = 1:Ntr*Nspan
%     writeDigitalPin(ard, 'D5', 1);
%     writeDigitalPin(ard, 'D6', 1);
%     while Epoc_label_True(1,trial)==0
%         if readDigitalPin(ard,'D9') == 1
%             Epoc_label_True(1,trial)= 1;
%         elseif readDigitalPin(ard,'D10') ==1
%             Epoc_label_True(1,trial)= 2;
%         end
%     end
%     writeDigitalPin(ard, 'D5', 0);
%     writeDigitalPin(ard, 'D6', 0);
%     for i = 1:2
%         writeDigitalPin(ard, 'D2', 1);
%         pause(0.1);
%         writeDigitalPin(ard, 'D2', 0);
%         pause(0.1);
%     end
%     writeDigitalPin(ard, 'D2', 1);
%     for sample = 1:Nsa
%         data = [];
%         while isempty(data) || toc(time)<(1/fs)
%             [data,~] = inlet.pull_sample(0);
%         end
%         time = tic;
%         Epoc_data(:,sample,trial) = data(1:Nch)';
%     end
%     writeDigitalPin(ard, 'D2', 0);
%     
% %     plot(TimeAxis,Epoc_data(1,:,trial));
% %     hold on
%     
%     EEG = pop_importdata('data',Epoc_data(:,:,trial),'srate',fs,'nbchan',Nch,'pnts',Nsa); % import data from MATLAB array
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG,0,'setname','eegdata','gui','off');
%     EEG = eeg_checkset( EEG );
%     EEG = pop_eegfilt(EEG, 3, 30, [], [0]); % highpass filtering at 1Hz
%     %EEG = pop_eegfilt(EEG, 0, 30, [], [0]); % low pass filtering at 20Hz
%     %eeglab redraw;
%     Epoc_data(:,:,trial) = EEG.data;
%     
% %     plot(TimeAxis,Epoc_data(1,:,trial));
% %     title('Raw and filtered EEG Data')
% %     xlabel('t (seconds)')
% %     ylabel('uV')
% %     hold off
%     if trial > Ntr
%         arg_ts  = MdlWn'* Epoc_data(:,:,trial) * Epoc_data(:,:,trial)'* MdlWn;
%         f_ts = log ((diag(arg_ts))/trace(arg_ts));
%         Epoc_label_Mdl(1,trial) = predict(Mdl,f_ts');
%         writeDigitalPin(ard, ['D' num2str(4+Epoc_label_Mdl(1,trial))], 1);
%         time = tic;
%                
%         for sample = 1:Nsa
%             data = [];
%             while isempty(data) || toc(time)<(1/fs)
%                 [data,~] = inlet.pull_sample(0);
%             end
%             time = tic;
%             Epoc_data_reaction(:,sample,trial) = data(1:Nch)';
%         end
%         
%         if Epoc_label_Mdl(1,trial) == Epoc_label_True(1,trial)
%             Epoc_label_reaction(1,trial) = 1;
%         else
%             Epoc_label_reaction(1,trial) = 2;
%         end
%         
%         for i = 1:floor((trial-1)/Ntr)
%             arg_ts  = Models{i,2}'* Epoc_data(:,:,trial) * Epoc_data(:,:,trial)'* Models{i,2};
%             f_ts = log ((diag(arg_ts))/trace(arg_ts));
%             Epoc_label_Mdls(i,trial) = predict(Models{i,1},f_ts');
%         end
%     end
%     if mod(trial,Ntr) == 0
%         % Train feature extraction
%         [Wn, f_tr, ClassLearn]=TrainCSP01( Epoc_data(:,:,1:trial), Epoc_label_True(1,1:trial), 2 );
%         % Train classifier
%         Models{trial/Ntr,1} = fitcdiscr(f_tr, Epoc_label_True(1,1:trial));
%         Models{trial/Ntr,2} = Wn;
%         figure;
%         for i = 1:trial
%             hold on
%             if Epoc_label_True(1,i) == 1
%                 plot3(f_tr(i,1), f_tr(i,2), f_tr(i,3), 'b.');
%             elseif Epoc_label_True(1,i) == 2
%                 plot3(f_tr(i,1), f_tr(i,2), f_tr(i,3), 'r.');
%             end
%         end
% 
%         
%         if trial == Ntr
%             Mdl = Models{trial/Ntr,1};
%             MdlWn = Models{trial/Ntr,2};
%         elseif trial > Ntr
%             Mdl_score = 0;
%             Mdl2_score = 0;
%             for i = trial-Ntr+1:trial
%                 if Epoc_label_Mdl(1,i) == Epoc_label_True(1,i)
%                     Mdl_score = Mdl_score +1;
%                 end
%                 if Epoc_label_Mdls((trial/Ntr)-1,i) == Epoc_label_True(1,i)
%                     Mdl2_score = Mdl2_score +1;
%                 end
%             end
% %             Model_record(1,trial/Ntr)=Mdl_score/Ntr;
% %             Model_record(2,trial/Ntr)=Mdl2_score/Ntr;
%             if Mdl2_score > Mdl_score
%                 Mdl = Models{(trial/Ntr)-1,1};
%                 MdlWn = Models{(trial/Ntr)-1,2};
%             end   
%         end
%     end
% 
%     while toc(time) < Tpause
%     end
%     writeDigitalPin(ard, ['D' num2str(4+Epoc_label_Mdl(1,trial))], 0);
%     Epoc_label_Mdls
% %     Model_record
% %     while toc(time)<Tpause
% %     end
% end
% 
% Mdl_scores = zeros(2,Nspan+1);
% for trial = 1:Ntr*Nspan
%     for model = 1:Nspan-1
%         if Epoc_label_Mdls(model,trial) == Epoc_label_True(1,trial)
%             Mdl_scores(1,model) = Mdl_scores(1,model)+1;
%         end
%         if Epoc_label_Mdls(model,trial) > 0
%             Mdl_scores(2,model) = Mdl_scores(2,model)+1;
%         end
%     end
%     if Epoc_label_Mdl(1,trial) == Epoc_label_True(1,trial)
%         Mdl_scores(1,Nspan+1) = Mdl_scores(1,Nspan+1)+1;
%     end
%     if Epoc_label_Mdl(1,trial) > 0
%         Mdl_scores(2,Nspan+1) = Mdl_scores(2,Nspan+1)+1;
%     end
% end
% Mdl_scores(1,:) = 100*(Mdl_scores(1,:)./Mdl_scores(2,:))
% 
% %% export
% filename = 'GK_2017-07-05';
% save(['onlineCSP02_' filename '.mat'], 'Epoc_data', 'Epoc_label_True', 'Epoc_label_Mdl', 'Epoc_label_Mdls', 'Epoc_data_reaction', 'Epoc_label_reaction', 'Models')
% 
% 
% % %% Reaction
% % 
% % Epoc_data_reaction_flt = zeros(Nch,Nsa,Ntr*Nspan);
% % 
% % for trial = Ntr+1 : Ntr*Nspan
% %     EEG = pop_importdata('data',Epoc_data_reaction(:,:,trial),'srate',fs,'nbchan',Nch,'pnts',Nsa); % import data from MATLAB array
% %     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG,0,'setname','eegdata','gui','off');
% %     EEG = eeg_checkset( EEG );
% %     EEG = pop_eegfilt(EEG, 3, 30, [], [0]); % highpass filtering at 1Hz
% %     %EEG = pop_eegfilt(EEG, 0, 30, [], [0]); % low pass filtering at 20Hz
% %     %eeglab redraw;
% %     Epoc_data_reaction_flt(:,:,trial) = EEG.data;
% % end
% % 
% % 
% % for ch =1:Nch
% %     figure;
% %     
% %     for trial = Ntr+1:Ntr*Nspan
% %         if Epoc_label_reaction(1,trial)==1
% %             color = [.8 0 0 0.1];
% %         else
% %             color = [0 .8 0 0.1];
% %         end
% %         hold on;
% %         plot((1:Nsa)/fs,(Epoc_data_reaction_flt(ch,:,trial))^2,'Color',color);
% %     end
% %     title(['Ch ' num2str(ch) ' in Time Domain']);
% %     xlabel('t (s)');
% %     ylabel('uV');
% % end
