% This is a function to record a section of data from g.Nautilus
% User MUST first initiate the device before calling this function!
% This function will return a matrix of data with the specified duration(in
% seconds) from the argument (default as 2 seconds)

function [out_data, mark] = RealTimeRecording(duration,To)

global state
state.device = true; % device connection?
state.acquisition = true; % data acquisition on?

% default case
if nargin == 0
    duration = 2;
end

% extra parameters
samplingRate = 500;
global gds_interface imgC imgBlank;

% clear the buffer
for i = (1:10)
[scans, ~] = gds_interface.GetData(0);
if scans < 20
    break
end
end

image(imgC);
title(To)
started = 0;
currentSample = 0;
while true
    [scans_received, data_received] = gds_interface.GetData(0);
    data(currentSample+1:currentSample+scans_received,:) = data_received;
    currentSample = currentSample + scans_received;
    % to find the starting point of stimuling
    
    if ~started
        for i = (1:size(data_received ,1))
            if ~data_received(i,34)
                started = 1;
                break
            end
        end
        if started
            for i = (1:size(data,1))
                if ~data(i,34)
                    started = i;
                    break
                end
            end
        end
    end
    
    if started && currentSample - started >= samplingRate * duration;

        image(imgBlank);
        title(To)
        break
    end
end

% out = data(started:started+samplingRate*duration-1 ,1:32);
out_data = data(:,1:32);
mark = started;
end