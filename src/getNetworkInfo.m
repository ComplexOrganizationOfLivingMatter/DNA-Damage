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
end

