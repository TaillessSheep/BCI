pIndex = 2;

imgC = imread('C.png');
imgBlank = imread('Blank.png');
switch pIndex
    case 1
        imgL = imread('C2_LH_P1.png');
        imgR = imread('C2_RH_P1.png');
    case 2
        imgL = imread('C2_LH_P2.png');
        imgR = imread('C2_RH_P2.png');
end

close all;
image(imgBlank);
set(gcf, 'Position', get(0, 'Screensize'));
pause (2)

image(imgC);
pause(2)

image(imgL);
pause(2)

image(imgR);
pause(2)
close
