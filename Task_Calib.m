if cnt_sample >= precnt_sample + cal_time
    
if TaskStopper == 0
    set(t,'string','Imagery','color','r'); drawnow;
    Do.queueOutputData(OutputSignal(3,:));
    Do.startBackground();
    TaskStopper=1;
end

Rawdata(:,:,cnt_raw+1,trial_cnt) = Buffer(1:downsampling:Buffer_FreshRate,1:129);

Signal_c4 = Buffer(1:Buffer_FreshRate,ch_c4(4)) - (Buffer(1:Buffer_FreshRate,ch_c4(1))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c4(2))/6 + Buffer(1:Buffer_FreshRate,ch_c4(3))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c4(5))/6 + Buffer(1:Buffer_FreshRate,ch_c4(6))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c4(7))/6);

Signal_c3 = Buffer(1:Buffer_FreshRate,ch_c3(4)) - (Buffer(1:Buffer_FreshRate,ch_c3(1))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c3(2))/6 + Buffer(1:Buffer_FreshRate,ch_c3(3))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c3(5))/6 + Buffer(1:Buffer_FreshRate,ch_c3(6))/6 ...
        + Buffer(1:Buffer_FreshRate,ch_c3(7))/6);

Signal_c4 = detrend(Signal_c4,'linear');
Signal_c3 = detrend(Signal_c3,'linear');
TempTask_c4 = filtfilt(B,A,Signal_c4(end-Fs+1:end,1));
TempTask_c3 = filtfilt(B,A,Signal_c3(end-Fs+1:end,1));
TempTask_c4 = filtfilt(stopB,stopA,TempTask_c4);
TempTask_c3 = filtfilt(stopB,stopA,TempTask_c3);

TempTaskFFT_c4 = fft(TempTask_c4.*h);
TempTaskFFT_c3 = fft(TempTask_c3.*h);
TempTaskFFTPower_c4 = 2*(abs(TempTaskFFT_c4).^2)/(Fs*Fs);
TempTaskFFTPower_c3 = 2*(abs(TempTaskFFT_c3).^2)/(Fs*Fs);

power_c4_task(:,cnt_task+1,trial_cnt) = TempTaskFFTPower_c4;  % stock power during a task
power_c3_task(:,cnt_task+1,trial_cnt) = TempTaskFFTPower_c3;

%% ERD calculation

Freq_min_c3 = 8;    % default setting
Freq_max_c3 = 13;
Freq_min_c4 = 8;
Freq_max_c4 = 13;

ERD_c4 = (TempTaskFFTPower_c4-TempRefFFTPower_c4)./TempRefFFTPower_c4*100;
ERD_c4_alpha = mean(ERD_c4(Freq_min_c4+1:Freq_max_c4+1,1));
ERD_c3 = (TempTaskFFTPower_c3-TempRefFFTPower_c3)./TempRefFFTPower_c3*100;
ERD_c3_alpha = mean(ERD_c3(Freq_min_c3+1:Freq_max_c3+1,1));

ERD_c4_task(cnt_task+1,trial_cnt) = ERD_c4_alpha; 
ERD_c3_task(cnt_task+1,trial_cnt) = ERD_c3_alpha; 

if ERD_c4_alpha > 100
    ERD_c4_alpha = 100;
end

if ERD_c3_alpha > 100
    ERD_c3_alpha = 100;
end

ERD_c4_stock_tmp(1:stocksize-1,1) = ERD_c4_stock_tmp(2:stocksize,1);
ERD_c3_stock_tmp(1:stocksize-1,1) = ERD_c3_stock_tmp(2:stocksize,1);

ERD_c4_stock_tmp(stocksize,1) = ERD_c4_alpha;    % ERD(stocksize,1) = new data
ERD_c3_stock_tmp(stocksize,1) = ERD_c3_alpha;

%%% smoothing %%%
ERD_c4_stock(1:stocksize-1,1) = ERD_c4_stock(2:stocksize,1);
ERD_c3_stock(1:stocksize-1,1) = ERD_c3_stock(2:stocksize,1);

ERD_c4_stock(stocksize,1) = mean(ERD_c4_stock_tmp(stocksize-smoothlevel:stocksize,1),1);  % smooth level
ERD_c3_stock(stocksize,1) = mean(ERD_c3_stock_tmp(stocksize-smoothlevel:stocksize,1),1);
%%%%%%%%%%%%%%%%%

set(plot0,'ydata',-ERD_c3_stock(stocksize,1)*fb,'xdata',3); drawnow;   % bar feedback

precnt_sample = cnt_sample;
cnt_task = cnt_task + 1;
cnt_raw = cnt_raw + 1;
    
end
