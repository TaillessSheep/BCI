clear;clc;
load('Mahsa_tO_test3Ts_copy.mat')
Trimming = 1000;
step = 200;
numS = Trimming / step;

num = size (mark,2); % number of trials

for i = (1:num)
    starts = mark(2,i);
    new_data((i-1)*Trimming + 1:i*1000,:) = data_received(starts:starts+Trimming-1,:);
    for j = (1:numS)
        new_mark(1,(i-1)*numS + j) = mark(1,i);
        new_mark(2,(i-1)*numS + j) = ((i-1)*numS + j-1)*step +1;
        new_mark(3,(i-1)*numS + j) = ((i-1)*numS + j-1)*step +1 + step - 1;
    end
    
end
data_received = new_data;
mark = new_mark;
save('Mahsa_tO_test3Ts.mat', 'Description', 'mark', 'data_received')