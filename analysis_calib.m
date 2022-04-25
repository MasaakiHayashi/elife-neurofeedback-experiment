% Origibnal filename: analysis_calib.mat
% changed 18/06/10

% Rest(5s) - Ready(1s) - Task(6s) - interval(3s), in total(15s)

% power_c4(c3)_rest = [Fs,RestTime*Fs/cal_time+1,trial_max]
% power_c4(c3)_task = [Fs,(TaskTime-ReadyTime)*Fs/cal_time+1,trial_max]

% ref_time = [2 5]
% ref_win = [21 41]
% task_ref_time = [7 11]; -> in this case, taskref_time = [1 5]

% Freq_min_c4:Freq_max_c4 = [8:13] (default)


%% Set filename

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

filename_calib = strcat(Subjectname,'_Calib_',Number,'_',date_y,date_m,date_d,'.mat');


%% Confirm whether to continue following processing

list = dir('*.mat');
assess = 0;

[list_num,~] = size(list);

for i = 1:list_num
    listfile = list(i,1);
    listfilename = char(listfile.name);
    correct = strcmp(filename_calib,listfilename);
    if  correct == 1
        assess = 1;
    end
end

measure = 1;
if assess == 1
    choice = questdlg('同一ファイルが存在するため，操作を続行するとファイルが上書きされます。',...
            '警告','続行','中止','中止');
    switch choice
        case '続行'
            measure = 1;
        case '中止'
            measure = 0;
    end
end


%% calculate stable value and median

if measure == 1
    
taskref_time = [1 6];
taskref_win = [taskref_time(1)*Fs/cal_time+1 (taskref_time(2)-1)*Fs/cal_time+1];

power_c4_ref = squeeze(nanmedian(power_c4_rest(:,ref_win(1):end,:),2)); % [Fs, trial]
power_c4_taskref = squeeze(nanmedian(power_c4_task(:,taskref_win(1):end,:),2));
power_c3_ref = squeeze(nanmedian(power_c3_rest(:,ref_win(1):end,:),2));
power_c3_taskref = squeeze(nanmedian(power_c3_task(:,taskref_win(1):end,:),2));

power_c4_ref_med = nanmedian(power_c4_ref,2);  % [Fs,1]
power_c4_taskref_med = nanmedian(power_c4_taskref,2);
power_c3_ref_med = nanmedian(power_c3_ref,2);
power_c3_taskref_med = nanmedian(power_c3_taskref,2);


%% figure: power spectra

figure(51)
subplot(1,2,1)
plot(power_c4_ref_med,'b'); hold on;
plot(power_c4_taskref_med,'r'); hold on;
legend('Rest','Task');
title('c4');
xlim([5 30])

subplot(1,2,2)
plot(power_c3_ref_med,'b'); hold on;
plot(power_c3_taskref_med,'r'); hold on;
legend('Rest','Task');
title('c3');
xlim([5 30])

% % % figure(51)  % c4
% % % for fi = 8:13 % that means 7-9 Hz ~ 12-14 Hz
% % %     subplot(2,3,fi-7)
% % %     plot(mean(power_c4_ref_med(fi:fi+2,1),1),'b'); hold on;
% % %     plot(mean(power_c4_taskref_med(fi:fi+2,1),1),'r');
% % %     title(strcat(num2str(fi-1),'-',num2str(fi+1),' Hz'));
% % %     legend('Rest','Task');
% % % end
% % % set(gcf,'color',[1 1 1]);


%% determine FOI (case. 1: depend on power spectra)

[~,tmp_freq_c4] = max(power_c4_ref_med(8:15,1));
Freq_max_c4 = tmp_freq_c4+8;
[~,tmp_freq_c3] = max(power_c3_ref_med(8:15,1));
Freq_max_c3 = tmp_freq_c3+8;

Freq_min_c4 = Freq_max_c4-2;
Freq_min_c3 = Freq_max_c3-2;

% [Freq_min_c4 Freq_max_c4]
% [Freq_min_c3 Freq_max_c3]


