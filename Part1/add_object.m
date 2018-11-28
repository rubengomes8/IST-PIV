function add_object(objects,box,prev_frame_box,im_hsv,connection)
%Similar to update, this one compares 2 box arrays


for i = 1:length(box)
    if connection(i) ~=0
        continue;
    end
    for j = 1:length(prev_frame_box)
        %calculate cost(color+distance)
        cost(j) = 
    end
    [best,n] = min(cost);
    if best < 0.1 %threshold. We need to be careful with the possibility of having 2 boxes choosing 1 box
        %add new object
    end
end

end

