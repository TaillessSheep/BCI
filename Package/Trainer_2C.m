%% Using Best Option that we got and applying on data and TestSet
clc; clear; close all;

name = 'Will_Aug_27_18';
%% loading the dataset
name_prepro = [name '_prepro12'];
load(name_prepro);

Trimming = 150;
% TrTrial = 300;

data = data(:,1:Trimming,:);

[numCh,TmSm,TrTrial] = size(data);

%% asigning labels to the data(split the TrainSet in two part to define different class
Train_Class1 = zeros(numCh,Trimming);
Train_Class2 = zeros(numCh,Trimming);
m=1; n=1;
for i= 1:TrTrial
    key = Labels(1,i);
    switch key
        case 1
            Train_Class1(:,:,m)=data(:,:,i);
            m = m+1;
        case 2
            Train_Class2(:,:,n)=data(:,:,i);
            n=n+1;
    end
end

[~,~,Tr_C1] = size(Train_Class1);
[~,~,Tr_C2] = size(Train_Class2);

%% Determining cov for each classe
cov_Train_Class1 = zeros(numCh,numCh);
cov_Train_Class2 = zeros(numCh,numCh);
for i= 1:Tr_C1
    cov_Train_Class1(:,:,i)= (Train_Class1(:,:,i)*Train_Class1(:,:,i)')/trace(Train_Class1(:,:,i)*Train_Class1(:,:,i)');
end

for i= 1:Tr_C2
    cov_Train_Class2(:,:,i)=  (Train_Class2(:,:,i)*Train_Class2(:,:,i)')/trace(Train_Class2(:,:,i)*Train_Class2(:,:,i)');
end

%% averaging for the cov for each class
tempp= cov_Train_Class1(:,:,1);
for i= 2: Tr_C1
    tempp=tempp+ cov_Train_Class1(:,:,i);
end
Ave_cov_Train_Class1= tempp/Tr_C1;

tempp= cov_Train_Class2(:,:,1);
for i= 2: Tr_C2
    tempp=tempp+ cov_Train_Class2(:,:,i);
end
Ave_cov_Train_Class2= tempp/Tr_C2;

%% We define the whitenning matrix base on 2 eigen value that we have     matrix=eig(c1+c2,c1)
% base on 6 eigen value (4 stimulation)
[V,D]=eig(Ave_cov_Train_Class1+Ave_cov_Train_Class2,Ave_cov_Train_Class1);
    Wn(:,1:3)=V(:,1:3);
    Wn(:,4:6)=V(:,end-2:end);

%% we want to multiple the train and test matrix toe the Whiteing matrix
for i= 1:TrTrial
    Arg_Ft_Tr(:,:,i)=Wn'*data(:,:,i)*data(:,:,i)'*Wn;
    Ft_Tr(:,i)= log ((diag(Arg_Ft_Tr(:,:,i)))/trace(Arg_Ft_Tr(:,:,i)));
end

Ft_Tr_Trainer= [ Ft_Tr;Labels]';

%% Classification
%LDA
[Classifier, ~] = LDA_6Eig_V1(Ft_Tr_Trainer);
disp('New classifier trained!')
save(['../Classifiers/' name '_classifer'], 'Wn', 'Classifier')