%% calculate ERD

ERD_c4_rest = NaN(Fs,RestTime*Fs/cal_time+1,trial_max);
ERD_c3_rest = NaN(Fs,RestTime*Fs/cal_time+1,trial_max);
ERD_c4_task = NaN(Fs,(TaskTime-ReadyTime)*Fs/cal_time+1,trial_max);
ERD_c3_task = NaN(Fs,(TaskTime-ReadyTime)*Fs/cal_time+1,trial_max);

for wi = 1:size(power_c4_rest,2)
    ERD_c4_rest(:,wi,:) = (squeeze(power_c4_rest(:,wi,:))-power_c4_ref)./power_c4_ref*100;
    ERD_c3_rest(:,wi,:) = (squeeze(power_c3_rest(:,wi,:))-power_c3_ref)./power_c3_ref*100;
end

for wi = 1:size(power_c4_task,2)
    ERD_c4_task(:,wi,:) = (squeeze(power_c4_task(:,wi,:))-power_c4_ref)./power_c4_ref*100;
    ERD_c3_task(:,wi,:) = (squeeze(power_c3_task(:,wi,:))-power_c3_ref)./power_c3_ref*100;
end

ERD_c4_task_stb = squeeze(nanmedian(ERD_c4_task(:,taskref_win(1):taskref_win(2),:),2));
ERD_c3_task_stb = squeeze(nanmedian(ERD_c3_task(:,taskref_win(1):taskref_win(2),:),2));

ERD_c4_task_stb_med = nanmedian(ERD_c4_task_stb,2);
ERD_c3_task_stb_med = nanmedian(ERD_c3_task_stb,2);


%% determine FOI (case. 2: depend on ERD)

% Freq_min_c3 = 8;    % default setting
% Freq_max_c3 = 13;
% Freq_min_c4 = 8;
% Freq_max_c4 = 13;

tmp_ERD_c4_min = 0;
tmp_ERD_c3_min = 0;

for fi = 8:13 % that means 7-9 Hz ~ 12-14 Hz
    if mean(ERD_c4_task_stb_med(fi:fi+2,1),1) < tmp_ERD_c4_min
        tmp_ERD_c4_min = mean(ERD_c4_task_stb_med(fi:fi+2,1),1);
        Freq_min_c4 = fi-1;
        Freq_max_c4 = fi+1;    
    end
    
    if mean(ERD_c3_task_stb_med(fi:fi+2,1),1) < tmp_ERD_c3_min
        tmp_ERD_c3_min = mean(ERD_c3_task_stb_med(fi:fi+2,1),1);
        Freq_min_c3 = fi-1;
        Freq_max_c3 = fi+1;    
    end
end

[Freq_min_c4 Freq_max_c4]
[Freq_min_c3 Freq_max_c3]


%% calculate median and 25% from distribution

rep_quan = [0.05, 0.25, 0.5, 0.75, 0.95];
% % rep_quan2 = [0.05, 0.1625, 0.275, 0.3875, 0.5, 0.6125, 0.725, 0.8375, 0.95];
rep_quan2 = [0.05, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 0.95];


power_c4_rest_dst = reshape(power_c4_rest(:,ref_win(1):end,:),Fs,[]);
power_c3_rest_dst = reshape(power_c3_rest(:,ref_win(1):end,:),Fs,[]);
power_c4_task_dst = reshape(power_c4_task(:,taskref_win(1):end,:),Fs,[]);
power_c3_task_dst = reshape(power_c3_task(:,taskref_win(1):end,:),Fs,[]);

power_c4_rest_dst_alpha = mean(power_c4_rest_dst(Freq_min_c4+1:Freq_max_c4+1,:),1);
power_c3_rest_dst_alpha = mean(power_c3_rest_dst(Freq_min_c3+1:Freq_max_c3+1,:),1);
power_c4_task_dst_alpha = mean(power_c4_task_dst(Freq_min_c4+1:Freq_max_c4+1,:),1);
power_c3_task_dst_alpha = mean(power_c3_task_dst(Freq_min_c3+1:Freq_max_c3+1,:),1);

