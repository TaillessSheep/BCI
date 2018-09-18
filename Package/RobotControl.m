
function RobotControl(command)
global leftMotor rightMotor wall_e


leftMotor = motor(wall_e,'D');
rightMotor = motor(wall_e,'C');
changeup = onCleanup(@CleanUp_Robot);
resetRotation(leftMotor);
resetRotation(rightMotor);

if (command == 1) % turn left
    LS = 70;
    RS = -70;
elseif(command == 2) % turn right
    LS = -70;
    RS = 70;    
elseif(command == 3) % forward
    LS = -77;
    RS = -75;
elseif(command == 4) % no mov
    LS = 0;
    RS = 0;
else
    warning(['Not able to recognise command: ' char(str(command))])
    LS = 0;
    RS = 0;
end

start(leftMotor, LS);
start(rightMotor, RS);
if ismember(command,[1,2,3])
    L = true;
    R = true;
else
    L = false;
    R = false;
end

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