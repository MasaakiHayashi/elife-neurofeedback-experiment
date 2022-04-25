%% Main program
% Rest(5s) - Ready(1s) - Task(6s) - interval(6s), in total(18s)

RestTime = 5;
ReadyTime = 6;
TMSTime = [6.5 11.5];    % stim range
LimitTime = [10.5 11.5];
TaskTime = 12;
InterTime = 16; % changed 19/03/06

SetParameter; EEGTMS = 0;   % SetParamers‚Å1‚É‚È‚Á‚Ä‚¢‚é‚©‚ç0‚É–ß‚·
SetNI;
SetSerial;

GetData_Parameter;
ti2 = ListenAmpserver;

while(recordingtag == 0)
    if trial_cnt <= trial_calib_num
        GetData_NA400ver164;
        
        if cnt_sample <= RestTime*Fs
            Rest;
             
        elseif cnt_sample > RestTime*Fs && cnt_sample <= ReadyTime*Fs
            Ready;
       
        elseif cnt_sample > ReadyTime*Fs && cnt_sample <= TaskTime*Fs
            Task_Calib;
        
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

close figure 100 figure 1000
fclose(ti2);


%% time-frequency map and topographic map

if DRAW == 1
    DrawingTimeTopo;
end


%% analyze calib data

analysis_calib;


%%

SessionCount    =   SessionCount+1;
TempNum         =   num2str(SessionCount);
TempNum2        =   strcat('Session ',TempNum);
set(UISession,'string',TempNum2);
stop(Do);


