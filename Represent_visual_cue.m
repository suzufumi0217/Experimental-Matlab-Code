function Represent_visual_cue(arduinoObj,steps_end,max_step_duration)

global isfinishstep
isfinishstep = 0;

global D_time
global D_R_state
global D_L_state
global D_R_w_hip
global D_L_w_hip
global D_R_FS
global D_L_FS

global step

global R_stepcount
global L_stepcount

R_stepcount = 1;
L_stepcount = 1;

D_time = {};
D_R_state = {};
D_L_state = {};
D_R_w_hip = {};
D_L_w_hip = {};
D_R_FS = {};
D_L_FS = {};

%スペックの低いパソコンでPTBを動かそうとするとSYNCHRONIZATION FAILURE!
%が表示されるがこのおまじないを書いとけば，実験の時間精度は落ちるがとりあえず動く．
Screen('Preference', 'SkipSyncTests', 0);
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
  
  % 必要に応じてカーソルを消してください
  %HideCursor;
  
  screenNumber = max(Screen('Screens'));
  [windowPtr, windowRect] = Screen('OpenWindow', screenNumber, 0);
  [width, height] = Screen('WindowSize', screenNumber);
  
  %描画する文字列
  Screen('TextFont',windowPtr, 'Courier New'); % フォントの種類によっては中央に描画できないことがあります。
  Screen('TextSize',windowPtr, 200);
  teststr = 'Done';
  %スクリーン上で文字列が占める長方形領域が normBoundsRect
  %事前にフォントの設定を済ませておくこと。
  [normBoundsRect, offsetBoundsRect]= Screen('TextBounds', windowPtr, teststr);
  
  %画面の中央の座標
  [centerX centerY] = RectCenter(windowRect);
  % ウィンドウでの呈示（デバッグ用）
%   [windowPtr, windowRect] = Screen('OpenWindow', screenNumber, 0, [100, 200, 700, 600]);
 
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

  Left_imagetex = Screen('MakeTexture', windowPtr, Left_imdata);
  Right_imagetex = Screen('MakeTexture', windowPtr, Right_imdata);
  black_imagetex = Screen('MakeTexture', windowPtr, black_imdata);
  %上と同じ
  %imagetex = Screen('MakeTexture', win, imdata(1:iy, 1:ix, :));
  %画像の左上だけを呈示
  %imagetex = Screen('MakeTexture', win, imdata(1:iy/2, 1:ix/2, :));
  
  % それぞれのキー入力を定義しておく．
  escapeKey = KbName('ESCAPE');
  LeftArrowKey = KbName('LeftArrow');
  RightArrowKey = KbName('RightArrow');
  KbName_E = KbName('E');
  
  while KbCheck; end % いずれのキーも押されていないことをチェック。
  
  step = 0;
  %escapeキーが押されるまで繰り返すwhile構造
  while 1
      %キーボードの情報を取得している．
      [ keyIsDown, seconds, keyCode ] = KbCheck;
      if keyIsDown
          
          if keyCode(LeftArrowKey)
              step = step + 1;
              Screen('DrawTexture', windowPtr, Left_imagetex,[],[0,0,width,height]);
              Screen('Flip', windowPtr);
              configureCallback(arduinoObj,"terminator",@readL_State);
              writeline(arduinoObj,"l");
              WaitNsec(max_step_duration + 1); %追加
              disp("Press right button!")
          end
          
          if keyCode(RightArrowKey)
              step = step + 1;
              Screen('DrawTexture', windowPtr, Right_imagetex,[],[0,0,width,height]);
              Screen('Flip', windowPtr);
              configureCallback(arduinoObj,"terminator",@readR_State);
              writeline(arduinoObj,"r");
              WaitNsec(max_step_duration + 1); %追加
              disp("Press left button!")
          end
          
          if keyCode(KbName_E)
              Screen('DrawTexture', windowPtr, black_imagetex);
              Screen('Flip', windowPtr);
              writeline(arduinoObj,"e");
              readline(arduinoObj); %"End Detection"
          end

          if keyCode(escapeKey)
              break; % while 文を抜けます。
          end

          if(step > steps_end)% step数を超えると終わる 
%               WaitNsec(1);
              break;
          end
  
          %いずれのキーも押されていないことをチェック。
          while KbCheck; end
      end
%       if(isfinishstep)
%           Screen('DrawTexture', windowPtr, black_imagetex);
%           Screen('Flip', windowPtr);
%           WaitNsec(1);
%           isfinishstep = false;
%       end
  end
  %文字列の描画（赤い円と緑の四角の中央に描画されるでしょうか）
  startX = centerX - normBoundsRect(RectRight)/2;
  startY = centerY + normBoundsRect(RectBottom)/2;
  DrawFormattedText(windowPtr, teststr, startX, startY, [255 255 255]);
  Screen('Flip', windowPtr);
  
  %何かキーが押されたら次のステップに進むようにする．
  KbWait([], 2);
 
  sca;
  ListenChar(0);
catch
  sca;
  ListenChar(0);
  psychrethrow(psychlasterror);
end