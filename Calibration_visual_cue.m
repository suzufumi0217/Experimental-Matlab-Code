function Calibration_visual_cue(arduinoObj,max_step_duration,end_steps,n_repeat,rest_time)

%During Calibration time, this function put visual cue and collect
%mesurment data.

global isRight
global isLeft
global n_gait %number of one gait cycle

%スペックの低いパソコンでPTBを動かそうとするとSYNCHRONIZATION FAILURE!
%が表示されるがこのおまじないを書いとけば，実験の時間精度は落ちるがとりあえず動く．
Screen('Preference', 'SkipSyncTests', 1);
% Right_arrowとLeft_arrowの画像提示を行う．
% escapeキーが押されたら終わる．
KbName('UnifyKeyNames');
% あらかじめ読み込んでおく必要がある関数たち
GetSecs;
WaitSecs(0.1);
try
    AssertOpenGL;
    
    ListenChar(1); %Matlabに対するキー入力を無効
    myKeyCheck;
    %Color Setting
    bgColor = [112 112 112]; % Background color(gray) 36cd/m2
    GreyColor = [170 170 170];% (Light gray) 50cd/m2
    white = [255 255 255];
    black = [0 0 0];
   

    % 必要に応じてカーソルを消してください
    HideCursor;
    
    %Screen Number
    screenNumber = max(Screen('Screens'));
    
    %画面全体でのvisual cueの表示
    [mainWindow, windowRect] = Screen('OpenWindow', screenNumber, bgColor);
    % ウィンドウでの呈示（デバッグ用）
%     [windowPtr, windowRect] = Screen('OpenWindow', screenNumber, 0, [100, 200, 700, 600]);
    
    [width, height] = Screen('WindowSize', screenNumber);
    
    %画面の中央の座標
    [centerX centerY] = RectCenter(windowRect);
    
    %実験プログラムを保存しているフォルダ内にrabbit.jpgを準備してください。
    Left_imgfile = 'Left_arrow.bmp';
    Right_imgfile = 'Right_arrow.bmp';
    black_imgfile = 'black.bmp';
    
    
    %画像の読み込み
    Left_imdata = imread(Left_imgfile, 'bmp');
    Right_imdata = imread(Right_imgfile,'bmp');
    black_imdata = imread(black_imgfile,'bmp');
    
    
    %画像サイズの幅（ix）が列の数に相当し、画像サイズの高さ（iy）が
    %行の数の相当するため、返り値は、iy, ixの順番になっている。
    [iy, ix, id] = size(Left_imdata);
    [iy, ix, id] = size(Right_imdata);
    [iy, ix, id] = size(black_imdata);
    
    Left_imagetex = Screen('MakeTexture', mainWindow, Left_imdata);
    Right_imagetex = Screen('MakeTexture', mainWindow, Right_imdata);
    black_imagetex = Screen('MakeTexture', mainWindow, black_imdata);
    %上と同じ
    %imagetex = Screen('MakeTexture', win, imdata(1:iy, 1:ix, :));
    %画像の左上だけを呈示
    %imagetex = Screen('MakeTexture', win, imdata(1:iy/2, 1:ix/2, :));
    
    while KbCheck; end % いずれのキーも押されていないことをチェック。
    
    %Initial variables
    isRight = 1;
    isLeft = 0;
    n_gait = 0;

% Present the waiting screen
Screen('DrawText', mainWindow, 'Please press the Space Key twice to proceed.', centerX-210, centerY+50, white);
Screen('Flip', mainWindow);
SpaceTwice;
    
    %１ルートが終わるのを何回繰り返すか
    for i = 1:n_repeat
        course_steps = 0;
        % Present the ready screen
        Screen('TextSize',mainWindow, 130);
        Screen('DrawText', mainWindow, 'Ready', centerX-180, centerY-65, black);        
        Screen('Flip', mainWindow);
        WaitSecs(1)
        
        %Present "start the course" cue
        Screen('TextSize',mainWindow, 130);
        Screen('DrawText', mainWindow, 'Start', centerX-180, centerY-65, black);
        Screen('Flip', mainWindow);
        WaitSecs(1)
        
        while course_steps < end_steps
            n_gait = n_gait + 1;
            if isRight
                course_steps = course_steps + 1;
                Screen('DrawTexture', mainWindow, Right_imagetex,[],[0,0,width,height]);
                Screen('Flip', mainWindow);
                configureCallback(arduinoObj,"terminator",@read_C_data);
                writeline(arduinoObj,"r");
                WaitNsec(max_step_duration + rest_time); %追加
                isRight = 0;
                isLeft = 1;
                if course_steps == end_steps
                    break;
                end
            end
            
            if isLeft
                course_steps = course_steps + 1;
                Screen('DrawTexture', mainWindow, Left_imagetex,[],[0,0,width,height]);
                Screen('Flip', mainWindow);
                configureCallback(arduinoObj,"terminator",@read_C_data);
                writeline(arduinoObj,"l");
                WaitNsec(max_step_duration + rest_time); %追加
                isRight = 1;
                isLeft = 0;
                if course_steps == end_steps
                    break;
                end
            end
            
        end
        %Retrun to initial variables
        isRight = 1;
        isLeft = 0;
        % Present the waiting screen
        Screen('TextSize',mainWindow, 30);
        Screen('DrawText', mainWindow, 'Please press the Space Key twice to proceed.', centerX-210, centerY+50, white);
        Screen('Flip', mainWindow);
        SpaceTwice;
        
    end
   
    %Exit : Present 'Done!', and wait 3 seconds and close
    Screen('TextSize',mainWindow, 130);
    Screen('DrawText', mainWindow, 'Done', centerX-140, centerY-65, white);
    Screen('Flip', mainWindow);
    WaitSecs(3.0);
    
    sca;
    ShowCursor;
    ListenChar(0);
catch
    sca;
    ListenChar(0);
    psychrethrow(psychlasterror);
end