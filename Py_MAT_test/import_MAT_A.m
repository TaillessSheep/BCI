time = (-1000:0);
y = ones(1,1001);

wait = 0;

while(true)
    try
        load('pydata.mat');
        if pydata.check
            newData = pydata.data;
            wait = 0;
        else
            disp(wait);
            wait = wait + 1;
            pause(0.0001);
            
        end
    catch
        disp('Troblem reading ''pydata.mat''.')
        pause(0.01);
        continue;
    end
    
    % raw_data = importdata();
    for i = (1: length(time)-1)
            y(i)=y(i+1);
    end
    y(length(time))=newData;
    plot(time,y);
    drawnow
    
    pydata.check = false;
    save('pydata.mat','-struct','pydata')
end
