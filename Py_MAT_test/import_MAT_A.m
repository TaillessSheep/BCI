%% Parameters
time = (-1000:0);
y = ones(1,1001);
fileName = 'pydata.mat';

%% Set up
newData = 0;
wait = 0;
test = 0;

%% Main body
try
    while (true)
        try
            newData = load(fileName);
            delete 'pydata.mat';
        catch ME
            disp(ME)
            disp('Troblem reading ''pydata.mat''.')
            pause(0.01);
        end

        y = wshift('1D',y,1);
        y(length(time))=newData.data;
        plot(time,y);
        drawnow
    end
catch ME
    disp(ME)
    disp('Program ending~');
    delete 'pydata.mat';
end