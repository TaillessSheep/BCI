% Function to generate an array of ture and false value with a given size
% It is a 1*n, where n = size, array
% the function first generate half of the array and then invert it to be
% the second half

function out = randGen(size)
temp = size /2;
t1 = randi([0 1], 1, temp);

for i = (1:temp)
    t2(i) = xor(t1(i),1);
end
    
out = [t1 flip(t2)];