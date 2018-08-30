% This is the script for real time EEG signal processing and robot
% controlling.
% The classifier in this code has to be pre-trained!
function RealTime_Main()
close all; clear; clc;
% a state variable for clean up script to use
global state
state.device = false; % device connection?
state.acquisition = false; % data acquisition on?
changeup = onCleanup(@CleanUp);
%% parameters
epochDuration = 0.5;
classifierName = 'Adam_8_8_18_classifer';

% config setting
samplingRate = 500; % sampling frequency

BandpassIndex = -1; % 47; % 36;
NotchIndex = -1;    % 3;
SensitivityIndex = 6;

%% preparation
epochSamples = epochDuration * samplingRate;

load(classifierName);

%% initiate the headset
InitiateDevice;
pause(3)

while true
    %% signal recording
    [data, mark] = RealTimeRecording(epochDuration);
    
    %% pre-processing
    data = 0.1*double(data);
    data = filtering(data);
    data = data(mark: mark+epochSamples-1, :);
    data = data';
    
    %% signal classifing
    Arg_Ft_Ts = Wn'*data * data'*Wn;
    Ft_Ts= log ((diag(Arg_Ft_Ts))/trace(Arg_Ft_Ts));
    fit = Classifier.predictFcn(Ft_Ts');
    
    %     disp(length(data))
%     temp = data(1);
%     while temp <= 10
%         temp = temp * 10;
%     end
%     temp = floor(temp);
%     command = mod(temp,4) + 1;
    %% robot controlling
    disp(fit);
    %     RobotControl(command);
    
    %% a short break
    pause(3)
end

end
