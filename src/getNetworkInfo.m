function [ ] = getNetworkInfo(directory, numCell)
%GETNETWORKINFO Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera

    %numFrames = length(frames);
    infoCell = importdata(strcat(directory, '\Cell_', numCell, '_results.mat'));
    centroidsFoci = infoCell.Datos{1,1};
    centroidsFoci = vertcat(centroidsFoci{:, 2});
    clear infoCell;

    load(strcat(directory, '\Cell_', numCell, '_MappingInfoHeterochromatinAndFoci'));
    load(strcat(directory, '\recognizedCells.mat'));
    rect = finalCells{str2num(numCell), 1};
    rect(rect<1) = 1;
    if rect(1) + rect(3) >= size(imgBinaryNoSmallCells, 1)
        rect(3) = size(imgBinaryNoSmallCells, 1) - 1 - rect(1);
    end
    if rect(2) + rect(4) >= size(imgBinaryNoSmallCells, 2)
        rect(4) = size(imgBinaryNoSmallCells, 2) - 1 - rect(2);
    end
    
    
    num_hetero = getAllThePixelsFromBorder(num_hetero);
    
    num_hetero_um = getUmFromPixels(num_hetero, rect);
    
    save(strcat(directory, '\Cell_', numCell, '_PixelsPerCell'), 'num_hetero', 'num_hetero_um');
    
    [ fociClusters ] = createFociClustersOfHeterochromatin( centroidsFoci, num_hetero_um);
    
    %[ centroidsHeterochromatin ] = meanOfPlanes( num_hetero_um );
    %Using all the pixels instead of the centroid of the heterochromatin
    centroidsHeterochromatin = vertcat(num_hetero_um{:});
    
    distanceFociVsHeterochromatin = pdist2(centroidsFoci, centroidsHeterochromatin);
    fociToCompare = repmat(centroidsFoci(:, 3), 1, size(centroidsHeterochromatin, 1));
    heterochromatinToCompare = repmat(centroidsHeterochromatin(:, 3), 1, size(centroidsFoci, 1));
    
    fociAboveHeterochromatin = fociToCompare > heterochromatinToCompare';
    fociAboveHeterochromatin = double(fociAboveHeterochromatin);
    fociAboveHeterochromatin(fociAboveHeterochromatin == 0) = -1;
    
    %We also take into accout if the focis is above or below
    %heterochromatin. When the sign is negative (< 0) it is below. Above
    %otherwise
    distanceFociVsHeterochromatin = distanceFociVsHeterochromatin .* fociAboveHeterochromatin;
    
    if size(centroidsFoci, 1) > 1
        distanceBetweenFoci = squareform(pdist(centroidsFoci));

        adjacencyMatrix = getConnectedGraphWithMinimumDistances( distanceBetweenFoci, zeros(size(centroidsFoci, 1)));
        
        paint3DNetworkFromAdjacencyMatrix(adjacencyMatrix, centroidsFoci, numCell, directory)
        
        adjacencyMatrixNoWeights = adjacencyMatrix;
        adjacencyMatrixNoWeights(adjacencyMatrixNoWeights > 0) = 1;
        degreePerFoci = sum(adjacencyMatrixNoWeights, 2);
        meanDistanceHeterchromatinPerFociDegree = zeros(max(degreePerFoci), 1);
        meanMinDistanceHeterchromatinPerFociDegree = zeros(max(degreePerFoci), 1);
        for numDegree = 1:max(degreePerFoci)
            focisInTheDegree = degreePerFoci == numDegree;
            if sum(focisInTheDegree) > 0
                distanceActual = distanceFociVsHeterochromatin(focisInTheDegree, :);
                meanDistanceHeterchromatinPerFociDegree(numDegree) = mean(mean(distanceActual, 2));
                [~, indices] = min(abs(distanceActual), [], 2);
                meanMinDistanceHeterchromatinPerFociDegree(numDegree) = mean(arrayfun(@(x, y) distanceActual(x, y), 1:size(distanceActual, 1), indices'));
            end
        end
    else
        distanceBetweenFoci = [];
        adjacencyMatrix = [];
        meanDistanceHeterchromatinPerFociDegree = mean(distanceFociVsHeterochromatin);
        [~, index] = min(abs(distanceFociVsHeterochromatin), [], 2);
        meanMinDistanceHeterchromatinPerFociDegree = distanceFociVsHeterochromatin(index);
        degreePerFoci = [];
    end
    close all
    save(strcat(directory, '\Cell_', numCell, '_networkInfo'), 'adjacencyMatrix', 'distanceFociVsHeterochromatin', 'distanceBetweenFoci', 'fociAboveHeterochromatin', 'centroidsFoci', 'centroidsHeterochromatin', 'meanDistanceHeterchromatinPerFociDegree', 'meanMinDistanceHeterchromatinPerFociDegree', 'degreePerFoci', 'fociClusters');
end

