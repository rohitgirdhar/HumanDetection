function ClassifierList = TrainClassifiers(total_blocks, pos, neg, nbins)
    % This function returns a list of classifiers trained using pos and neg
    % list of images
    % The pos and neg are integral images (zero padded) are 64x128
    
    ClassifierList(total_blocks,1) = LinearSVMClassifierHoG();
    % For now, select the blocks at random
    
    min_size = 16; % The min size of the block
    ht = 128;
    wd = 64;
    base_r = 2;     % Since the image is 0 padded
    base_c = 2;
    used = zeros(ht, wd);
    ratios = [[1 1];
              [0.5 1];
              [1 0.5]];
          
    for block = 1:total_blocks
        % get the coordinates of top left vertex
        safety_counter = 5000;
        r = getRandom(base_r, ht-min_size);
        c = getRandom(base_c, wd-min_size);
        while ( used(r,c) == 1 || safety_counter == 0 )
           r = getRandom(base_r, ht-min_size);
           c = getRandom(base_c, wd-min_size); 
           safety_counter = safety_counter - 1;
        end
        used(r,c) = 1;
        
        % now get the size of the block here
        s = getRandom(min_size, min(ht-r, wd-c));
        
        % select the ratio to use
        rat = getRandom(1, size(ratios, 1)+1);
        h = s*ratios(rat, 1);
        w = s*ratios(rat, 2);
        
        % Selected the block, now train a classifier for this block
        ClassifierList(block).block_r = r;
        ClassifierList(block).block_c = c;
        ClassifierList(block).block_w = w;
        ClassifierList(block).block_h = h;
        ClassifierList(block).classifier = TrainSingleClassifier(r,c,h,w,pos,neg, nbins);
    end