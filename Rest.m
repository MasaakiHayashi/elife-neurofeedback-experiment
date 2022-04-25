if cnt_sample >= precnt_sample + cal_time   % calculate ERD every 100 ms

if RestStopper == 0
    TempNum1 = num2str(trial_cnt);
    TempNum2 = strcat('Rest     ',TempNum1);
    if CONDI == 1 && calibtag == 0
        TempNum2 = strcat('Relax     ',TempNum1);
    end
    set(t,'string',TempNum2,'color','g'); drawnow;
    Do.queueOutputData(OutputSignal(1,:));
    Do.startBackground();

    success = Rapid2_SetPowerLevel(obj1, CSIntens*stim_TSCS(stim_cnt_num+1,1), 0);
    
    RestStopper=1;
end

Rawdata(:,:,cnt_raw+1,trial_cnt) = Buffer(1:downsampling:Buffer_FreshRate,1:129);
% Rawdata = [sample ch win trial]

Signal_c4 = Buffer(1:Buffer_FreshRate,ch_c4(4)) - (Buffer(1:Buffer_FreshRate,ch_c4(1))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c4(2))/6 + Buffer(1:Buffer_FreshRate,ch_c4(3))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c4(5))/6 + Buffer(1:Buffer_FreshRate,ch_c4(6))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c4(7))/6);

Signal_c3 = Buffer(1:Buffer_FreshRate,ch_c3(4)) - (Buffer(1:Buffer_FreshRate,ch_c3(1))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c3(2))/6 + Buffer(1:Buffer_FreshRate,ch_c3(3))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c3(5))/6 + Buffer(1:Buffer_FreshRate,ch_c3(6))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c3(7))/6);

Signal_c4   = detrend(Signal_c4,'linear');
Signal_c3   = detrend(Signal_c3,'linear');
TempRest_c4 = filtfilt(B,A,Signal_c4(end-Fs+1:end,1));  % extract data last 1000 ms
TempRest_c3 = filtfilt(B,A,Signal_c3(end-Fs+1:end,1));
TempRest_c4 = filtfilt(stopB,stopA,TempRest_c4);
TempRest_c3 = filtfilt(stopB,stopA,TempRest_c3);

TempRestFFT_c4 = fft(TempRest_c4.*h);
TempRestFFT_c3 = fft(TempRest_c3.*h);
TempRestFFTPower_c4 = 2*(abs(TempRestFFT_c4).^2)/(Fs*Fs);   % calculate power
TempRestFFTPower_c3 = 2*(abs(TempRestFFT_c3).^2)/(Fs*Fs);

power_c4_rest(:,cnt_rest+1,trial_cnt) = TempRestFFTPower_c4;  % stock power during a rest
power_c3_rest(:,cnt_rest+1,trial_cnt) = TempRestFFTPower_c3;

precnt_sample = cnt_sample;
cnt_rest = cnt_rest + 1;
cnt_raw = cnt_raw + 1;

end

