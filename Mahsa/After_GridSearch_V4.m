%% Using Best Option that we got and applying on Train and TestSet
clc; clear; close all;

load('KunYi_Sept_19_18B_prepro');

[numCh,TmSm,numTr] = size(data);

Trimming = 1500;
TrTrial = round(numTr*0.7);
TsTrial = numTr - TrTrial;

overall = 1;

randTest = 1;
disp(randTest)

% Shuffeling DataSet
% Random = randperm(TrTrial);
% Random = Random';

Train = zeros(numCh,Trimming,TrTrial);
Train(:,:,:) = data(:,1:Trimming,1:TrTrial);
Train_lable = Labels(1:TrTrial);
% Train(:,:,:) = Train(:,:,Random);
% Train_lable = Train_lable(Random);


Test = zeros(numCh,Trimming,TsTrial);
Test(:,:,:) = data(:,1:Trimming,TrTrial+1:end);
Test_lable = Labels(TrTrial+1:end);

%% Testing for making sure that shuffeling is currect
% count = 0;
% for i = (1:TrTrial)
%     if Labels(Random(i)) == Train_lable(i)
%         count = count + 1;
%     end
% end
% if (count ~= TrTrial)
%     error('Labels not match in Trial set');
% end
%
% count = 0;
% for i = (1:TsTrial)
%     if Labels(Random(TrTrial+i)) == Test_lable(i)
%         count = count + 1;
%     end
% end
% if (count ~= TsTrial)
%     error('Labels not match in Test set');
% end

%% asigning labels to the data(split the TrainSet in two part to define different class
Train_Class1 = zeros(numCh,Trimming);
Train_Class2 = zeros(numCh,Trimming);
m=1; n=1;
for i= 1:TrTrial
    key = Train_lable(1,i);
    switch key
        case 1
            Train_Class1(:,:,m)=Train(:,:,i);
            m = m+1;
        case 2
            Train_Class2(:,:,n)=Train(:,:,i);
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
    Arg_Ft_Tr(:,:,i)=Wn'*Train(:,:,i)*Train(:,:,i)'*Wn;
    Ft_Tr(:,i)= log ((diag(Arg_Ft_Tr(:,:,i)))/trace(Arg_Ft_Tr(:,:,i)));
end

Ft_Tr_Trainer= [ Ft_Tr;Train_lable]';


%% we want to prepare the test set
for i= 1:TsTrial
    Arg_Ft_Ts(:,:,i)=Wn'*Test(:,:,i)*Test(:,:,i)'*Wn;
    Ft_Ts(:,i)= log ((diag(Arg_Ft_Ts(:,:,i)))/trace(Arg_Ft_Ts(:,:,i)));
end

%% Classification
%LDA
[TrainedLDA, validationAccuracy1] =LDA_6Eig_V1(Ft_Tr_Trainer);
Accuracy_train=validationAccuracy1;
[LDAfit, p_t,~] = TrainedLDA.predictFcn(Ft_Ts');
count = 0;

Final_p(randTest).count = 0;

for i = 1:TsTrial
    p(i) = p_t(i,LDAfit(i,1));
    if LDAfit(i,1) == Test_lable(i)
        count = count + 1;
    end
%     if p(i) < 0.8
%         Final_p(randTest).count = Final_p(randTest).count + 1;
%         Final_p(randTest).L_index(Final_p(randTest).count) = Random(i + TrTrial);
%         Final_overall(overall) = Random(i + TrTrial);
%         overall = overall + 1;
%     end
end

Final_Accuracy_test(randTest)= count/TsTrial;
% Final_p(randTest).v = p;
% Final_p(randTest).ave = mean(p);
% Final_p(randTest).m = min(p);


Final_mean_Test = mean(Final_Accuracy_test);
Final_STD_Test = std2(Final_Accuracy_test);
% overall = overall - 1;
% Final_overall_c = zeros(1,3);
% for i = (1:overall)
%     %     if Final_overall(i) > 100
%     %         Final_overall(i) = Final_overall(i) - 100;
%     %     end
%     %     if Final_overall(i) > 100
%     %         Final_overall(i) = Final_overall(i) - 100;
%     %     end
%     lvl = ceil(Final_overall(i)/100);
%     Final_overall_c(lvl) = Final_overall_c(lvl) + 1;
% end