function ConnectFES(PORT)

global motionstim8
global info

% Connect
% motionstim8 = connectMotionstim('/dev/tty.usbserial-FTV5C6LJ');
strPORT = strcat('COM',num2str(PORT));
motionstim8 = connectMotionstim(strPORT);

% Initialize stimulation settings
info.AllChannels = [1 2 3 4 5 6 7 8]; % List of all channels that will be used for stim
info.lowFreqChannels = []; % Channels to use low stimulation on - currently not being used
info.PulseWidth = 200; % in microseconds
info.Mode = 0; % 0 = single pulse, 1 = doublet, 2 = triplet
info.ts1 = 10; % Main time in ms
info.ts2 = 6.0; % Group time in ms(number of channel*1.5)
info.N = 1; % channels will be stimulated every Nth time, should be 1 for current purposes
info.currentAmplitudes = zeros(1,length(info.AllChannels)); % start at 0 - no channels are on!
info.rampUpTime = 0.3; % time in seconds for up ramps
info.rampDownTime = 0.1; % time in seconds for down ramps
info.rampUpIncrements = 1; % number of increments in up ramps


% Determine amplitudes for each channel
info = InitializeAmplitude(motionstim8, info);


% Initialize all channels for upcoming stimulation
initializationHexCode = ChannelListInitialization(info.ts1, info.ts2, info.AllChannels, info.lowFreqChannels, info.N);
fwrite(motionstim8, sscanf(initializationHexCode,'%2x')', 'uint8')

end