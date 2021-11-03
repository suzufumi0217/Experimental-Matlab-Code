clear all
close all

%loading data
basename = "calibration_tr1012_";
trial_number = "3";
filename = strcat(basename,trial_number,'.mat');
load(filename);

%plotting
subplot(4,1,1)
plot(fh_time,fh_right_w_hip)
hold on 
yyaxis right
plot(fh_time,fh_right_FS)
xlabel("Right-Foot")

subplot(4,1,2)
plot(fh_time,fh_left_w_hip)
hold on 
yyaxis right
plot(fh_time,fh_left_FS)
xlabel("Left-foot")


%plotting
subplot(4,1,3)
plot(sh_time,sh_right_w_hip)
hold on 
yline(threshold.R_max)
% hold on
% yline(0)
hold on 
yyaxis right
plot(sh_time,state.R)
hold on
plot(sh_time,sh_right_FS)
xlabel("Right-Foot")


subplot(4,1,4)
plot(sh_time,sh_left_w_hip)
hold on 
yline(threshold.L_max)
% hold on
% yline(0)
hold on 
yyaxis right
plot(sh_time,state.L)
hold on
plot(sh_time,sh_left_FS)
xlabel("Left-foot")