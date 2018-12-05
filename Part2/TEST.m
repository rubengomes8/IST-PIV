% Calculate C2 to C1 transformation

im1=imread('rgb_image1_0001.png');
im2=imread('rgb_image2_0001.png');

load CalibrationData.mat
load depth1_0001.mat
depth1 = depth_array;
load depth2_0001.mat
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
[f1,d1]=vl_sift(single(rgb2gray(rgbd1)));
[f2,d2]=vl_sift(single(rgb2gray(rgbd2)));

%normalizes coordinates to matrix indexing
match1 = [uint64(f1(2,:))' uint64(f1(1,:))'];
match2 = [uint64(f2(2,:))' uint64(f2(1,:))'];

%%
% figure(1);
% imagesc(rgbd1);hold on;plot(f1(1,matches(1,:)),f1(2,matches(1,:)),'*');hold off;
% figure(2);
% imagesc(rgbd2);hold on;plot(f2(1,matches(2,:)),f2(2,matches(2,:)),'*');hold off;

%%
%%transform u,v into xyz, removing features that are in z = 0
point1 = [];
point2 = [];
for i = 1:min(length(match1),length(match2))
    
    aux1 = reshape(xyz1_img(match1(i,1),match1(i,2),:),[3 1]);
    if( aux1(3) ~= 0)
        point1 = [point1, aux1];
    end 
    
    aux2 = reshape(xyz2_img(match2(i,1),match2(i,2),:),[3 1]);
    if( aux2(3) ~= 0)
        point2 = [point2, aux1];
    end
     
end

%%
%%RANSAC
n_points = 5;
errorthresh=0.1;
niter=1000;
numinliers = [];
matching = [];

for i=1:niter-(n_points-1)
    %obtain N random matches from SIFT
    aux1 = randi([1 length(point1)],1,n_points);
    aux2 = randi([1 length(point2)],1,n_points);
    %store the match number
    matching = [matching [aux1 aux2]'];

    %obtain the xyz points corresponding to the match
    p1 = point1(:,aux1);  
    p2 = point2(:,aux2);   
    
    %calculate rotation and translation using procrustes
    [~,~,tr] = procrustes(p1',p2','scaling',false,'reflection',false);
  
    %count the number of inliers from this model
    sized = min(length(point1),length(point2));
    error = abs(point1(:,1:sized)'- point2(:,1:sized)'*tr.T + ones(length(point2),1)*tr.c(1,:));
    inds = find(error < errorthresh);  
    numinliers = [numinliers length(inds)];
    xyz2_morphed = xyz2*tr.T + ones(length(xyz2),1)*tr.c(1,:);
    xyz2_img_morphed = reshape(xyz2_morphed,[480 640 3]);


    %%
    pc1=pointCloud(xyz1,'Color',reshape(rgbd1,[480*640 3]));
    pc2=pointCloud(xyz2_morphed,'Color',reshape(rgbd2,[480*640 3]));
    figure(1);hold off;
    pcshow(pcmerge(pc1,pc2,0.001));
    drawnow;
    pause();
end
%% 
% use the best model
[mm,ind] = max(numinliers);
fprintf('Maximum num of inliers %d \n',mm);

p1 = point1(:,matching(1:n_points,ind));
p2 = point2(:,matching(n_points+1:end,ind));
    
[~,~,tr] = procrustes(p1',p2','scaling',false,'reflection',false);
xyz2_morphed = xyz2*tr.T + ones(length(xyz2),1)*tr.c(1,:);
xyz2_img_morphed = reshape(xyz2_morphed,[480 640 3]);


%%
pc1=pointCloud(xyz1,'Color',reshape(rgbd1,[480*640 3]));
pc2=pointCloud(xyz2_morphed,'Color',reshape(rgbd2,[480*640 3]));
figure(1);hold off;
pcshow(pcmerge(pc1,pc2,0.001));
drawnow;
