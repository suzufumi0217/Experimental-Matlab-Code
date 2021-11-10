function InitiateCalibration(arduinoObj,calib_steps,max_step_duration)

%Arduinoからの読み取り
%% read device name
readNline(arduinoObj,11)% read text from ARDUINO
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

%% calibration
%Arduinoへの書き込み
%send c
writeline(arduinoObj,"c");

writeline(arduinoObj, num2str(calib_steps));
writeline(arduinoObj, num2str(max_step_duration));

readNline(arduinoObj,2)% start calibration

%コールバック関数を設定している
configureCallback(arduinoObj,"terminator",@readRL_IMUData);

end

