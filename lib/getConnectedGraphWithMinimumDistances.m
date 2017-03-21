function [ adjacencyMatrix ] = getConnectedGraphWithMinimumDistances( distanceBetweenObjects, adjacencyMatrix)
%GETCONNECTEDGRAPHWITHMINIMUMDISTANCES Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera

    distanceObjectsRemaining = squareform(distanceBetweenObjects);
    distanceObjectsRemaining(logical(eye(size(distanceObjectsRemaining)))) = intmax('int16');
    connectedComps = 2;
    i = 1;
    while connectedComps > 1
        if i > size(adjacencyMatrix,1)
            i=1;
        end
        minimumDistance = min(distanceObjectsRemaining(:));
        [rowMin, colMin] = find(distanceObjectsRemaining == minimumDistance, 1);
        adjacencyMatrix(rowMin, colMin) = distanceObjectsRemaining(rowMin, colMin);
        adjacencyMatrix(colMin, rowMin) = distanceObjectsRemaining(rowMin, colMin);


        distanceObjectsRemaining(rowMin, colMin) = intmax('int32');
        distanceObjectsRemaining(colMin, rowMin) = intmax('int32');

        contConnectedComps = contConnectedComps - 1;
        if contConnectedComps <= 0
            connectedComps = graphconncomp(adjacencyMatrix, 'Directed', 'false');
            if connectedComps == 1
                return
            end
            contConnectedComps = connectedComps;
        end

        i = i + 1;
    end
end

