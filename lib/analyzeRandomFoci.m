function [ ] = analyzeRandomFoci( )
%ANALYZERANDOMFOCI Summary of this function goes here
%   Detailed explanation goes here

    randomFiles = getAllFiles('D:\Pablo\DNA-Damage\results\randomization');
    
    allMinDistacesOfFociToHeterochromatinRandom = {};
    allMeanDistacesOfFociToHeterochromatinRandom = {};
    
    for numRandomFile = 1:size(randomFiles, 1)
        fullPathFile = randomFiles{numRandomFile}
        if ~isempty(strfind(fullPathFile, 'randomizationOfCentroids_Cell'))
            directory = strrep(fullPathFile, 'randomization', 'segmentation');
            directorySplitted = strsplit(directory, '\');
            directory = strjoin(directorySplitted(1:end-1), '\');
            nameFile = directorySplitted{end};
            nameFileSplitted = strsplit(nameFile, '_');
            numCell = nameFileSplitted{end};
            numCell = numCell(1:end-4);

            load(strcat(directory, '\recognizedCells.mat'));
            rect = finalCells{str2num(numCell), 1};
            rect(rect<1) = 1;
            if rect(1) + rect(3) >= size(imgBinaryNoSmallCells, 1)
                rect(3) = size(imgBinaryNoSmallCells, 1) - 1 - rect(1);
            end
            if rect(2) + rect(4) >= size(imgBinaryNoSmallCells, 2)
                rect(4) = size(imgBinaryNoSmallCells, 2) - 1 - rect(2);
            end

            %Load randomizations
            load(fullPathFile);

            %Load heterochromatin info
            load(strcat(directory, '\Cell_', numCell, '_PixelsPerCell.mat'));

            for numRandom = 1:size(randomizationsCentroids, 1)
                randomCentroids = randomizationsCentroids{numRandom};
                randomCentroids = [randomCentroids(:, 2), randomCentroids(:, 1), randomCentroids(:, 3)];
                randomCentroids = getUmFromPixels({randomCentroids}, rect);

                [ fociClusters ] = createFociClustersOfHeterochromatin( vertcat(randomCentroids{:}), num_hetero_um);

                if ~isempty(strfind(fullPathFile, 'IR_30min'))
                    allMinDistacesOfFociToHeterochromatinRandom{1, end+1} = vertcat(fociClusters{:, 2})';
                    allMeanDistacesOfFociToHeterochromatinRandom{1, end+1} = vertcat(fociClusters{:, 3})';
                else
                    allMinDistacesOfFociToHeterochromatinRandom{2, end+1} = vertcat(fociClusters{:, 2})';
                    allMeanDistacesOfFociToHeterochromatinRandom{2, end+1} = vertcat(fociClusters{:, 3})';
                end
            end
        end
    end
    save('results\randomization\distances', 'allMinDistacesOfFociToHeterochromatinRandom', 'allMeanDistacesOfFociToHeterochromatinRandom');
    %Get the relevant info after all the compilation
    [hTTestMinPerNuclei, pValueTTestMinPerNuclei] = paintHistogramOfMeansPerNuclei(allMinDistacesOfFociToHeterochromatinRandom, 'minDistanceToHeterochromatin_Random', 12, [0,3], 'IR', 'VP16');
    [hTTestMeanPerNuclei, pValueTTestMeanPerNuclei]  = paintHistogramOfMeansPerNuclei(allMeanDistacesOfFociToHeterochromatinRandom, 'meanDistanceToHeterochromatin_Random', 12, [0, 10], 'IR', 'VP16');
    save('results\randomization\pvaluesOfComparisons', 'hTTestMinPerNuclei', 'pValueTTestMinPerNuclei', 'hTTestMeanPerNuclei', 'pValueTTestMeanPerNuclei');
end

