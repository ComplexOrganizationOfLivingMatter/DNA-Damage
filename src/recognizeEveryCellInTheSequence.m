function [ recognizedCells ] = recognizeEveryCellInTheSequence( sequenceFile, directory )
%RECOGNIZEEVERYCELLINTHESEQUENCE Summary of this function goes here
%   Detailed explanation goes here
    MIN_SIZE_CELL = 4500;
    recognizedCells = {};
    load(sequenceFile);
    
    imagesOfSerieByChannelCh0 = imagesOfSerieByChannel(:, 2);
    
    for numImg = 1:length(imagesOfSerieByChannelCh0)
        img = imagesOfSerieByChannelCh0{numImg};
%         %# Create the gaussian filter
%         gaussianFilter = fspecial('gaussian', [7 7], 1.5);
%         %# Filter it
%         imgGuass = imfilter(img, gaussianFilter, 'same');
        imgDilatted = imclose(img, strel('disk', 5));
        imgBinary = im2bw(imgDilatted, 0.28);
        imgRemoveBridges = bwmorph(imgBinary, 'bridge', Inf);
        imgFilled = bwmorph(imgRemoveBridges, 'fill', Inf);
        cells = regionprops(imgFilled, 'all');
        cellAreas = vertcat(cells.Area);
        cellsRejected = cells(cellAreas <= MIN_SIZE_CELL);
        cells = cells(cellAreas > MIN_SIZE_CELL);
        imgBinaryNoSmallCells = imgFilled;
        for numCell = 1:length(cellsRejected)
            imgBinaryNoSmallCells(cellsRejected(numCell).PixelList(:, 2), cellsRejected(numCell).PixelList(:, 1)) = 0;
        end
        imshow(imgBinaryNoSmallCells);
        recognizedCells(end+1) = {cells};
        save(strcat(directory, 'recognizedCells'), 'recognizedCells', 'imgBinaryNoSmallCells');
    end
end

