% Origibnal filename: MEP_measurement_2.mat
% changed 18/06/21

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

filename = strcat(Subjectname,'_',date_y,date_m,date_d,'_MEP_',Number,'.mat');

EEGTMS = 0;


%% Confirm whether to continue processing

list = dir('*.mat');
assess = 0;

[list_num,~] = size(list);

for i = 1:list_num
    listfile = list(i,1);
    listfilename = char(listfile.name);
    correct = strcmp(filename,listfilename);
    if  correct == 1
        assess = 1;
    end
end

mesure = 1;
if assess == 1
    choice = questdlg('同一ファイルが存在するため，計測を続行するとファイルが上書きされます。',...
            '警告','続行','中止','中止');
    switch choice
        case '続行'
            mesure = 1;
        case '中止'
            mesure = 0;
    end
end


%% Start to measure

scrsz = get(0,'MonitorPosition');

if mesure == 1

fs_MEP = 10000;
sense_MEP = sense;

NIs = daq.createSession('ni');
NIs.addAnalogInputChannel('Dev2', [0 1 2 3], 'Voltage'); % for R-FDI, L, TS, CS
NIs.Rate = fs_MEP;
NIs.DurationInSeconds = load_time;
NIs.NotifyWhenDataAvailableExceeds = 1000;

MVC

target = 0.1;

%%% EMG monitoring %%%
figure(11);
x_EMG = [0,0];
fbbar = bar(x_EMG); hold on;
plot([0.5 2.5],[target target],'-r','LineWidth',2);
set(gcf ,'NumberTitle','off','toolbar','none','menubar','none',...
    'position',[scrsz(2,1) scrsz(2,2) scrsz(2,3)*1 scrsz(2,4)]);
set(gca,'YLim',[0 target*2]);
%%%%%%%%%%%%%%%%%%%%%%

fid1 = fopen('log.bin','w');
lh = addlistener(NIs,'DataAvailable',@(src,eventdata)plotData(src,eventdata,MVC,sense_MEP,fbbar));
lh2 = addlistener(NIs,'DataAvailable', @(src,event) logData(src,event,fid1));

NIs.startBackground();

end
