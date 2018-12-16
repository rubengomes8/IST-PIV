function box = get_box(label, nr_obj, r)
    %Stores all detected objects and their bound box
    % CALCULA RGBD, N�O PERCEBO BEM O QUE ACONTECE AQUI
    
    %shows rgb image
    figure(4);imagesc(r.rgbd);
    %Shows point cloud
    pc=pointCloud(r.xyz,'Color',reshape(r.rgbd,[480*640 3]));
    figure(5);clf; showPointCloud(pc);
    
    %Label 0 is background!
    difZ = 0.4;
    indice = 1;
    box.Z = [];
 %%
    for i = 1:nr_obj
        %finds rows and columns with label i
        [row,c] = find(label==i);
        if length(row)<700
            continue;
        end
        
        aux = zeros(1,length(row));
        for a = 1:length(row)
            aux(a) = r.res_xyz(row(a),c(a),3);
        end
        mediana = median(aux);
        Xmax = -5;
        Xmin = 5;
        Ymax = -5;
        Ymin = 5;
        Zmax = -7;
        Zmin = 7;
        for a = 1:length(aux)
            if r.res_xyz(row(a),c(a),3) ~= 0
                if r.res_xyz(row(a),c(a),1) > Xmax && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Xmax = r.res_xyz(row(a),c(a),1);
                end


                if r.res_xyz(row(a),c(a),2) > Ymax && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Ymax = r.res_xyz(row(a),c(a),2);
                end


                if r.res_xyz(row(a),c(a),3) < Zmin && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Zmin = r.res_xyz(row(a),c(a),3);
                end



                if r.res_xyz(row(a),c(a),1) < Xmin && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Xmin = r.res_xyz(row(a),c(a),1);
                end

                if r.res_xyz(row(a),c(a),2) < Ymin && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Ymin = r.res_xyz(row(a),c(a),2);
                end

                if r.res_xyz(row(a),c(a),3) > Zmax && r.res_xyz(row(a),c(a),3)<mediana+difZ && r.res_xyz(row(a),c(a),3)>mediana-difZ
                    Zmax = r.res_xyz(row(a),c(a),3);
                end
            end
            %get color
            color(a,1:3) = reshape(rgb2hsv(r.rgbd(row(a),c(a),:)),[1 3]);
        end
    %% Obtain box coordinates
        if Xmin == 5 && Xmax == -5 && Ymin == 5 && Ymax == -5 && Zmin == 7 && Zmax == -7

        else
            box.X(indice,1) = Xmin;
            box.X(indice,2) = Xmax;
            box.X(indice,3) = Xmin;
            box.X(indice,4) = Xmax;
            box.X(indice,5:8) = box.X(indice,1:4);
            box.Y(indice,1:2) = Ymin;
            box.Y(indice,3:4) = Ymax;
            box.Y(indice,5:8) = box.Y(indice,1:4);
            box.Z(indice,1:4) = Zmin;
            box.Z(indice,5:8) = Zmax;
            box.connection(indice) = 0;
            box.nr(indice) = 0;
            box.cm(indice,:) = [(Xmax+Xmin)/2 (Ymax+Ymin)/2 (Zmax+Zmin)/2 ];
            [count1, ~] = histcounts(color(:,1),64);
            [count2, ~] = histcounts(color(:,2),64);
            box.hist(indice,:,:) = [count1 ; count2];
            %% Draw boxes
            hold on;
            patch([box.X(indice,1),box.X(indice,2),box.X(indice,4),box.X(indice,3)],...
                [box.Y(indice,1),box.Y(indice,2),box.Y(indice,4),box.Y(indice,3)],...
                [Zmin,Zmin,Zmin,Zmin],'white');
            patch([box.X(indice,5),box.X(indice,6),box.X(indice,8),box.X(indice,7)],...
                [box.Y(indice,5),box.Y(indice,6),box.Y(indice,8),box.Y(indice,7)],...
                [Zmax,Zmax,Zmax,Zmax],'white');
            patch([box.X(indice,1),box.X(indice,5),box.X(indice,7),box.X(indice,3)],...
                [box.Y(indice,1),box.Y(indice,5),box.Y(indice,7),box.Y(indice,3)],...
                [Zmin,Zmax,Zmax,Zmin],'white');
            patch([box.X(indice,2),box.X(indice,6),box.X(indice,8),box.X(indice,4)],...
                [box.Y(indice,2),box.Y(indice,6),box.Y(indice,8),box.Y(indice,4)],...
                [Zmin,Zmax,Zmax,Zmin],'white');
            alpha(0); %para ficar transparente
            indice = indice+1;
        end
    end
end