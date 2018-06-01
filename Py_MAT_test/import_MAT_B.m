% Reads the data from pydata.mat file
% Update the variable y
% And update the plot of y against time

%% Parameters
max_record = 1000;
sig_magni_max = 2;
sig_magni_min = -2;
%% Setup
time = (-(max_record-1):0);
y = ones(1,max_record);
%% Main body

while(true)
    try
        load('pydata.mat');
    catch
        disp('Troblem reading ''pydata.mat''.')
%         pause(0.01);
        continue;
    end
    
    % raw_data = importdata();
    y = wshift('1D',y,1);
    disp(pydata.data);
    y(max_record)=pydata.data;
    plot(time,y);
    axis([-(max_record-1) 0 sig_magni_min sig_magni_max]);
    drawnow
    pause (0.0005)
end
