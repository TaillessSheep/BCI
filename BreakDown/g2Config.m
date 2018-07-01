% To set the configuration

samplingRate = 500; % sampling frequency
bufferSize = 10;    % amount of samples (for each channel) matlab pull out from the headset
% common divisor of epochSample and breakSample


BandpassIndex = 36;
NotchIndex = 3;
SensitivityIndex = 6;


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