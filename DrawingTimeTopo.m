%% get data   % Rowdata = [time ch window trial]

data_all = permute(Rawdata(:,:,:,1:end-1),[1,3,2,4]);  % data_all = [time window ch trial]

fs = size(data_all,1);  % after down sampling
window_num = size(data_all,2);
ch = size(data_all,3);
trial_NUM = size(data_all,4);

H = hanning(fs);                   % [fs,1]
H = repmat(H,[1,ch,trial_NUM]);    % [fs ch trial]

alpha_c3 = [Freq_min_c3+1 Freq_max_c3+1];
beta = [14+1 20+1];


%% pre-processing

%%%%% small lap. and CAR(all ch) %%%%%
for i = 1:trial_NUM
    for j = 1:window_num
        x = squeeze(data_all(:,j,:,i));  % x = [time ch]
        x_mean = mean(x,2);
    
        for k = 1:ch
            data_all(:,j,k,i) = x(:,k) - x_mean(:,1);
        end
    end
end

data_all(:,:,ch_c3(4),:) = data_all(:,:,ch_c3(4),:) - (data_all(:,:,ch_c3(1),:)./6 + ...
    data_all(:,:,ch_c3(2),:)./6 + data_all(:,:,ch_c3(3),:)./6 + data_all(:,:,ch_c3(5),:)./6 + ...
    data_all(:,:,ch_c3(6),:)./6 + data_all(:,:,ch_c3(7),:)./6);
                
data_all(:,:,ch_c4(4),:) = data_all(:,:,ch_c4(4),:) - (data_all(:,:,ch_c4(1),:)./6 + ...
    data_all(:,:,ch_c4(2),:)./6 + data_all(:,:,ch_c4(3),:)./6 + data_all(:,:,ch_c4(5),:)./6 + ...
    data_all(:,:,ch_c4(6),:)./6 + data_all(:,:,ch_c4(7),:)./6);

%%%%% detrend, BPF, Notch %%%%%
for j = 1:window_num
    for k = 1:ch
        x = squeeze(data_all(:,j,k,:));  % x = [time trial]
        data_all(:,j,k,:) = detrend(x);
    end
end

[b,a] = butter(n,[0.1 24]/(fs/2),'bandpass');  % determine FOI depending on fs
data_all = filtfilt(b,a,data_all);
% [d,c] = butter(n,[49 51]/(fs/2),'stop');
% data_all = filtfilt(d,c,data_all);


%% calculate power, ERP, and LI

data_fft = zeros(fs,ch,trial_NUM);
power = zeros(fs,window_num,ch,trial_NUM);

%%%%% calculate power [fs window ch trial] %%%%%
for j = 1:window_num-1
    data_temp = squeeze(data_all(:,j,:,:));
    data_fft = fft(data_temp.*H);
    power(:,j,:,:) = 2*((abs(data_fft).^2)/(fs*fs));
end

%%%%% calculate ERP [fs window_num ch trial_NUM] %%%%%
ref_power = zeros(fs,ch,trial_NUM);
ERP = zeros(fs,window_num,ch,trial_NUM);

for l = 1:trial_NUM
    for k = 1:ch
        ref_power(:,k,l) = squeeze(median(power(:,ref_win(1):ref_win(2),k,l),2)); % mean -> median (2/11)
        for j = 1:window_num
            ERP(:,j,k,l) = (power(:,j,k,l)-ref_power(:,k,l))./ref_power(:,k,l)*100;
        end
    end
end

ERP_alpha = squeeze(mean(ERP(alpha_c3(1):alpha_c3(2),:,:,:),1));  % ERP_alpha = [window ch trial]
ERP_beta = squeeze(mean(ERP(beta(1):beta(2),:,:,:),1));
ERP_c3 = squeeze(ERP(:,:,36,:));  % ERP_c3 = [fs window trial]
ERP_c4 = squeeze(ERP(:,:,104,:));

ERP_c3_median = median(ERP_c3,3);
ERP_c4_median = median(ERP_c4,3);

%% drawing time-frequency map

