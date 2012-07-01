classdef LinearSVMClassifierHoG < handle
    properties
        % The block for which this classifier is
        block_r;
        block_c;
        block_h;
        block_w;
        
        % The classifier for this block
        classifier;
        
    end
end
