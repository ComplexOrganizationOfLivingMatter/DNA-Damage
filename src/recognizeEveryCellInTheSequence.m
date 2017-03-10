function [ recognizedCells ] = recognizeEveryCellInTheSequence( sequenceFile, directory )
%RECOGNIZEEVERYCELLINTHESEQUENCE Summary of this function goes here
%   Detailed explanation goes here
    MIN_SIZE_CELL = 4500;
    recognizedCells = {};
    imgsFinal = {};
    load(sequenceFile);
    
    imagesOfSerieByChannelCh0 = imagesOfSerieByChannel(:, 2);
    
    %Recognize the cells on each frame
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
        cells.frame = numImg;
        imgBinaryNoSmallCells = imgFilled;
        for numCell = 1:length(cellsRejected)
            imgBinaryNoSmallCells(cellsRejected(numCell).PixelList(:, 2), cellsRejected(numCell).PixelList(:, 1)) = 0;
        end
        %imshow(imgBinaryNoSmallCells);
        imgsFinal(end+1) = {imgBinaryNoSmallCells};
        recognizedCells(end+1) = {cells};
    end
    save(strcat(directory, 'recognizedCells'), 'recognizedCells', 'imgBinaryNoSmallCells');
    
    %Relate each file with its correspondence on the other frames
    cellsFound = vertcat(recognizedCells{:});
    totalCellsFound = length(cellsFound);
    %First number: label, second number: frameNumber
    correspondingCells = zeros(totalCellsFound, 2);
    
    actualLabelOfCell = 1;
    for numCellActual = 1:totalCellsFound
        if correspondingCells == 0
            actualCell = recognizedCells{numCellActual};
            correspondingCells(numCellActual, 1) = actualLabelOfCell;
            correspondingCells(numCellActual, 2) = actualCell.frame;
            for numCellToRecognized = 2:totalCellsFound
                if numCellToRecognized ~= numCellActual
                    cellToRecognized = recognizedCells{numCellActual};
                    
                end
            end
            
            actualLabelOfCell = actualLabelOfCell + 1;
        end
    end
end