ERD_c4_rest_dst = reshape(ERD_c4_rest(:,ref_win(1):end,:),Fs,[]);
ERD_c3_rest_dst = reshape(ERD_c3_rest(:,ref_win(1):end,:),Fs,[]);
ERD_c4_task_dst = reshape(ERD_c4_task(:,taskref_win(1):end,:),Fs,[]);
ERD_c3_task_dst = reshape(ERD_c3_task(:,taskref_win(1):end,:),Fs,[]);

ERD_c4_rest_dst_alpha = mean(ERD_c4_rest_dst(Freq_min_c4+1:Freq_max_c4+1,:),1);
ERD_c3_rest_dst_alpha = mean(ERD_c3_rest_dst(Freq_min_c3+1:Freq_max_c3+1,:),1);
ERD_c4_task_dst_alpha = mean(ERD_c4_task_dst(Freq_min_c4+1:Freq_max_c4+1,:),1);
ERD_c3_task_dst_alpha = mean(ERD_c3_task_dst(Freq_min_c3+1:Freq_max_c3+1,:),1);

% power_c4_rest_q = quantile(power_c4_rest_dst_alpha,rep_quan);
% power_c3_rest_q = quantile(power_c3_rest_dst_alpha,rep_quan);
% power_c4_task_q = quantile(power_c4_task_dst_alpha,rep_quan);
% power_c3_task_q = quantile(power_c3_task_dst_alpha,rep_quan);
% 
% ERD_c4_rest_q = quantile(ERD_c4_rest_dst_alpha,rep_quan);
% ERD_c3_rest_q = quantile(ERD_c3_rest_dst_alpha,rep_quan);
% ERD_c4_task_q = quantile(ERD_c4_task_dst_alpha,rep_quan);
% ERD_c3_task_q = quantile(ERD_c3_task_dst_alpha,rep_quan);

power_c4_rest_q2 = quantile(power_c4_rest_dst_alpha,rep_quan2);
power_c3_rest_q2 = quantile(power_c3_rest_dst_alpha,rep_quan2);
power_c4_task_q2 = quantile(power_c4_task_dst_alpha,rep_quan2);
power_c3_task_q2 = quantile(power_c3_task_dst_alpha,rep_quan2);

ERD_c4_rest_q2 = quantile(ERD_c4_rest_dst_alpha,rep_quan2);
ERD_c3_rest_q2 = quantile(ERD_c3_rest_dst_alpha,rep_quan2);
ERD_c4_task_q2 = quantile(ERD_c4_task_dst_alpha,rep_quan2);
ERD_c3_task_q2 = quantile(ERD_c3_task_dst_alpha,rep_quan2);


%% draw distribution during rest and task

numbin = 200;

