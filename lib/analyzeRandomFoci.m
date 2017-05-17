function [ ] = analyzeRandomFoci( )
%ANALYZERANDOMFOCI Summary of this function goes here
%   Detailed explanation goes here

    
    load(strcat(directory, '\recognizedCells.mat'));
    rect = finalCells{str2num(numCell), 1};
    rect(rect<1) = 1;
    if rect(1) + rect(3) >= size(imgBinaryNoSmallCells, 1)
        rect(3) = size(imgBinaryNoSmallCells, 1) - 1 - rect(1);
    end
    if rect(2) + rect(4) >= size(imgBinaryNoSmallCells, 2)
        rect(4) = size(imgBinaryNoSmallCells, 2) - 1 - rect(2);
    end
    
    getUmFromPixels(randomCentroids, rect);
    
    [ fociClusters ] = createFociClustersOfHeterochromatin( randomCentroids, num_hetero_um);
    
        if ~isempty(strfind(resultFiles{numFile}, 'IR_30min'))
            allMinDistacesOfFociToHeterochromatin{1, end+1} = vertcat(fociClusters{:, 2})';
            allMeanDistacesOfFociToHeterochromatin{1, end+1} = vertcat(fociClusters{:, 3})';
        else
            allMinDistacesOfFociToHeterochromatin{2, end+1} = vertcat(fociClusters{:, 2})';
            allMeanDistacesOfFociToHeterochromatin{2, end+1} = vertcat(fociClusters{:, 3})';
        end
    
    %Get the relevant info after all the compilation
    [hTTestMinPerNuclei, pValueTTestMinPerNuclei] = paintHistogramOfMeansPerNuclei(allMinDistacesOfFociToHeterochromatin, 'minDistanceToHeterochromatin_Random', 12, [0,3]);
    [hTTestMeanPerNuclei, pValueTTestMeanPerNuclei]  = paintHistogramOfMeansPerNuclei(allMeanDistacesOfFociToHeterochromatin, 'meanDistanceToHeterochromatin_Random', 12, [0, 10]);

end

