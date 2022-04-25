% function [Zi,Xi,Yi]=EEGmapping2(data, LOC, method, magmax, colorbar_onoff,select_ch,UseCh);

function [hs]=topography(data, LOC, method, magmax, colorbar_onoff,select_ch,UseCh)

% nargin:引数の数
if nargin<3, method=0; end
if nargin<4, magmax=0;end
if nargin<5, colorbar_onoff=[];end
if nargin<6, select_ch=[]; end
if nargin<7, UseCh=[]; end

CONTOURNUM=10;
BACKCOLOR=[1 1 1]; % [.93 .96 1];  % EEGLAB standard
HEADCOLOR=[0 0 0]; % default head color (black)
GRID_NUM=100; %Resolution
XMIN=0;XMAX=1;
YMIN=0;YMAX=1;
RMAX=0.5;

HEADRINGWIDTH =.007;% width of the cartoon head ring
HLINEWIDTH = 3;     % default linewidth for head, nose, ears
CIRCGRID      = 201;
HEADRAD=0.5; % 輪郭の大きさ
shiftv=0.5;
VIEW_MARGIN=0.15;

% Make mesh grid data
xi=linspace(0,1,GRID_NUM);
yi=linspace(0,1,GRID_NUM);

if     method==0, mname='linear';   % method:間のデータの保管の仕方
elseif method==1, mname='cubic';
elseif method==2, mname='nearest';
elseif method==3, mname='v4';% default
end

%%不均一なデータ(x,y,z)から，xiとyiで定義される空間でグリッドデータを作成する(Xi,Yi,Zi)

