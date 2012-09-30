classdef LinearSVMClassifierHoG < handle
    properties
        % The block for which this classifier is
        block_r = -1;
        block_c;
        block_h;
        block_w;
        
        % The classifier for this block
        classifier;
    end
    methods
        function obj = LinearSVMClassifierHoG(r,c,h,w)
            obj.block_r = r;
            obj.block_c = c;
            obj.block_h = h;
            obj.block_w = w;
        end
        function learn(self, pos, neg)
            self.classifier = TrainSingleClassifier(self.block_r,self.block_c,self.block_h,self.block_w,pos,neg,9);
        end
        function ret = predict(self, image)
            ret = ClassifyHoG(image, self);
        end
    end
end
