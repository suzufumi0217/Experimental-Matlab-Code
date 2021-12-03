close all

for tr=1:6
    F(tr) = figure;
    subplot(2,1,1)
    plot(C_time{tr,1},C_R_w_hip{tr,1})
    hold on
    yline(threshold.R_max)
    hold on
    yyaxis right
    plot(C_time{tr,1},C_R_FS{tr,1})
    xlabel("Right-Foot")
    
    subplot(2,1,2)
    plot(C_time{tr,2},C_L_w_hip{tr,1})
    hold on
    yline(threshold.L_max)
    hold on
    yyaxis right
    plot(C_time{tr,2},C_L_FS{tr,1})
    xlabel("Left-foot")
    
end