function [distance] = color_dist(histogram1,histogram2)
%Calculates distance between two color histograms using EMD

hist1 = reshape(histogram1,[2 length(histogram1(1,1,:))]);
hist2 = reshape(histogram2,[2 length(histogram2(1,1,:))]);

% Weights
w1 = [hist1(1,:) / (2*sum(hist1(1,:))); hist1(2,:) / (2*sum(hist1(2,:)))];
w2 = [hist2(1,:) / (2*sum(hist2(1,:))); hist2(2,:) / (2*sum(hist2(2,:)))];

distance = 1 - (sqrt(w1(:)')*sqrt(w2(:)));

end

