clear;
clc;

%% Paramater
max_record = 1000;
sig_magni_max = 2;
sig_magni_min = -2;

%% Setup
fileName = 'emotiv_values_2018_05_30_14_44_12643900';
fileName = [fileName '.csv'];

time = (-(max_record-1):0);
titles = {'F3' 'FC5' 'F7' 'T7' 'P7' 'O1' 'O2' 'P8' 'T8' 'F8' 'AF4' 'FC6' 'F4' 'AF3'};
for i = (1:8)
    y.(string(titles(i))) = ones(1,max_record);
    y.(string(titles(i)))(:) = 4050;
end

row = 2; % current node in the excl sheet

%% Main loop
while true
    data = xlsread(fileName, 'B' + string(row) + ':P' + string(row));
    row = row + 1;
    data = data(1:2:15);
    disp(data);
    for i = (1:8)
        y.(string(titles(i))) = wshift('1D',y.(string(titles(i))),1);
        y.(string(titles(i)))(max_record) = data(i);
        subplot(8,1,i);
        plot(time,y.(string(titles(i))));
        title(titles(i));
%         axis([-(max_record-1) 0 sig_magni_min sig_magni_max]);
        drawnow
    end
end
