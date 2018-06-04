function out = update_A(x)

global y;
y = wshift('1D',y,1);
y(1000)=x;

out = true;