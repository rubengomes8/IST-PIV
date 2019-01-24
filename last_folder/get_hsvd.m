function [im_hsv,im_depth,bg_depth] = get_hsvd(imgseq1)
%Returns arrays with depth(Z,i), color information(H,S,V,i), and background

%initialize matrixes with 0s
im_hsv=zeros(480,640,3,length(imgseq1(:)));
im_depth=zeros(480,640,length(imgseq1(:)));

%fill matrixes with pictures and signatures from depth camera
for i=1:length(imgseq1(:))
    im_hsv(:,:,:,i)=rgb2hsv(imread(imgseq1(i).rgb));
    load(imgseq1(i).depth);
    im_depth(:,:,i)=double(depth_array)/1000;
    figure(1)
    imshow(hsv2rgb(im_hsv(:,:,:,i)));
    figure(2);
    imagesc(im_depth(:,:,i));
end
bg_depth=median(im_depth,3);
figure(3);
imagesc(bg_depth);
end

