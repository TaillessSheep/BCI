clear;clc;

name = 'Will_Aug_27_18';
Existed_prepro = false;
addpath('../Data')
Existed_Data = what('../Data');
Existed_Data = Existed_Data.mat;
name_prepro = [name '_prepro.mat'];
for i = (1:length(Existed_Data))
    if strcmp(Existed_Data{i}, name_prepro)
        Existed_prepro = true;
        break
    end
end

if ~Existed_prepro
    error('Can not find the preprocessed data file.');
end
load(['../Data/' name_prepro])

numClass = max(Labels);
% separate data by classes
data_by_class.count = 0;
for i = (1:length(Labels))
    data_by_class(i).count = data_by_class(i).count + 1;
    data_by_class(i).data(:,:,data_by_class(i).count) = data(:,:,i);
end