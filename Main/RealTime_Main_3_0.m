% This is the script for real time EEG signal processing and robot
% controlling.
% The classifier in this code has to be pre-trained!
function RealTime_Main()
close all; clear; clc;
% a state variable for clean up script to use
global state wall_e gds_interface imgC imgBlank;
state.device = false; % device connection?
state.acquisition = false; % data acquisition on?
changeup = onCleanup(@CleanUp);
%% parameters---------------------------------------------------------------
epochSamples = 200; % should equal to the trimming used in classifier training
classifierName = 'Mahsa_classifer';
trials = 20;
breakTime = 4;
numClass = 2;
% startShift = 0;

% name of ouput file (data recorded in this test)
name = 'Mahsa_Sept_1_18_classifer_S5_Test4'; 

% config setting
samplingRate = 500; % sampling frequency

BandpassIndex = -1; % 47; % 36;
NotchIndex = -1;    % 3;
SensitivityIndex = 6;

%% preparation----------------------------------------------------------
% wall_e = legoev3('usb');
load(classifierName);
labels = randGen(trials,numClass);

Break = true;
ChangeImg = false;
%% initiate the headset
InitiateDevice;
pause(5);

recorder.len = 0;
recorder.timeSample = epochSamples;
recorder.numClass = numClass;

% clear the buffer
for i = (1:10)
[scans, ~] = gds_interface.GetData(0);
if scans < 20 % if it has been clean enough
    break
end
end

while ture
    if ChangeImg 
        if Break
            image(imgBlank);
        else
            image(imgC);
        end
    end
    [scans_received, data_received] = gds_interface.GetData(0);
    if Break % if it is taking a break
        if toc < breakTime  % if the break is not done
            continue
        else                % if the break is done 
            Break = false;
            continue
        end
    else     % if it is recording
        
        
end

end