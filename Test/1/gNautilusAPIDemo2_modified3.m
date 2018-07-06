% This is a demo script for the use of g.Nautilus in the g.NEEDaccess
% MATLAB API.
% It records data for 10 seconds from all analog channels available and
% stores the recorded data to a .mat file.

clear;
clc;

%% -------------------------------------------------
% Paramaters:
samplingRate = 500; % sampling frequency
bufferSize = 75;    % amount of samples (for each channel) matlab pull out from the headset
                    % common divisor of epochSample and breakSample

trialNum = 10;      % need to be a multiple of the amount of classes
epochDuration = 3;
breakDuration = 1.5;

imgLH = imread('LH.png');
imgRH = imread('RH.png');
imgC  = imread('C.png');

try
%% Parameter Set up
    
    
    
    epochSample = epochDuration * samplingRate;
    breakSample = breakDuration * samplingRate;
    trialSample = epochSample + breakSample;
    totalSample = trialNum * trialSample;

%     close all;
%     image(imgC);
%     set(gcf, 'Position', get(0, 'Screensize'));
%     drawnow();
    %% gds_interface setup
    % create gtecDeviceInterface object
    gds_interface = gtecDeviceInterface();
disp('ha');
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
            gnautilus_config.Channels(1,i).Sensitivity = supported_sensitivities(6);
            % do not use channel for CAR and noise reduction
            gnautilus_config.Channels(1,i).UsedForNoiseReduction = false;
            gnautilus_config.Channels(1,i).UsedForCAR = false;
            % do not use filters
            gnautilus_config.Channels(1,i).BandpassFilterIndex = -1;
            gnautilus_config.Channels(1,i).NotchFilterIndex = -1;
            % do not use a bipolar channel
            gnautilus_config.Channels(1,i).BipolarChannel = -1;
        end
    end
    % apply configuration to the gds interface
    gds_interface.DeviceConfigurations = gnautilus_config;
    % set configuration provided in DeviceConfigurations
    disp('huh');
    gds_interface.SetConfiguration();

%% Data Acquisition
    close all;
    image(imgC);
    set(gcf, 'Position', get(0, 'Screensize'));
    drawnow();
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


    mark = randGen(trialNum);
    sampleCurrent = 0;  % current sample index
    sampleHistory = 0;  % starting sample index of the current trial
    discard_count = 0;
%%
    for current_trial = (1:trialNum)
        mark(2,current_trial) = sampleCurrent + 1;
        while sampleCurrent - sampleHistory ~= trialSample
            if sampleCurrent - sampleHistory < epochSample
                if mark(1,current_trial)
                    image(imgLH);
                else
                    image(imgRH);
                end
            else
                image(imgC);
            end
            drawnow();
            % read data
            try
                [scans_received, data] = gds_interface.GetData(0);
                if (scans_received > bufferSize)
                    discard_count = discard_count + scans_received - bufferSize;
                elseif (scans_received < bufferSize)
                    msg = 'received: ' + string(scans_received);
                    error(msg);
                end
                data_received((sampleCurrent + 1) : (sampleCurrent + bufferSize), :) = data(1:bufferSize,:);
%                 clear data;
            catch ME
                disp(ME.message);
                disp(ME.stack.line);
                break;
            end
            sampleCurrent = sampleCurrent + bufferSize;
%             if (scans_received ~= bufferSize)
%                 msg = 'received: ' + string(scans_received);
%                 error(msg);
%             end
%             sampleCurrent = sampleCurrent + bufferSize;
        end
        sampleHistory = sampleCurrent;
    end
    close all;
%% stop data acquisition
    gds_interface.StopDataAcquisition();

    % clean up
    delete(gds_interface)
    % get user directory to save data in Documents/MATLAB folder
    % user_profile = getenv('USERPROFILE');
    % dirname = sprintf('%s\\Documents\\MATLAB', user_profile);
    dirname = pwd;
    filename = sprintf('%s\\data_received.mat', dirname);
    % convert data to double for later use in g.BSanalyze
    data_received = double(data_received);
    % if folder exists save variable there, if not do not save
    if (exist(dirname,'dir') == 7)
        save(filename, 'data_received');
    end

    clear gds_interface;
    clear gnautilus_config;
    disp('Data collection done~');
    disp('Discarded data: ' + string(discard_count));
    clearvars -except data_received mark;
    
catch ME
    disp(ME.message);
    disp(ME.stack.line);
    gds_interface.StopDataAcquisition();
    delete(gds_interface);
    clear gds_interface;
    clear gnautilus_config;
    close all;
end
