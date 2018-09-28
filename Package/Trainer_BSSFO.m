clc; clear; close all;
% Address = {'C:\Mahsaa\mahsa\Coding\BSSFO'}; % address the folder of SVM
% Address = {'C:\Mahsaa\mahsa\Coding\PaperConference_ICRA_Code\BSSFO_ICRA',... %DataSet
%     'C:\Mahsaa\mahsa\Coding\PaperConference_ICRA_Code\BSSFO_ICRA',... %m.file
%     'C:\Mahsaa\mahsa\Coding\PaperConference_ICRA_Code\BSSFO_ICRA',... %Labels
%     'C:\Mahsaa\mahsa\Coding\PaperConference_ICRA_Code\BSSFO_ICRA\SVM-KM'}; %SVM Folder
% addpath(Address{4})
name = 'Mahsa_Aug_30_18';

Trimming = 750;

load ([name '_prepro']);

data = data(:,1:Trimming,:);
%     Labels =LabelsSetMahsa_Sep1st_2Feature;

Labels = Labels-1;

numRand = 3; % 10
ctr = 1;
while ctr <= numRand
    disp(ctr)
    clearvars -except final ctr numRand BSS C X W W0 name Labels data Trimming %Address
    %     cd(Address{1})
    % [DATA, Label] = data_prepare_BCICIVIIb (subject, status, start_time, end_time, fs)
    %     [DATA, Label] = data_prepare_BCICIVIIb (mmm, 'train', 0.5, 2.5, 250);
    
    
    index = randperm(size(data,3));
    trainInd = index(1:round(0.7*size(data,3)));
    testInd = index(round(0.7*size(data,3))+1:end);
    %     trainInd = index(1:0.7*size(data,3)); %!
    %     testInd = index((0.7*size(data,3))+1:end); %!
    
    TrainLab = Labels(trainInd);
    TestLab = Labels(testInd);
    DATA = data(:,:,trainInd); % Train
    
    DATA(isnan(DATA)) = 0;
    %         cd(Address{2})
    trialLabel = TrainLab';
    
    %% Training for label 1 (left) and label 2 (right)
    
    %     for k = 1:size(trialLabel,2)
    % k = 1;
    %     disp(['.... training for K = ' num2str(k)])
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
        [updatedBSSFO, CSP, xsup, wsvm, w0svm] = BSSFO( DATA(:,:,trialLabel==0), DATA(:,:,trialLabel==1), 500, 1, initBSSFO, niter, kernel, kerneloption, verbose );
        disp(':)')
    catch ME
        disp(ME.message)
        disp(':(')
        continue
    end
    BSS{ctr}= updatedBSSFO; C{ctr}=CSP; X{ctr}=xsup; W{ctr}=wsvm; W0{ctr}=w0svm;
    %     end
    
    %% Evaluation on unseen data
    
    %     cd(Address{1})
    % [DATA, Label] = data_prepare_BCICIVIIb (mmm, 'test', 0.5, 2.5, 250);
    
    % DATA1 = testInd;
    DATA1 = data(:,:,testInd);
    Label = TestLab';
    
    
    DATA1(isnan(DATA1)) = 0;
    %     cd(Address{2})
    
    for j = 1:length(Label) % for every trial in test set
        
        %         for k = 1:size(BSS,2)
        updatedBSSFO=BSS{ctr}; CSP=C{ctr}; xsup=X{ctr}; wsvm=W{ctr}; w0svm=W0{ctr};
        x_flt = spectral_filtering( DATA1(:,:,j), [], 500, updatedBSSFO, verbose );
        features = feature_extraction( x_flt, CSP, updatedBSSFO, verbose );
        L = 1:updatedBSSFO.numBands;
        y = zeros(1,updatedBSSFO.numBands);
        for i = L(logical(updatedBSSFO.selected))
            y(i)=svmval(features{1,i},xsup{i},wsvm{i},w0svm{i},kernel,kerneloption);
        end
        res(j,1) = sign(sum(y.*updatedBSSFO.weight));
        %         val(j) = sum(y.*updatedBSSFO.weight);
    end
    res(res == 1) = 1;
    res(res == -1) = 2;
    temp = sum(res == Label+1)*100/length(res);
    final(ctr,1) = temp(1);
    final(ctr,2) = (temp(1)-50)/0.5;
    % disp(['Performance for subject ' num2str(mmm) ' = ' num2str(final(ctr,2))])
    ctr = ctr + 1;
end

disp ('.......................................................')
disp(['The average performance ' 'is = ' num2str(mean(final))])
disp(['The STD of performance '  'is = ' num2str(std(final))])
% save([datestr(now, 'yyyy-mmm-dd-HH-MM') '.mat'], 'final')
[accuracy,i] = max(final(:,1));
BSS = BSS{i}; C = C{i}; X = X{i}; W = W{i}; W0 = W0{i};
name_output = [name '_classifier_BSSFO'];
save(['../Classifiers/' name_output], 'BSS', 'C', 'X', 'W', 'W0', 'accuracy', 'Trimming')
disp([name '_classifier'])
% end
% rmpath(Address{4})



% save([name '_classifier_BSSFO'],'numRand','BSS','C','X','W','W0','Trimming')
