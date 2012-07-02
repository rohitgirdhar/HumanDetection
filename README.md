HumanDetection
==============

Implementation of Human Detection Algorithm by Zhu, Avidan et al in CVPR '06.

Author: Rohit Girdhar
        July 2012
        IIIT-H

Testing the Code:
    A pre-trained detector is supplied with the code in detector.mat file
    Load that file into matlab. It gives a cascade object named 'det'
    Use it to classify any image by:
        res = detector(<image filename> , det);
        % res stores the rectangles of detections
        % To plot those rectangles on the image, use:
        DrawRect(<image filename> res)

Training the detector:
    Use train_detector with the required arguments

