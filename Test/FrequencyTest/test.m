close all;clear;clc;
addpath([pwd '\Data']);
load('Thy_Jul_6_47_3_A.mat');


% rec_time = (1:double(size(data_received,1)))/500;
% for i = (1:8)
%     figure('name','time domain')
%     for j = (1:4)
%         subplot(4,1,j);
%         plot(rec_time, data_received(:,(i-1)*4+j));
%         title((i-1)*4+j);
%     end
% end

% x = data_received(:,1:32);
% for ch = (1:size(x,2))
%     %     A = fft(temp(:,ch));
%     figure('name',['frequency domain' char(string(ch))]);
%     xdft = fft(x(:,ch));
%     xdft = xdft(1:length(x(:,ch))/2+1);
%     DF = Fs/length(x(:,ch)); % frequency increment
%     freqvec = 0:DF:Fs/2;
%     
% %     hold on
%     plot(freqvec,abs(xdft))
%     xlabel('Frequency (Hz)');
%     xlim([2 100]);
% %     plot(abs(A))
% end
% % drawnow;
% title('Initial Data(Signal) for Subject AA');
% xlabel('Frequency (Hz)');
% xlim([2 100]);
% figure('name','Hz')
% t = data_received(:,1);
% plot(abs(fft(t)));
% % xlim([0 100]);
fs = 1000;
figure('name','Hz')
for i = (1:32)
    t = data_received(1:1500,i);
    t = t - mean(t);
    t = t/max(abs(t));
    N = 1500;
    X_mags = abs(fft(t));
%     N = length(data_received);
%     X_mags = abs(data_received(:,i));
    bin_vals = [0 : N-1];
    fax_Hz = bin_vals*fs/N;
    N_2 = ceil(N/2);
    plot(fax_Hz(1:N_2), X_mags(1:N_2))
    hold on
    xlim([2 100]);
%     ylim([0 10000]);
    xlabel('Frequency (Hz)')
    ylabel('Magnitude');
    title('Single-sided Magnitude spectrum (Hertz)');
end
%     