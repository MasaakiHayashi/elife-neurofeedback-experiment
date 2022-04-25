if cnt_sample >= precnt_sample + cal_time

if TaskStopper == 0
    if CONDI == 1
        set(t,'string','Rest','color','g'); drawnow;
    else
        set(t,'string','Imagery','color','r'); drawnow;
    end
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


%% Power feedback

power_c4_alpha = mean(TempTaskFFTPower_c4(Freq_min_c4+1:Freq_max_c4+1,1));
power_c3_alpha = mean(TempTaskFFTPower_c4(Freq_min_c4+1:Freq_max_c4+1,1));

power_c4_stock_tmp(1:stocksize-1,1) = power_c4_stock_tmp(2:stocksize,1);
power_c3_stock_tmp(1:stocksize-1,1) = power_c3_stock_tmp(2:stocksize,1);
power_c4_stock_tmp(stocksize,1) = power_c4_alpha;    % power(stocksize,1) = new data
power_c3_stock_tmp(stocksize,1) = power_c3_alpha;

%%% smoothing and redifinition of power value %%%
power_c4_stock(1:stocksize-1,1) = power_c4_stock(2:stocksize,1);
power_c3_stock(1:stocksize-1,1) = power_c3_stock(2:stocksize,1);

tmp_power_c4_stock = mean(power_c4_stock_tmp(stocksize-smoothlevel:stocksize,1),1);  % smooth level
tmp_power_c3_stock = mean(power_c3_stock_tmp(stocksize-smoothlevel:stocksize,1),1);

if AXIS == 1    % redefinition
    if CONDI == 1 % rest
        [~,power_c4_stock(stocksize,1)] = Search_nearest(tmp_power_c4_stock,axis_c4_rest_pwr);
        [~,power_c3_stock(stocksize,1)] = Search_nearest(tmp_power_c3_stock,axis_c3_rest_pwr);
    elseif CONDI == 2 || CONDI == 3 || CONDI == 4  % MI
        [~,power_c4_stock(stocksize,1)] = Search_nearest(tmp_power_c4_stock,axis_c4_task_pwr);
        [~,power_c3_stock(stocksize,1)] = Search_nearest(tmp_power_c3_stock,axis_c3_task_pwr);
    end
elseif AXIS == 2
    if CONDI == 1 % rest
        power_c4_stock(stocksize,1) = tmp_power_c4_stock;
        power_c3_stock(stocksize,1) = tmp_power_c3_stock;
    elseif CONDI == 2 || CONDI == 3 || CONDI == 4  % MI
        power_c4_stock(stocksize,1) = tmp_power_c4_stock;
        power_c3_stock(stocksize,1) = tmp_power_c3_stock;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% TMS stimulation

% set(pltpast10,'ydata',-power_c3_stock(1,1)*fb,'xdata',-power_c4_stock(1,1)*fb); drawnow limitrate;
% set(pltpast9,'ydata',-power_c3_stock(2,1)*fb,'xdata',-power_c4_stock(2,1)*fb); drawnow limitrate;
% set(pltpast8,'ydata',-power_c3_stock(3,1)*fb,'xdata',-power_c4_stock(3,1)*fb); drawnow limitrate;
% set(pltpast7,'ydata',-power_c3_stock(4,1)*fb,'xdata',-power_c4_stock(4,1)*fb); drawnow limitrate;
% set(pltpast6,'ydata',-power_c3_stock(5,1)*fb,'xdata',-power_c4_stock(5,1)*fb); drawnow limitrate;
set(pltpast5,'ydata',-power_c3_stock(6,1)*fb,'xdata',-power_c4_stock(6,1)*fb); drawnow limitrate;
set(pltpast4,'ydata',-power_c3_stock(7,1)*fb,'xdata',-power_c4_stock(7,1)*fb); drawnow limitrate;
set(pltpast3,'ydata',-power_c3_stock(8,1)*fb,'xdata',-power_c4_stock(8,1)*fb); drawnow limitrate;
set(pltpast2,'ydata',-power_c3_stock(9,1)*fb,'xdata',-power_c4_stock(9,1)*fb); drawnow limitrate;
set(pltpast1,'ydata',-power_c3_stock(10,1)*fb,'xdata',-power_c4_stock(10,1)*fb); drawnow limitrate;
set(pltnow,'ydata',-power_c3_stock(stocksize,1)*fb,'xdata',-power_c4_stock(stocksize,1)*fb); drawnow limitrate;

if cnt_sample > TMSTime(1,1)*Fs && cnt_sample <= LimitTime_trial(trial_cnt,1)*Fs && TMSStopper == 0
    if all(-power_c3_stock(stocksize-wait_pt+1:stocksize,1) >= def_trig_cue(1)) && ...
            all(-power_c3_stock(stocksize-wait_pt+1:stocksize,1) <= def_trig_cue(2))
        if all(-power_c4_stock(stocksize-wait_pt+1:stocksize,1) >= def_trig_cue(3)) && ...
                all(-power_c4_stock(stocksize-wait_pt+1:stocksize,1) <= def_trig_cue(4))
            Do.queueOutputData([0 0 0 0]);
            Do.startBackground();
            fprintf(obj1,'EHr');
            
            power_c3_stim(:,trial_cnt) = power_c3_stock;
            power_c4_stim(:,trial_cnt) = power_c4_stock;
            cnt_sample_stim(trial_cnt,1) = cnt_sample;
            
            if stim_TSCS(stim_cnt_num+1,1) == 0  % stim TS
                stim_cnt_TS = stim_cnt_TS + 1;
            else  % stim TSCS
                stim_cnt_TSCS = stim_cnt_TSCS + 1;
            end
            stim_TSCS_real(trial_cnt,1) = stim_TSCS(stim_cnt_num+1,1);
            stim_cnt_num = stim_cnt_TS + stim_cnt_TSCS;

            success = Rapid2_SetPowerLevel(obj1, 0, 0);
            
            TMSStopper = 1;
        end
    end
end
if cnt_sample > LimitTime_trial(trial_cnt,1)*Fs && TMSStopper == 0
    Do.queueOutputData([0 0 0 0]);
    Do.startBackground();
    fprintf(obj1,'EHr');

    power_c3_stim(:,trial_cnt) = power_c3_stock;
    power_c4_stim(:,trial_cnt) = power_c4_stock;
    cnt_sample_stim(trial_cnt,1) = cnt_sample;

    stim_TSCS_real(trial_cnt,1) = stim_TSCS(stim_cnt_num+1,1);

    success = Rapid2_SetPowerLevel(obj1, 0, 0); % ‚±‚±‚ª‰ñ‚ê‚Îinterval‚ÌŽžŠÔ‚ð’Z‚­‚µ‚Ä‚àok

    TMSStopper = 1;
end

precnt_sample = cnt_sample;
cnt_task = cnt_task + 1;
cnt_raw = cnt_raw + 1;


end
