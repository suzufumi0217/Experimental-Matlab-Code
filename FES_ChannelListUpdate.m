function hexCode = ChannelListUpdate(Pulse_Width, Amplitude, Mode)
% Used to update the amplitudes, pulsewidths, and stimulation modes of each 
% channel in Channel List Mode
%
% All inputs should be 1xn arrays. Inputs should be for each channel by
% increasing channel. Each input should be of the same length. 
%
% Pulse_Width: in microseconds
% Amplitude: in mA
% Mode: 0 - send single pulse
%       1 - send doublet
%       2 - send triplet
% Written by Heather Williams August 2019

checkSum = mod((sum(Pulse_Width) + sum(Amplitude) + sum(Mode)),32);
Byte1 = ['101' dec2bin(checkSum,5)];
hexCode = bin2hex(Byte1);

for i = 1:length(Pulse_Width)
    pulseWidthBin = dec2bin(Pulse_Width(i),9);
    Byte2 = ['0' dec2bin(Mode(i),2) '000' pulseWidthBin(1:2)];
    Byte3 = ['0' pulseWidthBin(3:end)];
    Byte4 = ['0' dec2bin(Amplitude(i),7)];
    hexCode = [hexCode ' ' bin2hex(Byte2) ' ' bin2hex(Byte3) ' ' bin2hex(Byte4)];
end