function images = ReadAllImages(dname, num_samples, nbins)
    % Reads num_samples from each image into the list images. Directly
    % returns integral image with nbins bins
    wd = 64;
    ht = 128;
    cd(dname);
    im_list = dir('.');
    cd('..');
    n_im = length(im_list);
    j = 1;
    for i=1:n_im
        if ~im_list(i).isdir()
            cur_file = fullfile(dname,im_list(i).name);
            cur_image = imread(cur_file);
            [cur_ht, cur_wd, ch] = size(cur_image);
            % divide the image into num_samples
            if(num_samples == 1)
                % center crop the image
                r = cur_ht/2 - ht/2 -1;
                c = cur_wd/2 - wd/2 -1;
                images{j} = GetIntegralHoG(imcrop(cur_image, [c, r, wd, ht]), nbins);
                j = j+1;
            else
                % now try to sample num_sample images out of the image
                get_images = num_samples;
                while(get_images > 0)
                    get_images = get_images - 1;
                    r = getRandom(1, cur_ht - ht);
                    c = getRandom(1, cur_wd - wd);
                    images{j} = GetIntegralHoG(imcrop(cur_image, [c, r, wd, ht]), nbins);
                    j = j+1;
                end
            end
        end
    end
    