figure(53)  % power, c4
subplot(2,2,1)
hist(power_c4_task_dst_alpha,numbin,'binlimits',[0 0.1],'facecolor',[0 0.4470 0.7410]); hold on;
hist(power_c4_rest_dst_alpha,numbin,'binlimits',[0 0.3],'edgecolor',[0.8500 0.3250 0.00980]); hold on;
% tmp_h_c4 = findobj(gca,'Type','patch');
% set(tmp_h_c4,'FaceColor',[0 0.4470 0.7410],'EdgeColor',[0 0 0])
Ylimhist  = get(gca,'ylim');
plot([power_c4_rest_q2(3) power_c4_rest_q2(3)],Ylimhist,'LineWidth',1,'color',[0 0.4470 0.7410]);
plot([power_c4_task_q2(3) power_c4_task_q2(3)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
plot([power_c4_rest_q2(5) power_c4_rest_q2(5)],Ylimhist,'LineWidth',3,'color',[0 0.4470 0.7410]);
plot([power_c4_task_q2(5) power_c4_task_q2(5)],Ylimhist,'LineWidth',3,'color',[0.8500 0.3250 0.00980]);
plot([power_c4_rest_q2(7) power_c4_rest_q2(7)],Ylimhist,'LineWidth',1,'color',[0 0.4470 0.7410]);
plot([power_c4_task_q2(7) power_c4_task_q2(7)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
xlabel('Power, [μV]'); ylabel('Frequency');
ylim([0 Ylimhist(2)]);
set(gcf,'color',[1 1 1]);
legend('rest','task','location','northeast');
title('C4');
hold off;

subplot(2,2,2)  % power, c3
hist(power_c3_rest_dst_alpha,numbin,'binlimits',[0 0.3],'edgecolor',[0 0.4470 0.7410]); hold on;
hist(power_c3_task_dst_alpha,numbin,'binlimits',[0 0.1],'facecolor',[0.8500 0.3250 0.00980]); hold on;
Ylimhist  = get(gca,'ylim');
plot([power_c3_rest_q2(3) power_c3_rest_q2(3)],Ylimhist,'LineWidth',1,'color',[0 0.4470 0.7410]);
plot([power_c3_task_q2(3) power_c3_task_q2(3)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
plot([power_c3_rest_q2(5) power_c3_rest_q2(5)],Ylimhist,'LineWidth',3,'color',[0 0.4470 0.7410]);
plot([power_c3_task_q2(5) power_c3_task_q2(5)],Ylimhist,'LineWidth',3,'color',[0.8500 0.3250 0.00980]);
plot([power_c3_rest_q2(7) power_c3_rest_q2(7)],Ylimhist,'LineWidth',1,'color',[0 0.4470 0.7410]);
plot([power_c3_task_q2(7) power_c3_task_q2(7)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
xlabel('Power, [μV]'); ylabel('Frequency');
ylim([0 Ylimhist(2)]);
set(gcf,'color',[1 1 1]);
legend('rest','task','location','northeast');
title('C3');
hold off;

subplot(2,2,3)  % ERD, c4
hist(ERD_c4_rest_dst_alpha,numbin,'binlimits',[-100 100],'facecolor',[0 0.4470 0.7410]); hold on;
hist(ERD_c4_task_dst_alpha,numbin,'binlimits',[-100 100],'facecolor',[0.8500 0.3250 0.00980]); hold on;
Ylimhist  = get(gca,'ylim');
plot([ERD_c4_rest_q2(3) ERD_c4_rest_q2(3)],Ylimhist,'LineWidth',1,'color',[0 0.4470 0.7410]);
plot([ERD_c4_task_q2(3) ERD_c4_task_q2(3)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
plot([ERD_c4_rest_q2(5) ERD_c4_rest_q2(5)],Ylimhist,'LineWidth',3,'color',[0 0.4470 0.7410]);
plot([ERD_c4_task_q2(5) ERD_c4_task_q2(5)],Ylimhist,'LineWidth',3,'color',[0.8500 0.3250 0.00980]);
plot([ERD_c4_rest_q2(7) ERD_c4_rest_q2(7)],Ylimhist,'LineWidth',1,'color',[0 0.4470 0.7410]);
plot([ERD_c4_task_q2(7) ERD_c4_task_q2(7)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
xlabel('ERD/ERS, %'); ylabel('Frequency');
xlim([-100 300]); ylim([0 Ylimhist(2)]);
set(gcf,'color',[1 1 1]);
legend('rest','task','location','northeast');
title('C4');
hold off;

subplot(2,2,4)  % ERD, c3
hist(ERD_c3_rest_dst_alpha,numbin,'binlimits',[-100 100],'facecolor',[0 0.4470 0.7410]); hold on;
hist(ERD_c3_task_dst_alpha,numbin,'binlimits',[-100 100],'facecolor',[0.8500 0.3250 0.00980]); hold on;
Ylimhist  = get(gca,'ylim');
plot([ERD_c3_rest_q2(3) ERD_c3_rest_q2(3)],Ylimhist,'LineWidth',1,'color',[0 0.4470 0.7410]);
plot([ERD_c3_task_q2(3) ERD_c3_task_q2(3)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
plot([ERD_c3_rest_q2(5) ERD_c3_rest_q2(5)],Ylimhist,'LineWidth',3,'color',[0 0.4470 0.7410]);
plot([ERD_c3_task_q2(5) ERD_c3_task_q2(5)],Ylimhist,'LineWidth',3,'color',[0.8500 0.3250 0.00980]);
plot([ERD_c3_rest_q2(7) ERD_c3_rest_q2(7)],Ylimhist,'LineWidth',1,'color',[0 0.4470 0.7410]);
plot([ERD_c3_task_q2(7) ERD_c3_task_q2(7)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
xlabel('ERD/ERS, %'); ylabel('Frequency');
xlim([-100 300]); ylim([0 Ylimhist(2)]);
set(gcf,'color',[1 1 1]);
legend('rest','task','location','northeast');
title('C3');
hold off;

% % % pd = fitdist(ERD_c4_rest_dst_alpha.','Rayleigh');


%% ERD(C4) during rest (C3が[-25 25]の時で）

ERD_c4_rest_dst_alpha_c3 = zeros(1,1);
power_c4_rest_dst_alpha_c3 = zeros(1,1);
cnt_within_c3_restERD = 0;
cnt_within_c3_restpwr = 0;

for wi = 1:size(ERD_c3_rest_dst_alpha,2)
    if ERD_c3_rest_dst_alpha(1,wi) > ERD_c3_rest_q2(1,4) && ERD_c3_rest_dst_alpha(1,wi) < ERD_c3_rest_q2(1,6)
        ERD_c4_rest_dst_alpha_c3(1,cnt_within_c3_restERD+1) = ERD_c4_rest_dst_alpha(1,wi);
        cnt_within_c3_restERD = cnt_within_c3_restERD + 1;
    end
    if power_c3_rest_dst_alpha(1,wi) > power_c3_rest_q2(1,4) && power_c3_rest_dst_alpha(1,wi) < power_c3_rest_q2(1,6)
        power_c4_rest_dst_alpha_c3(1,cnt_within_c3_restERD+1) = power_c4_rest_dst_alpha(1,wi);
        cnt_within_c3_restpwr = cnt_within_c3_restpwr + 1;
    end
end

ERD_c4_rest_q2_c3 = quantile(ERD_c4_rest_dst_alpha_c3,rep_quan2);
power_c4_rest_q2_c3 = quantile(power_c4_rest_dst_alpha_c3,rep_quan2);


%% ERD(C4) during task (C3が[-25 25]の時で）

ERD_c4_task_dst_alpha_c3 = zeros(1,1);
power_c4_task_dst_alpha_c3 = zeros(1,1);
cnt_within_c3_taskERD = 0;
cnt_within_c3_taskpwr = 0;

for wi = 1:size(ERD_c3_task_dst_alpha,2)
    if ERD_c3_task_dst_alpha(1,wi) > ERD_c3_task_q2(1,4) && ERD_c3_task_dst_alpha(1,wi) < ERD_c3_task_q2(1,6)
        ERD_c4_task_dst_alpha_c3(1,cnt_within_c3_taskERD+1) = ERD_c4_task_dst_alpha(1,wi);
        cnt_within_c3_taskERD = cnt_within_c3_taskERD + 1;
    end
    if power_c3_task_dst_alpha(1,wi) > power_c3_task_q2(1,4) && power_c3_task_dst_alpha(1,wi) < power_c3_task_q2(1,6)
        power_c4_task_dst_alpha_c3(1,cnt_within_c3_taskERD+1) = power_c4_task_dst_alpha(1,wi);
        cnt_within_c3_taskpwr = cnt_within_c3_taskpwr + 1;
    end
end

ERD_c4_task_q2_c3 = quantile(ERD_c4_task_dst_alpha_c3,rep_quan2);
power_c4_task_q2_c3 = quantile(power_c4_task_dst_alpha_c3,rep_quan2);

figure(61)
subplot(1,2,1)
hist(ERD_c4_task_dst_alpha,numbin,'binlimits',[-100 100],'facecolor',[0.8500 0.3250 0.00980]); hold on;
Ylimhist  = get(gca,'ylim');
plot([ERD_c4_task_q2(3) ERD_c4_task_q2(3)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
plot([ERD_c4_task_q2(5) ERD_c4_task_q2(5)],Ylimhist,'LineWidth',3,'color',[0.8500 0.3250 0.00980]);
plot([ERD_c4_task_q2(7) ERD_c4_task_q2(7)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
xlabel('ERD/ERS, %'); ylabel('Frequency');
xlim([-100 300]); ylim([0 Ylimhist(2)]);
set(gcf,'color',[1 1 1]);
title('ERD(C4) during task');
hold off;

subplot(1,2,2)
hist(ERD_c4_task_dst_alpha_c3,numbin,'binlimits',[-100 100],'facecolor',[0.8500 0.3250 0.00980]); hold on;
Ylimhist  = get(gca,'ylim');
plot([ERD_c4_task_q2_c3(3) ERD_c4_task_q2_c3(3)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
plot([ERD_c4_task_q2_c3(5) ERD_c4_task_q2_c3(5)],Ylimhist,'LineWidth',3,'color',[0.8500 0.3250 0.00980]);
plot([ERD_c4_task_q2_c3(7) ERD_c4_task_q2_c3(7)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
xlabel('ERD/ERS, %'); ylabel('Frequency');
xlim([-100 300]); ylim([0 Ylimhist(2)]);
set(gcf,'color',[1 1 1]);
title('ERD(C4) during task');
hold off;


%% create axis, Rest

% % % axis_quan_rest(1,1:76) = 0.05:0.00266:0.25;
% % % axis_quan_rest(1,76:126) = 0.25:0.01:0.75;
% % % axis_quan_rest(1,126:201) = 0.75:0.00266:0.95;
% % % axis_quan_rest(1:201) = 0.05:0.0045:0.95;

axis_resolution = 1:201;
axis_quan_rest(axis_resolution) = 0:0.005:1;

model_order = 7;

%%% power %%%
axis_c4_rest_pwr = quantile(power_c4_rest_dst_alpha_c3,axis_quan_rest);
axis_c3_rest_pwr = quantile(power_c3_rest_dst_alpha,axis_quan_rest);

% [model_p_c4_rest_pwr,~,mu_c4_rest_pwr] = polyfit(axis_resolution,axis_c4_rest_pwr,model_order);  % n次近似（最小2乗法）
% model_y_c4_rest_pwr = polyval(model_p_c4_rest_pwr,axis_resolution,[],mu_c4_rest_pwr);
% [model_p_c3_rest_pwr,~,mu_c3_rest_pwr] = polyfit(axis_resolution,axis_c3_rest_pwr,model_order);  % n次近似（最小2乗法）
% model_y_c3_rest_pwr = polyval(model_p_c3_rest_pwr,axis_resolution,[],mu_c3_rest_pwr);

%%% ERD %%%
axis_c4_rest_ERD = quantile(ERD_c4_rest_dst_alpha_c3,axis_quan_rest);
axis_c3_rest_ERD = quantile(ERD_c3_rest_dst_alpha,axis_quan_rest);

% [model_p_c4_rest_ERD,~,mu_c4_rest_ERD] = polyfit(axis_resolution,axis_c4_rest_ERD,model_order);
% model_y_c4_rest_ERD = polyval(model_p_c4_rest_ERD,axis_resolution,[],mu_c4_rest_ERD);
% [model_p_c3_rest_ERD,~,mu_c3_rest_ERD] = polyfit(axis_resolution,axis_c3_rest_ERD,model_order);
% model_y_c3_rest_ERD = polyval(model_p_c3_rest_ERD,axis_resolution,[],mu_c3_rest_ERD);

%%% figure %%%
% figure(55)
% subplot(2,2,1)  % power, c4
% plot(axis_c4_rest_pwr); hold on; plot(model_y_c4_rest_pwr);
% title('Power (C4) during Rest');
% subplot(2,2,2)  % power, c3
% plot(axis_c3_rest_pwr); hold on; plot(model_y_c3_rest_pwr);
% title('Power (C3) during Rest');
% subplot(2,2,3)  % ERD, c4
% plot(axis_c4_rest_ERD); hold on; plot(model_y_c4_rest_ERD);
% title('ERD (C4) during Rest');
% subplot(2,2,4)  % ERD, c3
% plot(axis_c3_rest_ERD); hold on; plot(model_y_c3_rest_ERD);
% title('ERD (C3) during Rest');


%% create axis, Task

axis_quan_task(axis_resolution) = 0:0.005:1;

%%% power %%%
axis_c4_task_pwr = quantile(power_c4_task_dst_alpha_c3,axis_quan_task);
axis_c3_task_pwr = quantile(power_c3_task_dst_alpha,axis_quan_task);

% [model_p_c4_task_pwr,~,mu_c4_task_pwr] = polyfit(axis_resolution,axis_c4_task_pwr,model_order);  % n次近似（最小2乗法）
% model_y_c4_task_pwr = polyval(model_p_c4_task_pwr,axis_resolution,[],mu_c4_task_pwr);
% [model_p_c3_task_pwr,~,mu_c3_task_pwr] = polyfit(axis_resolution,axis_c3_task_pwr,model_order);  % n次近似（最小2乗法）
% model_y_c3_task_pwr = polyval(model_p_c3_task_pwr,axis_resolution,[],mu_c3_task_pwr);

%%% ERD %%%
axis_c4_task_ERD = quantile(ERD_c4_task_dst_alpha_c3,axis_quan_task);
axis_c3_task_ERD = quantile(ERD_c3_task_dst_alpha,axis_quan_task);

% [model_p_c4_task_ERD,~,mu_c4_task_ERD] = polyfit(axis_resolution,axis_c4_task_ERD,model_order);
% model_y_c4_task_ERD = polyval(model_p_c4_task_ERD,axis_resolution,[],mu_c4_task_ERD);
% [model_p_c3_task_ERD,~,mu_c3_task_ERD] = polyfit(axis_resolution,axis_c3_task_ERD,model_order);
% model_y_c3_task_ERD = polyval(model_p_c3_task_ERD,axis_resolution,[],mu_c3_task_ERD);

%%% figure %%%
% figure(56)
% subplot(2,2,1)  % power, c4
% plot(axis_c4_task_pwr); hold on; plot(model_y_c4_task_pwr);
% title('Power (C4) during task');
% subplot(2,2,2)  % power, c3
% plot(axis_c3_task_pwr); hold on; plot(model_y_c3_task_pwr);
% title('Power (C3) during task');
% subplot(2,2,3)  % ERD, c4
% plot(axis_c4_task_ERD); hold on; plot(model_y_c4_task_ERD);
% title('ERD (C4) during task');
% subplot(2,2,4)  % ERD, c3
% plot(axis_c3_task_ERD); hold on; plot(model_y_c3_task_ERD);
% title('ERD (C3) during task');


%% read MVC file

% [MVCFileName,PathMVCFile] = uigetfile('*.mat','Select a MVC file');
% % addpath('PathMVCFile');
% 
% uiopen(MVCFileName,'True')
MVC = 100;

%% save

save(filename_calib,'power_c4_rest','power_c4_task','power_c3_rest','power_c3_task',...
    'Freq_min_c4','Freq_max_c4','Freq_min_c3','Freq_max_c3',...
    'axis_c4_rest_pwr','axis_c3_rest_pwr','axis_c4_rest_ERD','axis_c3_rest_ERD',...
    'axis_c4_task_pwr','axis_c3_task_pwr','axis_c4_task_ERD','axis_c3_task_ERD',...
    'MVC');

end  % if measure == 1



