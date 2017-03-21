function [ centroids ] = meanOfPlanes( cellsInfo )
%MEANOFPLANES Summary of this function goes here
%   Detailed explanation goes here
    centroids = zeros(length(cellsInfo), 3);
    for numCellFound = 1:length(cellsInfo)
        cellFound = cellsInfo{numCellFound};
        centroids(numCellFound, :) = mean(cellFound(:, :), 1);
    end
end

