function [  ] = createRandomFociWithinNuclei(maxRandomization)
%CREATERANDOMFOCIWITHINNUCLEI Summary of this function goes here
%   Detailed explanation goes here
    
    outputDirectory = 'results\randomization';
    mkdir(outputDirectory);
    allFiles = getAllFiles('results\segmentation\');
    onlyPixelsFiles = cellfun(@(x) isempty(strfind(x, 'Pixels')) == 0, allFiles);
    pixelsFiles = allFiles(onlyPixelsFiles);
    for numFile = 1:size(pixelsFiles, 1)
        fullPathFile = pixelsFiles{numFile};
        fullPathSplitted = strsplit(fullPathFile, '\');
        directory = strjoin(fullPathSplitted(1:end-1), '\');
        nameFileSplitted = strsplit(fullPathSplitted{end}, '_');
        numCell = nameFileSplitted{2};
        
        %We need the number of foci
        infoCell = importdata(strcat(directory, '\Cell_', numCell, '_results.mat'));
        centroidsFoci = infoCell.Datos{1,1};
        centroidsFoci = vertcat(centroidsFoci{:, 2});
        totalFoci = size(centroidsFoci, 1);
        clear infoCell centroidsFoci;
        
        %We need the area of the cell
        load(strcat(directory, '\segmentacion_ch_1-Cell_', numCell, '.mat'));
        
        %We have to remove the heterochormatina peaks from the possible
        %area where can fall the random foci
        load(fullPathFile);
        
        [pixelsXArea, pixelsYArea] = find(proyb_rect > 0);
        
        finalPixelArea = [];
        for i = 1:size(mask_Hetero, 2)
            actualAreaOfLayer = [pixelsXArea, pixelsYArea];
            [pixelXheteroOfLayer, pixelYheteroOfLayer] = find(mask_Hetero{i});
            actualPixelArea = actualAreaOfLayer(ismember(actualAreaOfLayer, [pixelXheteroOfLayer, pixelYheteroOfLayer], 'rows') == 0, :);
            actualPixelArea(:, 3) = i;
            finalPixelArea = vertcat(finalPixelArea, actualPixelArea);
        end
        
        %We already have all the info we need
        %Do the randomization
        randomizationsCentroids = cell(maxRandomization, 1);
        parfor numRandom = 1:maxRandomization
            randomCentroids = zeros(totalFoci, 3);
            tempPixelArea = finalPixelArea;
            for numFoci = 1:totalFoci
                %Pseudorandomly select a point within the possible area
                pickedRandomCentroid = randi(size(tempPixelArea, 1));
                randomCentroids(numFoci, :) = tempPixelArea(pickedRandomCentroid, :);
                %Remove also the possible pixels of the same Z
                tempPixelArea(ismember(tempPixelArea(:, 1:2), randomCentroids(numFoci, 1:2), 'rows'), :) = [];
            end
            randomizationsCentroids(numRandom) = {randomCentroids};
        end
        
        %save randomization
        finalOutputDir = strcat(outputDirectory, '\', strjoin(fullPathSplitted(end-2:end-1), '\'));
        mkdir(finalOutputDir);
        save(strcat(finalOutputDir, '\randomizationOfCentroids_Cell_', numCell), 'randomizationsCentroids');
    end
end

