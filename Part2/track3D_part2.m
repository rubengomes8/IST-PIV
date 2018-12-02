%function [objects, cam2toW] = track3D_part2( imgseq1, imgseq2, cam_params)


% Calculate C2 to C1 transformation

im1=imread('rgb_image1_001.png');
im2=imread('rgb_image2_001.png');

load CalibrationData.mat
load depth1_001.mat
depth1 = depth_array;
load depth2_001.mat
depth2 = depth_array;


%obtain xyz coordinates of the image in an array, all normalized to the rgb
%camera plane
xyz1=get_xyz_asus(depth1(:),[480 640],1:640*480,Depth_cam.K,1,0);
xyz2=get_xyz_asus(depth2(:),[480 640],1:640*480,Depth_cam.K,1,0);

%obtain rgb 
rgbd1 = get_rgbd(xyz1, im1, R_d_to_rgb, T_d_to_rgb, RGB_cam.K);
rgbd2 = get_rgbd(xyz2, im2, R_d_to_rgb, T_d_to_rgb, RGB_cam.K);

%xyz in image coordinates
xyz1_img = reshape(xyz1,[480,640,3]);
xyz2_img = reshape(xyz2,[480,640,3]);

%finds features using SIFT for each image
[f1,d1]=vl_sift(single(rgb2gray(im1)));
[f2,d2]=vl_sift(single(rgb2gray(im2)));

%Matches features found above
[matches,~] = vl_ubcmatch(d1, d2,1.3);

%normalizes coordinates to matrix indexing
match1 = [uint64(f1(2,matches(1,:)))' uint64(f1(1,matches(1,:)))'];
match2 = [uint64(f2(2,matches(2,:)))' uint64(f2(1,matches(2,:)))'];

%%
figure(1);
imagesc(im1);hold on;plot(f1(1,matches(1,:)),f1(2,matches(1,:)),'*');hold off;
figure(2);
imagesc(im2);hold on;plot(f2(1,matches(2,:)),f2(2,matches(2,:)),'*');hold off;

%%
%%transform u,v into xyz, removing features that are in z = 0
not_feature = [];
point1 = [];
point2 = [];
for i = 1:length(match1)
%     pts1 = match1(i,:);
%     pts2 = match2(i,:);
    aux1 = reshape(xyz1_img(match1(i,1),match1(i,2),:),[3 1]);
    aux2 = reshape(xyz2_img(match2(i,1),match2(i,2),:),[3 1]);  
    if( aux1(3) == 0 || aux2(3) == 0)
        not_feature = [not_feature i];
    end  
    point1(:,i) = aux1;
    point2(:,i) = aux2;
end

point1 = [point1 ];
point2 = [point2 ];
%%
%%RANSAC
n_points = 5;
errorthresh=0.08;
niter=10000;
numinliers = [];
matching = [];

for i=1:niter-(n_points-1)
    %obtain N random matches from SIFT
    aux = randperm(length(point1),n_points);
    
    %Check if chosen matches do not belong to not_feature
    while (sum(ismember(aux,not_feature) > 0))
        aux = randi([1 length(point1)],1,n_points);
    end
    %store the match number
    matching = [matching aux'];

    %obtain the xyz points corresponding to the match
    p1 = point1(:,aux);  
    p2 = point2(:,aux);   
    
    %calculate rotation and translation using procrustes
    [~,~,tr] = procrustes(p1',p2','scaling',false,'reflection',false);
  
    %count the number of inliers from this model
    error = vecnorm((point1(:,:)'- (point2(:,:)'*tr.T + ones(length(point2),1)*tr.c(1,:))),2,2);
    inds = find(error < errorthresh);  
    numinliers = [numinliers length(inds)];
    
end
%% 
% use the best model
[mm,ind] = max(numinliers);
fprintf('Maximum num of inliers %d \n',mm);

p1 = point1(:,matching(:,ind));
p2 = point2(:,matching(:,ind));
    
[~,~,tr] = procrustes(p1',p2','scaling',false,'reflection',false);
xyz2_morphed = xyz2*tr.T + ones(length(xyz2),1)*tr.c(1,:);
xyz2_img_morphed = reshape(xyz2_morphed,[480 640 3]);


%%
pc1=pointCloud(xyz1,'Color',reshape(rgbd1,[480*640 3]));
pc2=pointCloud(xyz2_morphed,'Color',reshape(rgbd2,[480*640 3]));
figure(3);hold off;
pcshow(pcmerge(pc1,pc2,0.001));
drawnow;
