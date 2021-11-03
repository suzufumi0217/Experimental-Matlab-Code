clear all
close all

%loading data
basename = 'sbstest0721';
version = '_v2';
trial = 'tr3';
filename = strcat(basename,version,trial,'.mat');
load(filename);

R_w_hip = right_w_hip{1,1};
L_w_hip = left_w_hip{1,1};
R_FS = right_fsr{1,1};
L_FS = left_fsr{1,1};
TIME = time{1,1};

%データを前半後半に分割する →　関数で書きたい
fh_right_w_hip = R_w_hip(1: floor(length(R_w_hip) / 2));
sh_right_w_hip = R_w_hip( floor(length(R_w_hip) / 2) + 1: end);
fh_left_w_hip = L_w_hip(1: floor(length(L_w_hip) / 2));
sh_left_w_hip = L_w_hip( floor(length(L_w_hip) / 2) + 1: end);
fh_right_FS = R_FS(1: floor(length(R_FS) / 2));
sh_right_FS = R_FS( floor(length(R_FS) / 2) + 1: end);
fh_left_FS = L_FS(1: floor(length(L_FS) / 2));
sh_left_FS = L_FS( floor(length(L_FS) / 2) + 1: end);
fh_time = TIME(1: floor(length(TIME) / 2));
sh_time = TIME( floor(length(TIME) / 2) + 1: end);

%make thresholds
[peaks] = calibration(fh_right_w_hip, fh_left_w_hip, fh_time);
threshold.R_max = peaks.R;
threshold.L_max = peaks.L;
threshold.FS = 1;

%detection
[state] = offlineDetection_BothLegs(sh_time, sh_right_w_hip, sh_right_FS, sh_left_w_hip, sh_left_FS, threshold);

%plotting
subplot(2,1,1)
plot(sh_time,state.R)
ylim([0,5])
hold on
yyaxis right
plot(sh_time,sh_right_w_hip)
hold on
yline(0)
hold on 
yline(threshold.R_max)
xlim([60,90])
xlabel("Right-Foot")


subplot(2,1,2)
plot(sh_time,state.L)
ylim([0,5])
hold on
yyaxis right
plot(sh_time,sh_left_w_hip)
hold on
yline(0)
hold on 
yline(threshold.L_max)
xlim([60,90])
xlabel("Left-foot")
