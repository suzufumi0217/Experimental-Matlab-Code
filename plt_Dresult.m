close all
load('C:\Users\Arai\Desktop\lower_limb\Experimental code\sandbox\DATA\sub1\detection_03-Dec-2021_1inExp.mat')
for tr=1:20
% tr = 2;
F = figure(tr);
%     subplot(2,1,1)
plot(D_time{tr,2},D_L_w_hip{tr,1},'LineWidth',2)
pbaspect([2.3 1 1])
xlim([D_time{tr,2}(1) D_time{tr,2}(end)])
yline(Max_L_w_hip/4,'LineWidth',2,"Color","red")
end
% yline(0)
% hold on
% yline(threshold.L_max / 4,"--b",'LineWidth',2)
%     ylabel("w-hip(deg/s)")
%     hold on
% yyaxis right
%     yline(threshold.FS,'LineWidth',2)
%     hold on
% plot(D_time{tr,2},D_L_FS{tr,1},'LineWidth',2,"Color","black")
% xlim([D_time{tr,2}(1) D_time{tr,2}(end)])
% pbaspect([2.3 1 1])
% legend("FSR")
% legend("ωhip IMU","FSR")
% hold on 
% xline(D_time{tr,2}(end)-0.3469)
%     plot(D_time{tr,2},D_L_state{tr,1})
%     legend("ω-hip","max-ω-hip/4","FSR-threshold","FSR")
%     xlabel("time(s)")


%     subplot(2,1,2)
%     plot(D_time{tr,2},D_L_w_hip{tr,1})
%     hold on
%     yline(threshold.L_max)
%     hold on
%     yyaxis right
%     plot(D_time{tr,2},D_L_FS{tr,1})
%     hold on
%     plot(D_time{tr,2},D_L_state{tr,1})
%     xlabel("time(s)")
% end
