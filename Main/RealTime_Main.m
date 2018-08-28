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
epochDuration = 3;
classifierName = 'LDA2eigWill';

% config setting
samplingRate = 500; % sampling frequency

BandpassIndex = -1; % 47; % 36;
NotchIndex = -1;    % 3;
SensitivityIndex = 6;

%% preparation
% add the path of the scrpts and fucntions used here
addpath('./RealTime_Package');
classifier = str2func(classifierName);

%% initiate the headset
InitiateDevice;

try
    while true
        %% signal recording
        data = RealTimeRecording(epochDuration);
        
        %% pre-processing
%         mark = data(:,34);
%         for i = ()
%         data = filtering(data);
        
        
        %% signal classifing
        temp = data(1);
        while temp <= 10
            temp = temp * 10;
        end
        temp = floor(temp);
        command = mod(temp,4) + 1;
        %% robot controlling
        disp(command);
        %     RobotControl(command);
        
        %% a short break
        pause(2)
    end
catch ME
    disp('Ending')
    gds_interface.StopDataAcquisition();
    delete(gds_interface);
    clear gds_interface;
    clear gnautilus_config;
end
end
