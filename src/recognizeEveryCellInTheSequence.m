function [ finalCells ] = recognizeEveryCellInTheSequence( sequenceFile, directory )
%RECOGNIZEEVERYCELLINTHESEQUENCE Summary of this function goes here
%   Detailed explanation goes here
    MIN_SIZE_CELL = 4500;
    MAX_DST_FRAMES = 2;
    recognizedCells = {};
    imgsFinal = {};
    load(sequenceFile);
    
    imagesOfSerieByChannelCh0 = imagesOfSerieByChannel(:, 2);
    MAX_SIZE = 0;
    %Recognize the cells on each frame
    for numImg = 1:length(imagesOfSerieByChannelCh0)
        img = imagesOfSerieByChannelCh0{numImg};
        MAX_SIZE = size(img);
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
        %imshow(imgBinaryNoSmallCells);
        imgsFinal(end+1) = {imgBinaryNoSmallCells};
        recognizedCells(end+1) = {cells};
    end
    
    %Relate each file with its correspondence on the other frames
    cellFrames = cellfun(@(x, y) ones(length(x) , 1)*y, recognizedCells, mat2cell(1:length(imagesOfSerieByChannelCh0), 1, ones(length(imagesOfSerieByChannelCh0), 1)), 'UniformOutput', false);
    cellFrames = vertcat(cellFrames{:});
    cellsFound = vertcat(recognizedCells{:});
    totalCellsFound = length(cellsFound);
    %First number: label, second number: frameNumber
    correspondingCells = zeros(totalCellsFound, 1);
    
    actualLabelOfCell = 1;
    for numCellActual = 1:totalCellsFound
        if correspondingCells(numCellActual) == 0
            actualCell = cellsFound(numCellActual);
            actualFrame = cellFrames(numCellActual);
            correspondingCells(numCellActual) = actualLabelOfCell;
            for numCellToRecognized = 2:totalCellsFound
                if numCellToRecognized ~= numCellActual && correspondingCells(numCellToRecognized) == 0
                    cellToRecognized = cellsFound(numCellToRecognized);
                    frameToRecognized = cellFrames(numCellToRecognized);
                    if (length(intersect(actualCell.PixelList, cellToRecognized.PixelList, 'rows')) > MIN_SIZE_CELL/2) && abs(actualFrame - frameToRecognized) <= MAX_DST_FRAMES
                        correspondingCells(numCellToRecognized) = actualLabelOfCell;
                        actualFrame = frameToRecognized;
                    end
                end
            end
            
            actualLabelOfCell = actualLabelOfCell + 1;
        end
    end
    
    finalCells = {};
    for actualLabel = 1:(actualLabelOfCell-1)
        actualFrames = cellFrames(correspondingCells == actualLabel);
        actualCells = cellsFound(correspondingCells == actualLabel);
        if length(actualFrames) > 3 && borderCell(actualCells, MAX_SIZE) == 0
            boundingBoxes = round(vertcat(actualCells.BoundingBox));
            finalCells(end+1, :) = {[min(boundingBoxes(:, 1))-5 min(boundingBoxes(:, 2))-5 max(boundingBoxes(:, 3))+10 max(boundingBoxes(:, 4))+10], actualFrames};
        end
    end
    
    save(strcat(directory, '\recognizedCells'), 'recognizedCells', 'imgBinaryNoSmallCells', 'finalCells');
end

