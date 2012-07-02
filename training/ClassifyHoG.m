function ret = ClassifyHoG(image, obj)
    % Function takes a LinearSVMClassifierHoG and classifies the image as
    % per it
    
    hog = ComputeHoG(image,obj.block_r, obj.block_c, obj.block_h, obj.block_w, 9);
    % hard coded nbins here for now...
    ret = svmclassify(obj.classifier, hog);
    