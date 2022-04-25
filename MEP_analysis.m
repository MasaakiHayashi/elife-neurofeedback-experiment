% Origibnal filename: MEP_analysis.mat
% changed 18/06/10, modified 18/11/21


%% Set filename

if EEGTMS == 0  % if not simultaneous measurement
    date = clock;
    date_y = num2str(date(1)-2000);
    if date(2) < 10
        date_m = strcat('0',num2str(date(2)));
    else
        date_m = num2str(date(2));
    end

    if date(3) < 10
        date_d = strcat('0',num2str(date(3)));
    else
        date_d = num2str(date(3));
    end

    filename_MEP = strcat(Subjectname,'_',date_y,date_m,date_d,'_MEP_',Number,'.mat');
end


%% Idetify trigger

% fs_MEP = 10000;
 
pri_stim = 0.2;                          % saving time range [s] prior to stim
time = (0:1/fs_MEP:pri_stim*2)-pri_stim;    % [s]
length = size(time,2);

trigger_TS = data_MEP(4,:);                  % TS trigger
trigger_CS = data_MEP(5,:);                  % CS trigger
[~,col] = find(trigger_TS > 1);          % find values of nonzero elements
col_size = size(col,2);
col2 = col;

for i = 1:col_size-1
    if col(i+1) == col(i)+1
        col2(i+1) = 0;
    end
end

th = find(col2);

col = col(th);

%[pks, locs] = findpeaks(data_MEP(4,:),'MinPeakHeight',0.5,'MinPeakDistance',Fs*0.5);
stim_num = size(col,2);

ch_num = size(data_MEP,1);


%% make seg_data sets

seg_data = zeros(ch_num,length,stim_num);

for i = 1:stim_num
    seg_data(:,:,i) = data_MEP(:,col(i)-pri_stim*fs_MEP:col(i)+pri_stim*fs_MEP);
end

seg_data_rev = seg_data;
seg_data_rev(2:3,:,:) = seg_data(2:3,:,:).*sense_MEP;


%% calculate MEP amplitue

finpk_time = [pri_stim*fs_MEP+0.005*fs_MEP,pri_stim*fs_MEP+0.05*fs_MEP]; % e.g. [2050,2500]
right_amp = zeros(stim_num,1);
left_amp = zeros(stim_num,1);

for i = 1:stim_num
    right_amp(i,1) = max(seg_data_rev(2,finpk_time(1):finpk_time(2),i)) - ...
                    min(seg_data_rev(2,finpk_time(1):finpk_time(2),i));
    left_amp(i,1) = max(seg_data_rev(3,finpk_time(1):finpk_time(2),i))- ...
                    min(seg_data_rev(3,finpk_time(1):finpk_time(2),i));
end

mean_right_amp = mean(right_amp,1)
mean_left_amp = mean(left_amp,1)

ylim_right = [mean_right_amp*-2 mean_right_amp*2];
ylim_left = [mean_left_amp*-2 mean_left_amp*2];

if isnan(ylim_right) == 1   % for avoid error
    ylim_right = [0 100];
    ylim_left = [0 100];
end


%% draw figure

fig_time = [(length-1)*4/8+1, (length-1)*6/8]; % e.g. [2001,4000] if fs_MEP = 10000 Hz
scrsz = get(0,'MonitorPosition');

figure(21)
set(gcf,'position',[scrsz(1,1)+50 scrsz(1,2)+350 scrsz(1,3)*0.3 scrsz(1,4)*0.5]);
for i = 1:stim_num
    subplot(4,1,1); hold on;
        plot(time,seg_data_rev(2,:,i));
        ylim(ylim_right)
    subplot(4,1,2); hold on;
        plot(time,seg_data_rev(3,:,i));
        ylim(ylim_left)
    subplot(4,1,3); hold on;
        plot(time,seg_data_rev(4,:,i));
    subplot(4,1,4); hold on;
        plot(time,seg_data_rev(5,:,i));
end

figure(22)
set(gcf,'position',[scrsz(1,3)*0.35 scrsz(1,2)+350 scrsz(1,3)*0.5 scrsz(1,4)*0.5]);
for i = 1:stim_num
    subplot(2,2,1); hold on;
        plot(time(fig_time(1):fig_time(2)),seg_data_rev(2,fig_time(1):fig_time(2),i))
        ylim(ylim_right);ylabel('Overwriting','Fontsize',12)
    subplot(2,2,2); hold on;
        plot(time(fig_time(1):fig_time(2)),seg_data_rev(3,fig_time(1):fig_time(2),i))
        ylim(ylim_left)
end
subplot(2,2,3)
    plot(time(fig_time(1):fig_time(2)),mean(seg_data_rev(2,fig_time(1):fig_time(2),:),3))
    ylim(ylim_right);ylabel('Averaging','Fontsize',12)
subplot(2,2,4)
    plot(time(fig_time(1):fig_time(2)),mean(seg_data_rev(3,fig_time(1):fig_time(2),:),3))
    ylim(ylim_left)

if EEGTMS == 0  % if not simultaneous measurement
    save(filename_MEP,'seg_data','sense_MEP','fs_MEP','right_amp','left_amp');
end
