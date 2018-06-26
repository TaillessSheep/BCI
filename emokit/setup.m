clear global;
clear;
clc;

global max time titles y; %f;

max = 500; % maximun data (for each channel) stored in workspace
time = (-(max-1):0);

titles = {'F3' 'FC5' 'F7' 'T7' 'P7' 'O1' 'O2' 'P8' 'T8' 'F8' 'AF4' 'FC6' 'F4' 'AF3'};

temp = zeros(1,max);
temp(:) = 4150;
for i = (1:14)
    y.(char(titles(i))) = temp;
end


% f = figure('Name','Raw Data');
% figures(2) = figure('Name','P8 T8 F8 AF4 FC6 F4 AF3');

