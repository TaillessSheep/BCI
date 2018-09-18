%% This is the general and the basic code for the Riemannian technique
clc; clear all;

oldpath = cd;
%cd('E:\Research\Datasets\BCICIV_IIa')
load('DataSet_Mahsa_Sep1st_2Feat.mat');
load('Labels_Mahsa_Sep1st_2feat.mat');
Trimming = 500;
numRand = 1;
metric_mean = {'euclid','logeuclid','riemann','ld'};
metric_dist = {'euclid','logeuclid','riemann','ld','kullback'};
acc = zeros(length(metric_mean),length(metric_dist),numRand);


for randTest = (1:numRand)
    disp(randTest)

data = DataSetMahsa_2Feature;
Labels = LabelsSetMahsa_Sep1st_2Feature;
Labels = Labels-1;


data = data(:,1:Trimming,:);

covData = zeros(32,32,1);
for i=1:size(data,3)
    covData(:,:,i) = cov(data(:,:,i)');
end

index = randperm(size(data,3));
trainInd = index(1:0.7*size(data,3));
testInd = index((0.7*size(data,3))+1:end);

Ytrain = Labels(trainInd);
trueYtest = Labels(testInd);
COVtrain = covData(:,:,trainInd);
COVtest = covData(:,:,testInd);

% TrTrial = 200;
% TsTrial = 300 - TrTrial; 
% 
% index = randperm(size(data,3));
% trainInd = index(Random(1:TrTrial));
% testInd = index(Random(TrTrial+1:end));




%%
% TrTrial = 200;
% TsTrial = 300 - TrTrial;  
% % Shuffeling DataSet
% Random = randperm(300);
% Random = Random';
%     
% Train = zeros(numCh,Trim,TrTrial);
% Train(:,:,:) = data(:,1:Trim,(Random(1:TrTrial)));
% Train_lable = Labels(Random(1:TrTrial));
%     
%     
% Test = zeros(numCh,Trim,TsTrial);
% Test(:,:,:) = data(:,1:Trim,(Random(TrTrial+1:end)));
% Test_lable = Labels(Random(TrTrial+1:end));
% 
% Ytrain = Train_lable;
% trueYtest = Test_lable;
% trainInd = TrTrial;
% testInd = TsTrial;
% COVtrain = covData(:,:,trainInd);
% COVtest = covData(:,:,testInd);



% Data formating
% COVtest = data.data(:,:,data.idxTest);
% trueYtest  = data.labels(data.idxTest);
% 
% COVtrain = data.data(:,:,data.idxTraining);
% Ytrain  = data.labels(data.idxTraining);

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



%% Discriminant geodesic filtering + MDM classification - Multiclass
% metric_mean = {'euclid','logeuclid','riemann','ld'};
% metric_dist = {'euclid','logeuclid','riemann','ld','kullback'};
% acc = zeros(length(metric_mean),length(metric_dist));
% 
% for i=1:length(metric_mean)
%     for j=1:length(metric_dist)
%         Ytest = fgmdm(COVtest,COVtrain,Ytrain,metric_mean{i},metric_dist{j});
%         acc(i,j) = 100*mean(Ytest==trueYtest);
%     end
% end
% disp('------------------------------------------------------------------');
% disp('Accuracy (%) - Rows : distance metric, Colums : mean metric');
% disp('------------------------------------------------------------------');
% displaytable(acc',metric_mean,10,{'.1f'},metric_dist)
% disp('------------------------------------------------------------------');

%% MDM classification - Binary case
% metric_mean = 'riemann';
% metric_dist = 'riemann';
% acc = diag(nan(4,1));
% 
% i=0 ; j=1;
%         % Select the trials
%         ixtrain = (Ytrain==i)|(Ytrain==j);
%         ixtest = (trueYtest==i)|(trueYtest==j);
%         % Classification
%         Ytest = mdm(COVtest(:,:,ixtest),COVtrain(:,:,ixtrain),Ytrain(ixtrain),metric_mean,metric_dist);
%         % Accuracy
%         acc(i,j) = 100*mean(Ytest==trueYtest(ixtest));
% 
% 
% disp('------------------------------------------------------------------');
% disp('Accuracy (%) - Rows/Colums : Couple of classes');
% disp('------------------------------------------------------------------');
% displaytable(acc'+acc,{'Right Hand','Left Hand','Foot','Tongue'},10,{'.1f'},{'Right Hand','Left Hand','Foot','Tongue'})
% disp('------------------------------------------------------------------');
% 
%% Discriminant geodesic filtering + MDM Classification - Binary case
% metric_mean = 'riemann';
% metric_dist = 'riemann';
% acc = diag(nan(4,1));
% 
% for i=1:4
%     for j=i+1:4
%         % Select the trials
%         ixtrain = (Ytrain==i)|(Ytrain==j);
%         ixtest = (trueYtest==i)|(trueYtest==j);
%         % Classification
%         Ytest = fgmdm(COVtest(:,:,ixtest),COVtrain(:,:,ixtrain),Ytrain(ixtrain),metric_mean,metric_dist);
%         % Accuracy
%         acc(i,j) = 100*mean(Ytest==trueYtest(ixtest));
%     end
% end

% disp('------------------------------------------------------------------');
% disp('Accuracy (%) - Rows/Colums : Couple of classes');
% disp('------------------------------------------------------------------');
% displaytable(acc'+acc,{'Right Hand','Left Hand','Foot','Tongue'},10,{'.1f'},{'Right Hand','Left Hand','Foot','Tongue'})
% disp('------------------------------------------------------------------');

%% Kmeans usupervised Classification - Binary case
% metric_mean = 'riemann';
% metric_dist = 'riemann';
% acc = diag(nan(4,1));
% 
% % for each couple of classes
% for i=1:4
%     for j=i+1:4
%         % Select the trials
%         ixtrain = (Ytrain==i)|(Ytrain==j);
%         ixtest = (trueYtest==i)|(trueYtest==j);
%         % Classification
%         Ytest = kmeanscov(COVtest(:,:,ixtest),COVtrain(:,:,ixtrain),2,metric_mean,metric_dist);
%         % Find the right labels
%         Classes = unique(trueYtest(ixtest));
%         truelabels = (trueYtest(ixtest) == Classes(1))+1;
%         % Accuracy
%         acc(i,j) = 100*mean(Ytest==truelabels);
%         if acc(i,j)<50
%             acc(i,j) = 100-acc(i,j);
%         end
%     end
% end
% 
% disp('------------------------------------------------------------------');
% disp('Accuracy (%) - Rows/Colums : Couple of classes');
% disp('------------------------------------------------------------------');
% displaytable(acc'+acc,{'Right Hand','Left Hand','Foot','Tongue'},10,{'.1f'},{'Right Hand','Left Hand','Foot','Tongue'})
% disp('------------------------------------------------------------------');
% 
%% Tangent Space LDA Classification - Binary case
% the riemannian metric
% metric_mean = 'riemann';
% % update tangent space for the test data - necessary if test data corresponds to
% % another session. by default 0.
% update = 0;
% acc = diag(nan(4,1));
% 
% for i=1:4
%     for j=i+1:4
%         % Select the trials
%         ixtrain = (Ytrain==i)|(Ytrain==j);
%         ixtest = (trueYtest==i)|(trueYtest==j);
%         % Classification
%         Ytest = tslda(COVtest(:,:,ixtest),COVtrain(:,:,ixtrain),Ytrain(ixtrain),metric_mean,update);
%         % Accuracy
%         acc(i,j) = 100*mean(Ytest==trueYtest(ixtest));
%     end
% end
% 
% disp('------------------------------------------------------------------');
% disp('Accuracy (%) - Rows/Colums : Couple of classes');
% disp('------------------------------------------------------------------');
% displaytable(acc'+acc,{'Right Hand','Left Hand','Foot','Tongue'},10,{'.1f'},{'Right Hand','Left Hand','Foot','Tongue'})
% disp('------------------------------------------------------------------');