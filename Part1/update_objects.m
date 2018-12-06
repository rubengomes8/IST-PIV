function [objects,connection] = update_objects(nr_obj, box, objects, current_frame)
% Compares previous known objects with current boxed object; return
% connection if exists
%   for example, if box(1) is connected to object 2 then connection(1) = 2
%   if there is no connection then connection(i) = 0;


% we use the box center of mass and image histogram and compare with the
% object center of mass(needs to be calculated here because it is not
% included in the struct) and color histogram

connection = zeros(1,nr_obj);

if isempty(objects)
    return 
end

for i = 1:nr_obj
    for j = 1:length(objects)
        %calculate cost(color+distance)
        cost(j) = xyz_dist(box.cm(i,:),objects(j).cm);% + color_dist(box.hist(i,:,:),objects(j).hist(end,:,:));
    end
    [best,n] = min(cost);
    if best < 0.2 %threshold. We need to be careful with the possibility of having 2 boxes choosing 1 object
        connection(i) = n;
        objects(j).X = [objects(j).X ; box.X(i,:)];
        objects(j).Y = [objects(j).Y ; box.Y(i,:)];
        objects(j).Z = [objects(j).Z ; box.Z(i,:)];
        objects(j).cm =box.cm(i,:);
        objects(j).hist = box.hist(i,:,:);
        objects(j).frames_tracked = [objects(j).frames_tracked current_frame];
    end 
   
end