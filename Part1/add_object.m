function [objects,connection]=add_object(objects,box,prev_frame_box,connection)
%Similar to update, this one compares 2 box arrays


for i = 1:length(box)
    if connection(i) ~=0
        continue;
    end
    for j = 1:length(prev_frame_box)
        %calculate cost(color+distance)
        cost(j) = xyz_dist(box.cm(i),box.cm(j)) + color_dist(box.hist(i,:,:),box.hist(j,:,:));
    end
    [best,n] = min(cost);
    if best < 0.1 %threshold. We need to be careful with the possibility of having 2 boxes choosing 1 box
        %add new object
        connection(i) = n;
        
    end
end

end
