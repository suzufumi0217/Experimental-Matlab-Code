function readR_State(src,~)

% global motionstim8
% global info
% global currentState
% global previousState

% currentState = 0;
% previousState = 0;
global isfinishstep
global R_stepcount

global step

global D_time
global D_R_state
global D_R_w_hip
global D_R_FS

% Read the ASCII data from the serialport object.
data = readline(src);
% disp(data)
%split the Data
DetectionData = strsplit(data,',');

if(length(DetectionData) == 4)
%     disp(DetectionData)
    TIME = DetectionData(1);
    STATE = DetectionData(2);
    FS = DetectionData(3);
    W_HIP = DetectionData(4);
    % % Convert the string data to numeric type and save it in the UserData
    % % property of the serialport object.
    time = str2double(TIME);
    state = str2double(STATE);
    fs = str2double(FS);
    w_hip = str2double(W_HIP);
    
    %Disp State
    disp([time,state])
    
    %データをarduino構造体のなかのDetectDataにしまう．
    src.UserData.Time(end+1) = time;
    src.UserData.R_State(end+1) = state;
    src.UserData.R_FS(end+1) = fs;
    src.UserData.Right_w_hip(end+1) = w_hip;
    
    %current_state != prev_stateの時SendChangeSignalを呼び出す
    % previousState = currentState;
    % currentState = state;
    %
    % if previousState ~= currentState
    %     info = sendChangeSignal(motionstim8, info, 1, currentState);
    % end
    
    % % Update the Count value of the serialport object.
    % src.UserData.Count = src.UserData.Count + 1;
    %
    % % If 1001 data points have been collected from the Arduino, switch off the
    % % callbacks and plot the data.
    % if src.UserData.Count > 1001
    %     configureCallback(src, "off");
    %     plot(src.UserData.Data(2:end));
    % end
elseif(DetectionData == compose("\nFinish Step"))
%     disp("R_finish")
    disp(strcat(num2str(step),"step finish"))
    configureCallback(src, "off");
%     WaitNsec(3);
    isfinishstep = true;
    D_time{R_stepcount,1} = src.UserData.Time;
    D_R_state{R_stepcount,1} = src.UserData.R_State;
    D_R_w_hip{R_stepcount,1} = src.UserData.Right_w_hip;
    D_R_FS{R_stepcount,1} = src.UserData.R_FS;
    src.UserData = struct("Time",[],"R_State",[],"L_State",[],"Right_w_hip",[],"Left_w_hip",[],"R_FS",[],"L_FS",[]);
    R_stepcount = R_stepcount + 1;
end


end
