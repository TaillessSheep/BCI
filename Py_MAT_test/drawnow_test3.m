%% Parameters
max_record = 1000;
sig_magni_max = 2;
sig_magni_min = -2;
%% Setup
time = (-(max_record-1):0);
y = ones(1,max_record);

%%
%%looping
% plot(time,y);

while(true)
    for x = (0:300)
        
        y = wshift('1D',y,1);
       
        y(length(y))=sin(2*pi*x/300);
        disp(size(time));
        disp(size(y));
        plot(time,y);
        axis([-(max_record-1) 0 sig_magni_min sig_magni_max]);
        
        drawnow
        
    end
end
