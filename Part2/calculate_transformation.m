function [tr] = calculate_transformation(r1,r2,im1,im2)
%Calculates the transformation from camera 2 to camera 1 
%using SIFT + RANSAC + PROCRUSTES

%finds features using SIFT for each image
[f1,d1]=vl_sift(single(rgb2gray(im1)));
[f2,d2]=vl_sift(single(rgb2gray(im2)));

%Matches features found above
[matches,~] = vl_ubcmatch(d1, d2,1.5);

%normalizes coordinates to matrix indexing
match1 = [uint64(f1(1,matches(1,:)))' uint64(f1(2,matches(1,:)))'];
match2 = [uint64(f2(1,matches(2,:)))' uint64(f2(2,matches(2,:)))'];

%% Matches
figure(1);
imagesc([im1 im2]);hold on;
line([match1(:,1)'; match2(:,1)'+640],[match1(:,2)';match2(:,2)']);hold off;

%%
%%transform u,v into xyz, removing features that are in z = 0
not_feature = [];
point1 = [];
point2 = [];
for i = 1:length(match1)
%     pts1 = match1(i,:);
%     pts2 = match2(i,:);
    aux1 = reshape(r1.res_xyz(match1(i,2),match1(i,1),:),[3 1]);
    aux2 = reshape(r2.res_xyz(match2(i,2),match2(i,1),:),[3 1]);  
    if( aux1(3) == 0 || aux2(3) == 0)
        not_feature = [not_feature i];
    end  
    point1(:,i) = aux1;
    point2(:,i) = aux2;
end
%%
%%RANSAC
n_points = 4;
errorthresh=0.16;
niter=200;
numinliers = [];
matching = [];
ind_inliers = [];

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
    error = vecnorm((point1(:,:)' - (point2(:,:)'*tr.T + ones(length(point2),1)*tr.c(1,:))),2,2);
    inds = find(error < errorthresh);  
    numinliers = [numinliers length(inds)];
    ind_inliers(i).index = inds;
    
end
%% 
% use the best model
[mm,ind] = max(numinliers);
fprintf('Maximum num of inliers %d \n',mm);

mtc = ind_inliers(ind).index;

p1 = point1(:,mtc);
p2 = point2(:,mtc);
    
[~,~,tr] = procrustes(p1',p2','scaling',false,'reflection',false);
xyz2_morphed = r2.xyz*tr.T + ones(length(r2.xyz),1)*tr.c(1,:);
xyz2_img_morphed = reshape(xyz2_morphed,[480 640 3]);

%%
figure(2);
imagesc([im1 im2]);hold on;
line([match1(mtc,1)'; match2(mtc,1)'+640],[match1(mtc,2)';match2(mtc,2)']);hold off;

pc1=pointCloud(r1.xyz,'Color',reshape(r1.rgbd,[480*640 3]));
pc2=pointCloud(xyz2_morphed,'Color',reshape(r2.rgbd,[480*640 3]));
figure(5);hold off;
pcshow(pcmerge(pc1,pc2,0.001));
drawnow;

end

