
% Di  = daq.createSession('ni');
Do  = daq.createSession('ni');

Do.addAnalogOutputChannel('Dev2',[0 1 2 3],'voltage');   % @5F

% % Do.queueOutputData([5 5 5]);

OutputSignal = [ ...
    5,0,0,0; ...
    0,5,0,0; ...
    5,5,0,0; ...
    0,0,5,0; ...
    5,0,5,0; ...
    0,5,5,0; ...
    5,5,5,0; ...
    0,0,0,5; ...
    5,0,0,5; ...
    0,5,0,5; ...
]; % DIN1~10


%% for simultaneous measurement

 
% if EEGTMS == 1
%     
%     fs_MEP = 100;   % default: 10000 H
%     sense_MEP = sense;
% 
%     Di.addAnalogInputChannel('Dev2',[0 1 2 3],'Voltage'); % for R-FDI, L-FDI, TS, CS
%     Di.Rate = fs_MEP;
%     Di.DurationInSeconds = load_time;
%     Di.NotifyWhenDataAvailableExceeds = 1000;
%     Di.IsContinuous = true; % CAUSION
%     
%     target = 0.1;
%     MVC = 100;
% 
%     %%% EMG monitoring %%%
% %     figure(11);
% %     x_EMG = [0,0];
% %     fbbar = bar(x_EMG); hold on;
% %     plot([0.5 2.5],[target target],'-r','LineWidth',2);
% %     set(gcf ,'NumberTitle','off','toolbar','none','menubar','none',...
% %         'position',[scrsz(1,1)+20 scrsz(1,2)+20 scrsz(1,3)*0.3 scrsz(1,4)*0.7]);
% %     set(gca,'YLim',[0 target*2]);
%     %%%%%%%%%%%%%%%%%%%%%%
% 
% fid1 = fopen('log.bin','w');
% % lh = addlistener(Di,'DataAvailable',@(src,eventdata) plotData(src,eventdata,MVC,sense_MEP,fbbar));
% lh2 = addlistener(Di,'DataAvailable', @(src,event) logData(src,event,fid1));
% 
% Di.startBackground();
% % % % [data_MEP,time,triggerTime] = Di.startForeground();
% 
% end