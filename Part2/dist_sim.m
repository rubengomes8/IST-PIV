function dist = dist_sim(objects2_w,objects1,k)

idx2 = find(objects2_w.frames_tracked == k);
idx1 = find(objects1.frames_tracked == k);

cm2 = [(max(objects2_w.X(idx2,:))+min(objects2_w.X(idx2,:)))/2 (max(objects2_w.Y(idx2,:))+min(objects2_w.Y(idx2,:)))/2 (max(objects2_w.Z(idx2,:))+min(objects2_w.Z(idx2,:)))/2];
cm1 = [(max(objects1.X(idx1,:))+min(objects1.X(idx1,:)))/2 (max(objects1.Y(idx1,:))+min(objects1.Y(idx1,:)))/2 (max(objects1.Z(idx1,:))+min(objects1.Z(idx1,:)))/2];


dist = norm(cm2-cm1);


end

