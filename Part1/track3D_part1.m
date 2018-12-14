function objects = track3D_part1(imgseq1, cam_params )
%%receives the images as inputs and  returns the 8 points describing the time trajectories of the enclosing box of the objects in world (camera) coordinates

[r, res_xyz_median] = get_rgb(imgseq1, cam_params);
objects = [];
obj = [];
aux = 0;
indice = 1;
max_z_bg = max(max(res_xyz_median));
for i=1:length(imgseq1(:))
    
    im_diff2 = abs(r(i).res_xyz(:,:,3)-res_xyz_median)>.5;
    im_diffiltered2=imopen(im_diff2,strel('disk',3));
    im_diffiltered2 = segment(im_diffiltered2,r(i).res_xyz(:,:,3));
    [label, nr_obj] = bwlabel(im_diffiltered2);
    
    %Background image
    figure(1);imagesc(res_xyz_median);
    %Depth image
    figure(2); imagesc(r(i).res_xyz(:,:,3));
    %Labeled Connected components
    figure(3);imagesc(label);

    
    %this should output the box coordinates of i objects and their centers of mass in xyz
    %meters
    % caso nao haja objectos na primeira imagem, fazer confirmação qual a
    % imagem que tem o primeiro objecto

   box = get_box(label, nr_obj, r(i));

    if indice == 1% first frame, store all objects!       
        prev_frame_box = box;
        indice = 0;
    elseif length(prev_frame_box.Z)<1
        prev_frame_box = box;
        continue
    elseif length(box.Z)<1
        prev_frame_box = box;
        continue
    else
        [box,prev_frame_box] = add_object(box,prev_frame_box,aux,max_z_bg,obj);
        aux = 1;
        for a = 1:length(prev_frame_box.X(:,1))
            if prev_frame_box.connection(a) ~= 0
                obj(prev_frame_box.nr(a)).X(i-1,:) = prev_frame_box.X(a,:);
                obj(prev_frame_box.nr(a)).Y(i-1,:) = prev_frame_box.Y(a,:);
                obj(prev_frame_box.nr(a)).Z(i-1,:) = prev_frame_box.Z(a,:);
            end
        end
        for a = 1:length(box.X(:,1))
            if box.connection(a) ~= 0
                obj(box.nr(a)).X(i,:) = box.X(a,:);
                obj(box.nr(a)).Y(i,:) = box.Y(a,:);
                obj(box.nr(a)).Z(i,:) = box.Z(a,:);
            end
        end
        prev_frame_box = box;
         
    end
    
       
end


%%
zero = zeros(1,8);
for i = 1:length(obj)
    indice = 1;
    for a = 1:length(obj(i).X(:,1)) 
        if obj(i).X(a,:) == zero
            continue;
        else
            objects(i).X(indice,:) = obj(i).X(a,:);
            objects(i).Y(indice,:) = obj(i).Y(a,:);
            objects(i).Z(indice,:) = obj(i).Z(a,:);
            objects(i).frames_tracked(indice) = a;
            indice = indice +1;
        end
    end
end
    
end