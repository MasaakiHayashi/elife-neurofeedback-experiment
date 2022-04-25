%% Main program
% Rest(5s) - Ready(1s) - Task(6s) - interval(6s), in total(18s)

RestTime = 5;
ReadyTime = 6;
TMSTime = [6.5 11.5];    % stim range
LimitTime = [10.5 11.5];
TaskTime = 12;
InterTime = 16; % changed 19/03/06

SetParameter;
SetNI;
SetSerial;

GetData_Parameter;
ti2 = ListenAmpserver;

while(recordingtag == 0)
    if trial_cnt <= trial_max % && stim_cnt_num <= stim_num
        GetData_NA400ver164;
        
        if cnt_sample <= RestTime*Fs
            Rest;
             
        elseif cnt_sample > RestTime*Fs && cnt_sample <= ReadyTime*Fs
            Ready;
       
        elseif cnt_sample > ReadyTime*Fs && cnt_sample <= TaskTime*Fs % && sample_Num < 20
            if PwrERD == 2
                Task_pwr;
            elseif PwrERD == 1
                Task_ERD;
            end
        
        elseif cnt_sample > TaskTime*Fs && cnt_sample <= InterTime*Fs
            interval;
            
        elseif cnt_sample > InterTime*Fs
            ResetTrial;
            trial_cnt = trial_cnt+1;
        end
            
    else
        break;
    end
end
% profile viewer

% % close figure 100 figure 1000
STOP;
close figure 100 figure 1000
fclose(ti2);


%% time-frequency map and topographic map

if DRAW == 1
    DrawingTimeTopo;
end

%% Stop daq and analyze MEP

% MEP_analysis;


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

if CONDI == 1; condi = 'Rest';
elseif CONDI == 2; condi = 'H';
elseif CONDI == 3; condi = 'M';
elseif CONDI == 4; condi = 'L';
elseif CONDI == 5; condi = 'Ctrl';
end

filename_main = strcat(Subjectname,'_',condi,'_',Number,'_',date_y,date_m,date_d,'.mat');


%% Confirm whether to continue following processing

list = dir('*.mat');
assess = 0;

[list_num,~] = size(list);

for i = 1:list_num
    listfile = list(i,1);
    listfilename = char(listfile.name);
    correct = strcmp(filename_main,listfilename);
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


%%

if measure == 1
    if PwrERD == 2
        save(filename_main,'CalibFileName','CONDI','power_c3_stim','power_c4_stim',...
            'cnt_sample_stim','LimitTime_trial','stim_TSCS','stim_TSCS_real',...
            'CSIntens','TSIntens');%,...
%             'seg_data','sense_MEP','fs_MEP','right_amp','left_amp');
    elseif PwrERD == 1
        save(filename_main,'CalibFileName','CONDI','ERD_c3_stim','ERD_c4_stim',...
            'cnt_sample_stim','LimitTime_trial','stim_TSCS','stim_TSCS_real',...
            'CSIntens','TSIntens');%,...
%             'seg_data','sense_MEP','fs_MEP','right_amp','left_amp');
    end
end

SessionCount    =   SessionCount+1;
TempNum         =   num2str(SessionCount);
TempNum2        =   strcat('Session ',TempNum);
set(UISession,'string',TempNum2);
stop(Do);

