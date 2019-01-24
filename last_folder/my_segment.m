function [im_diffiltered2]=my_segment(im_diffiltered2,depth)
%Segments objects in depth image using gradient
contour = edge(depth,0.3);
[row,col] = find(contour==1);

for i= 1:length(col)
        if row(i)>1 && col(i)>1 && row(i) < 480 && col(i)<640
        im_diffiltered2(row(i)-1,col(i)-1) = 0;
        im_diffiltered2(row(i)-1,col(i)) = 0;
        im_diffiltered2(row(i)-1,col(i)+1) = 0;

        im_diffiltered2(row(i),col(i)-1) = 0;
        im_diffiltered2(row(i),col(i)) = 0;
        im_diffiltered2(row(i),col(i)+1) = 0;

        im_diffiltered2(row(i)+1,col(i)-1) = 0;
        im_diffiltered2(row(i)+1,col(i)) = 0;
        im_diffiltered2(row(i)+1,col(i)+1) = 0;
        end
end
end
