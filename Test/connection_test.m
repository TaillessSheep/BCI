clear

wall_e = legoev3('usb');

leftMotor = motor(wall_e,'C');
rightMotor = motor(wall_e,'D');
resetRotation(leftMotor);
resetRotation(rightMotor);

LR = readRotation(leftMotor)
RR = readRotation(rightMotor)

start(leftMotor, -75);
start(rightMotor, 80);

while (abs(readRotation(leftMotor) - LR) <400)
end
% pause(1.5);

stop (leftMotor);
stop (rightMotor);
readRotation(leftMotor)
readRotation(rightMotor)