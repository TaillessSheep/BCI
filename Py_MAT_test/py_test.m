% Using function py to connect Python and MATLAB
%

clear;
clc;

%% Parameter
max_record = 1000;
sig_magni_max = 2;
sig_magni_min = -2;

%% Set up
[a,b,isloaded] = pyversion;
if not(isloaded)
    disp('Python is not loaded. Terminating program.');
    return;
end

if count(py.sys.path,pwd) == 0
    insert(py.sys.path,int32(0),pwd);
end

time = (-(max_record-1):0);
y = ones(1,max_record);
wait = 0;

%% Main

while true
   for x = (1:300)
       y = wshift('1D',y,1);
       y(max_record)= py.sig.sig(2*pi*x/300);
       plot(time,y);
       axis([-(max_record-1) 0 sig_magni_min sig_magni_max]);
       drawnow
   end

end
