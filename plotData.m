
function plotData(src,event,MVC,sens,fb)

Data = rms(event.Data(:,1:2).*sens);

set(fb,'YData',Data([1,2])/MVC);

% 
% %目標とする値
% target = 0.2;
% 
% %バーフィードバックの場合
% hold off
% bar(Data([1,2])/MVC);
% set(gca,'YLim',[0 target*2]);
% hold on
% plot([0.5 2.5],[target target],'-r','LineWidth',2);
%プロットの場合
%subplot(2,1,1)
%plot(event.TimeStamps,event.Data(:,1));
%set(gca,'XLim',[0 10]);
%hold on;
%subplot(2,1,2)
%plot(event.TimeStamps,event.Data(:,2));
%set(gca,'XLim',[0 10]);
%hold on;

end