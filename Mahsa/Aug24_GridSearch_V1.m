% Grid Search using all cores available
clc;clear;

spmd
    %% parameters
    loaded = load('Will_Aug_27_18_prepro3.mat');

    TrTrial = 140;
    TsTrial = 200 - TrTrial;
    
    numClassifier = 1;
    classifierNames = {['LDA_2Eig_V1'] ['LDA_4Eig_V1'] ['LDA_6Eig_V1'] };...%['LDA_8Eig_V1']...
                      
%                        ['SVM_2Eig_V1'] ['SVM_4Eig_V1'] ['SVM_6Eig_V1'] };...%['SVM_8Eig_V1']};
    %                        ['LR_2Eig_V1']  ['LR_4Eig_V1']  ['LR_6Eig_V1']...
%  ['QDA_2Eig_V1'] ['QDA_4Eig_V1'] ['QDA_6Eig_V1'] ...%['QDA_8Eig_V1']...
    Step = 100;
    
    timeSample = 300;  % timeSamples within each epoch in raw data
    numRand = 30;        % amount of experiments on different randoms
    numFold = 10;       
    numClass = 2;
    numCh = 32; % number of channels
    %% preparation
    max_eig = 3; % using maximum 6 columm
    Data_Raw = loaded.data;
    
    Labels = loaded.Labels;
%     clear 
    if(mod(timeSample, Step) ~= 0)
        error("timeSample can not be divided by Step!")
    end
    classifierTypes = {'LDA'};% 'SVM'}; % 'LR''QDA'
    
    Trimming = (Step:Step:timeSample);
    
    if (mod(TrTrial,numFold) == 0)
        Step_fold = TrTrial/numFold;
    else
        error('TrTrial can not be divided by FoldNum!')
    end
    
    addpath('./Classifier_functions')

    
    %% main    
    for cType = (1:numClassifier) % type of classifiers: 'LDA' 'QDA' 'LR' 'SVM'
        if( labindex == 1)
            disp(classifierTypes{cType})
        end
        
        numEig = 3;
