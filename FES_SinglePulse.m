function hexCode = SinglePulse(Channel_Num, Pulse_Width, Pulse_Current)
% Sending a command to the stimulator causes a single pulse been sent out 
% on a specific channel with desired current amplitude and pulse width.
%
% Channel_Num: the channel number for the channel that you want to send a
%             pulse on
% Pulse_Width: in microseconds
% Pulse_Current: in mA
% Written by Heather Williams August 2019

Channel_Num = Channel_Num-1; 
checkSum = mod((Channel_Num + Pulse_Width + Pulse_Current), 32);
pulseWidthBin = dec2bin(Pulse_Width,9);

Byte1 = ['111' dec2bin(checkSum,5)];
Byte2 = ['0' dec2bin(Channel_Num,3) '00' pulseWidthBin(1:2)];
Byte3 = ['0' pulseWidthBin(3:end)];
Byte4 = ['0' dec2bin(Pulse_Current,7)];

hexCode = [bin2hex(Byte1) ' ' bin2hex(Byte2) ' ' bin2hex(Byte3) ' ' bin2hex(Byte4)];