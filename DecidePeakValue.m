function [resultpks] = DecidePeakValue(w_hip,time)
%純粋にfindpeaksする
[pks,locs] = findpeaks(w_hip);

%peaksを降順に並べる
sortedpeaks = sort(pks,'descend');

%MinPeakHeightを求めるために上から10%の値をとってくる
MinPeakHeight = sortedpeaks(floor(length(pks)*0.1));

%MinPeakHeightを用いてもう一度findpeaks
[s_pks,s_locs] = findpeaks(w_hip,time,'MinPeakHeight', MinPeakHeight);

%隣り合うlocationの差分をとってくる
locs_diff = diff(s_locs);

%diffの平均を計算する
MinPeakDistance = sum(locs_diff) / length(locs_diff);

%MinPeakDistanceを用いてfindpeaks
r_pks = findpeaks(w_hip,time,'MinPeakHeight', MinPeakHeight, 'MinPeakDistance', MinPeakDistance);

%最終的なピーク値を決定する．
resultpks = sum(r_pks) / length(r_pks) * 0.5;
end

