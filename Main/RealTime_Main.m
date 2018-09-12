% This is the script for real time EEG signal processing and robot
% controlling.
% The classifier in this code has to be pre-trained!
function RealTime_Main()
close all; clear; clc;
% a state variable for clean up script to use
global state wall_e imgC
state.device = false; % device connection?
state.acquisition = false; % data acquisition on?
changeup = onCleanup(@CleanUp);
%% parameters---------------------------------------------------------------
epochDuration = 0.4; % in seconds
classifierName = 'Mahsa_classifer';
trials = 10;
breakTime = 2;
% startShift = 0;
% config setting
samplingRate = 500; % sampling frequency

probThreshold = 0.70;

% name of ouput file (data recorded in this test)
name = 'Mahsa_Sept_1_18_classifer_S5_Test4'; 

% headset config
BandpassIndex = -1; % 47; % 36;
NotchIndex = -1;    % 3;
SensitivityIndex = 6;

%% preparation----------------------------------------------------------
epochSamples = epochDuration * samplingRate;
% wall_e = legoev3('usb');
load(classifierName);
% labels = randGen(trials,2);

% initiate arduino
ard = arduino();
writeDigitalPin(ard, 'D13', 0);
%% initiate the headset
InitiateDevice;
pause(3)
count = 0;

recorder.len = 0;
recorder.timeSample = epochSamples;

% pauseTime = breakTime;  % pauseTime is the system pause time between each epoch
                        % it equals to breakTime - time taken to save data(calculated at 
                        % the end of the each epoch, but used at the begining of the next epoch)
for Total = (1:trials)
    %% label from user
    title(Total)
    drawnow
    label = user_label(ard);
    
    recorder.label(Total) = label;
    image(imgC)
    title(Total)
    %% system pause
    pause(breakTime);
    
    %% signal recording
    disp('Entered the for loop')
    [data, mark] = RealTimeRecording(epochDuration,Total,label);
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
    [command, prob] = online_CSP(data, Wn, Classifier);
    
    recorder.pred(Total) = command;
    recorder.prob(Total) = prob;
    if command == label
        count = count + 1;
    end
    disp('Classification done')
    
%     command = command + 1; % to adopt to two classes
    %% robot controlling
    
    disp([num2str(label) ': ' num2str(command)]); 
    if prob < probThreshold
        disp(['Certainty of the prediction is lower than the threshold: ' num2str(prob)])
    end
    
%     RobotControl(command);
    
    %% update the recorder + a short break
    tic
    save(['../OnlineData/' name],'recorder');
    pauseTime = breakTime - toc;
    if pauseTime < 0
        pauseTime = 0;
    end
    

end


% temp = count / trials;
% disp(temp)
% recorder.acc = temp;
close all;

end
