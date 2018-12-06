function objects = track3D_part1(imgseq1, cam_params )
%%receives the images as inputs and  returns the 8 points describing the time trajectories of the enclosing box of the objects in world (camera) coordinates

[r, res_xyz_median] = get_rgb(imgseq1, cam_params);

objects = [];
% objects.X = [];
% objects.Y = [];
% objects.Z = [];
% objects.cm = [];
% objects.hist = [];

for i=1:length(imgseq1(:))
    
    im_diff2 = abs(r(i).res_xyz(:,:,3)-res_xyz_median)>.7;
    im_diffiltered2=imopen(im_diff2,strel('disk',5));
    [label, nr_obj] = bwlabel(im_diffiltered2);
    
    %Background image
    figure(1);imagesc(res_xyz_median);
    %Depth image
    figure(2); imagesc(r(i).res_xyz(:,:,3));
    %Labeled Connected components
    figure(3);imagesc(label);

    
    %this should output the box coordinates of i objects and their centers of mass in xyz
    %meters
    [box,nr_obj] = get_box(label, nr_obj, r(i));
    connection = [];
    
    if i == 1 % first frame, store all objects!       
        prev_frame_box = box;
    
    else
        %1. Compare current box with all objects in object
         [objects,connection] = update_objects(nr_obj, box, objects,i);
        
        %2. For the remaining boxes of 1. compare with the last frame box array
         [objects,connection] = add_object(objects,box,prev_frame_box,connection,i);
        
        %3. For the remaining boxes of 2. save in array, thus deleting past boxes
        %unused boxes are:
         not_used = find(connection == 0);        
         prev_frame_box.X = box.X(not_used,:);
         prev_frame_box.Y = box.X(not_used,:);
         prev_frame_box.Z = box.X(not_used,:);
         prev_frame_box.cm = box.cm(not_used,:);
         prev_frame_box.hist = box.hist(not_used,:,:);
         
    end
end