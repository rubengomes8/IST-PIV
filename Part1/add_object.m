function [box,prev_frame_box]=add_object(box,prev_frame_box,aux)
%Similar to update, this one compares 2 box arrays
    number=1;
    for i = 1:length(box.X(:,1))
        cost = zeros(1,length(prev_frame_box.X(:,1)));
        for j = 1:length(prev_frame_box.X(:,1))
            %calculate cost(color+distance)
            xyz = xyz_dist(box.cm(i,:),prev_frame_box.cm(j,:));
            %color = color_dist(box.hist(i,:,:),prev_frame_box.hist(j,:,:));
            cost(j) = xyz;
        end
        [best,n] = min(cost);
        if best < 0.1 %threshold. We need to be careful with the possibility of having 2 boxes choosing 1 box
            %add new object
            box.connection(i) = n;
            prev_frame_box.connection(n) = i;
            if aux == 0
                box.nr(i) = number;
                prev_frame_box.nr(n) = number;
                number = number+1;
            else
                if prev_frame_box.nr(n) == 0
                    number = max(prev_frame_box.nr)+1;
                    box.nr(i) = number;
                    prev_frame_box.nr(n) = number;
                else
                    box.nr(i) = prev_frame_box.nr(n);
                end
            end
                
        end
    end

end
