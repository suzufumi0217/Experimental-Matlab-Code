function peak = calibration(R_w_hip)

%setting 
sum_peaks = 0;
peaks = 0;
peak = 0;
for i=1 : length(R_w_hip)
   
    [pks,locs] = findpeaks(R_w_hip{i,1});
    %sort peaks
    sorted_pks = sort(pks,"descend");
    %
    mean_TopTenPks(i) = mean(sorted_pks(1:(floor(length(sorted_pks) / 10)) ));
%     peaks = peaks + mean_TopTenPks;
end

peak = mean(mean_TopTenPks);

end


