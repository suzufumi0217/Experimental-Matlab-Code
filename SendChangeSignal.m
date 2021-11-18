function info = SendChangeSignal(motionstim8, info, mainleg, state)

% Triggers stimulation for a given state and given leg.
% motionstim8: serial port object
% info: structure containing settings for stimulation 
% leg: 1 for right leg, 2 for left leg
% state: 1, 2, 3 or 4
% Written by Heather Williams, August 2019

% define which channel corresponds with which muscle
channelList.right.BF = 1;
channelList.right.VM = 2;
channelList.right.SO = 3;
channelList.right.TA = 4;
channelList.left.BF = 5;
channelList.left.VM = 6;
channelList.left.SO = 7;
channelList.left.TA = 8;


% identify which leg is being used
if mainleg == 1
    mainlegStr = 'right';
    sublegStr = 'left';
elseif mainleg == 2
    mainlegStr = 'left';
    sublegStr = 'right';
end

% identify which channels are to be turned on/off
if state == 3 % Swing back
    on = sort([channelList.(sublegStr).BF channelList.(sublegStr).VM  channelList.(sublegStr).TA]);
    off = sort([channelList.(mainlegStr).BF channelList.(mainlegStr).VM channelList.(mainlegStr).SO channelList.(mainlegStr).TA channelList.(sublegStr).SO]);
    
elseif state == 4 % Push off
    on = sort([channelList.(mainlegStr).TA channelList.(sublegStr).SO]);
    off = sort([channelList.(mainlegStr).BF channelList.(mainlegStr).VM channelList.(mainlegStr).SO channelList.(sublegStr).BF channelList.(sublegStr).VM channelList.(sublegStr).TA]);

elseif state == 1 % no stimulation
    on = ([channelList.(mainlegStr).BF channelList.(mainlegStr).VM channelList.(mainlegStr).TA channelList.(sublegStr).SO]);
    off = sort([channelList.(mainlegStr).SO channelList.(sublegStr).BF channelList.(sublegStr).VM channelList.(sublegStr).TA]);
else 
    on = ([]);
    off = ([channelList.(mainlegStr).BF channelList.(mainlegStr).VM channelList.(mainlegStr).TA channelList.(mainlegStr).SO channelList.(sublegStr).SO channelList.(sublegStr).BF channelList.(sublegStr).VM channelList.(sublegStr).TA]);
end

% ramp up/down the approppriate channels
% [info,T,A] = onoffStim_pulse(motionstim8,info, on, off);
info = onoffStim(motionstim8,info, on, off);

end