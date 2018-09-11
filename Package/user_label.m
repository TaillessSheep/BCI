function label = user_label(ard)


writeDigitalPin(ard, 'D13', 0);

writeDigitalPin(ard, 'D13', 1);
L = 0;
R = 0;
while ~L && ~R
    L = readDigitalPin(ard, 'D3');
    R = readDigitalPin(ard, 'D4');
end
if ~xor(L,R)
    warning(['Both pins read ' num2str(L) '.'])
end

if L
    label = 1;
else
    label = 2;
end

writeDigitalPin(ard, 'D13', 0);

end