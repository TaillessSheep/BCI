% This is a script to record EEG signal from g.Nautilus
% MATLAB API
% The data is stored in both the workspace and a .mat file, both with the
% name data_received along with variable Description containing all the
% info about this recording
function DataRecording_Main()
clear;clc;
% a state variable for clean up script to use
global state gds_interface
state.device = false; % device connection?
state.acquisition = false; % data acquisition on?
changeup = onCleanup(@CleanUp);
%% Paramaters:
filename = 'Mahsa_No_Hand_B_Sep06_test1';

% config setting
samplingRate = 500; % sampling frequency

classNum = 2;       % amount of classes
trialNum = 100;     % need to be a multiple of the amount of classes
epochDuration = 5;  % durations are in seconds
breakDuration = 3;
restPerT = 101; % after every restPerT trials there will be a long break(rest)
restTime = 60; % the duration of the rest

BandpassIndex = -1; % 47; % 36;
NotchIndex = -1;    % 3;
SensitivityIndex = 6;

% image loading
% img(1).file = imread('C4_LH.png');  img(1).name = 'LeftHand_4C';
% img(2).file = imread('C4_RH.png');  img(2).name = 'RightHand_4C';
% img(3).file = imread('C4_LF.png');  img(3).name = 'LeftFeet_4C';
% img(4).file = imread('C4_RF.png');  img(4).name = 'RightFeet_4C';   
% img(5).file = imread('C.png');      img(5).name = 'C';

imgC = imread('C.png');
imgB = imread('Blank.png');



%% check validation of parameters
% check if the trialNum satifies
if mod(trialNum,classNum) ~= 0
    error(['"trialNum"(' trialNum ') is not a mltiple of "classNum"(' classNum ').'])
end

% % check if the amount stimuling image matches the amount of calsses
% if length(img) == classNum - 1 
%     error(['The amount of cue image does not match the amount of classes.\n'...
%         'The amount of image should equal to classNum + 1(the image of break).']);
% end
% imgB = length(img); % index of the image for break
    
%% Parameter Set up
epochSamples = epochDuration * samplingRate;
breakSamples = breakDuration * samplingRate;
trialSamples = epochSamples + breakSamples;
totalSamples = trialNum * trialSamples;

filename = ['../Data/' filename];

% Descrition of the signal(will be saved along with the data)
load configOptions;
Description.classNum = classNum;
Description.samplingRate = samplingRate;
Description.trials = trialNum;
Description.epoch.duration = epochDuration;
Description.epoch.samples = epochSamples;
Description.break.duration = breakDuration;
Description.break.samples = breakSamples;
if BandpassIndex == -1
    Description.filters.BandpassFilter = 'None';
else
    Description.filters.BandpassFilter = supported_filters.BandpassFilters(BandpassIndex+1);
end
if NotchIndex == -1
    Description.filters.NotchFilter = 'None';
else
    Description.filters.NotchFilter = supported_filters.NotchFilters(NotchIndex+1);
end
Description.Sensitivity = supported_sensitivities(SensitivityIndex);


try % block 1 
    %% gds_interface setup
    % create gtecDeviceInterface object
    gds_interface = gtecDeviceInterface();
    
    % define connection settings (loopback)
    gds_interface.IPAddressHost = '127.0.0.1';
    gds_interface.IPAddressLocal = '127.0.0.1';
    gds_interface.LocalPort = 50224;
    gds_interface.HostPort = 50223;
    state.device = true;
catch ME
    close all;
    disp('Block 1');
    disp(ME.message);
    
    delete(gds_interface);
    clear gds_interface;
    return;
