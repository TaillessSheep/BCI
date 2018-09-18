% In this file the class codes are updated to Base-3 and the number of the classifiers that should be trainded are increased.
clc; clear; close all;
T = {'A01T.mat','A02T.mat','A03T.mat','A04T.mat','A05T.mat','A06T.mat','A07T.mat','A08T.mat','A09T.mat',};
E = {'A01E.mat','A02E.mat','A03E.mat','A04E.mat','A05E.mat','A06E.mat','A07E.mat','A08E.mat','A09E.mat',};
C = {'A01E.mat','A02E.mat','A03E.mat','A04E.mat','A05E.mat','A06E.mat','A07E.mat','A08E.mat','A09E.mat',};
% Address = {'C:\Users\S_SHAHTA\Desktop\my files\PhD\Research\Datasets\BCICIV_2a_gdf',...
%     'C:\Users\S_SHAHTA\Desktop\ECO-BSSFO',...
%     'C:\Users\S_SHAHTA\Desktop\my files\PhD\Research\Datasets\BCICIV_true_labels_2a',...
%     'C:\Users\S_SHAHTA\Desktop\my files\PhD\Research\Softwares\SVM-KM'};
% addpath(Address{4})
Address = {'C:\Users\soroosh\Dropbox\PHD sync with Lab\Implementations\January-2017 error correction\BCICIV_2a_gdf',...
    'C:\Users\soroosh\Dropbox\PHD sync with Lab\Implementations\ECO-BSSFO',...
    'C:\Users\soroosh\Dropbox\PHD sync with Lab\Implementations\January-2017 error correction\true_labels_2A',...
    'D:\PhD documents\MATLAB toolboxes'};
addpath(genpath(Address{4}))
for mmm = 1:9
T = {'A01T.mat','A02T.mat','A03T.mat','A04T.mat','A05T.mat','A06T.mat','A07T.mat','A08T.mat','A09T.mat',};
E = {'A01E.mat','A02E.mat','A03E.mat','A04E.mat','A05E.mat','A06E.mat','A07E.mat','A08E.mat','A09E.mat',};
C = {'A01E.mat','A02E.mat','A03E.mat','A04E.mat','A05E.mat','A06E.mat','A07E.mat','A08E.mat','A09E.mat',};    
    
clearvars -except mmm C  E  T final Address
filenameT = T{mmm}; 
filenameC = C{mmm}; 
filenameE = E{mmm};
cd(Address{1})
load(filenameT);
cd(Address{2})
Nch=22; Nf=9; Nt=500; Nlb=4; trial=1;
% 1==left, 2==right, 3==foot, 4==tongue
data=zeros(Nch,Nt); DATA=zeros(Nch,Nt,288); 
classes=[769,770,771,772]; label=[1,2,3,4];
ExCode={[0,1,1,1],[1,0,1,1],[1,1,0,1],[1,1,1,0]};
trialLabel=zeros(288,size(ExCode{1},2));
for j=1:length(classes)
    temp=pos((typ==classes(j)),1);
    for i=1:length(temp)
%         data=s(((temp(i)-1000):(temp(i)+999)),1:Nch)';
        data = s(((temp(i)+125):(temp(i)+624)),1:Nch)';
        data(isnan(data))=0;
        M = mean(s(((temp(i)-500):(temp(i))),1:Nch));
        DATA(:,:,trial)= data-M';
        trialLabel(trial,:) = ExCode{j};
        trial=trial+1;
    end
end

%% Training for label 1 (left) and label 2 (right)
disp(['......... Training for subject = ' num2str(mmm) '...........'])
for k = 1:size(trialLabel,2)
disp(['.... training for K = ' num2str(k)])
initBSSFO.numBands = 20;
initBSSFO.sample = 20*rand(2,20);
initBSSFO.sample(2,:) = initBSSFO.sample(2,:)+20; 
verbose = 0;
kernel = 'gaussian';
kerneloption = 1;
niter = 5;
[updatedBSSFO, CSP, xsup, wsvm, w0svm] = BSSFO( DATA(:,:,trialLabel(:,k)==0), DATA(:,:,trialLabel(:,k)==1), 250, 4/2, initBSSFO, niter, kernel, kerneloption, verbose );
BSS{k}= updatedBSSFO; C{k}=CSP; X{k}=xsup; W{k}=wsvm; W0{k}=w0svm;
end
save(['train0' num2str(mmm)], 'BSS','C','X','W','W0')
%% Evaluation on unseen data
cd(Address{1})
load(filenameE);
cd(Address{3})
load(filenameC)
cd(Address{2})
disp(['......... Evaluation for subject = ' num2str(mmm) '...........'])
% unknown cue == 783    
temp = pos(typ == 783);
% index = ((classlabel == 1)| (classlabel == 3));
% temp = temp(index);
Result = zeros(288,4); %res= zeros(length(temp),size(trialLabel,2)); 
val = zeros(1,4); Ny = 10;
for j=1:length(temp)
        data = s(((temp(j)+125):(temp(j)+624)),1:Nch)';
        M = mean(s(((temp(j)-500):(temp(j))),1:Nch));
        DATA(:,:,trial)= data-M';
        trial=trial+1;
        for k = 1:size(trialLabel,2)
            updatedBSSFO=BSS{k}; CSP=C{k}; xsup=X{k}; wsvm=W{k}; w0svm=W0{k};
            x_flt = spectral_filtering( DATA(:,:,trial-1), [], 250, updatedBSSFO, verbose );
            features = feature_extraction( x_flt, CSP, updatedBSSFO, verbose );
            L = 1:updatedBSSFO.numBands;
            y = zeros(1,updatedBSSFO.numBands);
            for i = L(logical(updatedBSSFO.selected))
                y(i)=svmval(features{i},xsup{i},wsvm{i},w0svm{i},kernel,kerneloption);
            end
%             [~, indy] = sort(abs(y),'descend');
            y(isnan(y))=0;
            res(k) = sign(sum(y.*updatedBSSFO.weight));
            val(k) = sum(y.*updatedBSSFO.weight);
        end
        
        res(res == 1) = 0;
        res(res == -1) = 1;
        res(isnan(res)) = 0;
        select = [1,2,3,4];
        ttt = max(val(res == 0));
        if ttt==0
            val = 1;
            ttt=1;
        end
        if isempty(ttt)
            ttt = val(1);
        end
        
        Result(j,1) = select(val == ttt(1));
        
%         Result(j,1) = Analysis(res, ExCode);
%         for i = 1:length(ExCode)
%             dist(i) = sum( abs(ExCode{i} - res));
%         end
%         Result(j,1:length(label(dist == min(dist)))) = label(dist == min(dist));
            
    
end
temp = sum(Result == classlabel)*100/size(Result,1);
final(mmm,1) = temp(1);
final(mmm,2) = (temp(1)-25)/0.75;
disp(['Performance for subject ' num2str(mmm) ' = ' num2str(final(mmm,1))])
end
disp ('.......................................................')
disp(['The average performance is = ' num2str(mean(final))])
disp(['The STD of performance is = ' num2str(std(final))])
 save(['OVA-' datestr(now, 'yyyy-mmm-dd-HH-MM') '.mat'], 'final')


