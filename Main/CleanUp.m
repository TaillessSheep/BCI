% clean up scrpt
global state gds_interface wall_e
disp('Program terminated. Cleaning up.')
if state.acquisition
    gds_interface.StopDataAcquisition();
    disp('Acquisition stoped.')
end

if state.device
    delete(gds_interface);
    disp('Device disconnected.')
end

try 
    delete(wall_e);
catch
end
clear gds_interface;
clear gnautilus_config;