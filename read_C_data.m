function read_C_data(src,~)

global isRight
global isLeft
global n_gait
global C_time
global C_R_FS
global C_R_w_hip
global C_L_FS
global C_L_w_hip

% Read the ASCII data from the serialport object.
data = readline(src);
% disp(data)
%split the Data
CalibrationData = strsplit(data,',');

if(length(CalibrationData) == 3)
    disp(CalibrationData)
    TIME = CalibrationData(1);
    FS = CalibrationData(2);
    W_HIP = CalibrationData(3);
    % % Convert the string data to numeric type and save it in the UserData
    % % property of the serialport object.
    time = str2double(TIME);
    fs = str2double(FS);
    w_hip = str2double(W_HIP);
    
    %データをarduino構造体のなかにしまう．
    src.UserData.Time(end+1) = time;
    src.UserData.FS(end+1) = fs;
    src.UserData.w_hip(end+1) = w_hip;
    
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
elseif(CalibrationData == compose("\nFinish Step"))
    disp(CalibrationData)
%     disp(strcat(num2str(step),"step finish"))
    configureCallback(src, "off");
    
    if isRight
        C_time{n_gait,1} = src.UserData.Time;
        C_R_w_hip{n_gait,1} = src.UserData.w_hip;
        C_R_FS{n_gait,1} = src.UserData.FS;
    elseif isLeft
        C_time{n_gait,2} = src.UserData.Time;
        C_L_w_hip{n_gait,1} = src.UserData.w_hip;
        C_L_FS{n_gait,1} = src.UserData.FS;
    end
    
    src.UserData = struct("Time",[],"FS",[],"w_hip",[]);
end

end