%% taget box setting

% axis no kaiten
axis_c3_rest_ERD2 = -(fliplr(axis_c3_rest_ERD));
axis_c3_task_ERD2 = -(fliplr(axis_c3_task_ERD));
axis_c4_rest_ERD2 = -(fliplr(axis_c4_rest_ERD));
axis_c4_task_ERD2 = -(fliplr(axis_c4_task_ERD));

axis_c3_rest_pwr2 = -(fliplr(axis_c3_rest_pwr));
axis_c3_task_pwr2 = -(fliplr(axis_c3_task_pwr));
axis_c4_rest_pwr2 = -(fliplr(axis_c4_rest_pwr));
axis_c4_task_pwr2 = -(fliplr(axis_c4_task_pwr));

if AXIS == 1    % axis redefinition
    if CONDI == 1   % rest
%         target_pwr = [-25 -25 50 50];
        target_pwr = [0 0 0 0];
    elseif CONDI == 2
        target_pwr = [50 -25 50 50]; % 95% percentile -> [50 50 40 40],  2nd arg: 50 -> -25 (19/1/15) (à»â∫ìØ)
    elseif CONDI == 3
        target_pwr = [-25 -25 50 50]; % 95% percentile -> [-25 50 50 40]
    elseif CONDI == 4
        target_pwr = [-100 -25 50 50]; % 95% percentile -> [-90 50 40 40]
    elseif CONDI == 5
        target_pwr = [0 0 0 0];
    end
    
elseif AXIS == 2
    if PwrERD == 2 % power
        if CONDI == 1   % rest
%             target_pwr = [axis_c4_rest_pwr2(1,75) axis_c3_rest_pwr2(1,75) (axis_c4_rest_pwr2(1,125)-axis_c4_rest_pwr2(1,75)) (axis_c3_rest_pwr2(1,125)-axis_c3_rest_pwr2(1,75))]; % [c3_min c3_max c4_min c4_max]
            target_pwr = [0 0 0 0];
        elseif CONDI == 2   % MI
            target_pwr = [axis_c4_task_pwr2(1,151) axis_c3_task_pwr2(1,75) (axis_c4_task_pwr2(1,201)-axis_c4_task_pwr2(1,151)) (axis_c3_task_pwr2(1,201)-axis_c3_task_pwr2(1,151))];
        elseif CONDI == 3   % MI
            target_pwr = [axis_c4_task_pwr2(1,75) axis_c3_task_pwr2(1,75) (axis_c4_task_pwr2(1,125)-axis_c4_task_pwr2(1,75)) (axis_c3_task_pwr2(1,201)-axis_c3_task_pwr2(1,151))];
        elseif CONDI == 4   % MI
            target_pwr = [axis_c4_task_pwr2(1,1) axis_c3_task_pwr2(1,75) (axis_c4_task_pwr2(1,51)-axis_c4_task_pwr2(1,1)) (axis_c3_task_pwr2(1,201)-axis_c3_task_pwr2(1,151))];
        elseif CONDI == 5
            target_pwr = [0 0 0 0];
        end
    elseif PwrERD == 1 % ERD
        if CONDI == 1   % rest
%             target_pwr = [axis_c4_rest_ERD2(1,75) axis_c3_rest_ERD2(1,75) (axis_c4_rest_ERD2(1,125)-axis_c4_rest_ERD2(1,75)) (axis_c3_rest_ERD2(1,201)-axis_c3_rest_ERD2(1,151))]; % [c3_min c3_max c4_min c4_max]
            target_pwr = [0 0 0 0];
        elseif CONDI == 2   % MI
            target_pwr = [axis_c4_task_ERD2(1,151) axis_c3_task_ERD2(1,75) (axis_c4_task_ERD2(1,201)-axis_c4_task_ERD2(1,151)) (axis_c3_task_ERD2(1,201)-axis_c3_task_ERD2(1,151))];
        elseif CONDI == 3   % MI
            target_pwr = [axis_c4_task_ERD2(1,75) axis_c3_task_ERD2(1,75) (axis_c4_task_ERD2(1,125)-axis_c4_task_ERD2(1,75)) (axis_c3_task_ERD2(1,201)-axis_c3_task_ERD2(1,151))];
        elseif CONDI == 4   % MI
            target_pwr = [axis_c4_task_ERD2(1,1) axis_c3_task_ERD2(1,75) (axis_c4_task_ERD2(1,51)-axis_c4_task_ERD2(1,1)) (axis_c3_task_ERD2(1,201)-axis_c3_task_ERD2(1,151))];
        elseif CONDI == 5
            target_pwr = [0 0 0 0];
        end
    end
