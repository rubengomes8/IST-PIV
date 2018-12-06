close all;
load('cameraparametersAsus.mat');
%store all .jpeg and .mat files into variables
d=dir('*.jpg');
dd=dir('*.mat');
for i=1:length(d)
    imgseq1(i).rgb = d(i).name;
    imgseq1(i).depth = dd(i+1).name;
end
tic
objects = track3D_part1(imgseq1, cam_params);
toc

%%
for k=1:length(objects(2).frames_tracked)
    figure(1);
    plot3(objects(2).X(k,:) , objects(2).Y(k,:),objects(2).Z(k,:),'*')
    figure(2)
    im1 = imread( imgseq1(objects(2).frames_tracked(k)).rgb);
    imshow(im1)
    pause();
end