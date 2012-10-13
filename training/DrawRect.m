function J = DrawRect(img, boxes)
    % Returns an image after drawing the boxes over it
    n = length(boxes);
    img = imread(img);
    bxs = zeros(n,4);
    for i=1:n
        bxs(i,:) = boxes{i};
    end
    cols = ['b'];
    imshow(img), hold on
    for i=1:n
        rectangle('Position',bxs(i, :), 'LineWidth',2, 'EdgeColor',cols(mod(i,size(cols,2))+1));
    end
        

    