function [ ] = getNetworkInfo(directory, numCell)
%GETNETWORKINFO Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera

    infoCell = importdata(strcat(directory, '\Cell_', numCell, '_results.mat'));
    centroidsFoci = infoCell.Datos{1,1};
    centroidsFoci = vertcat(centroidsFoci{:, 2});
    clear infoCell;

    load(strcat(directory, '\Cell_', numCell, '_MappingInfoHeterochromatinAndFoci'));
    
    [ centroidsHeterochromatin ] = meanOfPlanes( num_hetero_um );

    
    distanceFociVsHeterochromatin = pdist2(centroidsFoci, centroidsHeterochromatin);
    fociToCompare = repmat(centroidsFoci(:, 3), 1, size(centroidsHeterochromatin, 1));
    heterochromatinToCompare = repmat(centroidsHeterochromatin(:, 3), 1, size(centroidsFoci, 1));
    
    fociAboveHeterochromatin = fociToCompare > heterochromatinToCompare';
    fociAboveHeterochromatin(fociAboveHeterochromatin == 0) = -1;
    
    %We also take into accout if the focis is above or below
    %heterochromatin. When the sign is negative (< 0) it is below. Above
    %otherwise
    distanceFociVsHeterochromatin = distanceFociVsHeterochromatin .* fociAboveHeterochromatin;
    
    if size(centroidsFoci, 1) > 1
        distanceBetweenFoci = squareform(pdist(centroidsFoci));

        adjacencyMatrix = getConnectedGraphWithMinimumDistances( distanceBetweenFoci, zeros(size(centroidsFoci, 1)));
        
        paint3DNetworkFromAdjacencyMatrix(adjacencyMatrix, centroidsFoci, numCell, directory)
        
        adjacencyMatrixTriu = triu(adjacencyMatrix, 1);
        adjacencyMatrixTriu(adjacencyMatrixTriu > 0) = 1;
        degreePerFoci = sum(adjacencyMatrixTriu, 2);
        distanceHeterchromatinPerFociDegree = zeros(max(degreePerFoci), 1);
        for numDegree = 1:max(degreePerFoci)
            focisInTheDegree = degreePerFoci == numDegree;
            if sum(focisInTheDegree) > 0
                distanceHeterchromatinPerFociDegree(numDegree) = mean(mean(distanceFociVsHeterochromatin(focisInTheDegree, :)));
            end
        end
    else
        distanceBetweenFoci = [];
        adjacencyMatrix = [];
        distanceHeterchromatinPerFociDegree = mean(distanceFociVsHeterochromatin);
        degreePerFoci = [];
    end
    save(strcat(directory, '\Cell_', numCell, '_networkInfo'), 'adjacencyMatrix', 'distanceFociVsHeterochromatin', 'distanceBetweenFoci', 'fociAboveHeterochromatin', 'centroidsFoci', 'centroidsHeterochromatin', 'distanceHeterchromatinPerFociDegree', 'degreePerFoci');
end

