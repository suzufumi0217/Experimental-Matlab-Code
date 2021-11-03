function [peaks] = calibration(R_w_hip, L_w_hip, time)

peaks.R = DecidePeakValue(R_w_hip,time);
peaks.L = DecidePeakValue(L_w_hip,time);

end