figure(61)  % C3.  mean -> median (2/11)
imagesc(ERP_c3_median); hold on;
Ylim  = get(gca,'ylim');
plot([(ReadyTime)*1000/100+1 (ReadyTime)*1000/100+1],Ylim,'k','linewidth',1);
axis xy;
xlabel('Time [s]');ylabel('Frequency [Hz]');
xlim([0 window_num]); ylim([5 30]);
colormap(jet);
caxis([-100 100]);
set(gcf,'color',[1 1 1]);
set(gca,'fontsize',14,'fontname','Times New Roman','xtick', ...
    [(5-1)*1000/100+1,(10-1)*1000/100+1,(15-1)*1000/100+1],'xticklabel',{'5','10','15'})

figure(62)  % C4
imagesc(ERP_c4_median); hold on;
Ylim  = get(gca,'ylim');
plot([(ReadyTime)*1000/100+1 (ReadyTime)*1000/100+1],Ylim,'k','linewidth',1);
axis xy;
xlabel('Time [s]');ylabel('Frequency [Hz]');
xlim([0 window_num]); ylim([5 30]);
colormap(jet);
caxis([-100 100]);
set(gcf,'color',[1 1 1]);
set(gca,'fontsize',14,'fontname','Times New Roman','xtick', ...
    [(5-1)*1000/100+1,(10-1)*1000/100+1,(15-1)*1000/100+1],'xticklabel',{'5','10','15'})


%% drawing topography map

ChannnelLocation;

ERP_alpha_task = squeeze(median(ERP_alpha(ref_task_win(1):ref_task_win(2),:,:),1));  % mean -> median (2/11)
ERP_beta_task = squeeze(median(ERP_beta(ref_task_win(1):ref_task_win(2),:,:),1));
ERP_alpha_task_median = squeeze(median(ERP_alpha_task,2));  % mean -> median
ERP_beta_task_median = squeeze(median(ERP_beta_task,2));

%%%%% figure %%%%%  
figure(63)
topography(ERP_alpha_task_median(:,1),loc,3);  % alpha
caxis([-100 100]);
set(gcf,'color',[1 1 1]);

figure(64)
topography(ERP_beta_task_median(:,1),loc,3);  % beta
caxis([-100 100]);
set(gcf,'color',[1 1 1]);


%% drawing histgram of ERD/ERS during the task

% numbin = 20;
% quanvalue = 0.25;
% 
% ERD_c4_task_median(SessionCount,1) = median(median(ERD_c4_task,1),2);
% ERD_c3_task_median(SessionCount,1) = median(median(ERD_c3_task,1),2);
% ERD_c4_task_quan(SessionCount,1) = median(quantile(ERD_c4_task,quanvalue,1),2);
% ERD_c3_task_quan(SessionCount,1) = median(quantile(ERD_c3_task,quanvalue,1),2);
% 
% figure(65)
% hist(ERD_c4_task,numbin,'binlimits',[-100 100]); hold on;
% hist(ERD_c3_task,numbin,'binlimits',[-100 100]);
% Ylimhist  = get(gca,'ylim');
% plot([ERD_c4_task_median(SessionCount,1) ERD_c4_task_median(SessionCount,1)],Ylimhist,'LineWidth',1,'color',[0 0.4470 0.7410]);
% plot([ERD_c3_task_median(SessionCount,1) ERD_c3_task_median(SessionCount,1)],Ylimhist,'LineWidth',1,'color',[0.8500 0.3250 0.00980]);
% plot([ERD_c4_task_quan(SessionCount,1) ERD_c4_task_quan(SessionCount,1)],Ylimhist,'LineWidth',3,'color',[0 0.4470 0.7410]);
% plot([ERD_c3_task_quan(SessionCount,1) ERD_c3_task_quan(SessionCount,1)],Ylimhist,'LineWidth',3,'color',[0.8500 0.3250 0.00980]);
% xlabel('ERD/ERS, %'); ylabel('Frequency');
% ylim([0 Ylimhist(2)]);
% set(gcf,'color',[1 1 1]);
% legend('C4','C3','location','northeast');
% hold off;




