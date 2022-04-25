stop(NIs)

fid2 = fopen('log.bin','r');
[data_MEP,count] = fread(fid2,[5,inf],'double');

figure(21)
subplot(4,1,1);
plot(data_MEP(2,:));    % R-MRP
subplot(4,1,2);
plot(data_MEP(3,:));    % L-MEP
subplot(4,1,3);
plot(data_MEP(4,:));    % TS trigger
subplot(4,1,4);
plot(data_MEP(5,:));    % CS trigger

delete(lh);
delete(lh2);

% % MEP_analysis;

pause(5)
close(11)

