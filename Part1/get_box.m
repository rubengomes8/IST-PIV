function [box] = get_box(im_depth,im_label, n_objects,cam_params)
%Stores all detected objects and their bound box

%Label 0 is background!



for i = 1:n_objects
    %finds rows and columns with label i
    [r,c] = find(im_label==i);
    %you can define a 3-d box with these parametres
    %however to get xyz you need to transform the depth image to the rgb
    %image and transform pixel to meters.
    [min(r); min(c); zmin; max(r); max(c); zmax];
    
    
    %8 points + center of mass, 3 coordinates, for each object
     box(i).X = 
     box(i).Y = 
     box(i).Z = 
     box(i).cm = %3 coordinates of center of mass
end

end

