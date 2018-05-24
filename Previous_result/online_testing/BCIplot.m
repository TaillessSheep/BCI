%% Plot live EEG
%   	x	y
% AF3	-0.15	0.3
% F7	-0.34	0.24
% F3	-0.17	0.2
% FC5	-0.28	0.12
% T7	-0.4	0
% P7	-0.37	-0.24
% O1	-0.16	-0.38
% O2	0.16	-0.38
% P8	0.37	-0.24
% T8	0.4	0
% FC6	0.28	0.12
% F4	0.17	0.2
% F8	0.34	0.24
% AF4	0.15	0.3
% addpath(genpath('C:\\Users\\Tim\\Downloads\\liblsl-Matlab'))
addpath(genpath('C:\\Users\\Tim\\ownCloud\\Electrical Engineering\\summer_2017_project\\software\\labstreaminglayer-master\\LSL\\liblsl-Matlab'));

%% plot raw data
BCIstream = BCIstreamObj();
plotrefreshdelay = 0.01;
plotrefresh = 0;

Mapx = [-0.15 -0.34 -0.17 -0.28 -0.4 -0.37 -0.16 0.16 0.37 0.4 0.28 0.17 0.34 0.15];
Mapy = [0.3 0.24 0.2 0.12 0 -0.24 -0.38 -0.38 -0.24 0 0.12 0.2 0.24 0.3];
[X,Y] = meshgrid(-0.5:0.01:0.5, -0.5:0.01:0.5);
figure;
while true
    Mapz = BCIstream(1); 
    if BCIstream.time > plotrefresh
        plotrefresh = BCIstream.time + plotrefreshdelay;
        Z = griddata(Mapx,Mapy,Mapz,X,Y,'natural');
% %         mesh(X,Y,Z);
%         hold off;
%         plot3(Mapx,Mapy,Mapz,'o');
%         hold on;
%         surf(X,Y,Z);
        plot(Mapx,Mapy,'o');
        hold on;
        contourf(X,Y,Z);
        hold off;
    end
end


%% plot filtered data
BCIstream = BCIstreamObj();



plotrefreshdelay = 0.01;
plotrefresh = 0;

HPF = dsp.HighpassFilter('SampleRate',1/plotrefreshdelay,'FilterType','IIR','StopbandFrequency',2,'PassbandFrequency',4);
LPF = dsp.LowpassFilter('SampleRate',1/plotrefreshdelay,'FilterType','IIR','StopbandFrequency',8,'PassbandFrequency',6);

Mapx = [-0.15 -0.34 -0.17 -0.28 -0.4 -0.37 -0.16 0.16 0.37 0.4 0.28 0.17 0.34 0.15];
Mapy = [0.3 0.24 0.2 0.12 0 -0.24 -0.38 -0.38 -0.24 0 0.12 0.2 0.24 0.3];
[X,Y] = meshgrid(-0.5:0.01:0.5, -0.5:0.01:0.5);
figure;
while true
    
    Mapz = step(HPF,BCIstream(1)); 
    Mapz = step(LPF,Mapz); 
    if BCIstream.time > plotrefresh
        plotrefresh = BCIstream.time + plotrefreshdelay;
        Z = griddata(Mapx,Mapy,Mapz,X,Y,'natural');
% %         mesh(X,Y,Z);
%         hold off;
%         plot3(Mapx,Mapy,Mapz,'o');
%         hold on;
%         surf(X,Y,Z);
        plot(Mapx,Mapy,'o');
        hold on;
        contourf(X,Y,Z);
        hold off;
    end
end



