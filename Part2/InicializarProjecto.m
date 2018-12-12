close all;
load('cameraparametersAsus.mat');
%store all .jpeg and .mat files into variables
d=dir('*.png');
dd=dir('*.mat');
for i=1:length(d)/2
    imgseq1(i).rgb = d(i).name;
    imgseq1(i).depth = dd(i+1).name;
end
a = 1;
for i = length(d)/2+1:length(d)
    imgseq2(a).rgb = d(i).name;
    imgseq2(a).depth = dd(i+1).name;
    a=a+1;
end
tic
[objects, cam2toW] = track3D_part2( imgseq1, imgseq2, cam_params);
toc
