%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--Online Spectrum visualization--%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
clc; clear; close all; 
cd ('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\online_testing');

%% Initialize receiving data

addpath(genpath('C:\\Users\\Tim\\Downloads\\liblsl-Matlab'))
%ReceiveData
lib = lsl_loadlib();
result = lsl_resolve_byprop(lib,'type','EEG');
inlet = lsl_inlet(result{1});

%[ChunkData,Timestamps] = inlet.pull_chunk()
%[SampleData,Timestamp] = inlet.pull_sample(0)

%% Algorithm 1:
Nch = 14;         %number of sensors
n = 1000;       %number of samples in sliding window
Fs = 128;       %sample frequency
Fd = 10;       %display frequency
data_window = zeros(Nch,n);
time = 0;
time2 = time;
time3 = time;
for i=1:n
    data=[];
    while isempty(data) || (time2-time)<(1/Fs)
        [data,time2] = inlet.pull_sample(0);
    end
    data_window(:,n) = data(1:Nch)';
    time = time2;
end

figure
f = Fs*(0:n-1)/n;

while true  %loop while receiving signal
    data=[];
    while isempty(data) || (time2-time)<(1/Fs)
        [data,time2] = inlet.pull_sample(0);
    end
    time = time2;
    data_window(:,1:n-1) = data_window(:,2:n);   %shift down
    data_window(:,n) = data(1:Nch);
    if (time3-time)<(1/Fd)
        for ch =1:Nch
            xf = abs(fft(data_window(ch,:)))/n;
            subplot(Nch,1,ch);
            plot(f(1:n/2),xf(1:n/2));
            title(['Ch ' num2str(ch) ' in Frequency Domain']);
            xlabel('f (Hz)');
            ylabel('uV');
        end
        time3 = time;
        pause(1/(3*Fs));
    end
end

