close all
clear all

global C_time
global C_R_FS
global C_R_w_hip
global C_L_FS
global C_L_w_hip

global D_time
global D_R_state
global D_L_state
global D_R_w_hip
global D_L_w_hip
global D_R_FS
global D_L_FS
global R_stepcount
global L_stepcount

%% Connect Arduino

ARDUINOPORT_number = 5;
strPORT = strcat('COM',num2str(ARDUINOPORT_number));
ARDUINO = serialport(strPORT,115200);
configureTerminator(ARDUINO,"CR");
ARDUINO.UserData = struct("Time",[],"FS",[],"w_hip",[]);

%% Calibration

%parameterを設定する
max_step_duration = 2; %Mesuring duration at each step 
course_steps = 4;%(sec) コースを何歩で完了するか
course_repeat = 2;%(times) コースを何回試行するか
rest_time = 2; %(s) 一歩ごとの間の時間
calibration_steps = course_steps * course_repeat;
disp(["all calibration_steps is",num2str(calibration_steps)])

%Initiate calibration
InitiateCalibration(ARDUINO,calibration_steps,max_step_duration);

%Start Calibration(Visual Cue and collecting Data)
Calibration_visual_cue(ARDUINO,max_step_duration,course_steps,course_repeat,rest_time);

%After collecting Data from Arduino
configureCallback(ARDUINO, "off");

F = figure('Name','Next offlinedetection & plotting');
w = waitforbuttonpress;
close(F)

%make thresholds
Max_R_w_hip = calibration(C_R_w_hip);
Max_L_w_hip = calibration(C_L_w_hip);
threshold.R_max = Max_R_w_hip;
threshold.L_max = Max_L_w_hip;
threshold.FS = 1;

%plotting
calib_f = figure;
subplot(2,1,1)
plot(C_time{1,1},C_R_w_hip{4,1})
hold on
yline(threshold.R_max)
hold on
yyaxis right
plot(C_time{1,1},C_R_FS{1,1})
xlabel("Right-Foot")

subplot(2,1,2)
plot(C_time{1,2},C_L_w_hip{4,1})
hold on 
yline(threshold.L_max)
hold on
yyaxis right
plot(C_time{1,2},C_L_FS{1,1})
xlabel("Left-foot")

%データの保存
trialdate = date;
prompt = 'What is the trial time? >> ';
calib_trialtime = input(prompt,'s');
filename = strcat("calibration_", trialdate,"_", calib_trialtime);
save(filename);
close all

disp('    R_max,    L_max,     FS')
disp([threshold.R_max,threshold.L_max,threshold.FS])
%% Connect FES(このテストではやらない)

% global motionstim8
% global info
% global currentState
% global previousState

% FESPORT_number = 6;
% ConnectFES(FESPORT_number);

F = figure('Name','Start online detection?');
w = waitforbuttonpress;
close(F)

ARDUINO.UserData = struct("Time",[],"R_State",[],"L_State",[],"Right_w_hip",[],"Left_w_hip",[],"R_FS",[],"L_FS",[]);
%% Detection
%Sending D_params
detection_steps = 15;
max_step_duration = 3;
% InitiateDetection(ARDUINO,threshold.R_max,threshold.L_max,threshold.FS,detection_steps,max_step_duration);
InitiateDetection(ARDUINO,30,30,1,detection_steps,max_step_duration);

%Motor Imagery
Detection_visual_cue(ARDUINO,detection_steps,max_step_duration);

F = figure('Name','Save DetectData?');
w = waitforbuttonpress;
close(F)

%Saving Detection Data
prompt = 'What is the trial number? >> ';
detect_trialtime = input(prompt,'s');
filename = strcat("detection_", trialdate,"_", detect_trialtime);
save(filename);

close all
%% Update D_params and start detection
% threshold.R_max = peaks.R;
% threshold.L_max = peaks.L;
% threshold.FS = 2;
% detection_steps = 10;
% max_step_duration = 5;
% 
% Update_Dparam(ARDUINO,threshold.R_max,threshold.L_max,threshold.FS,detection_steps,max_step_duration);

%% Disconnect FES & ARDUINO
% fwrite(motionstim8, sscanf(ExitChannelListMode,'%2x')', 'uint8');
% disconnectMotionstim(motionstim8);
%いらんかなこれ正味↓
DisconnectArduino(ARDUINO);