end

if fb == 1 % with visual feedback
    tarbox = rectangle('Facecolor',boxclr,'Edgecolor',boxclr,'Position',target_pwr);
end


%% Line setting

if AXIS == 1
    axis_x0 = 0;    
    axis_y0 = 0;
    line0   =   line([-100 100],[axis_y0 axis_y0],'color','g','LineWidth',4);
    line1   =   line([axis_x0 axis_x0],[-100 100],'color','g','LineWidth',4);
    axis_xlim = [-100 100];
    axis_ylim = [-100 100];
    
elseif AXIS == 2
    max_axis = 25;  % default: 1
    if PwrERD == 2
        if CONDI == 1
            axis_x0 = axis_c4_rest_pwr2(1,101);
            axis_y0 = axis_c3_rest_pwr2(1,101);
            line0   =   line([axis_c4_rest_pwr2(1,1) axis_c4_rest_pwr2(1,201)],[axis_y0 axis_y0],'color','g','LineWidth',4);
            line1   =   line([axis_x0 axis_x0],[axis_c3_rest_pwr2(1,1) axis_c3_rest_pwr2(1,201)],'color','g','LineWidth',4);
            axis_xlim = [axis_c4_rest_pwr2(1,max_axis) axis_c4_rest_pwr2(1,201)];
            axis_ylim = [axis_c3_rest_pwr2(1,max_axis) axis_c3_rest_pwr2(1,201)];
        else
            axis_x0 = axis_c4_task_pwr2(1,101);
            axis_y0 = axis_c3_task_pwr2(1,101);
            line0   =   line([axis_c4_task_pwr2(1,1) axis_c4_task_pwr2(1,201)],[axis_y0 axis_y0],'color','g','LineWidth',4);
            line1   =   line([axis_x0 axis_x0],[axis_c3_task_pwr2(1,1) axis_c3_task_pwr2(1,201)],'color','g','LineWidth',4);
            axis_xlim = [axis_c4_task_pwr2(1,max_axis) axis_c4_task_pwr2(1,201)];
            axis_ylim = [axis_c3_task_pwr2(1,max_axis) axis_c3_task_pwr2(1,201)];
        end
    elseif PwrERD == 1
        if CONDI == 1
            axis_x0 = axis_c4_rest_ERD2(1,101);
            axis_y0 = axis_c3_rest_ERD2(1,101);
            line0   =   line([axis_c4_rest_ERD2(1,1) axis_c4_rest_ERD2(1,201)],[axis_y0 axis_y0],'color','g','LineWidth',4);
            line1   =   line([axis_x0 axis_x0],[axis_c3_rest_ERD2(1,1) axis_c3_rest_ERD2(1,201)],'color','g','LineWidth',4);
            axis_xlim = [axis_c4_rest_ERD2(1,max_axis) axis_c4_rest_ERD2(1,201)];
            axis_ylim = [axis_c3_rest_ERD2(1,max_axis) axis_c3_rest_ERD2(1,201)];
        else
            axis_x0 = axis_c4_task_ERD2(1,101);
            axis_y0 = axis_c3_task_ERD2(1,101);
            line0   =   line([axis_c4_task_ERD2(1,1) axis_c4_task_ERD2(1,201)],[axis_y0 axis_y0],'color','g','LineWidth',4);
            line1   =   line([axis_x0 axis_x0],[axis_c3_task_ERD2(1,1) axis_c3_task_ERD2(1,201)],'color','g','LineWidth',4);
            axis_xlim = [axis_c4_task_ERD2(1,max_axis) axis_c4_task_ERD2(1,201)];
            axis_ylim = [axis_c3_task_ERD2(1,max_axis) axis_c3_task_ERD2(1,201)];
        end
    end
end


%% for definition of trigger cue

