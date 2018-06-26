function out = randGen(size)

t1 = randi([0,1],1,size/2);
for i = (1:size/2)
    t2(i) = xor(t1(i),1);
end
out = [t1 t2];
end