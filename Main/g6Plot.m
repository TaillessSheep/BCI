% plot data (analog channel 1, counter and validation indicator)
rec_time = (1:double(length(data_received)))/samplingRate;

for i = (1:8)
    figure();
    for j = (1:4)
        subplot(4,1,j);
        plot(rec_time, data_received(:,(i-1)*4+j));
    end
end