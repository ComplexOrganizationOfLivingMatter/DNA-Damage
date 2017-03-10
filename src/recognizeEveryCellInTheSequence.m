function [ recognizedCells ] = recognizeEveryCellInTheSequence( sequenceFile )
%RECOGNIZEEVERYCELLINTHESEQUENCE Summary of this function goes here
%   Detailed explanation goes here
    
    recognizedCells = {};
    load(sequenceFile);
    
    imagesOfSerieByChannelCh0 = imagesOfSerieByChannel(:, 2);
    
    for numImg = 1:length(imagesOfSerieByChannelCh0)
        img = imagesOfSerieByChannelCh0{numImg};
        imgDilatted = imdilate(img, strel('disk', 20));
        imgBinary = im2bw(imgDilatted, 0.2);
        cells = regionprops(imgBinary, 'all');
        cellAreas = vertcat(cells.Area);
        cellsRejected = cells(cellAreas <= 9500);
        cells = cells(cellAreas > 9500);
        imgBinaryNoSmallCells = imgBinary;
        for numCell = 1:length(cellsRejected)
            imgBinaryNoSmallCells(cellsRejected(numCell).PixelList(:, 2), cellsRejected(numCell).PixelList(:, 1)) = 0;
        end
        imshow(imgBinaryNoSmallCells);
        recognizedCells(end+1) = {cells};
    end
end

