function hexCode = FES_ChannelListInitialization(ts1, ts2, Channel_Stim, Channel_Lf, N_factor)
% Used to initialize frequencies for each channel and pulse timings
% 
% ts1: the stimulator will generate cyclically stimulation bursts with the 
%      time period ts1 on the selected channels. In milliseconds
% ts2: for doublet and triplet pulse modes, ts2 is the inter-pulse interval
% Channel_Stim: a list of all channels that will be used for stimulation,
%               including high frequency AND low frequency channels
% Channel_Lf: a list of the channels that will be used for stimulation at a 
%             low frequency (documentation is not clear about what these 
%             high and low frequencies actually are). This can be empty []
% N_factor: From the selected channels in the channel list Channel_Stim, 
%           one can choose a sub set of channels which will be accessed for 
%           stimulation only every N-th time the stimulator goes through 
%           the channel list
% Written by Heather Williams August 2019

mainTime = (ts1 - 1)*2;
groupTime = (ts2 - 1.5)*2;

channelStim = '00000000';
channelStim(1,end+1-Channel_Stim) = '1';

channelLf = '00000000';
if ~isempty(Channel_Lf)
    channelLf(1,end+1-Channel_Lf) = '1';
end

checkSum = mod((mainTime + groupTime + N_factor + bin2dec(channelStim) + bin2dec(channelLf)),8);

NBin = dec2bin(N_factor,3);
groupTimeBin = dec2bin(groupTime,5);
mainTimeBin = dec2bin(mainTime,11);

Byte1 = ['100' dec2bin(checkSum,3) NBin(1:2)];
Byte2 = ['0' NBin(end) channelStim(1:6)];
Byte3 = ['0' channelStim(7:8) channelLf(1:5)];
Byte4 = ['0' channelLf(6:8) '00' groupTimeBin(1:2)];
Byte5 = ['0' groupTimeBin(3:5) mainTimeBin(1:4)];
Byte6 = ['0' mainTimeBin(5:11)];

hexCode = [bin2hex(Byte1) ' ' bin2hex(Byte2) ' ' bin2hex(Byte3) ' ' bin2hex(Byte4) ' ' bin2hex(Byte5) ' ' bin2hex(Byte6)];