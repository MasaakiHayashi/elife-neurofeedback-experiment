SetSerial;

plevel = [40 0 40 0 40 0 40 0 40 0];
plevel = [30 60 30 60];
pause_time = 4;

for pi = 1:size(plevel,2)
    tic
    success = Rapid2_SetPowerLevel(obj1,plevel(1,pi),0);
    pause(pause_time);
    
    fprintf(obj1, '%s', 'Q@n''');
    pause(pause_time);
    
%     fprintf(obj1, '%s', 'Q@n''');
%     pause(pause_time);
    
%     success = Rapid2_SetPowerLevel(obj1,plevel(1,pi),0);
%     pause(pause_time);
    
    fprintf(obj1,'EHr');
    pause(pause_time);
    
%     fprintf(obj1, '%s', 'Q@n''');
%     pause(pause_time);
    toc
end


%%

% % fprintf(obj1,'b@]');
% % fprintf(obj1, '%s', 'Q@n''');
% % Di.queueOutputData([0 0 0 0]); Di.startBackground();
% % fprintf(obj1,'%s','EBx');
% % Di.queueOutputData([0 0 0 5]); Di.startBackground();
% % fprintf(obj1,'EHr');

