im=imread('rgb_image1_0001.png');
im2=imread('rgb_image1_001.png');

im = rgb2hsv(im);
im2 = rgb2hsv(im2);

% Histograms of Hue

[c1, h1] = histcounts(im(:,:,1),64);
[c2, h2] = histcounts(im2(:,:,1),64);

% [ca ha] = imhist(im(:,:,1), 64);
% [cb hb] = imhist(im2(:,:,1), 64);

% Features
f1 = h1(1:end-1)';
f2 = h2(1:end-1)';
% Weights
w1 = c1' / sum(c1);
w2 = c2' / sum(c2);

[~, fval] = emd(f1, f2, w1, w2, @gdf);