function [ predicted_label, true_labels ] = MDSM( data, indexing, labels )
% Classification based on Minimum distance to sub-manifold mean
[ sel, Ws ] = BSML( data, indexing, labels );
% sCOV_mapped = zeros(sel, sel, size(data.data, 3));

for i = 1: size(data.data, 3)
    COV_mapped(:,:,i) = Ws*data.data(:,:,i)*Ws';
end
ind = ~logical(sum(data.labels(data.idxTraining) == labels(indexing == 2),2));
COV_mapped_train = COV_mapped(:,:, data.idxTraining(ind));
Ytrain  = data.labels(data.idxTraining(ind));
%-----------------------------------------------------------
temp = Ytrain == labels(indexing == 0);
ind_s1 = sum(temp,2);
COV_mapped_1 = riemann_mean(COV_mapped_train(:,:,logical(ind_s1)));
temp = Ytrain == labels(indexing == 1);
ind_s2 = sum(temp,2);
COV_mapped_2 = riemann_mean(COV_mapped_train(:,:,logical(ind_s2)));
%------------------------------------------------------------
predicted_label = 0;
for i = 1:length(data.idxTest)
    d1 = distance_riemann(COV_mapped(:,:,data.idxTest(i)), COV_mapped_1);
    d2 = distance_riemann(COV_mapped(:,:,data.idxTest(i)), COV_mapped_2);
    if d1 <= d2
        predicted_label(i) = 0;
    else
        predicted_label(i) = 1;
    end
end
%-----------------------------------------------------------
true_labels = 2*ones(length(data.idxTest),1);
Ytest  = data.labels(data.idxTest);
temp = Ytest == labels(indexing == 0);
true_labels(logical(sum(temp,2))) = 0;

temp = Ytest == labels(indexing == 1);
true_labels(logical(sum(temp,2))) = 1;

end

