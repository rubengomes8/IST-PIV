function [box,prev_frame_box]=add_object(box,prev_frame_box,aux, max_z_bg,obj)
%This function checks if there is a connection between boxes in two frames
    number = 1;
    number2 = 1;
    for i = 1:length(box.X(:,1))
        cost = zeros(1,length(prev_frame_box.X(:,1)));
        for j = 1:length(prev_frame_box.X(:,1))
            %calculate cost(color+distance)
            xyz = xyz_dist(box.cm(i,:),prev_frame_box.cm(j,:), max_z_bg);
            color = color_dist(box.hist(i,:,:),prev_frame_box.hist(j,:,:));
            cost(i,j) = xyz+color;
        end
        [best(i),n] = min(cost(i,:)); %min cost for object i 
        if best(i) < 0.3 %threshold.
            other_connections = find(box.connection == n);
            if other_connections > 0
                if max(best(other_connections)) > best(i)
                box.connection(i) = n; %object i is connected to object n of the previous box
                prev_frame_box.connection(n) = i; %object of previous box n is connected to the object i
                box.connection(other_connections) = 0;
                prev_frame_box.connection(other_connections) = 0;
                else
                    %do not update the current object
                    n = -1;
                end    
            else
                box.connection(i) = n;
                prev_frame_box.connection(n) = i;
            end
            if aux == 0 %1st connection
                box.nr(i) = number; %number of the object
                prev_frame_box.nr(n) = number; 
                number = number+1;
            else
                if n > 0
                    if prev_frame_box.nr(n) == 0  %adiction of a new object
                        number = length(obj)+ number2;
                        box.nr(i) = number;
                        prev_frame_box.nr(n) = number;
                        number2 = number2+1;
                    else
                        box.nr(i) = prev_frame_box.nr(n); %only the current object (box) is updated
                    end
                end
            end          
        end
    end
end
