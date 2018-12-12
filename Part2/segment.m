function [im_diffiltered2]=segment(im_diffiltered2,depth)

contour = edge(depth,0.5);
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