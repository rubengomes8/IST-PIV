function [distance] = color_dist(histogram1,histogram2)
%Calculates distance between two color histograms using EMD

hist1 = reshape(histogram1,[2 length(histogram1(1,1,:))]);
hist2 = reshape(histogram2,[2 length(histogram2(1,1,:))]);

f1 = hist1(2,:)';
f2 = hist2(2,:)';
% Weights
w1 = hist1(1,:)' / sum(hist1(1,:));
w2 = hist2(1,:)' / sum(hist2(1,:));

distance = 1-(sqrt(w1(:)')*sqrt(w2(:)));
%might be necessay to nornalize distance to 0-1
%[~, distance] = emd(f1, f2, w1, w2, @gdf);
end

