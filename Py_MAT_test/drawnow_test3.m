%% Parameters
max_record = 1000;
sig_magni_max = 2;
sig_magni_min = -2;
%% Setup
time = (-(max_record-1):0);
y = ones(1,max_record);

cur  = ;
last = cur;
%%
%%looping
% plot(time,y);

while(true)
    for x = (0:300)
        disp('A');
        cur = get(clock);
        disp(cur - last);
        last = cur;
        y = wshift('1D',y,1);
        disp('B');
        cur = get(clock);
        disp(cur - last);
        last = cur;
        y(length(y))=sin(2*pi*x/300);
        disp('C');
        cur = get(clock);
        disp(cur - last);
        last = cur;
        plot(time,y);
        axis([-(max_record-1) 0 sig_magni_min sig_magni_max]);
        disp('D');
        cur = get(clock);
        disp(cur - last);
        last = cur;
        drawnow
        disp('E');
        cur = get(clock);
        disp(cur - last);
        last = cur;
    end
end
