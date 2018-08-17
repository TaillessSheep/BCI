% Function to generate an array of ture and false value with a given size
% It is a 1*n, where n = size, array
% the function first generate half of the array and then invert it to be
% the second half

function out = randGen(size,class)
temp = size /class;

for i = (1:class)
    t((i-1)*temp + 1:i*temp) = i;
end

out = datasample(t,size,'Replace',false);