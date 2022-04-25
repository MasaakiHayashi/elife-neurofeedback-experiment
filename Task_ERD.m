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


%% ERD feedback

ERD_c4_alpha = mean((TempTaskFFTPower_c4(Freq_min_c4+1:Freq_max_c4+1,1)-...
    TempRefFFTPower_c4(Freq_min_c4+1:Freq_max_c4+1,1))./...
    TempRefFFTPower_c4(Freq_min_c4+1:Freq_max_c4+1,1)*100);
ERD_c3_alpha = mean((TempTaskFFTPower_c3(Freq_min_c3+1:Freq_max_c3+1,1)-...
    TempRefFFTPower_c3(Freq_min_c3+1:Freq_max_c3+1,1))./...
    TempRefFFTPower_c3(Freq_min_c3+1:Freq_max_c3+1,1)*100);

ERD_c4_stock_tmp(1:stocksize-1,1) = ERD_c4_stock_tmp(2:stocksize,1);
ERD_c3_stock_tmp(1:stocksize-1,1) = ERD_c3_stock_tmp(2:stocksize,1);
ERD_c4_stock_tmp(stocksize,1) = ERD_c4_alpha;    % ERD(stocksize,1) = new data
ERD_c3_stock_tmp(stocksize,1) = ERD_c3_alpha;

%%% smoothing and redifinition of ERD value %%%
ERD_c4_stock(1:stocksize-1,1) = ERD_c4_stock(2:stocksize,1);
ERD_c3_stock(1:stocksize-1,1) = ERD_c3_stock(2:stocksize,1);

tmp_ERD_c4_stock = mean(ERD_c4_stock_tmp(stocksize-smoothlevel:stocksize,1),1);  % smooth level
tmp_ERD_c3_stock = mean(ERD_c3_stock_tmp(stocksize-smoothlevel:stocksize,1),1);

if AXIS == 1    % redefinition
    if CONDI == 1 % rest
    [~,ERD_c4_stock(stocksize,1)] = Search_nearest(tmp_ERD_c4_stock,axis_c4_rest_ERD);
    [~,ERD_c3_stock(stocksize,1)] = Search_nearest(tmp_ERD_c3_stock,axis_c3_rest_ERD);
    else
    [~,ERD_c4_stock(stocksize,1)] = Search_nearest(tmp_ERD_c4_stock,axis_c4_task_ERD);
    [~,ERD_c3_stock(stocksize,1)] = Search_nearest(tmp_ERD_c3_stock,axis_c3_task_ERD);
    end
elseif AXIS == 2
    if CONDI == 1 % rest
        ERD_c4_stock(stocksize,1) = tmp_ERD_c4_stock;
        ERD_c3_stock(stocksize,1) = tmp_ERD_c3_stock;
    else
        ERD_c4_stock(stocksize,1) = tmp_ERD_c4_stock;
        ERD_c3_stock(stocksize,1) = tmp_ERD_c3_stock;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% TMS stimulation

% set(pltpast10,'ydata',-ERD_c3_stock(1,1)*fb,'xdata',-ERD_c4_stock(1,1)*fb); drawnow limitrate;
% set(pltpast9,'ydata',-ERD_c3_stock(2,1)*fb,'xdata',-ERD_c4_stock(2,1)*fb); drawnow limitrate;
% set(pltpast8,'ydata',-ERD_c3_stock(3,1)*fb,'xdata',-ERD_c4_stock(3,1)*fb); drawnow limitrate;
% set(pltpast7,'ydata',-ERD_c3_stock(4,1)*fb,'xdata',-ERD_c4_stock(4,1)*fb); drawnow limitrate;
% set(pltpast6,'ydata',-ERD_c3_stock(5,1)*fb,'xdata',-ERD_c4_stock(5,1)*fb); drawnow limitrate;
set(pltpast5,'ydata',-ERD_c3_stock(6,1)*fb,'xdata',-ERD_c4_stock(6,1)*fb); drawnow limitrate;
set(pltpast4,'ydata',-ERD_c3_stock(7,1)*fb,'xdata',-ERD_c4_stock(7,1)*fb); drawnow limitrate;
set(pltpast3,'ydata',-ERD_c3_stock(8,1)*fb,'xdata',-ERD_c4_stock(8,1)*fb); drawnow limitrate;
set(pltpast2,'ydata',-ERD_c3_stock(9,1)*fb,'xdata',-ERD_c4_stock(9,1)*fb); drawnow limitrate;
set(pltpast1,'ydata',-ERD_c3_stock(10,1)*fb,'xdata',-ERD_c4_stock(10,1)*fb); drawnow limitrate;
set(pltnow,'ydata',-ERD_c3_stock(stocksize,1)*fb,'xdata',-ERD_c4_stock(stocksize,1)*fb); drawnow limitrate;

if cnt_sample > TMSTime(1,1)*Fs && cnt_sample <= LimitTime_trial(trial_cnt,1)*Fs && TMSStopper == 0
    if all(-ERD_c3_stock(stocksize-wait_pt+1:stocksize,1) >= def_trig_cue(1)) && ...
            all(-ERD_c3_stock(stocksize-wait_pt+1:stocksize,1) <= def_trig_cue(2))
        if all(-ERD_c4_stock(stocksize-wait_pt+1:stocksize,1) >= def_trig_cue(3)) && ...
                all(-ERD_c4_stock(stocksize-wait_pt+1:stocksize,1) <= def_trig_cue(4))
            Do.queueOutputData([0 0 0 0]);
            Do.startBackground();
            fprintf(obj1,'EHr');
            
            ERD_c3_stim(:,trial_cnt) = ERD_c3_stock;
            ERD_c4_stim(:,trial_cnt) = ERD_c4_stock;
            cnt_sample_stim(trial_cnt,1) = cnt_sample;
            
            if stim_TSCS(stim_cnt_num+1,1) == 0  % stim TS
                stim_cnt_TS = stim_cnt_TS + 1;
            else  % stim TSCS
                stim_cnt_TSCS = stim_cnt_TSCS + 1;
            end
            stim_TSCS_real(trial_cnt,1) = stim_TSCS(stim_cnt_num+1,1);
            stim_cnt_num = stim_cnt_TS + stim_cnt_TSCS;
            
            success = Rapid2_SetPowerLevel(obj1, 0, 0); % ‚±‚±‚ª‰ñ‚ê‚Îinterval‚ÌŽžŠÔ‚ð’Z‚­‚µ‚Ä‚àok
            
            TMSStopper = 1;
        end
    end
end
if cnt_sample > LimitTime_trial(trial_cnt,1)*Fs && TMSStopper == 0
    Do.queueOutputData([0 0 0 0]);
    Do.startBackground();
    fprintf(obj1,'EHr');

    ERD_c3_stim(:,trial_cnt) = ERD_c3_stock;
    ERD_c4_stim(:,trial_cnt) = ERD_c4_stock;
    cnt_sample_stim(trial_cnt,1) = cnt_sample;

    stim_TSCS_real(trial_cnt,1) = stim_TSCS(stim_cnt_num+1,1);

    success = Rapid2_SetPowerLevel(obj1, 0, 0); % ‚±‚±‚ª‰ñ‚ê‚Îinterval‚ÌŽžŠÔ‚ð’Z‚­‚µ‚Ä‚àok

    TMSStopper = 1;
end

precnt_sample = cnt_sample;
cnt_task = cnt_task + 1;
cnt_raw = cnt_raw + 1;


end
