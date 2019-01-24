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
% figure(1);
% imagesc([im1 im2]);hold on;
% line([match1(:,1)'; match2(:,1)'+640],[match1(:,2)';match2(:,2)']);hold off;

%%
point1 = [];
point2 = [];
count = 1;
for i = 1:length(match1)
    aux1 = reshape(r1.res_xyz(match1(i,2),match1(i,1),:),[3 1]);
    aux2 = reshape(r2.res_xyz(match2(i,2),match2(i,1),:),[3 1]);
    % if one is a fake feature do not add to match list
    if(aux1(3) == 0 || aux2(3) == 0 || sum(r1.rgbd(match1(i,2),match1(i,1),:)) == 0 || sum(r2.rgbd(match2(i,2),match2(i,1),:)) == 0)
        continue;
    end  
    point1(:,count) = aux1;
    point2(:,count) = aux2;
    matched1(count,2) = match1(i,2);
    matched1(count,1) = match1(i,1);
    matched2(count,2) = match2(i,2);
    matched2(count,1) = match2(i,1);   
    count = count +1;
end
%%
%%RANSAC
n_points = 4;
errorthresh=0.3;
niter=500;
numinliers = [];
matching = [];
ind_inliers = [];
transf=[];
for i=1:niter-(n_points-1)
    %obtain N random matches from SIFT
    aux = randperm(length(point1),n_points);
    %store the match number
    matching = [matching aux'];
    %obtain the xyz points corresponding to the match
    p1 = point1(:,aux);  
    p2 = point2(:,aux);   
    %calculate rotation and translation using procrustes
    [~,~,tr_t] = procrustes(p1',p2','scaling',false,'reflection',false);
    %count the number of inliers from this model
    Diff = point1(:,:)' - (point2(:,:)'*tr_t.T + ones(length(point2),1)*tr_t.c(1,:));
    error2 = sqrt(sum(Diff.^2,2));
    inds = find(error2 < errorthresh);
    transf = [transf tr_t];
    numinliers = [numinliers length(inds)];
    ind_inliers(i).index = inds; 
end
%% 
% use the best model
[mm,ind] = max(numinliers);
% fprintf('Maximum num of inliers %d \n',mm);

mtc_1 = matching(:,ind);
% figure(2);
% imagesc([r1.rgbd r2.rgbd]);hold on;
% line([matched1(mtc_1,1)'; matched2(mtc_1,1)'+640],[matched1(mtc_1,2)';matched2(mtc_1,2)']);hold off;

mtc = ind_inliers(ind).index;

p1 = point1(:,mtc);
p2 = point2(:,mtc);
    
[~,Y_er,tr] = procrustes(p1',p2','scaling',false,'reflection',false);

error = mean(sqrt(sum((p1'-Y_er).^2,2)));
xyz2_morphed = r2.xyz*tr.T + ones(length(r2.xyz),1)*tr.c(1,:);
xyz2_img_morphed = reshape(xyz2_morphed,[480 640 3]);

%%
% figure(3);
% imagesc([r1.rgbd r2.rgbd]);hold on;
% line([matched1(mtc,1)'; matched2(mtc,1)'+640],[matched1(mtc,2)';matched2(mtc,2)']);hold off;

% pc1=pointCloud(r1.xyz,'Color',reshape(r1.rgbd,[480*640 3]));
% pc2=pointCloud(xyz2_morphed,'Color',reshape(r2.rgbd,[480*640 3]));
% figure(5);hold off;
% pcshow(pcmerge(pc1,pc2,0.001));
% drawnow;

end

