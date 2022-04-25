
% clear figure 10 figure 100

Fs     = 1000;

% % maxERS = 100;
fntsz1 = 130;

%%% 5F %%%
%%% scr size = [1281 -225 1920 1177]
% pos1 = [1281 -225 700 1177];  % figure 10
% pos2 = [1951 -225 1170 1177]; % figure 100
% pos3 = [20 450 500 200];      % figure 1000
% pos4 = [550 450 500 200];      % figure 1001
%%%%%%%%%%
% pos1 = [1 41 550 737];
% pos2 = [551 41 730 737];

%%% 9s3 %%%
pos1 = [scrsz(2,1) scrsz(2,2) scrsz(2,3)*7/16 scrsz(2,4)];  % figure 10
pos2 = [scrsz(2,1)+scrsz(2,3)*7/16 scrsz(2,2) scrsz(2,3)*9/16 scrsz(2,4)]; % figure 100
pos3 = [20 450 500 200];      % figure 1000
pos4 = [550 450 500 200];      % figure 1001


%% FB or NoFB, Condition, ERD or Power, figure, simultaneous measurement
FB = get(UIFB,'Value');
if FB == 1
   fb = 1;
elseif FB == 2
   fb = 0;
end

CONDI = get(UICONDI,'Value');   % 1:Rest, 2:i-ERD(High), 3:middle, 4:low
PwrERD = get(UIPwrERD,'Value'); % 1:Power, 2:ERD
DRAW = get(UIDRAW,'Value'); 
AXIS = get(UIAXIS,'Value');
STIM = get(UISTIM,'Value');

EEGTMS = 1; % if simultaneous measurement (EEG and TMS)


%% preparing figures

%%% Figure(1000) : provided ERD intensity %%%
if calibtag == 0    % for main session
disp2 = figure(1000); hold on;

boxclr = [0/255 0/255 255/255];

clr10 = [80/255 80/255 80/255];
clr9 = [100/255 100/255 100/255];
clr8 = [120/255 120/255 120/255];
clr7 = [140/255 140/255 140/255];
clr6 = [160/255 160/255 160/255];
clr5 = [180/255 180/255 180/255];
clr4 = [200/255 200/255 200/255];
clr3 = [220/255 220/255 220/255];
clr2 = [240/255 240/255 240/255];
clr1 = [255/255 255/255 255/255];

SetTargetBox;

pltpast10 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr10,'MarkerEdgeColor',clr10,'MarkerSize',15);
pltpast9 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr9,'MarkerEdgeColor',clr9,'MarkerSize',15);
pltpast8 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr8,'MarkerEdgeColor',clr8,'MarkerSize',15);
pltpast7 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr7,'MarkerEdgeColor',clr7,'MarkerSize',15);
pltpast6 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr6,'MarkerEdgeColor',clr6,'MarkerSize',15);
pltpast5 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr5,'MarkerEdgeColor',clr5,'MarkerSize',15);
pltpast4 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr4,'MarkerEdgeColor',clr4,'MarkerSize',15);
pltpast3 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr3,'MarkerEdgeColor',clr3,'MarkerSize',15);
pltpast2 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr2,'MarkerEdgeColor',clr2,'MarkerSize',15);
pltpast1 = plot(axis_x0,axis_y0,'wo','MarkerFaceColor',clr1,'MarkerEdgeColor',clr1,'MarkerSize',15);
pltnow   = plot(axis_x0,axis_y0,'ro','MarkerFaceColor','r','MarkerSize',15);
% cross    = plot(-100,-20,'w+','MarkerSize',15);     % ’Ž‹“_

set(gcf,'menu','none','toolbar','none','position',pos2,'color',[0 0 0]);
axis tight; axis off;
xlim(axis_xlim)
ylim(axis_ylim)
hold off;

elseif calibtag == 1 % for calib session, bar feedback
disp2 = figure(1000); hold on;
line0 = line([1 5],[0 0],'color','r','LineWidth',4);
line1 = line([1 2.5],[0 0],'color','g','LineWidth',4);
line2 = line([3.5 5],[0 0],'color','g','LineWidth',4);
plot0 = bar(3,0,'r','BarWidth',1,'LineStyle','none');
baseline_handle=get(plot0,'BaseLine');
set(baseline_handle,'LineStyle','none');
set(gcf,'menu','none','toolbar','none','position',pos2,'color',[0 0 0])
axis tight; axis off
xlim([1 5])
ylim([-100 100])
hold off;
end

%%% Figure(100) : task instruction %%%
disp = figure(100); hold on;
set(gcf,'color',[0 0 0],'position',pos1,'menu','none','toolbar','none');
axis off; axis tight;
t = text(1,1,'Rest','fontsize',fntsz1,'color','y','FontWeight','bold',...
    'HorizontalAlignment','center');
ylim([0 2]); xlim([0 2]);
hold off;


