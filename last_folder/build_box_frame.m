function [X, Y, Z] = build_box_frame(v1,v2,objects1,objects2_w)
%Builds box with 2 camera boxes
if ~isempty(v1) && ~isempty(v2)
    %Object exists in both cameras in this frame
    Xmax = max([objects1.X(v1,:) objects2_w.X(v2,:)]);
    Xmin = min([objects1.X(v1,:) objects2_w.X(v2,:)]);
    Ymax = max([objects1.Y(v1,:) objects2_w.Y(v2,:)]);
    Ymin = min([objects1.Y(v1,:) objects2_w.Y(v2,:)]);
    Zmax = max([objects1.Z(v1,:) objects2_w.Z(v2,:)]);
    Zmin = min([objects1.Z(v1,:) objects2_w.Z(v2,:)]);
elseif ~isempty(v1) && isempty(v2)
    %Object only exists in camera 1
    Xmax = max(objects1.X(v1,:));
    Xmin = min(objects1.X(v1,:));
    Ymax = max(objects1.Y(v1,:));
    Ymin = min(objects1.Y(v1,:));
    Zmax = max(objects1.Z(v1,:));
    Zmin = min(objects1.Z(v1,:)); 
else
    %object only exists in camera 2
    Xmax = max(objects2_w.X(v2,:));
    Xmin = min(objects2_w.X(v2,:));
    Ymax = max(objects2_w.Y(v2,:));
    Ymin = min(objects2_w.Y(v2,:));
    Zmax = max(objects2_w.Z(v2,:));
    Zmin = min(objects2_w.Z(v2,:)); 
end
%construct final box by fusing boxes(sensor fusion)
X(1) = Xmin;
X(2) = Xmax;
X(3) = Xmin;
X(4) = Xmax;
X(5:8) = X(1:4);
Y(1:2) = Ymin;
Y(3:4) = Ymax;
Y(5:8) = Y(1:4);
Z(1:4) = Zmin;
Z(5:8) = Zmax;
end

