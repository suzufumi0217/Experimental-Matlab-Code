function readRL_IMUData(src,~)

% global motionstim8
% global info
% global currentState
% global previousState

% Read the ASCII data from the serialport object.
data = readline(src);
% disp(data)
%split the Data
arduinoData = strsplit(data,',');

if(length(arduinoData) >= 5)
    %分割したデータ
    TIME = arduinoData(1,1);
    RightIMUData = arduinoData(1,2);
    LeftIMUData = arduinoData(1,3);
    RightFSData = arduinoData(1,4);
    LeftFSData = arduinoData(1,5);
    
    disp(arduinoData)
    % % Convert the string data to numeric type and save it in the UserData
    % % property of the serialport object.
    Time = str2double(TIME);
    RightIMU = str2double(RightIMUData);
    LeftIMU = str2double(LeftIMUData);
    RightFS = str2double(RightFSData);
    LeftFS = str2double(LeftFSData);
    
    src.UserData.Time(end+1) = Time;
    src.UserData.Right_w_hip(end+1) = RightIMU;
    src.UserData.Left_w_hip(end+1) = LeftIMU;
    src.UserData.R_FS(end+1) = RightFS;
    src.UserData.L_FS(end+1) = LeftFS;
end

            
% % Update the Count value of the serialport object.
% src.UserData.Count = src.UserData.Count + 1;
% 
% % If 1001 data points have been collected from the Arduino, switch off the
% % callbacks and plot the data.
% if src.UserData.Count > 1001
%     configureCallback(src, "off");
%     plot(src.UserData.Data(2:end));
% end

end