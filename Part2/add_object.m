function [box,prev_frame_box]=add_object(box,prev_frame_box,aux, max_z_bg,obj)
%Similar to update, this one compares 2 box arrays
    number=1;
    for i = 1:length(box.X(:,1))
        cost = zeros(1,length(prev_frame_box.X(:,1)));
        for j = 1:length(prev_frame_box.X(:,1))
            %calculate cost(color+distance)
            xyz = xyz_dist(box.cm(i,:),prev_frame_box.cm(j,:), max_z_bg);
            color = color_dist(box.hist(i,:,:),prev_frame_box.hist(j,:,:));
            cost(j) = xyz+color;
        end
        [best,n] = min(cost); %min cost for object i 
        if best < 0.2 %threshold. We need to be careful with the possibility of having 2 boxes choosing 1 box
            %add new object
            box.connection(i) = n; %object i is connected to object n of the previous box
            prev_frame_box.connection(n) = i; %object of previous box n is connected to the object i
            if aux == 0 %1st connection
                box.nr(i) = number; %number of the object
                prev_frame_box.nr(n) = number; 
                number = number+1;
            else
                if prev_frame_box.nr(n) == 0 %adiction of a new object
                    number = length(obj)+1;
                    box.nr(i) = number;
                    prev_frame_box.nr(n) = number;
                else
                    box.nr(i) = prev_frame_box.nr(n); %only the current object (box) is updated
                end
            end
                
        end
    end

end