if isempty(UseCh)~=1
    [Xi,Yi,Zi]=griddata(LOC(UseCh,1),LOC(UseCh,2),data(UseCh),xi,yi',mname);
else
    [Xi,Yi,Zi]=griddata(LOC(:,1),LOC(:,2),data,xi,yi',mname);
end

% Make masking data
mask=(sqrt((Xi-0.5).^2+(Yi-0.5).^2) <= RMAX);% 0or1

% Find minmum and maxmum of data(補間された領域での最大・最小)
if nargin < 4,
	ii=find( mask ~= 0 );
	amax=max(max(abs(Zi(ii))));
	amin=min(min(abs(Zi(ii))));
%    amin=-amax;
else

    if length(magmax)==2 % [amin,amax]=[magmax(1),magmax(2)] 
        amin=magmax(1);
        amax=magmax(2);
    else 
        amax=magmax;
        amin=-magmax;
    end

end


% 任意のカラーマップを定義する.
% Set colorma p
%if amin==0,COLORMAP=powermap(64);%TODO
%else,      COLORMAP=jet(64);
%end

COLORMAP=jet(64);
%map=[ones(1,3);COLORMAP];% 白地を付加
map=COLORMAP;
colormap(map);

%-----------------------------------------
% Draw image
%-----------------------------------------
%hs=imagesc([0 1],[0 1],Zi);
%hs=imagesc([min(Xi) max(Xi)],[min(Yi) max(Yi)],mask.*Zi);

% P1 = get(0,'ScreenSize');
% figure('Position', P1)

hs=imagesc(Xi(1,:),Yi(:,1),Zi);
if isempty(UseCh)~=1 % mapに使うCh以外を白色にする
    set(hs,'AlphaData',~isnan(Zi));
end
set(gca,'YDir','normal'); % axis xy;
axis([-VIEW_MARGIN 1+VIEW_MARGIN -VIEW_MARGIN 1+VIEW_MARGIN]);
hold on;

l=linspace(0,2*pi,CIRCGRID);
rx=sin(l);
ry=cos(l);

%///////////////////////////////////////////////////////////
% patchでimageを隠す.

vm=(1+VIEW_MARGIN)/2;
%上周り
%Lx=[vm vm -vm -vm  vm vm];
%Ly=[0  vm  vm -vm -vm  0];

%下周り
Lx=[vm vm -vm -vm vm vm];
Ly=[0 -vm -vm  vm vm  0];

fillx=[[rx(:)' rx(1)]*HEADRAD Lx]+shiftv;
filly=[[ry(:)' ry(1)]*HEADRAD Ly]+shiftv;
patch(filly,fillx,ones(size(filly)),BACKCOLOR,'edgecolor','none');

%pause;
%///////////////////////////////////////////////////////////
% 等高線
[cls chs] = contour(Xi,Yi,Zi,CONTOURNUM,'k');
% [~,~] = contour(Xi,Yi,Zi,CONTOURNUM,'k');
% clabel(cls,chs);

%pause;
%///////////////////////////////////////////////////////////
% 輪郭

hin=HEADRAD*(1- HEADRINGWIDTH/2);  % inner head ring radius

headx = [[rx(:)' rx(1) ]*(hin+HEADRINGWIDTH)  [rx(:)' rx(1)]*hin]+shiftv;
heady = [[ry(:)' ry(1) ]*(hin+HEADRINGWIDTH)  [ry(:)' ry(1)]*hin]+shiftv;
ringh= patch(headx,heady,ones(size(headx)),HEADCOLOR,'edgecolor',HEADCOLOR); hold on

%pause;
%///////////////////////////////////////////////////////////
% チャンネルの位置

h=plot3(LOC(:,1),LOC(:,2),2.5*ones(size(LOC(:,2))),...
      'LineStyle','none','LineWidth',1,'Marker','o',...
      'MarkerEdgeColor','k','MarkerfaceColor','k', 'MarkerSize',2);%TODO
  
if select_ch~=0
h2=plot3(LOC(select_ch,1),LOC(select_ch,2),2.5*ones(size(LOC(select_ch,2))),...
      'LineStyle','none','LineWidth',2,'Marker','+',...
      'MarkerEdgeColor','k', 'MarkerSize',10);%TODO
end

%///////////////////////////////////////////////////////////
% 鼻と耳

% RMAX = 0.5
base  = RMAX-.0046;
basex = 0.18*RMAX;                   % nose width
tip   = 1.15*RMAX; 
tiphw = .04*RMAX;                    % nose tip half width
tipr  = .01*RMAX;                    % nose tip rounding
q = .04; % ear lengthening
%EarX  = [.497-.005  .510  .518  .5299 .5419  .54    .547   .532   .510   .489-.005] +shiftv;
%EarY  = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199]+shiftv;
EarX = [.489 .503 .518 .5299 .5419 .548 .547 .532 .510 .485]+shiftv;
EarY = [.0965 .1125 .1083 .0976 .0655 -.0055 -.0932 -.1313 -.1384 -.1199]+shiftv;


NoseX=[basex;tiphw;0;-tiphw;-basex]    +shiftv;
NoseY=[base;tip-tipr;tip;tip-tipr;base]+shiftv;

plot3(  NoseX,NoseY, 2*ones(size(NoseY)),'Color',HEADCOLOR,'LineWidth',HLINEWIDTH); % plot nose
plot3(   EarX, EarY, 2*ones(size(EarX)), 'Color',HEADCOLOR,'LineWidth',HLINEWIDTH); % plot left ear
plot3(-EarX+1, EarY, 2*ones(size(EarY)), 'Color',HEADCOLOR,'LineWidth',HLINEWIDTH); % plot right ear


%pause;
%///////////////////////////////////////////////////////////

hold off
axis off
set(gcf,'Color','w');% background:white
caxis([amin amax]);
% title(['MapFreq: ' num2str(Mfreq(1)) 'to' num2str(Mfreq(2))])

% TODO
% カラーバーを表示する
%if isequal(colorbar_onoff,1), mycolorbar([amin amax]); end
if isequal(colorbar_onoff,1)
    h=colorbar; 
    ylabel(h,'ERS(%)')
elseif isequal(colorbar_onoff,2)
    h=colorbar; 
    ylabel(h,'Rvalue','fontsize',20)
    set(h,'fontsize',20); 
elseif isequal(colorbar_onoff,3)
    h=colorbar; 
    ylabel(h,'ERS(db)')
end
end




