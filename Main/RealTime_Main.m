% This is the script for real time EEG signal processing and robot
% controlling.
% The classifier in this code has to be pre-trained!
function RealTime_Main()
close all; clear all; clc;
% a state variable for clean up script to use
global state wall_e imgC recorder name
state.device = false; % device connection?
state.acquisition = false; % data acquisition on?
changeup = onCleanup(@CleanUp_online);
%% parameters---------------------------------------------------------------

classifierName = 'Mahsa_Aug_30_18_classifier';
methodName = {'CSP' 'Riem' 'BSSFO'}; % all the method of classifying
mIndex = 2; % index of the method we want to use(the methods in the methodName)
name = 'Riem_test90'; 

trials = 50;
breakTime = 2;

probThreshold = 0.70;

% name of ouput file (data recorded in this test)


% headset config
samplingRate = 500; % sampling frequency
BandpassIndex = -1; % 47; % 36;
NotchIndex = -1;    % 3;
SensitivityIndex = 6;

%% preparation----------------------------------------------------------
% wall_e = legoev3('usb');
load([classifierName '_' methodName{mIndex}]); % load the info for the classifier
epochSamples = Trimming;
labels = randGen(trials,2);

% initiate arduino
% ard = arduino();
% writeDigitalPin(ard, 'D13', 0);
%% initiate the headset
InitiateDevice;
pause(5)
count = 0;

recorder.len = 0;
recorder.timeSample = epochSamples;
recorder.trials = trials;
% pauseTime = breakTime;  % pauseTime is the system pause time between each epoch
                        % it equals to breakTime - time taken to save data(calculated at 
                        % the end of the each epoch, but used at the begining of the next epoch)
for Total = (1:trials)
    %% label from user
    title(Total)
    drawnow
%     label = user_label(ard);
    label = labels(Total);
    
    recorder.label(Total) = label;
    image(imgC)
    title(Total)
    %% system pause
    pause(breakTime+rand);
    
    %% signal recording
    disp('Entered the for loop')
    [data, mark] = RealTimeRecording(epochSamples,Total,label);
    tic
    disp('Data captured')
    len = size(data,1);
    recorder.mark(1,Total) = recorder.len + 1;
    recorder.mark(2,Total) = recorder.len + mark;
    recorder.data(recorder.len+1:recorder.len+len,:) = data;
    recorder.len = recorder.len + len;

    
    %% pre-processing
    data = 0.1*double(data);
    data = filtering(data);
    data = data(mark: mark+epochSamples-1, :);
    data = data';
    
    %% signal classifing
    switch mIndex
        case 1
            [command, prob] = online_CSP(data, Wn, Classifier);
        case 2
            command = online_Riem(cov(data'), covData,Labels, metric_mean, metric_dist);
        case 3
            command = online_BSSFO(data, BSS, C, X, W, W0);
            
    end
    
    recorder.pred(Total) = command;
    try
    recorder.prob(Total) = prob;
    catch
    end
    if command == label
        count = count + 1;
    end
    disp('Classification done')
    
    %% robot controlling
    recorder.lag(Total) = toc;
    disp([num2str(label) ': ' num2str(command)]); 
    try
    if prob < probThreshold
        disp(['Certainty of the prediction is lower than the threshold: ' num2str(prob)])
    end
    catch
    end
    
%     RobotControl(command);
    
    %% update the recorder + a short break
%     tic
%     save(['../OnlineData/' name],'recorder');
%     pauseTime = breakTime - toc;
%     if pauseTime < 0
%         pauseTime = 0;
%     end
%     

end


% temp = count / trials;
% disp(temp)
% recorder.acc = temp;
close all;
disp(sum(recorder.pred == recorder.label)*100/trials )
end
