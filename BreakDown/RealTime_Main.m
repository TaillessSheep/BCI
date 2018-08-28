% This is the script for real time EEG signal processing and robot
% controlling.
% The classifier in this code has to be pre-trained!

close all; clear; clc;

%% parameters
epochDuration = 3;

%% preparation
% add the path of the scrpts and fucntions used here
addpath('./RealTime_Package');

%% initiate the headset
InitiateDevice;

while true
    %% signal recording
    data = RealTimeRecording(epochDuration);
    
    %% signal processing
    temp = data(1);
    while temp <= 10
        temp = temp * 10;
    end
    temp = floor(temp);
    command = mod(temp,4) + 1;
    %% robot controlling
    disp(command);
%     RobotControl(command);
end
