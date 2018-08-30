function out = filtering (raw)

% BP Filter 1 [0.5 100]
[z,p,k] = cheby2(10,60,2*[0.5, 100]/500, 'bandpass');
[sos, d] = zp2sos(z,p,k);
temp = filtfilt(sos, d, raw);
% BP Filter 2 [4 40]
[z,p,k] = cheby2(20,60,2*[4, 40]/500, 'bandpass');
[sos, d] = zp2sos(z,p,k);
out = filtfilt(sos, d, temp);
end
