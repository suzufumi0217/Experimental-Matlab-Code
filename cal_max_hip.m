function peak = cal_max_hip(w_hip)
%calibrate the parameters like max hip angular velocity
%setting 
sum_peaks = 0;
peaks = 0;
peak = 0;
for i=1:length(w_hip)
   
    [pks,locs] = findpeaks(w_hip{i,1});
    %sort peaks
    sorted_pks = sort(pks,"descend");
    %
    mean_TopTenPks(i) = mean(sorted_pks(1:(floor(length(sorted_pks) / 10)) ));
%     peaks = peaks + mean_TopTenPks;
end

peak = mean(mean_TopTenPks);

end


