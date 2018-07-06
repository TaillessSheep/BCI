% To record data

%% Count Down & Buffer Clearing
tic;
pre = toc;
cur = toc;


image(imgC);
set(gcf, 'Position', get(0, 'Screensize'));
drawnow();

% count down
for i = (5:-1:-1)
    if i > 0
        title(i);
    else
        title('FOR THE SAKE OF HUMANITY!!!');
    end
    while(cur - pre <= 1)
        cur = toc;
        [scans_received_dum, data_dum] = gds_interface.GetData(0);
    end
    pre = cur;
end

%% Recording
mark = randGen(trialNum);
sampleCurrent = 0;  % current sample index
discard_count = 0;

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