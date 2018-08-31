
function RobotControl(command)
global leftMotor rightMotor wall_e


leftMotor = motor(wall_e,'D');
rightMotor = motor(wall_e,'C');
changeup = onCleanup(@CleanUp_Robot);
resetRotation(leftMotor);
resetRotation(rightMotor);

if (command == 1)
    LS = -77;
    RS = -75;
elseif(command == 2)
    LS = 70;
    RS = -70;
elseif(command == 3)
    LS = -70;
    RS = 70;
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
    if (abs(readRotation(leftMotor)) >= 390)
        stop (leftMotor);
        L = false;
    end
    if (abs(readRotation(rightMotor)) >= 390)
        stop (rightMotor);
        R = false;
    end
    pause(0.001)
end

stop (leftMotor);
stop (rightMotor);

end