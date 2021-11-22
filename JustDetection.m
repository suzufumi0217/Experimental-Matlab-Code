%JustDetection
%After 1 trial of experiment consists of calibration and detection part, we
%use this code for just detection. This function also update D_params part.
%If you want to update D_params, please erase comment out.

%% Connect Arduino
ARDUINOPORT_number = 5;
strPORT = strcat('COM',num2str(ARDUINOPORT_number));
ARDUINO = serialport(strPORT,115200);
configureTerminator(ARDUINO,"CR");

readNline(ARDUINO,11)% read text from ARDUINO
%Initialization of the sensor returned: All is well.
% All is well.
% Device connected!
% Enable DLPF for Accelerometer returned: All is well.
% Enable DLPF for Gyroscope returned: All is well.
% Enable DLPF for Accelerometer returned: All is well.
% Enable DLPF for Gyroscope returned: All is well.
% setSampleRate returned: All is well.
% All is well.
% blank
% Configuration complete!
%% Update D_params and start detection
% threshold.FS = 1;
% D_course_steps = 4;
% D_course_repeat = 2;
% detection_steps = D_course_steps * D_course_repeat;
% max_step_duration = 5;
% 
% Update_Dparam(ARDUINO,threshold.R_max,threshold.L_max,threshold.FS,detection_steps,max_step_duration);

ARDUINO.UserData = struct("Time",[],"State",[],"FS",[],"w_hip",[]);
%% Detection
%Sending D_params
max_step_duration = 5;
D_course_steps = 4;
D_course_repeat = 2;
detection_steps = D_course_steps * D_course_repeat;
rest_time = 5; %(s) 一歩ごとの間の時間
disp(["all detection_steps is",num2str(detection_steps)])

InitiateDetection(ARDUINO,threshold.R_max,threshold.L_max,threshold.FS,detection_steps,max_step_duration);
%For debugging
% InitiateDetection(ARDUINO,30,30,1,detection_steps,max_step_duration);

%Motor Imagery
Detection_visual_cue(ARDUINO,max_step_duration,D_course_steps,D_course_repeat,rest_time);

% F = figure('Name','Save DetectData?');
% w = waitforbuttonpress;
% close(F)

%Saving Detection Data
prompt = 'What is the trial number? >> ';
detect_trialtime = input(prompt,'s');
filename = strcat("only_detection_", trialdate,"_", detect_trialtime);
save(filename,"D_time","D_R_FS","D_L_FS","D_R_state","D_L_state","D_R_w_hip","D_L_w_hip");

close all