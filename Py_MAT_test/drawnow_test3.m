%%setup
time = (-1000:0);
y = ones(1,1001);

%%
%%looping
% plot(time,y);

while(true)
    for x = linspace(0,2*pi,400)
        for i = (1: length(time)-1)
            y(i)=y(i+1);
        end
        y(length(time))=sin(x);
        plot(time,y);
        drawnow
    end
end
