function objects = track3D_part1(imgseq1, cam_params )
%%receives the images as inputs and  returns the 8 points describing the time trajectories of the enclosing box of the objects in world (camera) coordinates


[im_hsv,im_depth,bg_depth] = get_hsvd(imgseq1);

for i=1:length(imgseq1(:))
    im_diff = abs(im_depth(:,:,i)-bg_depth)>.2;
    im_diffiltered=imopen(im_diff,strel('disk',5));
    [im_label,n_objects]= bwlabel(im_diffiltered);
    
    %this should output the box coordinates of i objects and their centers of mass in xyz
    %meters
    box = get_box(im_depth, im_label, n_objects, cam_params);
    
    if i == 1 % first frame, store all objects!       
        prev_frame_box = box;
    
    else
        %1. Compare current box with all objects in object
        connection = update_objects(objects, box, im_hsv(:,:,:,i) );
        %   if conected update
        
        %2. For the remaining boxes of 1. compare with the last frame box array
        add_object(objects,box,prev_frame_box,im_hsv(:,:,:,i),connection);
        
        %3. For the remaining boxes of 2. save in array, thus deleting past
        %boxes
        prev_frame_box = box(not_used);  
    end
end

end

