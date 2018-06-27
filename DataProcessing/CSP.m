% CSP

clc, clear all, close all;
%% adding sub-folder
addpath([pwd '\CSP_package'])

%% loading the dataset
Data = load('Data_CHE64_WMA_AW');
Train = Data.train;
Test = Data.test;
[TrCh,TrTime,TrTrial] = size(Train);
[TsCh,TsTime,TsTrial] = size(Test);
%% maybe we have a outlier in data set we use zscore to change these noises to normal face.
% for i = TrTrial
%     Train(:,:,i) = zscore(Train(:,:,i));
% end
%
% for i = TsTrial
%     Test(:,:,i) = zscore(Test(:,:,i));
% end
%% loading the labels
true_abels= load('true_labels_aw');
true_abels= true_abels.true_y;
%% put all the Train and Test set together and define how many Train and Test we want to take
Complete_Data(:,:,1:TrTrial) = Train;
Complete_Data(:,:,TrTrial+1:280) = Test;
TrTrial = 168;
TsTrial = 280 - TrTrial;
Train = Complete_Data(:,:,1:TrTrial);
Test = Complete_Data(:,:,TrTrial+1:280);
%% asigning labels to the data(split the TrainSet in two part to define different class
m=1; n=1;
for i= 1:TrTrial
    key = true_abels(1,i);
    switch key
        case 1
            Train_Class1(:,:,m)=Train(:,:,i);
            m = m+1;
        case 2
            Train_Class2(:,:,n)=Train(:,:,i);
            n=n+1;
    end
end
%% Getting the size of the Train_Class1 and Train_Class2
[~,~,Tr_C1] = size(Train_Class1);
[~,~,Tr_C2] = size(Train_Class2);
%% Determining cov for each classe
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
[V,D]=eig(Ave_cov_Train_Class1+Ave_cov_Train_Class2,Ave_cov_Train_Class1);
Wn(:,1)=V(:,1);
Wn(:,2)=V(:,end);

% base on 4 eigen value (4 stimulation)
% [V,D]=eig(Ave_cov_Train_Class1+Ave_cov_Train_Class2,Ave_cov_Train_Class1);
% Wn(:,1:2)=V(:,1:2);
% Wn(:,3:4)=V(:,end-1:end);

% base on 6 eigen value (4 stimulation)
% [V,D]=eig(Ave_cov_Train_Class1+Ave_cov_Train_Class2,Ave_cov_Train_Class1);
% Wn(:,1:3)=V(:,1:3);
% Wn(:,4:6)=V(:,end-2:end);

%% we want to multiple the train and test matrix toe the Whiteing matrix
for i= 1:TrTrial
    Arg_Ft_Tr(:,:,i)=Wn'*Train(:,:,i)*Train(:,:,i)'*Wn;
    Ft_Tr(:,i)= log ((diag(Arg_Ft_Tr(:,:,i)))/trace(Arg_Ft_Tr(:,:,i)));
end
Ft_Tr_Trainer= [ Ft_Tr;true_abels(1:1:TrTrial)]';

%% we want to prepare the test set
for i= 1:TsTrial
    Arg_Ft_Ts(:,:,i)=Wn'*Test(:,:,i)*Test(:,:,i)'*Wn;
    Ft_Ts(:,i)= log ((diag(Arg_Ft_Ts(:,:,i)))/trace(Arg_Ft_Ts(:,:,i)));
end


Accuracy_train = zeros(4,20);
Accuracy_test =  zeros(4,20);
%% Classification
%%%%%LDA
for k= 1:20
[TrainedLDA, validationAccuracy1] = LDA_CSP_COV_2eigChe64WMA(Ft_Tr_Trainer);
Accuracy_train(1,k)=validationAccuracy1;
LDAfit = TrainedLDA.predictFcn(Ft_Ts');
count = 0;

for i = 1:TsTrial
    if LDAfit(i,1) == true_abels(1,i+TrTrial)
        count = count + 1;
    else
    end
end
Accuracy_test(1,k)= count/TsTrial;
%%%%%QDA
[TrainedQDA,validationAccuracy2] =QDA_CSP_COV_2eigChe64WMA(Ft_Tr_Trainer);
Accuracy_train(2,k)=validationAccuracy2;
QDAfit = TrainedQDA.predictFcn(Ft_Ts');
count = 0;
for i = 1:TsTrial
    if QDAfit(i,1) == true_abels(1,i+TrTrial)
        count = count + 1;
    else
    end
end
Accuracy_test(2,k) = count/TsTrial;

%%%%%LR
[TrainedLogReg, validationAccuracy3] = LRA_CSP_COV_2eigChe64WMA(Ft_Tr_Trainer);
Accuracy_train(3,k) = validationAccuracy3;

LogRegfit = TrainedLogReg.predictFcn(Ft_Ts');
count = 0;

for i = 1:TsTrial
    if LogRegfit(i,1) == true_abels(1,i+TrTrial)
        count = count + 1;
    else
    end
end
Accuracy_test(3,k) = count/TsTrial;
%%%%%SWM
[TrainedSVM, validationAccuracy4] = SVM_CSP_COV_2eigChe64WMA(Ft_Tr_Trainer);
Accuracy_train(4,k) = validationAccuracy4;
SVMfit = TrainedSVM.predictFcn(Ft_Ts');
count = 0;

for i = 1: 1:TsTrial
    if SVMfit(i,1) == true_abels( 1,i+TrTrial)
        count = count + 1;
    else
    end
end
Accuracy_test(4,k) = count/TsTrial;

end
%%
LDA_MAX_train=max(Accuracy_train(1,:));
LDA_mean_train=mean(Accuracy_train(1,:));
LDA_STD_Train = std2(Accuracy_train(1,:));
LDA_MAX_TS=max(Accuracy_test(1,:));
LDA_mean_TS=mean(Accuracy_test(1,:));
%%
QDA_MAX_train=max(Accuracy_train(2,:));
QDA_mean_train=mean(Accuracy_train(2,:));
QDA_STD_Train = std2(Accuracy_train(2,:));
QDA_MAX_TS=max(Accuracy_test(2,:));
QDA_mean_TS=mean(Accuracy_test(2,:));
%%
LR_MAX_train=max(Accuracy_train(3,:));
LR_mean_train=mean(Accuracy_train(3,:));
LR_STD_Train = std2(Accuracy_train(3,:));
LR_MAX_TS=max(Accuracy_test(3,:));
LR_mean_TS=mean(Accuracy_test(3,:));

%%
SWM_MAX_train=max(Accuracy_train(4,:));
SWM_mean_train=mean(Accuracy_train(4,:));
SWM_STD_Train = std2(Accuracy_train(4,:));
SWM_MAX_TS=max(Accuracy_test(4,:));
SWM_mean_TS=mean(Accuracy_test(4,:));















