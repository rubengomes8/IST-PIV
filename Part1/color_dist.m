function [distance] = color_dist(hist1,hist2)
%Calculates distance between two color histograms using EMD

f1 = hist1(2,1:end-1)';
f2 = hist2(2,1:end-1)';
% Weights
w1 = hist1(1,:)' / sum(hist1(1,:));
w2 = hist2(2,:)' / sum(hist1(2,:));

%might be necessay to nornalize distance to 0-1
[~, distance] = emd(f1, f2, w1, w2, @gdf);
end

