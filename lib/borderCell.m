function [ isBoderCell ] = borderCell(cells, MAX_SIZE )
%BORDERCELL Summary of this function goes here
%   Detailed explanation goes here
    %vertcat(cells);
    hulls = vertcat(cells.ConvexHull);
    if sum(hulls(:, 1) >= MAX_SIZE(1) - 1) > 0 || sum(hulls(:, 2) >= MAX_SIZE(2) - 1) > 0 || sum(hulls(:, 1) <= 1) > 0 || sum(hulls(:, 2) <= 1) > 0 
        isBoderCell = 1;
    else
        isBoderCell = 0;
    end
end

