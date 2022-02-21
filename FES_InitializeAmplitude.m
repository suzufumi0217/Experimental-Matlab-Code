function info = FES_InitializeAmplitude(motionstim8, info)
% Goes through each channel, saves last number as the amplitude, switches
% channel by entering any non-number string or just hitting enter. 
% motionstim8: serial port object
% info: structure containing settings for stimulation (including list of
%       channels to be used, ts1, ts2, list of low-frequency channels,
%       N-factor, pulsewidth, and stimulation pulse mode). This channel 
%       will add another field that contains the amplitudes for each
%       channel, which are determined using this function.
% Written by Heather Williams, August 2019

info.maxAmplitudes = zeros(1,length(info.AllChannels));

for i = 1:length(info.AllChannels) % loop through each channel
    
    % Initialize ScienceMode
    tempAmpl = 0;
    hexcode = FES_ChannelListInitialization(info.ts1, info.ts2, info.AllChannels(i), info.lowFreqChannels, info.N);
    fwrite(motionstim8, sscanf(hexcode,'%2x')', 'uint8')
    
    % Asks for an amplitude to be entered in the command window. This
    % amplitude will be used to stimulate the current channel. New 
    % amplitudes will be asked for until a non-number string (or empty 
    % string) is entered. 
    while ~isnan(tempAmpl)
       %システムにamplitudeの値を入力する
        tempAmpl = str2double(input(['enter an amplitude for channel ' num2str(info.AllChannels(i)) ': '],'s'));
        if ~isnan(tempAmpl)
            info.maxAmplitudes(i) = tempAmpl;
            %FESに入力されたamplitudeを書き込んでいる
            fwrite(motionstim8, sscanf(FES_ChannelListUpdate(info.PulseWidth, tempAmpl, info.Mode),'%2x')', 'uint8')
        end
    end
    
    % Exit channel mode so that the settings can be reset for the next
    % channel
    fwrite(motionstim8, sscanf(FES_ExitChannelListMode,'%2x')', 'uint8')
end