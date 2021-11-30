%% offline Detection (11/30)
clear all
close all
load("calibration_25-Nov-2021_4(s)inExp.mat")

%Focus on which leg?
% RorL = 1; %Right
RorL = 2; %Left

%Detection Algorithm
for i = 1:6
    %put the data in the variables depends on the main leg
    if RorL == 1 %Mainleg is Right
        time = C_time{i,RorL};
        current_FS = C_R_FS{i,1};
        current_w_hip = C_R_w_hip{i,1};
        threshold_hip_max = Max_R_w_hip;
    end
    
    if RorL == 2 %Mainleg is Left
        time = C_time{i,RorL};
        current_FS = C_L_FS{i,1};
        current_w_hip = C_L_w_hip{i,1};
        threshold_hip_max = Max_L_w_hip;
    end
    %Initial Value
    current_state(1) = 3;
    current_w_hip(1) = 0;
    
    %threshold_hip_max/2
    
    % Detectoin Algorithm
    for j = 2:length(time)
        if current_state(j-1) == 3
            if current_FS(j) < threshold.FS %下降を含めてArduinoでは書いている
                current_state(end+1) = 4;
            else
                current_state(end+1) = current_state(j-1);
            end
        elseif current_state(j-1) == 4
            if current_w_hip(j-1) > threshold_hip_max/4 && current_w_hip(j) < threshold_hip_max/4 && current_FS(j) < threshold.FS
                current_state(end+1) = 1;
            else
                current_state(end+1) = current_state(j-1);
            end
        elseif current_state(j-1) == 1
            if current_FS(j) > threshold.FS
                current_state(end+1) = 2;
            else
                current_state(end+1) = current_state(j-1);
            end
        elseif current_state(j-1) == 2
            current_state(end+1) = current_state(j-1);
        end
        
    end
    %Plotting Figure
    F(i) = figure;
    plot(time,current_w_hip)
    hold on
    yline(threshold_hip_max)
    hold on
    yyaxis right
    plot(time,current_FS)
    hold on
    plot(time,current_state)
    
    %Initialize the variables
    current_state = [];
end