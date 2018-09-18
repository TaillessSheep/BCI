% In this file the class codes are updated to Base-3 and the number of the classifiers that should be trainded are increased.
clc; clear; close all;
Address = {'C:\Mahsaa\mahsa\Coding\PaperConference_ICRA_Code\BSSFO_ICRA',... %DataSet
    'C:\Mahsaa\mahsa\Coding\PaperConference_ICRA_Code\BSSFO_ICRA',... %m.file
    'C:\Mahsaa\mahsa\Coding\PaperConference_ICRA_Code\BSSFO_ICRA',... %Labels
    'C:\Mahsaa\mahsa\Coding\PaperConference_ICRA_Code\BSSFO_ICRA\SVM-KM'}; %SVM Folder
addpath(Address{4})

mmm = 2;

for ctr = 1:3 %10
    
    clearvars -except mmm final Address ctr mmm
    cd(Address{1})
    trimming = 250;
    
    load ('Mahsa_Aug_30_18_DataSet');
    load ('Mahsa_Aug_30_18_labels');
%     load ('Mahsa_Aug_30_18_prepro');
    data = data(:,1:trimming,:);
    Labels =Labels;
    
    Labels = Labels-1;
    
    index = randperm(size(data,3));
    trainInd = index(1:round(0.7*size(data,3)));
    testInd = index(round(0.7*size(data,3))+1:end);
    
    TrainLab = Labels(trainInd);
    TestLab = Labels(testInd);
    DATA = data(:,:,trainInd); % Train
    
    DATA(isnan(DATA)) = 0;
    cd(Address{2})
    trialLabel = TrainLab';
    
    %% Training for label 1 (left) and label 2 (right)
    disp(['......... Training for subject = ' num2str(mmm) ' ...........'])
    for k = 1:size(trialLabel,2)
        disp(['.... training for K = ' num2str(k)])
        initBSSFO.numBands = 40;
        initBSSFO.sample = 10*rand(2,40);
        initBSSFO.sample(2,:) = initBSSFO.sample(2,:)+10;
        for i = 1:initBSSFO.numBands
            initBSSFO.sample(:,i) = checkValidityBSSFO( initBSSFO.sample(:,i) );
        end
        verbose = 0;
        kernel = 'gaussian';
        kerneloption = 1;
        niter = 45;

        try
            [updatedBSSFO, CSP, xsup, wsvm, w0svm] = BSSFO( DATA(:,:,trialLabel(:,k)==0), DATA(:,:,trialLabel(:,k)==1), 500, 1, initBSSFO, niter, kernel, kerneloption, verbose );
        catch ME
            disp(ME.message)
            [updatedBSSFO, CSP, xsup, wsvm, w0svm] = BSSFO( DATA(:,:,trialLabel(:,k)==0), DATA(:,:,trialLabel(:,k)==1), 500, 1, initBSSFO, niter, kernel, kerneloption, verbose );
        end
        BSS{k}= updatedBSSFO; C{k}=CSP; X{k}=xsup; W{k}=wsvm; W0{k}=w0svm;
    end
    
    %% Evaluation on unseen data
    
    cd(Address{1})
    % [DATA, Label] = data_prepare_BCICIVIIb (mmm, 'test', 0.5, 2.5, 250);
    
    % DATA1 = testInd;
    DATA1 = data(:,:,testInd);
    Label = TestLab';
    
    
    DATA1(isnan(DATA1)) = 0;
    cd(Address{2})
    disp(['......... Evaluation for subject = ' num2str(mmm) '...........'])
    for j = 1:length(Label) % for every trial in test set
        
        %         for k = 1:size(BSS,2)
        k = 1;
        updatedBSSFO=BSS{k}; CSP=C{k}; xsup=X{k}; wsvm=W{k}; w0svm=W0{k};
        x_flt = spectral_filtering( DATA1(:,:,j), [], 500, updatedBSSFO, verbose );
        features = feature_extraction( x_flt, CSP, updatedBSSFO, verbose );
        L = 1:updatedBSSFO.numBands;
        y = zeros(1,updatedBSSFO.numBands);
        for i = L(logical(updatedBSSFO.selected))
            y(i)=svmval(features{1,i},xsup{i},wsvm{i},w0svm{i},kernel,kerneloption);
        end
        res(j,k) = sign(sum(y.*updatedBSSFO.weight));
        val(j,k) = sum(y.*updatedBSSFO.weight);
        %         end
        
    end
    res(res == 1) = 1;
    res(res == -1) = 2;
    temp = sum(res == Label+1)*100/size(res,1);
    final(ctr,1) = temp(1);
    final(ctr,2) = (temp(1)-50)/0.5;
    % disp(['Performance for subject ' num2str(mmm) ' = ' num2str(final(ctr,2))])
end
Reult{mmm} = final;
disp ('.......................................................')
disp(['The average performance; Subject' num2str(mmm) 'is = ' num2str(mean(final))])
disp(['The STD of performance; Subject' num2str(mmm) 'is = ' num2str(std(final))])
% save([datestr(now, 'yyyy-mmm-dd-HH-MM') '.mat'], 'final')
% end
rmpath(Address{4})
