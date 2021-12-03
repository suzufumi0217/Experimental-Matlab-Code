close all
for tr=1:20
    F = figure;
    subplot(2,1,1)
    plot(D_time{tr,1},D_R_w_hip{tr,1})
    hold on
    yline(threshold.R_max)
    hold on
    yyaxis right
    plot(D_time{tr,1},D_R_FS{tr,1})
    hold on
    plot(D_time{tr,1},D_R_state{tr,1})
    xlabel("Right-Foot")
    
    subplot(2,1,2)
    plot(D_time{tr,2},D_L_w_hip{tr,1})
    hold on
    yline(threshold.L_max)
    hold on
    yyaxis right
    plot(D_time{tr,2},D_L_FS{tr,1})
    hold on
    plot(D_time{tr,2},D_L_state{tr,1})
    xlabel("Left-foot")
end
