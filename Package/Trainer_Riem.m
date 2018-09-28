%% This is the general and the basic code for the Riemannian techniqueclear;
clear;clc; 

name = 'Mahsa_Aug_30_18';
%% loading the dataset
name_prepro = [name '_prepro'];
load(name_prepro);

% name = 'ha';
% load('DataSet_Mahsa_Sep1st_2Feat.mat');
% load('Labels_Mahsa_Sep1st_2feat.mat');
Trimming = 750;
numRand = 20;

metric_mean = {'euclid','logeuclid','riemann','ld'};
metric_dist = {'euclid','logeuclid','riemann','ld','kullback'};
acc = zeros(length(metric_mean),length(metric_dist),numRand);

% data = DataSetMahsa_2Feature;
% Labels = LabelsSetMahsa_Sep1st_2Feature;


data = data(:,1:Trimming,:);

covData = zeros(32,32,1);
for i=1:size(data,3)
    covData(:,:,i) = cov(data(:,:,i)');
end


for randTest = (1:numRand)
    disp(randTest)
    
    index = randperm(size(data,3));
    trainInd = index(1:round(0.7*size(data,3)));
    testInd = index(round(0.7*size(data,3))+1:end);
    
    Ytrain = Labels(trainInd);
    trueYtest = Labels(testInd);
    COVtrain = covData(:,:,trainInd);
    COVtest = covData(:,:,testInd);
    
    
    %% MDM classification - Multiclass
    
    
    for i=1:length(metric_mean)
        for j=1:length(metric_dist)
            Ytest = mdm(COVtest,COVtrain,Ytrain,metric_mean{i},metric_dist{j});
            acc(i,j,randTest) = 100*mean(Ytest==trueYtest);
            %         acc(i,j) = 100*mean(Ytest==trueYtest);
        end
    end
end
AA = mean(acc,3);
disp('------------------------------------------------------------------');
disp('Accuracy (%) - Rows : distance metric, Colums : mean metric');
disp('------------------------------------------------------------------');
displaytable(AA',metric_mean,10,{'.1f'},metric_dist)
disp('------------------------------------------------------------------');

% to find the combination with highest accuracy
[V1, I1] = max(AA);
[V2, I2] = max(V1);
max_value = V2;
max_index = [I2 I1(I2)];

e
metric_mean_opt = metric_mean;
metric_mean = metric_mean{max_index(2)};
metric_dist_opt = metric_dist;
metric_dist = metric_dist{max_index(1)};

% saving data
name_output = [name '_classifier_Riem'];
save(['../Classifiers/' name_output], 'covData', 'Labels', 'metric_mean', ...
     'metric_dist', 'metric_mean_opt', 'metric_dist_opt', 'max_value','Trimming');
 
disp([name '_classifier'])