%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--Online CSP--%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% filter by window/epoc, then cut off begining of each window
%
% 
clc; clear; close all; 
cd ('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project');
addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\online_testing'))

%% Set variables

Nch = 14;           %number of sensors
Nlb = 2;            %number of actions/labels
Nfe = 6;            %number of features
Tepoc = 2;          %epoc duration in seconds
Tcut = 0.5;         %amount to trim for filter artefacts
Tdelay = 0.5;       %delay between button press and recording
Trest = 4;          %delay between trials
Taction = 2;        %time to run classified action
fs = 128;           %sample frequency
Nsa = floor(Tepoc * fs);    %number of samples per epoc
Nsa_l = floor((Tepoc + Tcut) * fs);    %number of samples per epoc before trimming
Ntr_min = 20;                %number of training epocs before first model
score_threshold = 0.7;
Passband = [8 30];
[Filt_B,Filt_A] = butter(5,Passband/(fs/2));

robot_on = 1;
topspeed = 50;

display_spec = 0;
display_feature = 1;

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
button = [...
    {'rest'},{'d2'};
    {'forward'},{'d4'};
    {'back'},{'d7'};
    {'left'},{'d8'};
    {'right'},{'d12'}
    ];
[Ncl,~]=size(button);
led_record = 'd3';
pin_stop = 'd13';
led=[...
    {'rest'},{'d5'};
    {'forward'},{'d6'};
    {'back'},{'d9'};
    {'left'},{'d10'};
    {'right'},{'d11'};
    {'record'},{led_record}];
for pin = 1:Ncl + 1
    configurePin(ard, led{pin,2}, 'PWM');
    writeDigitalPin(ard, led{pin,2}, 0);
end
% writeDigitalPin(ard, led.record, 1);

for btn = 1:Ncl
    configurePin(ard, button{btn,2}, 'DigitalInput');
end


% writePWMDutyCycle(ard,led.forward,0.13);
% writeDigitalPin(ard, led.record, 0);

%value = readDigitalPin(ard,'D12');
%% Lego Mindstorm robot control
if robot_on
    robot = legoev3('usb');
    % robot = legoev3('bluetooth','COM7');
    clearLCD(robot)
    writeStatusLight(robot,'off')
    motor_r = motor(robot,'A');
    motor_l = motor(robot,'B');
    motor_m = motor(robot,'D');
    motor_m.Speed = 0;
    motor_r.Speed = 0;
    motor_l.Speed = 0;
    start(motor_r);
    start(motor_l);
    start(motor_m);
    % stop(motor_r)
    % beep(robot)
    % writeLCD(robot,'Hello, LEGO!',5,8)
    % playTone(robot,5000,0.2,5)
    % writeStatusLight(robot,'red')
    % writeStatusLight(robot,'green')
    % writeStatusLight(robot,'off')
    sensor_ir = irSensor(robot,1);
    time_bite  = tic;
    bite_proximity = 100;
    
end

%% Run experiment

running = 1;
% Filt_state=filtic(Filt_B,Filt_A,zeros(1,Nsa),zeros(1,Nsa));%zeros(200,46144);%max(length(Filt_A),length(Filt_B))-1,Nch);
EEG_window = zeros(Nch,Nsa_l);
EEG_window_filt = zeros(Nch,Nsa_l);
EEG_window_filt_trim = zeros(Nch,Nsa);
Firstrun=1;
Mdl = [];
Label_tr = [];
Label_ts = [];
Data_tr = [];
Data_ts = [];
Ntr = 0;
Nts = 0;
State_tr=0;
State_ts=0;

predictions=[];
Npred=0;
Npred_true=0;

if display_spec
    F_spec = figure();
end
if display_feature
    F_feature = figure();
end
while running == 1
    if State_tr==0 || State_ts==0
        State_ts=1;
        time_ts=tic;
    end
    if State_ts==1 && toc(time_ts) >= (Tepoc + Tdelay)
        State_ts=0;
        time_action=tic;
        Nts = Nts +1;
        Data_ts(:,:,Nts) = EEG_window_filt_trim;
        
    end
    
    Tepoc = 2;          %epoc duration in seconds
