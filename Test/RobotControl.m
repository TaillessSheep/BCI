
function RobotControl(command)
wall_e = legoev3('usb');

leftMotor = motor(wall_e,'D');
rightMotor = motor(wall_e,'C');
resetRotation(leftMotor);
resetRotation(rightMotor);

if (command == 1)
    LS = -77;
    RS = -75;
elseif(command == 2)
    LS = 75;
    RS = -75;
elseif(command == 3)
    LS = -75;
    RS = 75;
elseif(command == 4)
    LS = 0;
    RS = 0;
else
    warning(['Not able to recognise command: ' char(str(command))])
    LS = 0;
    RS = 0;
end

start(leftMotor, LS);
start(rightMotor, RS);
L = true;
R = true;
while L || R
    if (abs(readRotation(leftMotor)) >= 400)
        stop (leftMotor);
        L = false;
    end
    if (abs(readRotation(rightMotor)) >= 400)
        stop (rightMotor);
        R = false;
    end
    pause(0.001)
end

stop (leftMotor);
stop (rightMotor);
disp(readRotation(leftMotor))
disp(readRotation(rightMotor))
end