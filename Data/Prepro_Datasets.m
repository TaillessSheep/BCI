% Data pre-processing script
% preprocess the files with the same given prefix of file name

clc; clear; close all;
%% parameters
name = 'KunYi_Sept_19_18B';

NumCh = 32;
timeSample = 1500;
LabelOffset = 0;

%% preparation
addpath('../main');
% names for different files
% prefix = [name '_test']; % prefix for data files need to be read
prefix = [name '_test'];
name_save = [name '_prepro'];% name of the file to save


% look for all raw data file with the given prefix
files = what('.');
files = files.mat;
nIndex = 1;
for i = (1:length(files))
    if (startsWith(files{i},prefix))
        dataFiles{nIndex} = files{i};
        nIndex = nIndex + 1;
    end
end
if(nIndex == 1)
    error('Can not find any data file with the given prefix.');
end
dataFiles_num = length(dataFiles);

% containers for later use
POS = [];
SIP_Labels1 = [];
DATA = [];
L = 0;

for f = (1:dataFiles_num)
    load(dataFiles{f}); % loading data
    Data_received(f).RAW =0.1*double(data_received);
    POS = cat(2,POS,mark(2,:) + L);
    SIP_Labels1 = cat(2,SIP_Labels1,mark(1,:));
    L = L + length(Data_received(f).RAW);
    
    %% filtering
    Data_received(f).BPF = filtering(Data_received(f).RAW);

    %% Combining data
    DATA = cat(1,DATA,Data_received(f).BPF);
    
end

%% Lables:
Labels = SIP_Labels1 + LabelOffset;

%% Defining DataSet
% we should define duration of each epoch % here is 1000
for i=1:length(Labels)
DataSet(:,:,i) = DATA(POS(i):POS(i)+timeSample-1,:)';    
end
data = DataSet(1:NumCh,:,:);
save(name_save, 'data', 'Labels');
disp(['Done! Preprocessed ' num2str(dataFiles_num) ' files.']);
disp([num2str(length(Labels)) ' trials detected.'])

