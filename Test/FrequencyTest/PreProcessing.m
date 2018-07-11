%%%%%%%%%%%%%%%%% Pre-Processing%%%%%%%%%%%%%%%%%
clc; clear;% close all;

%% adding sub-folder
addpath([pwd '\Preprocessing_package'])

%% Loading DataSet
load('data_set_IVa_aa.mat');
cnt=0.1*double(cnt);
%% Define the Filter here
filt = MahsaFilter;
Nch=118;
pos=mrk.pos;                                                       %moment which stimulation is started for each trial
type=mrk.y;                                                          % in which trial which class is happend

Wtrain_set=zeros(118,3500,length(type)-sum(isnan(type)));
Wtest_set = zeros(118, 3500, sum(isnan(type)));
disp('loaded')

% train=zeros(118,350,length(type)-sum(isnan(type)));
% test = zeros(118, 350, sum(isnan(type)));
label=[1,2];
%% Split the DataSet for preparing in regards applying filter
%before starting the second one (3499)
%transpose bec of the invers plate
temp=pos(isnan(type));                                       %find isnan and it is my test
for i=1:length(temp)
    Wtest_set(:,:,i) = cnt(temp(i):temp(i)+3499,:)';
end

temp=pos(~isnan(type));                                     %find not isnan and it is my train
for i=1:length(temp)
    Wtrain_set(:,:,i) = cnt(temp(i):temp(i)+3499,:)';
end

%% Hint:For each function we have to know what is the input(vector or matrix)
%% Filtering DataSet - Define the Filter here
% 1- using the filterdesigner/fdatool in command
% 2- save the filter as a m file from File>> Generate Matlab code and Save as fdp file
% 3- put the name of the filter at the first of the code
for i = 1:size(Wtrain_set,3)
    for j = 1:size(Wtrain_set,1)
        ftrain_set(j,:,i) = filter(filt, Wtrain_set(j,:,i));
    end
end
for i = 1:size(Wtest_set,3)
    for j = 1:size(Wtest_set,1)
        ftest_set(j,:,i) = filter(filt, Wtest_set(j,:,i));
    end
end

% save(['FilterCHE64_Dataset_al'], 'ftest_set', 'ftrain_set');      %Saving the Filter
%% Drawing Initial TrainSet before applying Filter
% figure('name','Raw Data')
W=mean(Wtrain_set,3);
% for kk=1:118
% A=fft(W(kk,:));
% hold on
%  plot (abs(A))
% end
%% *
figure('name','Raw Data')
fs = 1000;
N = 3500;
for ch = (1:118)
    t = W(ch,:);
    t = t - mean(t);
    t = t/max(abs(t));
    X_mags = abs(fft(t));
    bin_vals = [0 : N-1];
    fax_Hz = bin_vals*fs/N;
    N_2 = ceil(N/2);
    plot(fax_Hz(1:N_2), X_mags(1:N_2))
    hold on
end
title('Initial Data(Signal) for Subject AA')
xlabel('Frequency (Hz)')
xlim([2 49]);



%% Drawing TrainSet after applying Filter
% figure('name','After Filtering')
W=mean(ftrain_set,3);
% for jj=1:118
% A=fft(W(jj,:));
% hold on
%  plot(abs(A))
% end
% title('TrainSet of Subject AA by applying MFilter Chebyshev2 order64 FC 8~30')
% xlabel('Frequency (Hz)')
% xlim([2 100]);
%% *
fs = 1000;
N = 3500;
figure('name','After Filtering')
for ch = (1:118)
    t = W(ch,:);
    t = t - mean(t);
    t = t/max(abs(t));
    X_mags = abs(fft(t));
    bin_vals = [0 : N-1];
    fax_Hz = bin_vals*fs/N;
    N_2 = ceil(N/2);
    plot(fax_Hz(1:N_2), X_mags(1:N_2))
    hold on
end
title('TrainSet of Subject AA by applying MFilter Chebyshev2 order64 FC 8~30')
xlabel('Frequency (Hz)')
xlim([2 49]);


%% Smoothening The dataset  % soft the outlier data for electords
% load('FilterCHE64_Dataset_al');
for i=1:size(ftest_set,3)
    for j= 1:size(ftest_set,2)
        for k= 1:size(ftest_set,1)
            val=ftest_set(k,j,i);
            if (isnan(val)==1  || isinf(val)==1)
                ftrain_set(k,j,i) = 0;
            else
            end
        end
    end
end


for i = 1:size(ftrain_set,3)
    for j = 1:size(ftrain_set,2)
        for k = 1:size(ftrain_set,1)
            val = ftrain_set(k,j,i);
            if ( isnan(val)==1 || isinf(val)==1 )
                ftrain_set(k,j,i) = 0;
            else
            end
        end
    end
end


%% Prepearing for Downsampling (best one is simple moving average and Weighted Moving Average)
%reduse the resolution
% Defining the mode
% 0: No smoothening, 1: Moving Median, 2: Simple Moving Average, 3: Weighted Moving Average
ModeSmoothening = 3;
WindowSize = 1;                                                 % if small no effect if big bluring for data

switch (ModeSmoothening)
    case 0
        % Nothing Happens like Random Sample
        Wtrain_set = ftrain_set;
        Wtest_set = ftest_set;
        
    case 1
        [ Wtrain_set ,Wtest_set ] = Moving_Median( ftrain_set, ftest_set);
    case 2
        [ Wtrain_set ,Wtest_set ] = Simple_Moving_Average( WindowSize,ftrain_set,ftest_set );
    case 3
        [ Wtrain_set ,Wtest_set ] = EXPWeighted_Moving_Average( WindowSize,ftrain_set,ftest_set );
end

%% Drawing The output after applying preparing filter
% W=mean(Wtrain_set,3);
% for kk=1:118
% A=fft(W(kk,:));
% hold on
%  plot(abs(A))
% end
% title('Smoothing by EXPWeighted Moving Average')
% xlabel('Frequency (Hz)')
% xlim([2 100]);
%% Downsampling % we want to take each 10

[ train, test ] = Simple_Downsampling( Wtrain_set, Wtest_set );
% save('Data_CHE64_WMA_AY.mat', 'test', 'train');

%% Drawing The output after applying Downsampling
% figure('name','After Downsampling')
W=mean(train,3);
% for kk=1:118
% A=fft(W(kk,:));
% hold on
%  plot(abs(A))
% end
% title('Applying Downsampleing on train')
% xlabel('Frequency (Hz)')
% xlim([2 100]);
%% *
fs = 100;
N = 350;
figure('name','After Downsampling')
for ch = (1:118)
    t = W(ch,:);
    t = t - mean(t);
    t = t/max(abs(t));
    X_mags = abs(fft(t));
    bin_vals = [0 : N-1];
    fax_Hz = bin_vals*fs/N;
    N_2 = ceil(N/2);
    plot(fax_Hz(1:N_2), X_mags(1:N_2))
    hold on
end
xlim([2 49]);
title('Applying Downsampleing on train')
xlabel('Frequency (Hz)')