function [objects, cam2toW] = track3D_part2( imgseq1, imgseq2, cam_params)

[r1, res1_xyz_median] = get_rgb(imgseq1, cam_params);
[r2, res2_xyz_median] = get_rgb(imgseq2, cam_params);
objects = struct;
obj1=[];
obj2=[];
objects1=[];
objects2=[];
objects2_w=[];
aux1 = 0;
indice1 = 1;
max_z_bg1 = max(max(res1_xyz_median));
aux2 = 0;
indice2 = 1;
max_z_bg2 = max(max(res2_xyz_median));

%% Calculates Transformation from Procrustes
[tr] = calculate_transformation(r1(1),r2(2),imread(imgseq1(1).rgb),imread(imgseq2(1).rgb));
cam2toW.R = tr.T';
cam2toW.T = tr.c(1,:)';
%% Motion detection

for i=1:length(imgseq1(:))
    
    %% Background Subtratction
    %Image 1
    im_diff21 = abs(r1(i).res_xyz(:,:,3)-res1_xyz_median)>.5;
    im_diffiltered21 = imopen(im_diff21,strel('disk',3));
    im_diffiltered21 = my_segment(im_diffiltered21,r1(i).res_xyz(:,:,3));
    [label1, nr_obj1] = bwlabel(im_diffiltered21);
    %Image2
    im_diff22 = abs(r2(i).res_xyz(:,:,3)-res2_xyz_median)>.5;
    im_diffiltered22 = imopen(im_diff22,strel('disk',3));
    im_diffiltered22 = my_segment(im_diffiltered22,r2(i).res_xyz(:,:,3));
    [label2, nr_obj2] = bwlabel(im_diffiltered22);
    
    %Background image
    %figure(1);imagesc([res1_xyz_median res2_xyz_median]);
    %Depth image
    %figure(2); imagesc([r1(i).res_xyz(:,:,3) r2(i).res_xyz(:,:,3)]);
    %Labeled Connected components
    %figure(3);imagesc([label1 label2]);
    
    %Outputs frames' boxes
    box1 = get_box(label1, nr_obj1, r1(i));
    box2 = get_box(label2, nr_obj2, r2(i));
    
    %% PARA A BOX 1
    if indice1 == 1       
        prev_frame_box1 = box1;
        indice1 = 0;
    elseif length(prev_frame_box1.Z)<1
        prev_frame_box1 = box1;
    elseif length(box1.Z)<1
        prev_frame_box1 = box1;
    else
        %Compares objects found on previous and current frame
        [box1,prev_frame_box1] = add_object(box1,prev_frame_box1,aux1,max_z_bg1,obj1);
        aux1 = 1;
        for a = 1:length(prev_frame_box1.X(:,1))
            if prev_frame_box1.connection(a) ~= 0
                obj1(prev_frame_box1.nr(a)).X(i-1,:) = prev_frame_box1.X(a,:);
                obj1(prev_frame_box1.nr(a)).Y(i-1,:) = prev_frame_box1.Y(a,:);
                obj1(prev_frame_box1.nr(a)).Z(i-1,:) = prev_frame_box1.Z(a,:);
            end
        end
        for a = 1:length(box1.X(:,1))
            if box1.connection(a) ~= 0
                obj1(box1.nr(a)).X(i,:) = box1.X(a,:);
                obj1(box1.nr(a)).Y(i,:) = box1.Y(a,:);
                obj1(box1.nr(a)).Z(i,:) = box1.Z(a,:);
            end
        end
        prev_frame_box1 = box1;
    end
    %% PARA BOX 2
    if indice2 == 1
        prev_frame_box2 = box2;
        indice2 = 0;
    elseif length(prev_frame_box2.Z)<1
        prev_frame_box2 = box2;
    elseif length(box2.Z)<1
        prev_frame_box2 = box2;
    else
        [box2,prev_frame_box2] = add_object(box2,prev_frame_box2,aux2,max_z_bg2,obj2);
        aux2 = 1;
        for a = 1:length(prev_frame_box2.X(:,1))
            if prev_frame_box2.connection(a) ~= 0
                obj2(prev_frame_box2.nr(a)).X(i-1,:) = prev_frame_box2.X(a,:);
                obj2(prev_frame_box2.nr(a)).Y(i-1,:) = prev_frame_box2.Y(a,:);
                obj2(prev_frame_box2.nr(a)).Z(i-1,:) = prev_frame_box2.Z(a,:);
            end
        end
        for a = 1:length(box2.X(:,1))
            if box2.connection(a) ~= 0
                obj2(box2.nr(a)).X(i,:) = box2.X(a,:);
                obj2(box2.nr(a)).Y(i,:) = box2.Y(a,:);
                obj2(box2.nr(a)).Z(i,:) = box2.Z(a,:);
            end
        end
        prev_frame_box2 = box2;    
    end
       
