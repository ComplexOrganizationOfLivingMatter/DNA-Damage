function [ ] = paint3DNetworkFromAdjacencyMatrix( adjacencyMatrix, centroids, numCell, directory)
%PAINT3DNETWORKFROMADJACENCYMATRIX Summary of this function goes here
%   Detailed explanation goes here
    [Xout,Yout,Zout] = gplot3(adjacencyMatrix, centroids);
    h1 = figure ('visible',  'off'); 
    plot3(centroids(:, 1), centroids(:, 2), centroids(:, 3), '.', 'Color', [0 0.5 0], 'MarkerSize', 30);
    hold on;
    plot3(Xout, Yout, Zout, 'Color', [0 0 0]);
    xlabel('Eje X')
    ylabel('Eje Y')
    zlabel('Eje Z')
    grid on
    savefig(strcat(directory, '\Cell_', numCell, '_sortingNetwork'));
    saveas(h1, strcat(directory, '\Cell_', numCell, '_sortingNetwork.tiff'), 'tiff');
end

