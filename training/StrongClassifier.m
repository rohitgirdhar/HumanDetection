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
        function [fp,dt] = learn(self, pos, neg, pos_val, neg_val, false_pos_rate, req_det)
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
                [f,d, th] = self.getStats(pos, neg, req_det);
                self.threshold = th;    % reducing the threshold
                self
                fp = fp*f
                dt = dt*d
            end
            self.coeff = self.coeff(1:cnt-1, 1);
            
        end
        function [fpr,dr, th] = getStats(self, pos, neg, req_det)
            n_pos = length(pos);
            n_neg = length(neg);
            actual = zeros(1, n_pos + n_neg);
            actual(1:n_pos) = 1;
            
            detected = zeros(1,n_pos+n_neg);
            ths = zeros(1,n_pos+n_neg);
            det_th = zeros(1,n_pos);
            for i=1:n_pos
                [res, thr] = self.predict(pos{i});
                det_th(i) = thr;
                detected(i) = res;
                ths(i) = thr;
            end
            
            for i=1:n_neg
                [res, thr] = self.predict(neg{i});
                detected(n_pos+i) = res;
                ths(n_pos+i) = thr;
            end
            det_th = sort(det_th, 'descend');
            if(req_det > 1) 
                req_det = 1;
            end
            num_det = ceil(req_det*n_pos);
            th  = det_th(num_det);
            dr = num_det/(n_pos*1.0);
            
            fpr = 0;
            for i=n_pos+1:n_pos+n_neg
                if(actual(i) == 0 && ths(i)>th)
                    fpr = fpr + 1;
                end
            end
            fpr = fpr/(n_neg);
        end
        
        
        
        function [R, val] = predict(self, image)
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
        
    end
end