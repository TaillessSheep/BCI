% This is a script to record EEG signal from g.Nautilus
% MATLAB API
% The data is stored in both the workspace and a .mat file, both with the
% name data_received

clear;
clc;

%% Paramaters:
% config setting
samplingRate = 500; % sampling frequency
bufferSize = 10;    % amount of samples (for each channel) matlab pull out from the headset
                    % common divisor of epochSample and breakSample

trialNum = 10;      % need to be a multiple of the amount of classes
epochDuration = 3;  % durations are in seconds
breakDuration = 1.5;

BandpassIndex = 36;   
NotchIndex = 3;
SensitivityIndex = 6;

% image loading
imgLH = imread('LH.png');
imgRH = imread('RH.png');
imgC  = imread('C.png');

% name of the file storing the data
filename = "data_received36_Jun28_B.mat";

try
%% Parameter Set up
    epochSample = epochDuration * samplingRate;
    breakSample = breakDuration * samplingRate;
    trialSample = epochSample + breakSample;
    totalSample = trialNum * trialSample;
    
    %% gds_interface setup
    % create gtecDeviceInterface object
    gds_interface = gtecDeviceInterface();
    
    % define connection settings (loopback)
    gds_interface.IPAddressHost = '127.0.0.1';
    gds_interface.IPAddressLocal = '127.0.0.1';
    gds_interface.LocalPort = 50224;
    gds_interface.HostPort = 50223;

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
    gnautilus_config.NumberOfScans = bufferSize;
    gnautilus_config.InputSignal = supported_input_sources(1).Value;
    gnautilus_config.NoiseReduction = false;
    gnautilus_config.CAR = false;
    % acquire additional channels counter and validation indicator
    gnautilus_config.Counter = true;
    gnautilus_config.ValidationIndicator = true;
    % do not acquire other additional channels
    gnautilus_config.AccelerationData = false;
    gnautilus_config.LinkQualityInformation = false;
    gnautilus_config.BatteryLevel = false;
    gnautilus_config.DigitalIOs = false;

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
    disp('About to start!');
    gds_interface.SetConfiguration();

%% Data Acquisition Initiation
    
    % start data acquisition
    gds_interface.StartDataAcquisition();
    % record data for 10 second and plot three channels (analog channel 1,
    % counter and validation indicator) of each scan acquired
    
    % NOTE: the line below is for a 32-channel g.Nautilus device. If a 8-,
    % 16- or 64-channel is used the code below has to be changed to
    % 8-channel: data_received = single(zeros(2500, 10));
    % 16-channel: data_received = single(zeros(2500, 18));
    % 64-channel: data_received = single(zeros(2500, 66));
    data_received = single(zeros(totalSample,34));
    close all;
    image(imgC);
    set(gcf, 'Position', get(0, 'Screensize'));
    drawnow();
    
%% Count Down & Buffer Clearing
    sampleCurrent = 0;  % current sample index
    tic;
    pre = toc;
    cur = toc;  
    test = single(zeros(10,34));
    % wait for the inital garbage data to be cleared
    for i = (20:-1:1)
        while(cur - pre <= 1)
            cur = toc;
            [scans_received, data] = gds_interface.GetData(0);
            data_received((sampleCurrent + 1) : (sampleCurrent + scans_received), :) = data;
            sampleCurrent = sampleCurrent + scans_received;
        end
        pre = cur;
    end
    % count down
    for i = (10:-1:-1)
        if i > 0
            title(i);
        else
            title('FOR THE SAKE OF HUMANITY!!!');
        end
        while(cur - pre <= 1)
            cur = toc;
            [scans_received, data] = gds_interface.GetData(0);
            data_received((sampleCurrent + 1) : (sampleCurrent + scans_received), :) = data;
            sampleCurrent = sampleCurrent + scans_received;
        end
        
        pre = cur;
    end
%% Recording
    mark = randGen(trialNum);
    
    for current_trial = (1:trialNum)
        % recording epoch
        mark(2,current_trial) = sampleCurrent + 1; % starting point of epoches in the second row
        
        while sampleCurrent - mark(2,current_trial) + 1 < epochSample
            
            if mark(1,current_trial)
                image(imgLH);
            else
                image(imgRH);
            end
            title(current_trial);
            drawnow();
            % read data
            try
                [scans_received, data] = gds_interface.GetData(bufferSize);
                data_received((sampleCurrent + 1) : (sampleCurrent + scans_received), :) = data;
                clear data;
            catch ME
                disp(ME.message);
                disp(ME.stack.line);
                break;
            end
            sampleCurrent = sampleCurrent + scans_received;
        end
        
        % While recording break
        mark(3,current_trial) = sampleCurrent + 1;  % starting porint of breaks in the third row
        while sampleCurrent - mark(3,current_trial) + 1 < breakSample
            
            image(imgC);
            title(current_trial);
            drawnow();
            % read data
            try
                [scans_received, data] = gds_interface.GetData(bufferSize);
                data_received((sampleCurrent + 1) : (sampleCurrent + scans_received), :) = data;
                clear data;
            catch ME
                disp(ME.message);
                disp(ME.stack.line);
                break;
            end
            sampleCurrent = sampleCurrent + scans_received;
        end
        
    end
    close all;
%% stop data acquisition
    disp('Recording done. Cleaning up the mess~');

    gds_interface.StopDataAcquisition();

    % clean up
    delete(gds_interface)
    % get user directory to save data in Documents/MATLAB folder
    % user_profile = getenv('USERPROFILE');
    % dirname = sprintf('%s\\Documents\\MATLAB', user_profile);
%     dirname = pwd;
%     filename = sprintf('%s\\data_received36_Jun28_A.mat', dirname);
%     % convert data to double for later use in g.BSanalyze
%     data_received = double(data_received);
%     % if folder exists save variable there, if not do not save
%     if (exist(dirname,'dir') == 7)
%         save(filename, 'data_received');
%     end

    data_temp = data_received(mark(2,1):size(data_received,1),:);
    clear data_received;
    data_received = data_temp;

    save(filename,'data_received');

    clear gds_interface;
    clear gnautilus_config;
    disp('All done~');
    % ploting
    rec_time = (1:double(size(data_received,1)))/samplingRate;
    for i = (1:8)
        figure();
        for j = (1:4)
            subplot(4,1,j);
            plot(rec_time, data_received(:,(i-1)*4+j));
            title((i-1)*4+j);
        end
    end
%     clearvars -except data_received mark sampleCurrent;
    
    
    
catch ME
    close all;
    disp(ME.message);
    disp(ME.stack.line);
    gds_interface.StopDataAcquisition();
    delete(gds_interface);
    clear gds_interface;
    clear gnautilus_config;
end
