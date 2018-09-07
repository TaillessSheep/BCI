% This is the script for real time EEG signal processing and robot
% controlling.
% The classifier in this code has to be pre-trained!
function RealTime_Main()
close all; clear; clc;
% a state variable for clean up script to use
global state wall_e
state.device = false; % device connection?
state.acquisition = false; % data acquisition on?
changeup = onCleanup(@CleanUp);
%% parameters---------------------------------------------------------------
epochDuration = 0.4; % in seconds
classifierName = 'Mahsa_classifer';
trials = 20;
breakTime = 4;
startShift = 0;
% config setting
samplingRate = 500; % sampling frequency

BandpassIndex = -1; % 47; % 36;
NotchIndex = -1;    % 3;
SensitivityIndex = 6;

% name of ouput file (data recorded in this test)
name = 'Mahsa_Sept_1_18_classifer_S5_Test4'; 

%% preparation----------------------------------------------------------
epochSamples = epochDuration * samplingRate;
% wall_e = legoev3('usb');
load(classifierName);
labels = randGen(trials,2);

%% initiate the headset
InitiateDevice;
pause(3)
count = 0;

recorder.len = 0;
recorder.timeSample = epochSamples;

for Total = (1:trials)

    %% signal recording
    disp('Entered the for loop')
    [data, mark] = RealTimeRecording(epochDuration,Total);
    disp('Data captured')
    len = size(data,1);
    recorder.mark(1,Total) = recorder.len + 1;
    recorder.mark(2,Total) = recorder.len + mark;
    recorder.data(recorder.len+1:recorder.len+len,:) = data;
    recorder.len = recorder.len + len;
%     recorder.labels(Total) = labels(Total);
    
    %% pre-processing
    data = 0.1*double(data);
    data = filtering(data);
    data = data(mark: mark+epochSamples-1, :);
    data = data';
    
    %% signal classifing
    Arg_Ft_Ts = Wn'*data * data'*Wn;
    Ft_Ts= log ((diag(Arg_Ft_Ts))/trace(Arg_Ft_Ts));
    [command, prob] = Classifier.predictFcn(Ft_Ts');
    recorder.pred(Total) = command;
    recorder.prob(Total) = prob;
    if command == labels(Total)
        count = count + 1;
    end
    disp('Classification done')
    
%     command = command + 1; % to adopt to two classes
    %% robot controlling
    
    disp([num2str(labels(Total)) ': ' num2str(command)]); 
    
    
%     RobotControl(command);
    
    %% update the recorder + a short break
    tic
    if ~exist('../OnlineData','dir')
        mkdir('../OnlineData')
    end
    save(['../OnlineData/' name],'recorder');
    temp = breakTime - toc;
    if temp < 0
        temp = 0;
    end
    pause(temp)

end

% temp = count / trials;
% disp(temp)
% recorder.acc = temp;

end