end
try %block 2
    % get connected devices
    connected_devices = gds_interface.GetConnectedDevices();
    % create g.Nautilus configuration object
    gnautilus_config = gNautilusDeviceConfiguration();
    % set serial number in g.Nautilus device configuration
    gnautilus_config.Name = connected_devices(1,1).Name;
    
    % set configuration to use functions in gds interface which require device
    % connection
    gds_interface.DeviceConfigurations = gnautilus_config;
    % get available channels
    available_channels = gds_interface.GetAvailableChannels();
    % get supported sensitivities
    supported_sensitivities = gds_interface.GetSupportedSensitivities();
    % get supported input sources
    supported_input_sources = gds_interface.GetSupportedInputSources();
    
    % edit configuration to have a sampling rate of 250Hz, 4 scans,all
    % available analog channels as well as ValidationIndicator and Counter.
    % Acquire the EEG electrode signal of g.Nautilus
    gnautilus_config.SamplingRate = samplingRate;
    gnautilus_config.NumberOfScans = 10;
    gnautilus_config.InputSignal = supported_input_sources(1).Value;
    gnautilus_config.NoiseReduction = false;
    gnautilus_config.CAR = false;
    % acquire additional channels counter and validation indicator
    gnautilus_config.Counter = false;
    gnautilus_config.ValidationIndicator = true;
    % do not acquire other additional channels
    gnautilus_config.AccelerationData = false;
    gnautilus_config.LinkQualityInformation = false;
    gnautilus_config.BatteryLevel = true;
    gnautilus_config.DigitalIOs = true;
    
    for i=1:size(gnautilus_config.Channels,2)
        if (available_channels(1,i))
            gnautilus_config.Channels(1,i).Available = true;
            gnautilus_config.Channels(1,i).Acquire = true;
            % set sensitivity to 187.5 mV
            gnautilus_config.Channels(1,i).Sensitivity = supported_sensitivities(SensitivityIndex);
            % do not use channel for CAR and noise reduction
            gnautilus_config.Channels(1,i).UsedForNoiseReduction = false;
            gnautilus_config.Channels(1,i).UsedForCAR = false;
            % do not use filters
            gnautilus_config.Channels(1,i).BandpassFilterIndex = BandpassIndex;
            gnautilus_config.Channels(1,i).NotchFilterIndex = NotchIndex;
            % do not use a bipolar channel
            gnautilus_config.Channels(1,i).BipolarChannel = -1;
        end
    end
    % apply configuration to the gds interface
    gds_interface.DeviceConfigurations = gnautilus_config;
    % set configuration provided in DeviceConfigurations
    disp('Setting configuration.');
    gds_interface.SetConfiguration();
catch ME
    close all;
    disp('Block 2');
    disp(ME.message);

    delete(gds_interface);
    clear gds_interface;
    clear gnautilus_config;
    return;
end

try % block 3
    %% Data Acquisition Initiation
    disp('About to start!');
    % start data acquisition
    gds_interface.StartDataAcquisition();
    state.acquisition = true;
    [~, data_received] = gds_interface.GetData(0);
    disp(['Battry level: ' num2str(data_received(1,33))]);
    pause(2);
    % record data for 10 second and plot three channels (analog channel 1,
    % counter and validation indicator) of each scan acquired
    
    % NOTE: the line below is for a 32-channel g.Nautilus device. If a 8-,
    % 16- or 64-channel is used the code below has to be changed to
    % 8-channel: data_received = single(zeros(2500, 10));
    % 16-channel: data_received = single(zeros(2500, 18));
    % 64-channel: data_received = single(zeros(2500, 66));
    data_received = single(zeros(totalSamples,35));
    close all;
    image(imgB);
    set(gcf, 'Position', get(0, 'Screensize'));
    
    %% Count Down & Buffer Clearing
    sampleCurrent = 0;  % current sample index
    tic;
    pre = toc;
    cur = toc;
    test = single(zeros(10,35));
    % count down without display
    % wait for the inital garbage data to be cleared
    for i = (3:-1:1)
        while(cur - pre <= 1)
            cur = toc;
            [scans_received, data] = gds_interface.GetData(0);
        end
        pre = cur;
    end
    % count down with display
    for i = (10:-1:-1)
        if i > 0
            title(i);
        else
            title('FOR THE SAKE OF HUMANITY!!!');
        end
        while(cur - pre <= 1)
            cur = toc;
            [~, ~] = gds_interface.GetData(0);
        end
        pre = cur;
    end
    
    
    %% Recording
    mark = randGen(trialNum,classNum);
    sampleCurrent = 0;  % current sample index
    for current_trial = (1:trialNum)
        % recording epoch
