function [box,nr_obj] = get_box(label, nr_obj, r)
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
    box.X = [];
    box.Y = [];
    box.Z = [];
    box.cm = [];
    box.hist = [];
 %%
    for i = 1:nr_obj
        Xmax = -100;
        Xmin = 100;
        Ymax = -15;
        Ymin = 15;
        Zmax = -10;
        Zmin = 10;
        color = [];
        %finds rows and columns with label i
        [row,c] = find(label==i);
        aux = zeros(1,length(row));
        for a = 1:length(row)
            aux(a) = r.res_xyz(row(a),c(a),3);
        end
        mediana = median(aux);
        if sum(aux) ~= 0   
            for a = 1:length(row)
                if r.res_xyz(row(a),c(a),3) == 0
                    continue
                end
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
        end
%% Obtain box coordinates
    if Xmax == -100
        continue
    else
        box.X(end+1,1) = Xmin;
        box.X(end,2) = Xmax;
        box.X(end,3) = Xmin;
        box.X(end,4) = Xmax;
        box.X(end,5:8) = box.X(end,1:4);
        box.Y(end+1,1:2) = Ymin;
        box.Y(end,3:4) = Ymax;
        box.Y(end,5:8) = box.Y(end,1:4);
        box.Z(end+1,1:4) = Zmin;
        box.Z(end,5:8) = Zmax;
        box.cm(end+1,:) = [(Xmax+Xmin)/2 (Ymax+Ymin)/2 (Zmax+Zmin)/2 ];
        [count, hbox] = histcounts(color(:,1),64);
        box.hist(end+1,:,:) = [count ; hbox(1:end-1)];
    end
%% Draw boxes
        hold on;
        patch([box.X(end,1),box.X(end,2),box.X(end,4),box.X(end,3)],...
            [box.Y(end,1),box.Y(end,2),box.Y(end,4),box.Y(end,3)],...
            [Zmin,Zmin,Zmin,Zmin],'white');
        patch([box.X(end,5),box.X(end,6),box.X(end,8),box.X(end,7)],...
            [box.Y(end,5),box.Y(end,6),box.Y(end,8),box.Y(end,7)],...
            [Zmax,Zmax,Zmax,Zmax],'white');
        patch([box.X(end,1),box.X(end,5),box.X(end,7),box.X(end,3)],...
            [box.Y(end,1),box.Y(end,5),box.Y(end,7),box.Y(end,3)],...
            [Zmin,Zmax,Zmax,Zmin],'white');
        patch([box.X(end,2),box.X(end,6),box.X(end,8),box.X(end,4)],...
            [box.Y(end,2),box.Y(end,6),box.Y(end,8),box.Y(end,4)],...
            [Zmin,Zmax,Zmax,Zmin],'white');
        alpha(0); %para ficar transparente
    end
    nr_obj = length(box.cm);
end