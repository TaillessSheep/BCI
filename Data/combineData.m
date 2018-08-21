% This is a function to combine the data in one recording
% (same recording different test with the same configuration:
% sampling rate; epoch duration; classNum; filters; Sensitivity)

function combineData(name)

count = 1; % counter for files with the same name

fileName = [name '_test1.mat'];
load(fileName);
Des = Description; % to record the standard Description
samples = Des.epoch.samples;

Csamples = 0;
Cmark = 0;

while exist(fileName, 'file')
    load(fileName); % load the next data set
    %% verify comfiguration
    check(1) = Des.classNum == Description.classNum;
    check(2) = Des.samplingRate == Description.samplingRate;
    check(3) = Des.epoch.duration == Description.epoch.duration;
    
    if (check)
    else
        msg = 'The data have different configuration in the following field: ';
        if ~check(1)
            msg = [msg 'calssNum, '];
        end
        if ~check(2)
            msg = [msg 'samplingRate, '];
        end
        if ~check(3)
            msg = [msg 'epochDuration.'];
        end
        error(msg);
    end
    
    %% combining
    trials = Description.trials;
    
    for t = (1:trials)
        new_data(Csamples + 1 : Csamples + samples,:) = data_received(mark(2,t):mark(2,t)+samples-1,1:32);
        new_mark(1, Cmark+1) = mark(1,t);
        new_mark(2, Cmark+1) = Csamples + 1;
        Csamples = Csamples + samples;
        Cmark = Cmark + 1;
    end
    
    
    %% preparation for next search
    count = count + 1;
    fileName = [name '_test' num2str(count) '.mat']; % name of file for next search
end

data_received = 0.1 * double(new_data);
mark = new_mark;
Description.trials = Cmark;
disp(['Combining done! Combined ' num2str(count - 1) ' files in total.']);
save(name,'data_received', 'mark', 'Description');

end