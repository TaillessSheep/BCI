clear;clc;
load ('predictions_test4')
% true_Label = [1 1 1 1 2, 2 2 1 2 2,1 1 2 2 1, 1 2 2 1 1 , 2 2 2 1 2, 1 2 1 2 1, 1 2 2 2 1 , 1 2 1 2 2,1 2 1 1 2, 2 1 2 2 1, 1 2 2 1 2, 1 1 1 2 2 , 2 1 1 2 2 , 1 2 2 1 2, 1 2 1 2 1, 1 2 2 2 1, 1 1 2 2 2, 1 1 2 2 1, 1 2 2 2 1, 1 2 1 2 1];
% true_Label = [1 1 2 2 2, 1 1 2 1 1 , 2 1 2 2 1 , 1 1 2 2 1 , 2 1 2 1 2 , 2 1 2 1 2, 1 2 1 1 2 , 2 2 2 1 2 , 2 2 1 2 2 , 1 1 2 2 2 ];
% true_Label = ones(1,50);
true_Label = [1 2 1 1 2, 2 1 2 2 1, 2 2 1 1 2, 2 2 1 2 2 , 1 1 2 1 2, 2 1 2 2 1, 1 2 2 1 2, 1 1 1 2 1, 2 2 1 2 2, 2 1 2 1 2];


count = 0;
for i = (1:length (command))
    if command(i) == true_Label(i)
        count = count + 1;
    end
end

acc = count/length(command);