% plot data (analog channel 1, counter and validation indicator)
rec_time = (1:double(sampleCurrent))/250;
subplot(3,1,1);
plot(rec_time, data_received(:,2));
ylabel('Amplitude [µV]');
subplot(3,1,2);
% NOTE: the line below is for a 32-channel g.Nautilus device. If a 8-,
% 16- or 64-channel is used the code below has to be changed to
% 8-channel :  plot(rec_time, data_received(:,9));
% 16-channel : plot(rec_time, data_received(:,17));
% 64-channel : plot(rec_time, data_received(:,65));
plot(rec_time, data_received(:,33));
ylabel('Counter');
subplot(3,1,3);
% NOTE: the line below is for a 32-channel g.Nautilus device. If a 8-,
% 16- or 64-channel is used the code below has to be changed to
% 8-channel :  plot(rec_time, data_received(:,10));
% 16-channel : plot(rec_time, data_received(:,18));
% 64-channel : plot(rec_time, data_received(:,66));
plot(rec_time, data_received(:,34));
ylabel('Valid');
xlabel('Seconds');