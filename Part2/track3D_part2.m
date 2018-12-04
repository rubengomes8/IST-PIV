function [objects, cam2toW] = track3D_part2( imgseq1, imgseq2, cam_params)


[r1, res1_xyz_median] = get_rgb(imgseq1, cam_params);
[r2, res2_xyz_median] = get_rgb(imgseq2, cam_params);


%% Calculates Transformation from Procrustes
[tr] = calculate_transformation(r1(1),r2(2),imread(imgseq1(1).rgb),imread(imgseq2(1).rgb));

%% Motion detection

for i=1:length(imgseq1(:))
    
    %% Background Subtratction
    %Image 1
    im_diff21 = abs(r1(i).res_xyz(:,:,3)-res1_xyz_median)>.7;
    im_diffiltered21 = imopen(im_diff2,strel('disk',5));
    [label1, nr_obj1] = bwlabel(im_diffiltered21);
    %Image2
    im_diff22 = abs(r2(i).res_xyz(:,:,3)-res2_xyz_median)>.7;
    im_diffiltered22 = imopen(im_diff22,strel('disk',5));
    [label2, nr_obj2] = bwlabel(im_diffiltered22);
    
    %Background image
    figure(1);imagesc([res1_xyz_median res2_xyz_median]);
    %Depth image
    figure(2); imagesc([r(i).res_xyz(:,:,3) r(i).res_xyz(:,:,3)]);
    %Labeled Connected components
    figure(3);imagesc([label1 label2]);

    %this should output the box coordinates of i objects and their centers of mass in xyz
    %meters
    box1 = get_box(label1, nr_obj1, r1(i));
    box2 = get_box(label2, nr_obj2, r2(i));
    
    
    %% This should be slightly different from part 1
    if i == 1 % first frame, store all objects!       
        prev_frame_box = box;
    
    else
        %1. Compare current box with all objects in object
%         [objects,connection] = update_objects(nr_obj, box, objects);
        
        %2. For the remaining boxes of 1. compare with the last frame box array
%         [objects,connection] = add_object(objects,box,prev_frame_box,connection);
        
        %3. For the remaining boxes of 2. save in array, thus deleting past boxes
        %unused boxes are:
%         not_used = find(connection == 0)
%         prev_frame_box = box(findnot_used);  
    end


end
