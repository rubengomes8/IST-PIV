function [distance] = xyz_dist(cm1,cm2,max)
%Calculates normalized euclidian distance from center of mass

distance = norm(cm1-cm2)/max;

end

