function [ Train_set_S, Test_set_S] = EXPWeighted_Moving_Average( WindowSize,train_set,test_set )
Train_set_S = [];
Test_set_S = [];

for i = 1:size(train_set,3)
    %     for j = 1:size(train_set,1)
    
     val_tr = tsmovavg(train_set(:,:,i)','e',WindowSize,1);
     Train_set_S(:,:,i) = val_tr';
    %     end
end

for i = 1:size(test_set,3)
    %    for j = 1:size(test_set,1)
    val_ts = tsmovavg(test_set(:,:,i)','e',WindowSize,1);
    Test_set_S(:,:,i) = val_ts';
end
% end
end