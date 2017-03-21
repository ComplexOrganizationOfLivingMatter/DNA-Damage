function [ adjacencyMatrix ] = getConnectedGraphWithMinimumDistances( distanceBetweenObjects, adjacencyMatrix)
%GETCONNECTEDGRAPHWITHMINIMUMDISTANCES Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera

    distanceObjectsRemaining = distanceBetweenObjects;
    distanceObjectsRemaining(logical(eye(size(distanceObjectsRemaining)))) = intmax('int16');
    connectedComps = 2;
    while connectedComps > 1
        minimumDistance = min(distanceObjectsRemaining(:));
        [rowMin, colMin] = find(distanceObjectsRemaining == minimumDistance, 1);
        adjacencyMatrix(rowMin, colMin) = distanceObjectsRemaining(rowMin, colMin);
        adjacencyMatrix(colMin, rowMin) = distanceObjectsRemaining(rowMin, colMin);


        distanceObjectsRemaining(rowMin, colMin) = intmax('int32');
        distanceObjectsRemaining(colMin, rowMin) = intmax('int32');
        
        connectedComps = graphconncomp(sparse(adjacencyMatrix), 'Directed', 'false');
        if connectedComps == 1
            return
        end
    end
end

