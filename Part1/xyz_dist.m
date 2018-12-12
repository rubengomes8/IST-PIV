function [distance] = xyz_dist(cm1,cm2)
%Calculates normalized euclidian distance from center of mass

distance = norm(cm1-cm2)/10;

end

