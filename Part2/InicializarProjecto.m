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
