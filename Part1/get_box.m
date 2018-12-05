function box = get_box(label, nr_obj, r)
    %Stores all detected objects and their bound box
    % CALCULA RGBD, N�O PERCEBO BEM O QUE ACONTECE AQUI
    
    %shows rgb image
    figure(4);imagesc(r.rgbd);
    %Shows point cloud
    pc=pointCloud(r.xyz,'Color',reshape(r.rgbd,[480*640 3]));
    figure(5);clf; showPointCloud(pc);
    
    %Label 0 is background!
    %difX = 1;
    %difY = 1.5;
    difZ = 0.4;
 %%
    for i = 1:nr_obj
        Xmax = -5;
        Xmin = 5;
        Ymax = -5;
        Ymin = 5;
        Zmax = -7;
        Zmin = 7;
        %finds rows and columns with label i
        [row,c] = find(label==i);
        aux = zeros(1,length(row));
        for a = 1:length(row)
            aux(a) = r.res_xyz(row(a),c(a),3);
        end
        mediana = median(aux);
        for a = 1:length(row)
            if r.res_xyz(row(a),c(a),1) ~= 0
                if r.res_xyz(row(a),c(a),1) > Xmax && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Xmax = r.res_xyz(row(a),c(a),1);
                end
            end
            if r.res_xyz(row(a),c(a),2) ~= 0
                if r.res_xyz(row(a),c(a),2) > Ymax && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Ymax = r.res_xyz(row(a),c(a),2);
                end
            end
            if r.res_xyz(row(a),c(a),3) ~=0
                if r.res_xyz(row(a),c(a),3) < Zmin && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Zmin = r.res_xyz(row(a),c(a),3);
                end
            end
            
            if r.res_xyz(row(a),c(a),1) ~= 0
                if r.res_xyz(row(a),c(a),1) < Xmin && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Xmin = r.res_xyz(row(a),c(a),1);
                end
            end
            if r.res_xyz(row(a),c(a),2) ~= 0 
                if r.res_xyz(row(a),c(a),2) < Ymin && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Ymin = r.res_xyz(row(a),c(a),2);
                end
            end
            if r.res_xyz(row(a),c(a),3) ~=0 
                if r.res_xyz(row(a),c(a),3) > Zmax && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Zmax = r.res_xyz(row(a),c(a),3);
                end
            end
            %get color
            color(a,1:3) = reshape(rgb2hsv(r.rgbd(row(a),c(a),:)),[1 3]);
        end
%% Obtain box coordinates
    if Xmin == 5 && Xmax == -5 && Ymin == 5 && Ymax == -5 && Zmin == 7 && Zmax == -7
        box.X(i,1:8) = 0;
        box.Y(i,1:8) = 0;
        box.Z(i,1:8) = 0;
    else
        box.X(i,1) = Xmin;
        box.X(i,2) = Xmax;
        box.X(i,3) = Xmin;
        box.X(i,4) = Xmax;
        box.X(i,5:8) = box.X(i,1:4);
        box.Y(i,1:2) = Ymin;
        box.Y(i,3:4) = Ymax;
        box.Y(i,5:8) = box.Y(i,1:4);
        box.Z(i,1:4) = Zmin;
        box.Z(i,5:8) = Zmax;
    end
        box.cm(i,:) = [(Xmax+Xmin)/2 (Ymax+Ymin)/2 (Zmax+Zmin)/2 ];
        [count, hbox] = histcounts(color(:,1),64);
        box.hist(i,:,:) = [count ; hbox(1:end-1)];
%% Draw boxes
        hold on;
        patch([box.X(i,1),box.X(i,2),box.X(i,4),box.X(i,3)],...
            [box.Y(i,1),box.Y(i,2),box.Y(i,4),box.Y(i,3)],...
            [Zmin,Zmin,Zmin,Zmin],'white');
        patch([box.X(i,5),box.X(i,6),box.X(i,8),box.X(i,7)],...
            [box.Y(i,5),box.Y(i,6),box.Y(i,8),box.Y(i,7)],...
            [Zmax,Zmax,Zmax,Zmax],'white');
        patch([box.X(i,1),box.X(i,5),box.X(i,7),box.X(i,3)],...
            [box.Y(i,1),box.Y(i,5),box.Y(i,7),box.Y(i,3)],...
            [Zmin,Zmax,Zmax,Zmin],'white');
        patch([box.X(i,2),box.X(i,6),box.X(i,8),box.X(i,4)],...
            [box.Y(i,2),box.Y(i,6),box.Y(i,8),box.Y(i,4)],...
            [Zmin,Zmax,Zmax,Zmin],'white');
        alpha(0); %para ficar transparente
    end
end