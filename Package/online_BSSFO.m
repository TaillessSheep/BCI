function pred = online_BSSFO(DATA1 ,updatedBSSFO ,CSP ,xsup ,wsvm ,w0svm)
DATA1(isnan(DATA1)) = 0;

x_flt = spectral_filtering( DATA1(:,:), [], 500, updatedBSSFO, false );
features = feature_extraction( x_flt, CSP, updatedBSSFO, false );
L = 1:updatedBSSFO.numBands;
y = zeros(1,updatedBSSFO.numBands);
for i = L(logical(updatedBSSFO.selected))
    y(i)=svmval(features{1,i},xsup{i},wsvm{i},w0svm{i},'gaussian',1);
end
res = sign(sum(y.*updatedBSSFO.weight));

if res > 0
    pred = 1;
else
    pred = 2;
end

end