function [ ] = analyzeNetworksAndGetCharacteristics()
%ANALYZENETWORKSANDGETCHARACTERISTICS Summary of this function goes here
%   Detailed explanation goes here

    resultFiles = getAllFiles('results\segmentation\');
    networkTableInfo = [];
    networkTableOtherInfo = {};
    for numFile = 1:size(resultFiles, 1)
        fullPathFile = resultFiles{numFile};
        if ~isempty(strfind(resultFiles{numFile}, 'networkInfo.mat')) && isempty(strfind(resultFiles{numFile}, 'C_30min'))
            fullPathFile
            nameFileSplitted = strsplit(fullPathFile, '\');
            
            numCell = strsplit(nameFileSplitted{end}, '_');
            numCell = numCell{2};
            
            classOfCell = nameFileSplitted{3};
            
            serieOfCell = nameFileSplitted{4};
            
            load(fullPathFile);
            if ~isempty(adjacencyMatrix)
                if isempty(networkTableInfo)
                    networkTableInfo = mainNetworksCCs(numCell, classOfCell, serieOfCell, distanceBetweenFoci, adjacencyMatrix);
                else
                    networkTableInfo(end+1, :) = mainNetworksCCs(numCell, classOfCell, serieOfCell, distanceBetweenFoci, adjacencyMatrix);
                end
                networkTableOtherInfo(end+1, :) = {meanDistanceHeterchromatinPerFociDegree, meanMinDistanceHeterchromatinPerFociDegree};
            end
        end
    end
    save('results\segmentation\characteristicsOfNetworks', 'networkTableInfo', 'networkTableOtherInfo');
    
    meanDistanceHeterchromatinPerFociDegree = padcat(networkTableOtherInfo{:, 1})';
    meanMinDistanceHeterchromatinPerFociDegree = padcat(networkTableOtherInfo{:, 2})';
    distanceHeterochromatinPerFociDegree = horzcat(meanDistanceHeterchromatinPerFociDegree, meanMinDistanceHeterchromatinPerFociDegree);
    distanceHeterochromatinPerFociDegree(isnan(distanceHeterochromatinPerFociDegree)) = 0;
    distanceHeterochromatinPerFociDegreeDS = mat2dataset(distanceHeterochromatinPerFociDegree);
    distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(1:size(meanDistanceHeterchromatinPerFociDegree, 2)) = cellfun(@(x) strcat('mean', x), distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(1:size(meanDistanceHeterchromatinPerFociDegree, 2)), 'UniformOutput', false);
    distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(size(meanDistanceHeterchromatinPerFociDegree, 2)+1 : size(meanDistanceHeterchromatinPerFociDegree, 2)+size(meanMinDistanceHeterchromatinPerFociDegree, 2)) = cellfun(@(x) strcat('meanMin', x), distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(size(meanDistanceHeterchromatinPerFociDegree, 2)+1 : size(meanDistanceHeterchromatinPerFociDegree, 2)+size(meanMinDistanceHeterchromatinPerFociDegree, 2)), 'UniformOutput', false);
    
    writetable(horzcat(networkTableInfo, dataset2table(distanceHeterochromatinPerFociDegreeDS)), 'results\segmentation\characteristicsOfNetworks.csv');
    writetable(horzcat(networkTableInfo, dataset2table(distanceHeterochromatinPerFociDegreeDS)), 'results\segmentation\characteristicsOfNetworks.xls');
end