%% Set parameters

%%% trial %%%
trial_calib_num = 20;
% if calibtag == 1
%     trial_max = trial_calib_num;
% end

trial_time = InterTime;

%%% channel %%%
% ch_c4(1:7) = [87 93 103 104 105 110 111]; % for SLAP
% ch_c3(1:7) = [29 30 35 36 37 41 42];
ch_c4(1:7) = [79 92 102 104 106 116 118]; % for LLAP
ch_c3(1:7) = [7 20 34 36 46 52 54];

getch = 130;                              % EMG ch

%%% band-pass filter %%%
n           = 3;
Band        = [1 100];
Wn          = [Band(1) Band(2)]/(Fs/2);
[B,A]       = butter(n, Wn, 'bandpass');

EMG_Band    = [5 450];
EMG_Wn      = [EMG_Band(1) EMG_Band(2)]/(Fs/2);
[EMGB,EMGA] = butter(n, EMG_Wn, 'bandpass');
    
%%% band-stop filter %%%
stopBand        = [49 51];
stopWn          = [stopBand(1) stopBand(2)]/(Fs/2);
[stopB,stopA]   = butter(n-1, stopWn, 'stop');

%%% TMS Parameters %%%
wait_pt         = 3;    % ‰½“_ŽlŠp‚ÉŽû‚Ü‚Á‚½‚çŽhŒƒ‚ð‚·‚é‚©

stim_num        = 40;   % updata 19/03/15
stim_TS_num     = 10;
stim_TSCS_num   = 10;
stim_cnt_TS     = 0;
stim_cnt_TSCS   = 0;
stim_cnt_num    = 0;

stim_TSCS       = zeros(stim_num,1);   % 0:TS only, 1:CS+TS
for ti = 1:stim_num/2
    [~,tmpstim_TSCS] = sort(rand(2,1),1);
    stim_TSCS(2*(ti-1)+1,1) = tmpstim_TSCS(1,1)-1;
    stim_TSCS(2*(ti-1)+2,1) = tmpstim_TSCS(2,1)-1;
end
stim_TSCS_real  = NaN(trial_max,1);   % 0:TS only, 1:CS+TS, 2:not stimulated

[~,rand_tmp] = sort(rand(trial_max,1),1);
LimitTime_trial = zeros(trial_max,1);
for ti = 1:trial_max
    LimitTime_trial(ti,1) = LimitTime(1) + (LimitTime(2)-LimitTime(1))/trial_max*rand_tmp(ti,1);
end

%%% initialazation %%%
cnt_sample      = 1;
precnt_sample   = 1;

RestStopper     = 0;
ReadyStopper    = 0;
TaskStopper     = 0;
BufferStopper   = 0;
TMSStopper      = 0;

trial_cnt       = 1;

if exist('SessionCount','var') == 0
     SessionCount = 1;
end


%% for ERD calculation

ttt       = 299;    % Mov[end-299:end]
cal_time  = 100;    % every calculate 100 ms

cnt_num         = 0;
cnt_rest        = 0;
cnt_ready       = 0;
cnt_task        = 0;
cnt_raw         = 0;

power_c4_rest = NaN(Fs,RestTime*Fs/cal_time+1,trial_max);
power_c3_rest = NaN(Fs,RestTime*Fs/cal_time+1,trial_max);
power_c4_task = NaN(Fs,(TaskTime-ReadyTime)*Fs/cal_time+1,trial_max);
power_c3_task = NaN(Fs,(TaskTime-ReadyTime)*Fs/cal_time+1,trial_max);

ref_time = [1 5];
ref_win = [ref_time(1)*Fs/cal_time+1 (ref_time(2)-1)*Fs/cal_time+1];
ref_task_time = [ReadyTime+1 TaskTime-1];  % default : [7 11]
ref_task_win = [ref_task_time(1)*Fs/cal_time+1 (ref_task_time(2)-1)*Fs/cal_time+1];

stocksize = 11; % 100ms*10stock
power_c4_stock = zeros(stocksize,1);
power_c3_stock = zeros(stocksize,1);
power_c4_stock_tmp = zeros(stocksize,1);
power_c3_stock_tmp = zeros(stocksize,1);
ERD_c4_stock = zeros(stocksize,1);
ERD_c3_stock = zeros(stocksize,1);
ERD_c4_stock_tmp = zeros(stocksize,1);
ERD_c3_stock_tmp = zeros(stocksize,1);

power_c4_stim = zeros(stocksize,trial_max);   % for TMS
power_c3_stim = zeros(stocksize,trial_max);
ERD_c4_stim = zeros(stocksize,trial_max);   % for TMS
ERD_c3_stim = zeros(stocksize,trial_max);
cnt_sample_stim = zeros(trial_max,1);

smoothlevel = 9;    % default: 9

h = hanning(Fs);
downsampling = 20;  % 1000 Hz -> 50 Hz

  