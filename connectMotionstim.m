function motionstim8 = connectMotionstim(port)
% port should be a string of the following form:
%	For Linux: '/dev/ttyS0' (check port to replace ttyS0)
%   For Mac: '/dev/tty.KeySerial1' (check USB Serial Number in System
%            Report to replace KeySerial1)
%	For Windows: 'COM1' (check Device Manager to replace 1)
% Written by Heather Williams, August 2019

clear motionstim8 instrfind % disconnect to make sure that connection will work
if ~contains(port,seriallist)
    error('serial port not available - check if right port is selected and restart computer if still not avaialble')
    fclose(instrfind)
end

motionstim8 = serial(port);
set(motionstim8,'BaudRate',115200);
if strcmp(motionstim8.Status,'closed')
    fopen(motionstim8);
end
