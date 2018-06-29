% To record data

%% preparation clearing out the buffer

pre = toc;
cur = toc;

for i = (5:-1:0)
    while(cur - pre < 1)
        cur = toc;
        try
            [scans_received_dum, data_dum] = gds_interface.GetData(8);
        catch ME
            disp(ME.message);
            break;
        end
    end
    if i == 0
        disp('for the sake of humanity!');
    else
        disp(i);
    end
    pre = cur;
end


%% starting recording
samples_acquired = 0;
% NOTE: the line below is for a 32-channel g.Nautilus device. If a 8-,
% 16- or 64-channel is used the code below has to be changed to
% 8-channel: data_received = single(zeros(2500, 10));
% 16-channel: data_received = single(zeros(2500, 18));
% 64-channel: data_received = single(zeros(2500, 66));
data_received = single(zeros(5000, 34));
while (samples_acquired < 5000)
    try
        [scans_received, data] = gds_interface.GetData(8);
        data_received((samples_acquired + 1) : (samples_acquired + scans_received), :) = data;
    catch ME
        disp(ME.message);
        break;
    end
    samples_acquired = samples_acquired + scans_received;
end