%         for numEig = (1:max_eig)
            if( labindex == 1)
                disp([' eig = ' num2str(numEig*2)])
            end
            classifier_index = (cType - 1) * max_eig + numEig;
            classifier_Func = str2func(classifierNames{classifier_index});
            
            for TrimIndex = (1:timeSample/Step)
                cTrimming = Trimming(TrimIndex);
                Data = Data_Raw(:,1:cTrimming,:);
                [~,TmSm,numTr] = size(Data);
                if( labindex == 1)
                    disp(['  Trim = ' num2str(TmSm)])
                end
                
                for randTest = (1:numRand)
                    if( labindex == 1)
                        disp(['   r = ' num2str(randTest)])
                    end
                    
                    % generate random vector
                    Random = randperm(numTr);
                    Randomfixx = Random';
                    
                    Train = zeros(numCh,TmSm,TrTrial);
                    Train(:,:,:) = Data(:,:,(Randomfixx(1:TrTrial)));
                    Train_lable = Labels(Randomfixx(1:TrTrial));
                    
                    Test = zeros(numCh,TmSm,TsTrial);
                    Test(:,:,:) = Data(:,:,(Randomfixx(TrTrial+1:end)));
                    Test_lable = Labels(Randomfixx(TrTrial+1:end));
                    TestTrial = size(Test,3);
                    
                    
                    fold_index = 1; % to keeep track of selected fold
                    for start = (1:Step_fold:TrTrial)
                        
                        CV.valDataSet = Train(:,:,start:start+TrTrial/numFold-1);
                        CV.val_label = Train_lable(1,start:start+TrTrial/numFold-1);
                        CV.VaTrial = size(CV.valDataSet,3);
                        
                        CV.Train = Train(:,:,[1:start-1 start+TrTrial/numFold:end]);
                        CV.TrTrial = size(CV.Train,3);
                        %                     disp(['CV.TrTrial: ' num2str(CV.TrTrial)])
                        CV.Train_label = Train_lable(1,[1:start-1 start+TrTrial/numFold:end]);
                        
                        % Get the Different Clasess
                        for i = (1: numClass)
                            CV.Train_class(i).count = 0;
                            CV.Train_class(i).data = zeros(32,cTrimming);
                            CV.Train_class(i).cov = zeros(numCh,numCh);
                        end
                        
                        for i = 1:CV.TrTrial
                            class = CV.Train_label(1,i); % what class is this signal
                            temp = CV.Train_class(class).count; % how many trials this class had (not inclding the current one)
                            temp = temp + 1; % how many trials this class has (inclding the current one)
                            CV.Train_class(class).data(:,:,temp) = CV.Train(:,:,i);
                            CV.Train_class(class).count = temp;
                        end
                        
                        for class = (1:numClass)
                            for i= 1:CV.Train_class(class).count
                                temp_data = CV.Train_class(class).data(:,:,i);
                                CV.Train_class(class).cov(:,:,i)= (temp_data*temp_data')/trace(temp_data*temp_data');
                            end
                            CV.Train_class(class).cov_Ave = mean(CV.Train_class(class).cov,3);
                        end
                        
                        if (numClass == 2) % we might need to add thing here for more classes
                            CV.Wn = zeros(numCh,numEig*2);
                            CV.Arg_Ft_Tr = zeros(numEig*2,numEig*2,CV.TrTrial);
                            CV.Ft_Tr = zeros(numEig*2, CV.TrTrial);
                            CV.Arg_Ft_Ts = zeros(numEig*2,numEig*2,CV.VaTrial);
                            CV.Ft_Ts = zeros(numEig*2, CV.VaTrial);
                            
                            [V,D]=eig(CV.Train_class(1).cov_Ave+CV.Train_class(2).cov_Ave,CV.Train_class(1).cov_Ave);
                            CV.Wn(:,1:numEig) = V(:,1:numEig); % numEig = "1", Taking one column, numEig = "2", Taking 2 column, numEig = "3", Taking 3 column.
                            CV.Wn(:,numEig+1:numEig*2) = V(:,end-numEig+1:end);
                            
                            for i= 1:CV.TrTrial
                                CV.Arg_Ft_Tr(:,:,i)=CV.Wn'*CV.Train(:,:,i)*CV.Train(:,:,i)'*CV.Wn;
                                CV.Ft_Tr(:,i)= log ((diag(CV.Arg_Ft_Tr(:,:,i)))/trace(CV.Arg_Ft_Tr(:,:,i)));
                                
                            end
                            
                            CV.Ft_Tr_Trainer = [ CV.Ft_Tr;CV.Train_label]';
%                             temp_Trainer = CV.Ft_Tr_Trainer;  % for creating new classifier function

                            for i= 1:CV.VaTrial
                                CV.Arg_Ft_Ts(:,:,i)=CV.Wn'*CV.valDataSet(:,:,i)*CV.valDataSet(:,:,i)'*CV.Wn;
                                CV.Ft_Ts(:,i)= log ((diag(CV.Arg_Ft_Ts(:,:,i)))/trace(CV.Arg_Ft_Ts(:,:,i)));
                            end
                            
%                             [TrainedLDA, validationAccuracy1] = classifier_Func(CV.Ft_Tr_Trainer);
                            [Trained, ~] = classifier_Func(CV.Ft_Tr_Trainer);
                            
                            Fit = Trained.predictFcn(CV.Ft_Ts');
                            
                            count = 0;
                            for i = 1:CV.VaTrial
                                if Fit(i,1) == CV.val_label(i)
                                    count = count + 1;
                                end
                            end
                            % accuracy for different folds with the same classType, eigNum & Trimming
                            Accuracy_CrsValidation_F(fold_index) = count/CV.VaTrial; 
                            
                        else
                            
                            error('Yo! Human! I can not support more than 2 classes!')
                        end
                        
                        fold_index = fold_index + 1;
                    end
                    Accuracy_CrsValidation_R.mean(randTest) = mean(Accuracy_CrsValidation_F);
                    Accuracy_CrsValidation_R.std(randTest) = std2(Accuracy_CrsValidation_F);
                end
                info(classifier_index,TrimIndex,1) = mean(Accuracy_CrsValidation_R.mean);
                info(classifier_index,TrimIndex,2)  = mean(Accuracy_CrsValidation_R.std);
            end
%         end
    end
    if labindex > 1
        labSend(info,1);
    else 
        for i = (2:numlabs)
            new_info = labReceive(i);
            info = info + new_info;
        end
        info = info / numlabs;
    end
    
    disp('Done')
end

info_final = info{1};
