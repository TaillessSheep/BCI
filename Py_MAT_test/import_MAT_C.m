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
wait = 0;
%% Main body

while(true)
    try
        load('pydata.mat');
        if pydata.check
            newData = pydata.data;
            wait = 0;
        else
            disp(wait);
            wait = wait + 1;
            pause(0.0001);
            
        end
    catch
        disp('Troblem reading ''pydata.mat''.')
        pause(0.01);
        continue;
    end
    
    % raw_data = importdata();
    y = wshift('1D',y,1);
    y(length(time))=newData;
    plot(time,y);
    drawnow
    
    pydata.check = false;
    save('pydata.mat','-struct','pydata')
end
