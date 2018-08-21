
pause(2);


tic;
d = RealTimeRecording(10);
toc;

% count = 0;
% for i = (1:7)
% [scans(i), ~] = gds_interface.GetData(0);
% end
% 
% tic
% while count  <= 500*5
%     [scans, ~] = gds_interface.GetData(0);
%     count = count + scans;
% end
% toc