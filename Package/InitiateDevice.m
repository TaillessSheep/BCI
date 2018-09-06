% Starter script for g.Nautilus
% This script will initiate the device, set configuration, and initiate
% data acquisition
    
%% Parameter Set up
% Descrition of the signal(will be saved along with the data)
load configOptions;
Description.samplingRate = samplingRate;
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


%% gds_interface setup
global gds_interface imgC imgBlank imL imR state;
% loading images
imgC = imread('C.png');
imgBlank = imread('Blank.png');
imL = imread('C4_LH.png');
imR = imread('C4_RH.png');

% create gtecDeviceInterface object

gds_interface = gtecDeviceInterface();

% define connection settings (loopback)
gds_interface.IPAddressHost = '127.0.0.1';
gds_interface.IPAddressLocal = '127.0.0.1';
gds_interface.LocalPort = 50224;
gds_interface.HostPort = 50223;

% get connected devices
connected_devices = gds_interface.GetConnectedDevices();
state.device = true; % device connection?
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
gnautilus_config.NumberOfScans = 0;
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

%% Data Acquisition Initiation
disp('Starting data acquisition.');
% start data acquisition
gds_interface.StartDataAcquisition();
warning('off','gtecMATLABAPI:DAQErrorWarning');
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

% opening window for cue image
close all;
image(imgBlank);
set(gcf, 'Position', get(0, 'Screensize'));