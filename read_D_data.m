function read_D_data(src,~)

global isRight
global isLeft
global n_gait
global D_time
global D_R_state
global D_R_FS
global D_R_w_hip
global D_L_state
global D_L_FS
global D_L_w_hip

global info
global motionstim8
global currentState

% Read the ASCII data from the serialport object.
data = readline(src);
% disp(data)
%split the Data
DetectionData = strsplit(data,',');

%Check MainLeg
if isRight
    mainleg = 1;
elseif isLeft
    mainleg = 2;
end

if(length(DetectionData) == 4)
    disp(DetectionData)
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
    
    %データをarduino構造体のなかにしまう．
    src.UserData.Time(end+1) = time;
    src.UserData.State(end+1) = state;
    src.UserData.FS(end+1) = fs;
    src.UserData.w_hip(end+1) = w_hip;
    
    %current_state != prev_stateの時SendChangeSignalを呼び出す
    previousState = currentState;
    currentState = state;
    
    if previousState ~= currentState
        info = SendChangeSignal(motionstim8, info, mainleg, currentState);
    end
   
elseif(DetectionData == compose("\nFinish Step") || DetectionData == compose("\nTime is up"))
    disp(DetectionData)
    disp(strcat(num2str(n_gait),"gait finish"))
    configureCallback(src, "off");
    
    %Stop stimulating muscle
    info = SendChangeSignal(motionstim8, info, mainleg, 0);
    
    if isRight
        D_time{n_gait,1} = src.UserData.Time;
        D_R_state{n_gait,1} = src.UserData.State;
        D_R_w_hip{n_gait,1} = src.UserData.w_hip;
        D_R_FS{n_gait,1} = src.UserData.FS;
    elseif isLeft
        D_time{n_gait,2} = src.UserData.Time;
        D_L_state{n_gait,1} = src.UserData.State;
        D_L_w_hip{n_gait,1} = src.UserData.w_hip;
        D_L_FS{n_gait,1} = src.UserData.FS;
    end
            
    src.UserData = struct("Time",[],"State",[],"FS",[],"w_hip",[]);
end

end