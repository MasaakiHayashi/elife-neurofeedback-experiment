% GUI Main program
% Origibnal filename: Start_measurement.mat
% changed 18/06/10

close all 

scrsz   = get(0,'ScreenSize');
set(gcf,'Units','Pixels', 'Position',[300,scrsz(4)-800,1000,350],...
    'NumberTitle','Off', 'Menu','None');

UISession = uicontrol(gcf,'Style','Text','Position',[100 300 300 50],...
            'string','Session','FontSize',40,'BackGroundColor',[0.8 0.8 0.8]);
UIMVC     = uicontrol(gcf,'Style','Push','Position',[0 30 250 100],...
            'String','MVCë™íË','FontSize',20,'CallBack','MVC_measurement;');
UImeaMEP  = uicontrol(gcf,'Style','Push','Position',[250 30 250 100],...
            'String','MEPë™íË','FontSize',20,'CallBack','MEP_measurement_2;');
UIanaMEP  = uicontrol(gcf,'Style','Push','Position',[500 30 250 100],...
            'string','MEPâêÕÅïï€ë∂','FontSize',20,'CallBack','MEP_analysis;');
UITh      = uicontrol(gcf,'Style','listbox','Position',[600 195 80 110],...
            'string','1|2|0.5|0.2|0.1|0.05','FontSize',13,'BackGroundColor',[0.8 0.8 0.8]);
UITh2     = uicontrol(gcf,'Style','listbox','Position',[500 195 80 60],...
            'string','R FDI|L FDI','FontSize',16,'BackGroundColor',[0.8 0.8 0.8]);
UITh3     = uicontrol(gcf,'Style','listbox','Position',[700 195 80 110],...
            'string','10|20|30|40|50|60','FontSize',13,'BackGroundColor',[0.8 0.8 0.8]);
UIClose   = uicontrol(gcf,'Style','Push','Position',[750 30 250 100],...sess
            'string','stop','FontSize',20,'CallBack','stop_daq');

uicontrol(gcf,'Style','Text','String','TIME:','FontSize',12,...
    'Units','Pixels','Position',[850 220 50 30],'Horizontal','Left');
uicontrol(gcf,'Style','Edit','String','','FontSize',18,...
    'Units','Pixels','Position',[850 195 50 30],'Horizontal','Left',...
    'CallBack','load_time = get(gcbo,''string'');');

uicontrol(gcf,'Style','Text','String','Input Subject''s ID:','FontSize',12,...
    'Units','Pixels','Position',[60 220 180 30],'Horizontal','Left');
uicontrol(gcf,'Style','Edit','String','','FontSize',18,...
    'Units','Pixels','Position',[60 195 180 30],'Horizontal','Left',...
    'CallBack','Subjectname = get(gcbo,''string'');');

uicontrol(gcf,'Style','Text','String','Input trial number:','FontSize',12,...
    'Units','Pixels','Position',[250 220 180 30],'Horizontal','Left');
uicontrol(gcf,'Style','Edit','String','','FontSize',18,...
    'Units','Pixels','Position',[250 195 180 30],'Horizontal','Left',...
    'CallBack','num = get(gcbo,''string'');');

                      
%% real-time PSD & ERD

% x1=0; y1=0; x2=0; y2=0;
% figure(50);
% set(gcf,'menu','none','toolbar','none','position',[590 470 1000 400])
% [hax,hp1,hp2] = plotyy(x1,y1,x2,y2);
% xlabel('time')
% ylabel(hax(1),'PSD [É V^{2}/Hz]')
% ylabel(hax(2),'ERD %')
% xlim(hax(1),[0 120]); xlim(hax(2),[0 120]); 
% ylim(hax(1),[0 5]); set(hax(1),'YTickMode','Auto');
% ylim(hax(2),[-100 100]); set(hax(2),'YTickMode','Auto') 
% 
% % set(hax(1),'Xlim',[0 120], 'Ylim', [0 10])
% % set(hax(2),'Xlim',[0 120], 'Ylim', [-100 100])
% set(hp1,'XDataSource', 'x1','YDataSource', 'y1', 'Color',[1 0 0])
% set(hp2,'XDataSource', 'x2','YDataSource', 'y2','Color',[0 0 1])
% set(gca,'XTick',[0 50 60 120]);
% set(gca,'XGrid','on', 'GridLineStyle', '-');
% set(hax(1),'YColor','r')
% set(hax(2),'YColor','b')