end
%% Segment that returns data following requirements
zero = zeros(1,8);
for i = 1:length(obj1)
    indice = 1;
    for a = 1:length(obj1(i).X(:,1)) 
        if obj1(i).X(a,:) == zero
            continue;
        else
            objects1(i).X(indice,:) = obj1(i).X(a,:);
            objects1(i).Y(indice,:) = obj1(i).Y(a,:);
            objects1(i).Z(indice,:) = obj1(i).Z(a,:);
            objects1(i).frames_tracked(indice) = a;
            indice = indice +1;
        end
    end
end
%%
zero = zeros(1,8);
for i = 1:length(obj2)
    indice = 1;
    for a = 1:length(obj2(i).X(:,1)) 
        if obj2(i).X(a,:) == zero
            continue;
        else
            objects2(i).X(indice,:) = obj2(i).X(a,:);
            objects2(i).Y(indice,:) = obj2(i).Y(a,:);
            objects2(i).Z(indice,:) = obj2(i).Z(a,:);
            objects2(i).frames_tracked(indice) = a;
            indice = indice +1;
        end
    end
end

% transformation of coordinates of objects in cam2 to world
for i = 1:length(objects2)
    for k = 1:length(objects2(i).X(:,1))
        for j = 1:8
            xyz = ([objects2(i).X(k,j) objects2(i).Y(k,j) objects2(i).Z(k,j)]*tr.T+tr.c(1,:))';
            objects2_w(i).X(k,j)=xyz(1,1);
            objects2_w(i).Y(k,j)=xyz(2,1);
            objects2_w(i).Z(k,j)=xyz(3,1);
        end
    end
    objects2_w(i).frames_tracked = objects2(i).frames_tracked;
end

%%
count =1;
for i = 1:length(objects1) 
    similarity = Inf*ones(1,length(objects2_w));
    % Try to find a Match to object1(i) from the other camera
    for j = 1:length(objects2_w)
        dist = 0;
        matched = intersect(objects2_w(j).frames_tracked, objects1(i).frames_tracked);
        if ~isempty(matched)
            %Found coincident frames,checking similarity by distance
            for k = 1:length(matched)
                dist = dist + dist_sim(objects2_w(j),objects1(i),matched(k));    
            end
            similarity(j) = dist / length(matched);
        end   
    end 
    [best,n] = min(similarity);
    if best < 0.35
        % Match found, creating object
        objects(count).frames_tracked = union(objects2_w(n).frames_tracked,objects1(i).frames_tracked);
        for l = 1:length(objects(count).frames_tracked)
            v2= find(objects2_w(n).frames_tracked == objects(count).frames_tracked(l));
            v1= find(objects1(i).frames_tracked == objects(count).frames_tracked(l));
            [objects(count).X(l,:), objects(count).Y(l,:) ,objects(count).Z(l,:)] = build_box_frame(v1,v2,objects1(i),objects2_w(n));
        end
        %Leaving a token to flag the match
        objects2_w(n).frames_tracked(1) = -objects2_w(n).frames_tracked(1);
        count = count+1;
    else
        %Match not found, create object solo
        objects(count).X = objects1(i).X;
        objects(count).Y = objects1(i).Y;
        objects(count).Z = objects1(i).Z;
        objects(count).frames_tracked = objects1(i).frames_tracked;
        count = count+1;
    end
    
end
    
% Insert into objects() the remaining objects of objects2_w
for i = 1:length(objects2_w)
    if objects2_w(i).frames_tracked(1) > 0
        objects(count).X = objects2_w(i).X;
        objects(count).Y = objects2_w(i).Y;
        objects(count).Z = objects2_w(i).Z;
        objects(count).frames_tracked = objects2_w(i).frames_tracked;
        count = count+1;
    end
end
end

