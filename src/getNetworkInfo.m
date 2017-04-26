function [ ] = getNetworkInfo(directory, numCell, frames)
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
    
    fociClusters = cell(length(num_hetero_um), 3);
    
    num_hetero = getAllThePixelsFromBorder(num_hetero);
    
    num_hetero_um = getUmFromPixels(num_hetero);
    
    for numCentroidFoci = 1:size(centroidsFoci, 1)
        centroidFoci = centroidsFoci(numCentroidFoci, :);
        minDistance = intmax('int16');
       	minCluster = 0;
        for clusterHeterochromatin = 1:size(fociClusters, 1)
            distances = pdist2(centroidFoci, num_hetero_um{clusterHeterochromatin});
            actualDistance = min(abs(distances), [], 2);
            if minDistance > actualDistance
                minDistance = actualDistance;
                minCluster = clusterHeterochromatin;
            end
        end
        fociClusters{minCluster, 1}(end+1, :) = centroidFoci;
        fociClusters{minCluster, 2}(end+1, :) = minDistance;
        fociClusters{minCluster, 3}(end+1, :) = mean(cellfun(@(x) min(pdist2(centroidFoci, x)), num_hetero_um));
    end
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

