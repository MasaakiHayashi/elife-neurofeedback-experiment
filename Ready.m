if cnt_sample >= precnt_sample + cal_time   % calculate ERD every 100 ms

if  ReadyStopper == 0
    set(t,'string','Ready','color','y'); drawnow;
    Do.queueOutputData(OutputSignal(2,:));
    Do.startBackground();    
 
    fprintf(obj1, '%s', 'Q@n''');

    ReadyStopper = 1;

    % calculate reference    mean -> median (2/11)
    TempRefFFTPower_c4 = squeeze(nanmedian(power_c4_rest(:,ref_win(1):ref_win(2),trial_cnt),2));
    TempRefFFTPower_c3 = squeeze(nanmedian(power_c3_rest(:,ref_win(1):ref_win(2),trial_cnt),2));
end

Rawdata(:,:,cnt_raw+1,trial_cnt) = Buffer(1:downsampling:Buffer_FreshRate,1:129);

precnt_sample = cnt_sample;    % rest‚Å’l•Ï‚í‚Á‚Ä‚é‚©‚çtask‚Ü‚Å‚É–ß‚µ‚Æ‚­
cnt_raw = cnt_raw + 1;

end

