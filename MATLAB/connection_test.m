clear
wall_e = legoev3('usb');

leftMotor = motor(wall_e,'C');
rightMotor = motor(wall_e,'D');

start(leftMotor, 50);
start(rightMotor, -50);

pause(2);

stop (leftMotor);
stop (rightMotor);