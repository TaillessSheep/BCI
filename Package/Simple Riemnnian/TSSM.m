function [ predicted_label, true_labels, score ] = TSSM( data, indexing, labels, classifier )
[ sel, Ws ] = BSML( data, indexing, labels );
sCOV_mapped = zeros(sel, sel, size(data.data, 3));
for i = 1: size(data.data, 3)
    COV_mapped(:,:,i) = Ws*data.data(:,:,i)*Ws';
end
ind = ~logical(sum(data.labels(data.idxTraining) == labels(indexing == 2),2));
Ytrain  = data.labels(data.idxTraining(ind));
%-----------------------------------------------------------
temp = Ytrain == labels(indexing == 1);
ind_s2 = sum(temp,2);
P = riemann_mean(COV_mapped);
%--------------------------------------------------------
Strain = Tangent_space_my(COV_mapped(:,:,data.idxTraining(ind)),P)';
Stest = Tangent_space_my(COV_mapped(:,:,data.idxTest),P)';
% Strain = tangent_mapping(COV_mapped(:,:,data.idxTraining(ind)),P);
% Stest = tangent_mapping(COV_mapped(:,:,data.idxTest),P);

if strcmp(classifier, 'LDA')
    mdl = fitcdiscr(Strain, ind_s2);
    [predicted_label score] = predict(mdl, Stest);
    
elseif strcmp(classifier, 'SVM')
    mdl = fitcsvm(Strain, ind_s2);
    [predicted_label score] = predict(mdl, Stest);
    
elseif strcmp(classifier, 'QDA')
    [predicted_label score] = classify( Stest, Strain, ind_s2 );
    
elseif strcmp(classifier, 'Tree')
    mdl = fitctree(Strain, ind_s2);
    [predicted_label score] = predict(mdl, Stest);
end
%-----------------------------------------------------------
true_labels = 2*ones(length(data.idxTest),1);
Ytest  = data.labels(data.idxTest);
temp = Ytest == labels(indexing == 0);
true_labels(logical(sum(temp,2))) = 0;

temp = Ytest == labels(indexing == 1);
true_labels(logical(sum(temp,2))) = 1;


end

