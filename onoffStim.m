function info = onoffStim(motionstim8, info,on, off)
% Turn channels on or off, with a ramp. 
% Ramp ups will go from current amplitude, so if channel is already on then
% it will just stay on. Ramps down are designed to go to zero (and again,
% if channel is already at 0 it will stay there). 
% motionstim8: serial port object
% info: structure containing settings for stimulation 
% on: list of channels to be turned on, can be an empty array
% off: list of channels to be turned off, can be an empty array
% Written by Heather Williams, August 2019

% Calculate number of increments for ramp down (based on number of
% increments for ramp up). Since ramp down is shorter than ramp up, once a
% channel has been ramped down it will stay at 0 for the remaining time in
% which the other channels are ramping up.
rampDownIncrements = ceil(info.rampDownTime/info.rampUpTime*info.rampUpIncrements);

% set up matrix of amplitudes to set at each time increment
Amplitudes = zeros(info.rampUpIncrements, length(info.AllChannels));
for i = 1:length(info.AllChannels)
    if ismember(info.AllChannels(i),on)
        Amplitudes(1:info.rampUpIncrements,i) = round(linspace(info.currentAmplitudes(i),info.maxAmplitudes(i),info.rampUpIncrements))';
    elseif ismember(info.AllChannels(i),off)
        Amplitudes(1:info.rampUpIncrements,i) = [round(linspace(info.currentAmplitudes(i),0,rampDownIncrements))'; zeros(info.rampUpIncrements - rampDownIncrements,1)];
    else
        Amplitudes(1:info.rampUpIncrements,i) = info.currentAmplitudes(i);
    end
end

% generate and send hex code to the device at each increment, then pause
% before moving on to next increment 
for i = 1:info.rampUpIncrements
    hexcode = ChannelListUpdate(info.PulseWidth*ones(1,length(info.AllChannels)), Amplitudes(i,:), info.Mode*ones(1,length(info.AllChannels)));
    fwrite(motionstim8, sscanf(hexcode,'%2x')', 'uint8')
%     pause(info.rampUpTime/info.rampUpIncrements)
end
info.currentAmplitudes = Amplitudes(end,:);