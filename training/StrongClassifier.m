classdef StrongClassifier < handle
    properties
        weak_clsr;
        max_classifiers = 50;
        coeff = zeros(50,1);
        threshold = 0;
    end
    methods
        function obj = StrongClassifier()
            obj.weak_clsr = LinearSVMClassifierHoG.empty(50,0);
        end
        function [fp,dt] = learn(self, pos, neg, pos_val, neg_val, false_pos_rate)
            persistent blocks;
            
            if(isempty(blocks))
                blocks = getAllBlocks;
            end
            used = zeros(size(blocks,1),1);
            
            cnt = 1;
            fp = 1.0;
            dt = 1.0;
            n_pos_val = size(pos_val,2);
            n_neg_val = size(neg_val,2);
            
            wts = zeros(1, n_pos_val + n_neg_val);
            wts(1:n_pos_val) = 1.0/(2.0*double(n_pos_val));
            wts(n_pos_val+1:n_pos_val + n_neg_val) = 1.0/(2.0*double(n_neg_val));
            
            total_blocks = 250;
            clsr = LinearSVMClassifierHoG.empty(total_blocks,0);
            while(fp > false_pos_rate && cnt <= self.max_classifiers)
                for i=1:total_blocks
                    r = getRandom(1,size(blocks,1)+1);
                    while(used(r) ~= 0)
                        r = getRandom(1,size(blocks,1)+1);
                    end
                    WC = LinearSVMClassifierHoG(blocks(r,1),blocks(r,2),blocks(r,3),blocks(r,4));
                    WC.learn(pos, neg);
                    clsr(i) = WC;
                end
                
                [best_c, wts, alpha] = GetBestClassifier(clsr, pos_val, neg_val, wts, 9);
                self.weak_clsr(cnt) = best_c;
                self.weak_clsr(cnt)
                self.coeff(cnt,1) = alpha;
                cnt = cnt+1;
                self.threshold = sum(self.coeff)*0.5;
                [f,d] = self.getStats(pos, neg);
                self
                fp = fp*f
                dt = dt*d
            end
            self.coeff = self.coeff(1:cnt-1, 1);
            
        end
        function [fpr,dr] = getStats(self, pos, neg)
            n_pos = length(pos);
            n_neg = length(neg);
            actual = zeros(1, n_pos + n_neg);
            actual(1:n_pos) = 1;
            
            detected = zeros(1,n_pos+n_neg);
            for i=1:n_pos
                detected(i) = self.predict(pos{i});
            end
            
            for i=1:n_neg
                detected(i + n_pos) = self.predict(neg{i});
            end
           
            
            fpr = 0;
            dr = 0;
            for i=1:n_pos+n_neg
                if(actual(i) == 1 && detected(i) == 1)
                    dr = dr + 1;
                end
                if(actual(i) == 0 && detected(i) == 1)
                    fpr = fpr + 1;
                end
            end
            fpr = fpr/(n_neg);
            dr = dr/(n_pos);
        end
        function [R] = predict(self, image)
            val = 0;
            for i=1:size(self.weak_clsr,2)
                if(~isempty(self.weak_clsr(i)) && i<=size(self.coeff,1))
                    val = val + self.coeff(i)*self.weak_clsr(i).predict(image);
                end
            end
            if(val >= self.threshold)
                R = 1;
            else
                R = 0;
            end
        end
        function [R] = predictScale(self, image)
        end
    end
end