function [ fociClusters ] = createFociClustersOfHeterochromatin( centroidsFoci, num_hetero_um)
%CREATEFOCICLUSTERSOFHETEROCHROMATIN Summary of this function goes here
%   Detailed explanation goes here
    fociClusters = cell(length(num_hetero_um), 3);
    
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

end

