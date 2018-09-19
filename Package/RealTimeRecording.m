% This is a function to record a section of data from g.Nautilus
% User MUST first initiate the device before calling this function!
% This function will return a matrix of data with the specified duration(in
% seconds) from the argument (default as 2 seconds)

function [out_data, mark] = RealTimeRecording(epochSamples,To,label, pIndex)

global state
state.device = true; % device connection?
state.acquisition = true; % data acquisition on?

% extra parameters

global gds_interface imgC imgBlank imgL imgR;

% clear the buffer
for i = (1:10)
[scans, ~] = gds_interface.GetData(0);
if scans < 20
    break
end
end

% image(imgC);
if label == 1
    image(imgL)
else
    image(imgR)
end
title(To)
started = 0;
currentSample = 0;
while true
    [scans_received, data_received] = gds_interface.GetData(0);
    data(currentSample+1:currentSample+scans_received,:) = data_received;
    
    % to find the starting point of stimuling
    
    if ~started
        for i = (1:size(data_received ,1))
            if data_received(i,34) % if record while black ~
                started = currentSample + i;
                break
            end
        end
%         if started
%             for i = (1:size(data,1))
%                 if data(i,34)      % if record while black ~
%                     started = i;
%                     break
%                 end
%             end
%         end
    end
    currentSample = currentSample + scans_received;
    
    if started && currentSample - started >= epochSamples
        image(imgC)
        title(To)
        drawnow
        break
    end
end

% out = data(started:started+samplingRate*duration-1 ,1:32);
out_data = data(:,1:32);
mark = started;
end