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
epochDuration = 0.3;
classifierName = 'Will_Aug_27_18_classifer';

% config setting
samplingRate = 500; % sampling frequency

BandpassIndex = -1; % 47; % 36;
NotchIndex = -1;    % 3;
SensitivityIndex = 6;

% name of the file to save the recorder
name = 'test4';

%% preparation
epochSamples = epochDuration * samplingRate;
% wall_e = legoev3('usb');
load(classifierName);

%% initiate the headset
InitiateDevice;
pause(10)
Ones = 0;
Total = 0;
recorder.len = 0;
recorder.timeSample = epochSamples;

for Total = (1:50)
%     Total = Total + 1;
    %% signal recording
%     disp('Entered the for loop')
    title(Total)
    [data, mark] = RealTimeRecording(epochDuration,Total);
%     disp('Data captured')
    len = size(data,1);
    recorder.mark(1,Total) = recorder.len + 1;
    recorder.mark(2,Total) = recorder.len + mark;
    recorder.data(recorder.len+1:recorder.len+len,:) = data;
    
    %% pre-processing
    data = 0.1*double(data);
    data = filtering(data);
    data = data(mark: mark+epochSamples-1, :);
    data = data';
    
    %% signal classifing
    Arg_Ft_Ts = Wn'*data * data'*Wn;
    Ft_Ts= log ((diag(Arg_Ft_Ts))/trace(Arg_Ft_Ts));
    command(Total) = Classifier.predictFcn(Ft_Ts');
%     disp('Classification done')
%     if command == 1
%         Ones = Ones + 1;
%     end
%     command = command + 1; % to adopt to two classes
    %% robot controlling
    
%     disp([num2str(Total) ': ' num2str(Ones)]); 
%     
%     disp(command);
%     RobotControl(command);
    
    %% update the recorder + a short break
    tic
    save(name,'recorder');
    temp = 5 - toc;
    if temp < 0
        temp = 0;
    end
    pause(temp)

end
save(['predictions_' name], 'command')
end
