function [objects,connection]=add_object(objects,box,prev_frame_box,connection,current_frame)
%Similar to update, this one compares 2 box arrays


for i = 1:length(box)
    if connection(i) ~=0
        continue;
    end
    for j = 1:length(prev_frame_box)
        %calculate cost(color+distance)
        cost(j) = xyz_dist(box.cm(i,:),prev_frame_box.cm(j,:)) + color_dist(box.hist(i,:,:),prev_frame_box.hist(j,:,:));
    end
    [best,n] = min(cost);
    if best < 0.1 %threshold. We need to be careful with the possibility of having 2 boxes choosing 1 box
        %add new object
        connection(i) = n;
        new = length(objects) + 1;
        objects(new).X = [prev_frame_box.X(j,:) ; box.X(i,:)];
        objects(new).Y = [prev_frame_box.Y(j,:) ; box.X(i,:)];
        objects(new).Z = [prev_frame_box.Z(j,:) ; box.X(i,:)];
        objects(new).cm =box.cm(i,:);
        objects(new).hist = box.hist(i,:,:);
        objects(new).frames_tracked = [current_frame-1 current_frame];
        
    end
end

end
