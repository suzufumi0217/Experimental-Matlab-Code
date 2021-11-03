%%Testing arrow trial
function RL_arrow_display_testing

Screen('Preference', 'SkipSyncTests', 0);
%Motor Imagery
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
  [centerX, centerY] = RectCenter(windowRect);
  % ウィンドウでの呈示（デバッグ用）
%   [windowPtr, windowRect] = Screen('OpenWindow', screenNumber, 0, [100, 200, 700, 600])
  
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
  
  step = 1;
  %escapeキーが押されるまで繰り返すwhile構造
  while 1
      %キーボードの情報を取得している．
      [ keyIsDown, seconds, keyCode ] = KbCheck;
      if keyIsDown
          
          if keyCode(LeftArrowKey)
              now = GetSecs();
              Screen('DrawTexture', windowPtr, Left_imagetex,[],[0,0,width,height]);
              Screen('Flip', windowPtr,now+2);
%               writeline(arduinoObj,"l");
%               configureCallback(arduinoObj,"terminator",@readL_State);
%               if(isfinishstep)
%                   Screen('DrawTexture', windowPtr, black_imagetex);
%                   Screen('Flip', windowPtr);
%                   configureCallback(arduinoObj, "off");
%                   waitNsec(1);
%                   isfinishstep = false;
%                   
%               end
%               isfinish = WaitNsec(5);
%               if(isfinish)
%                   Screen('DrawTexture', windowPtr, black_imagetex);
%                   Screen('Flip', windowPtr);
%                   configureCallback(arduinoObj, "off");
%               end
              disp(step)
              step = step + 1  ;
              %ここにDetectionが終わったら？黒い画面に戻るように書こうか．
          end
          
          if keyCode(RightArrowKey)
              now = GetSecs();
              Screen('DrawTexture', windowPtr, Right_imagetex,[],[0,0,width,height]);
              Screen('Flip', windowPtr,now+2);
%               writeline(arduinoObj,"r");
%               configureCallback(arduinoObj,"terminator",@readR_State);
%               isfinish = WaitNsec(5);
%               if(isfinish)
%                   Screen('DrawTexture', windowPtr, black_imagetex);
%                   Screen('Flip', windowPtr);
%                   configureCallback(arduinoObj, "off");
%               end
              disp(step)
              step = step + 1;
              %ここにDetectionが終わったら？黒い画面に戻るように書こうか．
          end
          
%           if keyCode(KbName_E)
%               writeline(arduinoObj,"e");
%               readline(arduinoObj)
%           end

          if keyCode(escapeKey)
              break; % while 文を抜けます。
          end
%           configureCallback(arduinoObj, "off");
%           
          if(step > 20)
              break; 
          end
  
          %いずれのキーも押されていないことをチェック。
          while KbCheck; end
      end
  end
  %文字列の描画（赤い円と緑の四角の中央に描画されるでしょうか）
  startX = centerX - normBoundsRect(RectRight)/2;
  startY = centerY + normBoundsRect(RectBottom)/2;
  DrawFormattedText(windowPtr, teststr, startX, startY, [255 255 255]);
  Screen('Flip', windowPtr);
 
  KbWait([], 2);
  %KbWait;
 
  sca;
  ListenChar(0);
catch
  sca;
  ListenChar(0);
  psychrethrow(psychlasterror);
end