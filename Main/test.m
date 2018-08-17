clear;
clc;

% img(1).file = imread('LH.png');
% img(2).file = imread('RH.png');
% img(3).file = imread('C.png');
% 
% close all;
% image(img(2).file);
% set(gcf, 'Position', get(0, 'Screensize'));

imgLH = imread('LH_1.png');
imgRH= imread('RH.png');
imgC= imread('C.png');

close all;
image(imgLH);
set(gcf, 'Position', get(0, 'Screensize'));