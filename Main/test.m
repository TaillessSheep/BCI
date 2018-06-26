clear;
clc;

%% parameters
epochDuration = 3;
breakDuration = 1.5;
trialNum = 10;
scaler = 100;
bufferSize = 5;

%% setup
imgLh = imread('LH.png');
imgRh = imread('RH.png');
imgNon = imread('crosshair.png');

epochStop = epochDuration * scaler;
breakStop = epochStop + breakDuration * scaler;

%% main body
mark = randGen(trialNum);
sampleCurrent = 0; % current sample index
sampleHistory = 0; % starting sample index of this trial
for current_trial = (1:trialNum)
    mark(2,current_trial) = sampleCurrent + 1;
    while not(sampleCurrent - sampleHistory == breakStop)
        if sampleCurrent - sampleHistory < epochStop
            disp('epoch');
    %         sampleCurrent = SampleCurrent + bufferSize;
            if mark(1,current_trial)
                image(imgLh);
            else
                image(imgRh);
            end
        elseif sampleCurrent - sampleHistory < breakStop
            disp('breaking');
            image(imgNon);
        end
        drawnow();
%         read data
        sampleCurrent = sampleCurrent + bufferSize;
    end
    sampleHistory = sampleCurrent;
end

