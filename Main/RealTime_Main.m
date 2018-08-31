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
%% parameters
epochDuration = 2;
classifierName = 'Mahsa_Aug_30_18_classifer';

% config setting
samplingRate = 500; % sampling frequency

BandpassIndex = -1; % 47; % 36;
NotchIndex = -1;    % 3;
SensitivityIndex = 6;

%% preparation
epochSamples = epochDuration * samplingRate;
% wall_e = legoev3('usb');
load(classifierName);

%% initiate the headset
InitiateDevice;
pause(3)
Ones = 0;
Total = 0;
for k=1
    Total = Total + 1;
    %% signal recording
    disp('Entered the for loop')
    [data, mark] = RealTimeRecording(epochDuration);
    disp('Data captured')
    %% pre-processing
    data = 0.1*double(data);
    data = filtering(data);
    data = data(mark: mark+epochSamples-1, :);
    data = data';
    
    %% signal classifing
    Arg_Ft_Ts = Wn'*data * data'*Wn;
    Ft_Ts= log ((diag(Arg_Ft_Ts))/trace(Arg_Ft_Ts));
    command = Classifier.predictFcn(Ft_Ts');
    disp('Classification done')
    if command == 1
        Ones = Ones + 1;
    end
%     command = command + 1; % to adopt to two classes
    %% robot controlling
    
    disp([num2str(Total) ': ' num2str(Ones/Total)]); 
    
    disp(command);
%     RobotControl(command);
    
    %% a short break
    pause(2)

end

end