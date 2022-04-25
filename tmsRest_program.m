while(recordingtag == 0)
    if trial_count < 2 
       GetData_NA400ver164;
       %/////////////////////////////
           Signals(count_sample2+1:count_sample2+size(new_EEGData,1),:) = new_EEGData;
           count_sample2 = count_sample2 + sample_Num;
       if count_sample >= count_sample_pre2 + 5010
           fprintf(obj1,'%s','Q@n');
           count_sample_pre2 = count_sample;
       end
       if State_Flag == 1 && TMScount <= 26
           if count_sample >= count_sample_pre1 + TMSfs(TMScount)*1000
              count_sample_pre1 = count_sample;
              TMSflag = 1;
              TMScount= TMScount + 1;
%              fprintf(obj1,'b@]');
%              fprintf(obj1,'%s','Q@n');
              if mod(TMScount,10)==1
                 fprintf('\n%s%d%s\n','>>>>>>>>>>>',TMScount,'<<<<<<<<<<<');  
              end
           end
       end
       
       if TMSflag == 1
          fprintf('%d%s',TMSfs(TMScount),'>');
%           queueOutputData(Do,OutputSignal(7,:)); % unknown error occured
%           startBackground(Do);
          fprintf(obj1,  'EHr');%ŽhŒƒ—p
          TMSflag = 0;
          count_sample_pre2 = count_sample;
       end
       
       if count_sample>= 500 && State_Flag == 0
          State_Flag = 11; % Rest Ready
          Stopper = 0;
       elseif count_sample>=2000 && State_Flag == 11
          State_Flag = 1; % Rest Start
          Stopper = 0;
       elseif count_sample > TMStime*1000+5000 && State_Flag == 1
          State_Flag = 6; % Rest END Ready
          Stopper = 0;
       end
       if Stopper == 0
          switch State_Flag
              case 11
                  queueOutputData(Do,[0,0,0,0]);
                  startBackground(Do);
                  count_sample2 = 0;
                  set(t,'string','Rest','color','k');
                  drawnow;
                  Stopper = 1;
              case 1
                  set(t,'string','+');drawnow;
                  queueOutputData(Do,OutputSignal(1,:));
                  startBackground(Do);
                  Stopper = 1;
                  count_sample_pre1 = count_sample;
                  fprintf('%s%d%s\n','>>>>>>>>>>>0',TMScount,'<<<<<<<<<<<');
                  fprintf('%d%s',TMSfs(TMScount),'>');
              case 6
                  stop(Di);
                  set(t,'string','Finish','color','k');drawnow;
                  queueOutputData(Do,OutputSignal(6,:));
                  startBackground(Do);
                  Stopper=1;
                  tmsSignals2 = Signals;
                  trial_count = trial_count+1;
          end 
       end
      
    else
        break;
    end
end
fclose(ti2);
fclose(fid1);
stop(Do);
stop(Di);
fclose(obj1);
fprintf('\n%s\n','Finish')
time = clock;
Time = num2str(time(1));
for i = 1:4
    if time(i+1)< 10
       Time = [Time,'0',num2str(time(i+1))]; %#ok<*AGROW>
    else
       Time = [Time,num2str(time(i+1))];
    end
end
TMScount_pre = TMScount;
save(['data_Resting',Time],'tmsSignals2')

try
    movefile([pwd,'\tmslog.bin'],[pwd,'\rest_data_',Time,'.bin']);
catch
    fclose all;
    movefile([pwd,'\tmslog.bin'],[pwd,'\rest_data_',Time,'.bin']);
end
