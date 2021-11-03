function [state] = offlineDetection_BothLegs(time, R_w_hip, R_FS, L_w_hip, L_FS, thresholds)

% transitions.T1 = [];
% transitions.T2 = [];
% transitions.T3 = [];
% transitions.T4 = [];

%stateも構造体にする
state.R = [];
state.L = [];

%時間
current_time = time(1,1);

%右足に関して
R_prev_state = 0;
R_current_state = 0;
R_current_w_hip = R_w_hip(1,1);
R_current_aa_hip = 0;
R_current_FS = R_FS(1,1);

%左足に関して
L_prev_state = 0;
L_current_state = 0;
L_current_w_hip = L_w_hip(1,1);
L_current_aa_hip = 0;
L_current_FS = L_FS(1,1);

state.R = [state.R;R_current_state];
state.L = [state.L;L_current_state];
for i = 2:length(R_w_hip)
    prev_time = current_time;
    %右足について
    R_prev_state = R_current_state;
    R_prev_w_hip = R_current_w_hip;
    R_prev_aa_hip = R_current_aa_hip;
    R_current_w_hip = R_w_hip(i);
    R_current_aa_hip = R_w_hip(i) - R_w_hip(i-1);
    current_time = time(i);
    R_current_FS = R_FS(i);
    
    if(R_prev_state == 0 || R_prev_state == 2)
        if((R_prev_w_hip >= thresholds.R_max) && R_current_aa_hip <= 0 && R_prev_aa_hip >= 0 && R_current_FS < thresholds.FS)
            R_current_state = 4;
%             time_stamp4 = current_time;
%             transitions.T4 = [transitions.T4;i];
        end
    elseif(R_prev_state == 1)
        if(  R_current_FS > thresholds.FS )
            R_current_state = 2;
%             time_stamp2 = current_time;
%             transitions.T2 = [transitions.T2;i];
        end
%     elseif(prev_state == 3)
%         if((prev_w_hip >= thresholds.max) && current_aa_hip <= 0 && prev_aa_hip >= 0)
%             current_state = 4;
%             time_stamp4 = current_time;
%             transitions.T4 = [transitions.T4;i];
%         end
    elseif(R_prev_state == 4)
        if(R_prev_w_hip > 0 && R_current_w_hip <= 0)
            R_current_state = 1;
%             time_stamp1 = current_time;
%             transitions.T1 = [transitions.T1;i];
        end
    end
    state.R = [state.R;R_current_state];
    %左足について
    L_prev_state = L_current_state;
    L_prev_w_hip = L_current_w_hip;
    L_prev_aa_hip = L_current_aa_hip;
    L_current_w_hip = L_w_hip(i);
    L_current_aa_hip = L_w_hip(i) - L_w_hip(i-1);
    L_current_FS = L_FS(i);
    
    if(L_prev_state == 0 || L_prev_state == 2)
        if((L_prev_w_hip >= thresholds.L_max) && L_current_aa_hip <= 0 && L_prev_aa_hip >= 0 && L_current_FS < thresholds.FS)
            L_current_state = 4;
%             time_stamp4 = current_time;
%             transitions.T4 = [transitions.T4;i];
        end
    elseif(L_prev_state == 1)
        if( L_current_FS > thresholds.FS )
            L_current_state = 2;
%             time_stamp2 = current_time;
%             transitions.T2 = [transitions.T2;i];
        end
%     elseif(prev_state == 3)
%         if((prev_w_hip >= thresholds.max) && current_aa_hip <= 0 && prev_aa_hip >= 0)
%             current_state = 4;
%             time_stamp4 = current_time;
%             transitions.T4 = [transitions.T4;i];
%         end
    elseif(L_prev_state == 4)
        if(L_prev_w_hip > 0 && L_current_w_hip <= 0)
            L_current_state = 1;
%             time_stamp1 = current_time;
%             transitions.T1 = [transitions.T1;i];
        end
    end
    state.L = [state.L;L_current_state];
end
end