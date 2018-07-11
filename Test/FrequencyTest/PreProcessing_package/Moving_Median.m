function [ train_set_S,test_set_S ] = Moving_Median( train_set, test_set)

train_set_S = [];
test_set_S = [];

for i = 1:size(train_set,3)
   for j = 1:size(train_set,1)
        train_set_S(j,:,i) = movmedian(train_set(j,:,i),10,'omitnan');
   end
end

for i = 1:size(test_set,3)
   for j = 1:size(test_set,1)
        test_set_S(j,:,i) = movmedian(test_set(j,:,i),10,'omitnan');
   end
end

end