%         [~, ~] = gds_interface.GetData(0);
        image(imgC);
        
        title(current_trial);
        tic;
        while toc <= epochDuration+0.1
            % read data
            
            [scans_received, data] = gds_interface.GetData(0);
            data_received((sampleCurrent + 1) : (sampleCurrent + scans_received), :) = data;
            
            sampleCurrent = sampleCurrent + scans_received;
        end
        
        % recording break
        image(imgB);
        title(current_trial);
%         drawnow();
        tic;
        while toc <= breakDuration+0.1
            % read data
            
            [scans_received, data] = gds_interface.GetData(0);
            data_received((sampleCurrent + 1) : (sampleCurrent + scans_received), :) = data;
            clear data;
            
            sampleCurrent = sampleCurrent + scans_received;
        end
        
        if mod(current_trial,restPerT)==0
            tic
            while toc < restTime
                countDown = ceil(restTime - toc);
                disp(countDown)
                title(countDown)
                pause(0.1)
            end
        end
    end
    close all;
    %% stop data acquisition
    disp('Recording done.');
    
    gds_interface.StopDataAcquisition();
    state.acquisition = false;
    
    % clean up
    delete(gds_interface)
    state.device = false;
    estim_index = 1;
    bstim_index = 1;
    for i = (2:size(data_received,1))
        if ((data_received(i-1,34) ~= 0 && data_received(i,34) == 0))
%         if ((data_received(i-1,34) == 0 && data_received(i,34) ~= 0))
            estim(estim_index) = i;
            estim_index = estim_index + 1;
        end
        if ((data_received(i-1,34) == 0 && data_received(i,34) ~= 0))
%         if ((data_received(i-1,34) ~= 0 && data_received(i,34) == 0))
            bstim(bstim_index) = i;
            bstim_index = bstim_index + 1;
        end
    end
    if length(estim) ~= trialNum || length(bstim) ~= trialNum
        error(['Amount of stimulating captured does not match trialNum.\nCaptured: '...
            num2str(length(estim)) ';  trialNum: ' num2str(trialNum) ';']);
    end
    mark(2,:) = estim;
    mark(3,:) = bstim;
    
    if ~exist('../Data','dir')
        mkdir('../Data')
    end
    save(filename,'data_received', 'mark', 'Description');
    
    batteryLVL = data_received(length(data_received),33);
    if batteryLVL < 10
        warning(['Battery level CRITICAL: ' num2str(batteryLVL) '%'])
    elseif batteryLVL < 20
        warning(['Battery level LOW: ' num2str(batteryLVL) '%'])
    else
        disp(['Battery level: ' num2str(batteryLVL)])
    end
    
    clear gds_interface;
    clear gnautilus_config;
    % ploting
    rec_time = (1:double(size(data_received,1)))/500; %samplingRate;
    for i = (1:8)
        figure();
        for j = (1:4)
            subplot(4,1,j);
            plot(rec_time, data_received(:,(i-1)*4+j));
            title((i-1)*4+j);
        end
    end
%     figure('name','event');
%     plot(rec_time,data_received(:,34));
    clearvars -except filename;
    load(filename);
    
catch ME
    close all;
    disp('Block 3');
    disp(ME.message);
    
%     gds_interface.StopDataAcquisition();
%     delete(gds_interface);
%     clear gds_interface;
%     clear gnautilus_config;
    
    disp(ME.stack.line);
    return;
end

end


