% Pre-Processing

clc; clear; close all; 
%% adding sub-folder
addpath([pwd '\PreProcessing_package
    
for i=1:length(temp)
test_set(:,:,i) = cnt(temp(i):temp(i)+3499,:)';    
end

temp=pos(~isnan(type));                                     %find not isnan and it is my train
for i=1:length(temp)
train_set(:,:,i) = cnt(temp(i):temp(i)+3499,:)';
end

%% Hint:For each function we have to know what is the input(vector or matrix)
%% Filtering DataSet - Define the Filter here
% 1- using the filterdesigner/fdatool in command
% 2- save the filter as a m file from File>> Generate Matlab code and Save as fdp file
% 3- put the name of the filter at the first of the code
for i = 1:size(train_set,3)
    for j = 1:size(train_set,1)
        ftrain_set(j,:,i) = filter(filt, train_set(j,:,i));
    end
end
for i = 1:size(test_set,3)
    for j = 1:size(test_set,1)
        ftest_set(j,:,i) = filter(filt, test_set(j,:,i));
    end
end

% save(['FilterCHE64_Dataset_al'], 'ftest_set', 'ftrain_set');      %Saving the Filter
%% Drawing Initial TrainSet before applying Filter
W=mean(train_set,3);
for kk=1:118
A=fft(W(kk,:));
hold on
 plot (abs(A))
end
title('Initial Data(Signal) for Subject AA')
xlabel('Frequency (Hz)')
xlim([2 100]);

%% Drawing TrainSet after applying Filter
W=mean(ftrain_set,3);
for jj=1:118
A=fft(W(jj,:));
hold on
 plot(abs(A))
end
title('TrainSet of Subject AA by applying MFilter Chebyshev2 order64 FC 8~30')
xlabel('Frequency (Hz)')
xlim([2 100]);

%% Smoothening The dataset  % soft the outlier data for electords
% load('FilterCHE64_Dataset_al');
for i=1:size(ftest_set,3);
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
        [ train_set ,test_set ] = Moving_Median( ftrain_set, ftest_set);
    case 2
        [ train_set ,test_set ] = Simple_Moving_Average( WindowSize,ftrain_set,ftest_set );
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
save('Data_CHE64_WMA_AY.mat', 'test', 'train');

%% Drawing The output after applying Downsampling

W=mean(train,3);
for kk=1:118
A=fft(W(kk,:));
hold on
 plot(abs(A))
end
title('Applying Downsampleing on train')
xlabel('Frequency (Hz)')
xlim([2 100]);