Tcut = 0.5;         %amount to trim for filter artefacts
Tdelay = 0.5;       %delay between button press and recording
Trest = 4;          %delay between trials
Taction = 2;
    
    
    if State_tr==0
        for btn = 1:Ncl
            if readDigitalPin(ard,button{btn,2}) == 1
                Label_tr = [Label_tr btn];
                time_tr = tic;
                State_tr=1;
                State_ts=0;
                writeDigitalPin(ard, led_record, 1);
                if robot_on
                    switch button{Label_tr(1,end),1}
                        case 'left'
                            motor_l.Speed = -topspeed;
                            motor_r.Speed = topspeed;
                        case 'right'
                            motor_l.Speed = topspeed;
                            motor_r.Speed = -topspeed;
                        case 'rest'
                            motor_l.Speed = 0;
                            motor_r.Speed = 0;
                        case 'forward'
                            motor_l.Speed = topspeed;
                            motor_r.Speed = topspeed;
                        case 'back'
                            motor_l.Speed = -topspeed;
                            motor_r.Speed = -topspeed;
                    end
                end
                break;
            end
        end
    end
    if State_tr == 1 && toc(time_tr)>(Tepoc+Tdelay)
        if robot_on
            motor_r.Speed = 0;
            motor_l.Speed = 0;
        end
        if ~isempty(Mdl)
            predictions=[predictions Out_class];
            Npred=Npred+1;
            if Out_class == Label_tr(1,end)
                Npred_true=Npred_true+1;
            end
        end
        Ntr = Ntr+1;
        Data_tr(:,:,Ntr) = EEG_window_filt_trim;
        State_tr = 0;
        writeDigitalPin(ard, led_record, 0);
        if length(Label_tr)>=Ntr_min && length(unique(Label_tr))==Ncl
            % Train feature extraction
            Reg_G = [];
            Reg_y = 0;
            Reg_b = 0;
            Reg_s = 1;
            Reg_K = []; %eye(Nch);
            Reg_a = 0;
            [Wn, f_tr, Class_comb, Ncomb, S_class] = TrainRCSP01(Data_tr, Label_tr, Nfe/2, Reg_G, Reg_y, Reg_b, Reg_s, Reg_K, Reg_a);

            % Train classifier
            Mdl=cell(1,Ncomb);
            for comb = 1:Ncomb
                Mdl{1,comb} = fitcdiscr(f_tr(:,:,comb), Label_tr);
            end

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
    if Nsa_in < Nsa_l
        EEG_window = [EEG_window(:,Nsa_in+1 : Nsa_l), EEG_ChunkData(1:Nch,:)];
    elseif Nsa_in >= Nsa_l
        EEG_window = EEG_ChunkData(1:Nch, Nsa_in - Nsa_l + 1:Nsa_in);
    end
        
    % filter
    EEG_window_filt = filter(Filt_B, Filt_A, EEG_window,[],2);
    
    % trim window
    EEG_window_filt_trim = EEG_window_filt(:,end-Nsa:end);
       
    
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
        Out_scores = zeros(Ncomb,Ncl);
        for comb = 1:Ncomb
            arg_ts  = Wn(:,:,comb)'* EEG_window_filt_trim(:,:) * EEG_window_filt_trim(:,:)'* Wn(:,:,comb);
            f_ts = log ((diag(arg_ts))/trace(arg_ts));
            [~, Out_scores(comb,:)] = predict(Mdl{1,comb},f_ts');
        end
        % display spectrum
        if display_spec
            EEG_window_spafilt=Wn'*EEG_window_filt_trim;
            figure(F_spec);
            spectrogram(EEG_window_spafilt(1,:),100,80,100,fs,'yaxis');
        end
        % display classification
        if display_feature
            figure(F_feature);
            hold off
            for i = 1:Ntr
                if Label_tr(1,i) == 1
                    plot(f_tr(i,1,1), f_tr(i,end,1), 'b.');
                elseif Label_tr(1,i) == 2
                    plot(f_tr(i,1,1), f_tr(i,end,1), 'r.');
                elseif Label_tr(1,i) == 3
                    plot(f_tr(i,1,1), f_tr(i,end,1), 'c.');
                elseif Label_tr(1,i) == 4
                    plot(f_tr(i,1,1), f_tr(i,end,1), 'm.');
                elseif Label_tr(1,i) == 5
                    plot(f_tr(i,1,1), f_tr(i,end,1), 'y.');
                end
                hold on
            end
            plot(f_ts(1,1), f_ts(4,1), 'g.');
        end
        Out_score = mean(Out_scores,1)
        [Out_score_max,Out_class] = max(Out_score)
        Npred_true/Npred
        for pin = 1:Ncl
            writePWMDutyCycle(ard,led{pin,2},Out_score(1,pin));
        end
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
        if robot_on  && State_tr==0
            switch button{Out_class,1}
                case 'left'
                    motor_l.Speed = -topspeed * Out_score_max;
                    motor_r.Speed = topspeed * Out_score_max;
                case 'right'
                    motor_l.Speed = topspeed * Out_score_max;
                    motor_r.Speed = -topspeed * Out_score_max;
                case 'rest'
                    motor_l.Speed = 0;
                    motor_r.Speed = 0;
                case 'forward'
                    motor_l.Speed = topspeed * Out_score_max;
                    motor_r.Speed = topspeed * Out_score_max;
                case 'back'
                    motor_l.Speed = -topspeed * Out_score_max;
                    motor_r.Speed = -topspeed * Out_score_max;
            end
            if sensor_ir.readProximity < bite_proximity
                motor_m.Speed = 20;
                time_bite  = tic;
            elseif toc(time_bite)>1
                motor_m.Speed = 0;
            end
        end
        pause(0.1);
    end
    if readDigitalPin(ard,pin_stop) == 1
        running =0;
    end
end

if robot_on
    motor_r.Speed = 0;
    motor_l.Speed = 0;
end
save(['Slidingwindow' datestr(now,'yyyy-mm-dd HH-MM') '.mat'], 'Data_tr', 'Label_tr', 'Wn', 'f_tr', 'Class_comb', 'Ncomb', 'Mdl', 'Npred', 'Npred_true');

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
