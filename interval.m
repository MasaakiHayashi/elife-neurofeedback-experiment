if BufferStopper == 0
    set(t,'string',' ');
    drawnow;
    Do.queueOutputData(OutputSignal(4,:));
    Do.startBackground();   
    stop(Do);
    
    if calibtag == 0
        set(pltpast10,'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltpast9, 'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltpast8, 'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltpast7, 'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltpast6, 'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltpast5, 'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltpast4, 'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltpast3, 'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltpast2, 'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltpast1, 'ydata',axis_y0,'xdata',axis_x0); drawnow;
        set(pltnow,   'ydata',axis_y0,'xdata',axis_x0); drawnow;
    end
    
    if calibtag == 1
        set(plot0,'ydata',0,'xdata',3); drawnow;
    end    

    success = Rapid2_SetPowerLevel(obj1, 0, 0);
    
    dispname = strcat('trial:',num2str(trial_cnt),...
        ',  TS only:',num2str(stim_cnt_TS),',  CS+TS:',num2str(stim_cnt_TSCS));
    if calibtag == 0
        dispname
%         disp(dispname);
    end
    
    BufferStopper = 1;
end

