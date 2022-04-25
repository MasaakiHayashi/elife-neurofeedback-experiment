% Origibnal filename: MVC_measurement.mat
% changed 18/06/21

%% Set filename

MVCside = get(UIMVCside,'Value'); 
if MVCside == 1     % Right FDI
    analysis_ch = 2;
    side = '_right_'
elseif MVCside == 2 % Left FDI
    analysis_ch = 3;
    side = '_left_'
end

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

filename_MVC = strcat(Subjectname,'_',date_y,date_m,date_d,'_MVC',side,'_',Number,'.mat');

EEGTMS = 0;


%% Confirm whether to continue processing

list = dir('*.mat');
assess = 0; % "0" -> not exist same filename

[list_num,~] = size(list);

for i = 1:list_num
    listfile = list(i,1);
    listfilename = char(listfile.name);
    correct = strcmp(filename_MVC,listfilename);    % same filename -> true("1")
    if correct == 1
        assess = 1;
    end
end

measure = 1;    % "1" -> continue measurement
if assess == 1
    choice = questdlg('同一ファイルが存在するため，計測を続行するとファイルが上書きされます。',...
            '警告','続行','中止','中止');
    switch choice
        case '続行'
            measure = 1;
        case '中止'
            measure = 0;
    end
end


%% Start to measure

scrsz = get(0,'MonitorPosition');

if measure == 1

fs_MVC = 2000;
sense_MVC = sense;

NIs = daq.createSession('ni'); % Create data acqu. session for specific vendor
NIs.addAnalogInputChannel('Dev2', [0 1], 'Voltage'); % for R-FDI, L-FDI
NIs.Rate = fs_MVC;                 % Rate of operation in scans per second
NIs.DurationInSeconds = 10;    % Specify duration of acquisition
NIs.NotifyWhenDataAvailableExceeds = 100;

figure(2)
plot([0 10],[1 1],'-r'); hold on;
plot([3 3],[0 2],'-k'); plot([8 8],[0 2],'-k');
set(gcf ,'NumberTitle','off','toolbar','none','menubar','none');
set(gcf,'position',[scrsz(2,1) scrsz(2,2) scrsz(2,3) scrsz(2,4)]);  % sub monitor
set(gca,'YLim',[0 2],'XLim',[0 10]);

fid1 = fopen('log.bin','w');   % for write
lh = addlistener(NIs,'DataAvailable',...
    @(src,event)plot(event.TimeStamps,abs(event.Data)));
%lh = addlistener(NIs,'DataAvailable',...
%     @(src,event)plot(event.TimeStamps,rms(event.Data)));

lh2 = addlistener(NIs,'DataAvailable',...
    @(src,event)logData(src,event,fid1));

NIs.startBackground();
NIs.wait();

fid2 = fopen('log.bin','r');  % for read
[data_MVC,count] = fread(fid2,[3,inf],'double');    % data(1,:) -> time

pause(5);

delete(lh);
delete(lh2);


% post-processing

figure(3)
subplot(2,1,1)
    plot(data_MVC(1,:),data_MVC(2,:));  % right
subplot(2,1,2)
    plot(data_MVC(1,:),data_MVC(3,:));  % left
set(gcf,'position',[scrsz(1,1)+50 scrsz(1,2)+300 scrsz(1,3)*0.8 scrsz(1,4)*0.5]); % main

time_range = [4,7];
MVC = rms(data_MVC(analysis_ch,time_range(1)*fs_MVC:time_range(2)*fs_MVC))

save(filename_MVC,'data_MVC','MVC','sense_MVC','fs_MVC');

pause(5)
close(2)

end
