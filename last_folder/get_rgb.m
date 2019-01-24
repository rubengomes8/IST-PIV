function [r, res_xyz_median] = get_rgb(imgseq1, cam_params)
%opens all images and stores their xyz and rgb values in r struct.
%calculates background depth image
    for i=1:length(imgseq1(:))
        im = imread(imgseq1(i).rgb);
        load(imgseq1(i).depth);
        r(i).xyz = get_xyz_asus(depth_array(:),[480 640],(1:640*480)',cam_params.Kdepth,1,0);
        r(i).res_xyz = reshape(r(i).xyz,[480,640,3]);
        res_z(:,:,i) = r(i).res_xyz(:,:,3);
        R = cam_params.R;
        T = cam_params.T;
        K_rgb = cam_params.Krgb;
        r(i).rgbd = get_rgbd(r(i).xyz, im, R, T, K_rgb);
    end
    res_xyz_median = median(res_z,3);
end