if AXIS == 1
    if CONDI == 1   % rest
        def_trig_cue = [-25 25 -25 25]; % [c3_min c3_max c4_min c4_max]
    elseif CONDI == 2   % MI
        def_trig_cue = [-25 25 50 100];
    elseif CONDI == 3   % MI
        def_trig_cue = [-25 25 -25 25];
    elseif CONDI == 4   % MI
        def_trig_cue = [-25 25 -100 -50];
    elseif CONDI == 5   % MI
        def_trig_cue = [-25 25 -100 100];   % C3ÇÃílÇæÇØêßå¿
% %         def_trig_cue = [-25 25 50 100; -25 25 -25 25; -25 25 -100 -50];
    end
    
elseif AXIS == 2
    if PwrERD == 2 % power
        if CONDI == 1   % rest
            def_trig_cue = [axis_c3_rest_pwr2(1,75) axis_c3_rest_pwr2(1,125) axis_c4_rest_pwr2(1,75) axis_c4_rest_pwr2(1,125)]; % [c3_min c3_max c4_min c4_max]
        elseif CONDI == 2   % MI
            def_trig_cue = [axis_c3_task_pwr2(1,75) axis_c3_task_pwr2(1,125) axis_c4_task_pwr2(1,151) axis_c4_task_pwr2(1,201)];
        elseif CONDI == 3   % MI
            def_trig_cue = [axis_c3_task_pwr2(1,75) axis_c3_task_pwr2(1,125) axis_c4_task_pwr2(1,75) axis_c4_task_pwr2(1,125)];
        elseif CONDI == 4   % MI
            def_trig_cue = [axis_c3_task_pwr2(1,75) axis_c3_task_pwr2(1,125) axis_c4_task_pwr2(1,1) axis_c4_task_pwr2(1,51)];
        elseif CONDI == 5   % MI
            def_trig_cue = [axis_c3_task_pwr2(1,75) axis_c3_task_pwr2(1,125) axis_c4_task_pwr2(1,1) axis_c4_task_pwr2(1,201)];
% %             def_trig_cue = [axis_c3_task_pwr2(1,75) axis_c3_task_pwr2(1,125) axis_c4_task_pwr2(1,151) axis_c4_task_pwr2(1,201);...
% %                 axis_c3_task_pwr2(1,75) axis_c3_task_pwr2(1,125) axis_c4_task_pwr2(1,75) axis_c4_task_pwr2(1,125);...
% %                 axis_c3_task_pwr2(1,75) axis_c3_task_pwr2(1,125) axis_c4_task_pwr2(1,1) axis_c4_task_pwr2(1,51)];
        end
    elseif PwrERD == 1 % ERD
            if CONDI == 1   % rest
                def_trig_cue = [axis_c3_rest_ERD2(1,75) axis_c3_rest_ERD2(1,125) axis_c4_rest_ERD2(1,75) axis_c4_rest_ERD2(1,125)]; % [c3_min c3_max c4_min c4_max]
            elseif CONDI == 2   % MI
                def_trig_cue = [axis_c3_task_ERD2(1,75) axis_c3_task_ERD2(1,125) axis_c4_task_ERD2(1,151) axis_c4_task_ERD2(1,201)];
            elseif CONDI == 3   % MI
                def_trig_cue = [axis_c3_task_ERD2(1,75) axis_c3_task_ERD2(1,125) axis_c4_task_ERD2(1,75) axis_c4_task_ERD2(1,125)];
            elseif CONDI == 4   % MI
                def_trig_cue = [axis_c3_task_ERD2(1,75) axis_c3_task_ERD2(1,125) axis_c4_task_ERD2(1,1) axis_c4_task_ERD2(1,51)];
            elseif CONDI == 5   % MI
                def_trig_cue = [axis_c3_task_ERD2(1,75) axis_c3_task_ERD2(1,125) axis_c4_task_ERD2(1,1) axis_c4_task_ERD2(1,201)];
%                 def_trig_cue = [axis_c3_task_ERD2(1,75) axis_c3_task_ERD2(1,125) axis_c4_task_ERD2(1,151) axis_c4_task_ERD2(1,201);...
%                     axis_c3_task_ERD2(1,75) axis_c3_task_ERD2(1,125) axis_c4_task_ERD2(1,75) axis_c4_task_ERD2(1,125);...
%                     axis_c3_task_ERD2(1,75) axis_c3_task_ERD2(1,125) axis_c4_task_ERD2(1,1) axis_c4_task_ERD2(1,51)];
            end
    end
end
