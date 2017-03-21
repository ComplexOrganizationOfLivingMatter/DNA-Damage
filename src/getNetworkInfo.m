function [ ] = getNetworkInfo(directory, numCell)
%GETNETWORKINFO Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera
    load(strcat(directory, '\Cell_', numCell, '_MappingInfoHeterochromatinAndFoci'));
    
    [ centroidsFoci ] = meanOfPlanes( num_foci_verde_um );
    [ centroidsHeterochromatin ] = meanOfPlanes( num_hetero_um );
    
    distanceBetweenFoci = squareform(pdist(centroidsFoci));
    distanceFociVsHeterochromatin = pdist2(centroidsFoci, centroidsHeterochromatin);
    fociToCompare = repmat(centroidsFoci(:, 3), 1, size(centroidsHeterochromatin, 1));
    heterochromatinToCompare = repmat(centroidsHeterochromatin(:, 3), 1, size(centroidsFoci, 1));
    
    fociAboveHeterochromatin = fociToCompare > heterochromatinToCompare';
    fociAboveHeterochromatin(fociAboveHeterochromatin == 0) = -1;
    
    %We also take into accout if the focis is above or below
    %heterochromatin. When the sign is negative (< 0) it is below. Above
    %otherwise
    distanceFociVsHeterochromatin = distanceFociVsHeterochromatin .* fociAboveHeterochromatin;
    
    
end

