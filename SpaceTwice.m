function SpaceTwice()
keycheck = 0;
KbName('UnifykeyNames');

spaceKey = KbName('space');

while (keycheck<2)
    [keyIsDown,secs,keycode] = KbCheck;
    if keycode(spaceKey)
        keycheck = keycheck + 1;
        WaitSecs(0.1);
    end
end