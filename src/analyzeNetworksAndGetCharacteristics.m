function [ ] = analyzeNetworksAndGetCharacteristics()
%ANALYZENETWORKSANDGETCHARACTERISTICS Summary of this function goes here
%   Detailed explanation goes here

    resultFiles = getAllFiles('results\segmentation\');
    networkTableInfo = [];
    networkTableOtherInfo = {};
    clusterTableInfo = [];
    allMinDistacesOfFociToHeterochromatin = {};
    allMeanDistacesOfFociToHeterochromatin = {};
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
                if ~isempty(strfind(resultFiles{numFile}, 'IR_30min'))
                    allMinDistacesOfFociToHeterochromatin{1, end+1} = vertcat(fociClusters{:, 2})';
                    allMeanDistacesOfFociToHeterochromatin{1, end+1} = vertcat(fociClusters{:, 3})';
                else
                    allMinDistacesOfFociToHeterochromatin{2, end+1} = vertcat(fociClusters{:, 2})';
                    allMeanDistacesOfFociToHeterochromatin{2, end+1} = vertcat(fociClusters{:, 3})';
                end
                percentageOfHeterochromatinWithoutFoci = sum(cellfun(@(x) isempty(x), fociClusters(:, 2)))/size(fociClusters, 1);
                numberOfFociPerHeterochromatin = mean(cellfun(@(x) length(x), fociClusters(:, 2)));
                stdNumberOfFociPerHeterochromatin = std(cellfun(@(x) length(x), fociClusters(:, 2)));
                meanDistanceHeterochromatinPerCluster = mean(vertcat(fociClusters{:, 2}));
                stdDistanceHeterochromatinPerCluster = std(vertcat(fociClusters{:, 2}));
                if isempty(networkTableInfo)
                    clusterTableInfo = table(percentageOfHeterochromatinWithoutFoci, numberOfFociPerHeterochromatin, stdNumberOfFociPerHeterochromatin, meanDistanceHeterochromatinPerCluster, stdDistanceHeterochromatinPerCluster);
                    networkTableInfo = mainNetworksCCs(numCell, classOfCell, serieOfCell, distanceBetweenFoci, adjacencyMatrix);
                else
                    clusterTableInfo(end+1, :) = table(percentageOfHeterochromatinWithoutFoci, numberOfFociPerHeterochromatin, stdNumberOfFociPerHeterochromatin, meanDistanceHeterochromatinPerCluster, stdDistanceHeterochromatinPerCluster);
                    networkTableInfo(end+1, :) = mainNetworksCCs(numCell, classOfCell, serieOfCell, distanceBetweenFoci, adjacencyMatrix);
                end
                
                networkTableOtherInfo(end+1, :) = {meanDistanceHeterchromatinPerFociDegree, meanMinDistanceHeterchromatinPerFociDegree};
            end
        end
    end
    close all
    
    IR_MinDistancesOfFociToHeterocrhomatin = horzcat(allMinDistacesOfFociToHeterochromatin{1, :});
    VP16_MinDistancesOfFociToHeterocrhomatin = horzcat(allMinDistacesOfFociToHeterochromatin{2, :});
    
    emptyCells = cellfun(@(x) ~isempty(x), allMinDistacesOfFociToHeterochromatin);
    frequenciesIR = cellfun(@(x) histcounts(x, 12, 'BinLimits', [0,3]), allMinDistacesOfFociToHeterochromatin(1, emptyCells(1, :)), 'UniformOutput', false);
    frequenciesVP16 = cellfun(@(x) histcounts(x, 12, 'BinLimits', [0,3]), allMinDistacesOfFociToHeterochromatin(2, emptyCells(2, :)), 'UniformOutput', false);
    
    listDistributionIR = cellfun(@(x) x/sum(x), frequenciesIR, 'UniformOutput', false);
    listDistributionVP16 = cellfun(@(x) x/sum(x), frequenciesVP16, 'UniformOutput', false);
    
    meanListDistributionIR = mean(vertcat(listDistributionIR{:}));
    meanListDistributionVP16 = mean(vertcat(listDistributionVP16{:}));
    stdeviationVP16 = std(vertcat(listDistributionVP16{:}));
    stdeviationIR = std(vertcat(listDistributionIR{:}));
    standarderrorIR = stdeviationIR ./ sqrt(length(vertcat(listDistributionIR{:})));
    standarderrorIR(isnan(standarderrorIR)) = 0;
    standarderrorVP16 = stdeviationVP16 ./ sqrt(length(vertcat(listDistributionVP16{:})));
    standarderrorVP16(isnan(standarderrorVP16)) = 0;
    
    
    irMinsPerNuclei = vertcat(allMinDistacesOfFociToHeterochromatin(1, :))';
    vp16MinsPerNuclei = vertcat(allMinDistacesOfFociToHeterochromatin(2, :))';
    
    irMeanMinsPerNuclei = cellfun(@(x) mean(x), irMinsPerNuclei);
    vp16MeanMinsPerNuclei = cellfun(@(x) mean(x), vp16MinsPerNuclei);
    
    [hTTestMinPerNuclei, pValueTTestMinPerNuclei] = ttest2(irMeanMinsPerNuclei(~isnan(irMeanMinsPerNuclei)), vp16MeanMinsPerNuclei(~isnan(vp16MeanMinsPerNuclei)));
    
     figMin = figure; barMin = bar([meanListDistributionVP16', meanListDistributionIR']);
    figMin.Colormap = colormap('copper');
    hold on;
    errorbar([0.85:11.85; 1.15:12.15]', [meanListDistributionVP16', meanListDistributionIR'], [standarderrorVP16', standarderrorIR'],'r.')
    legend('VP16', 'IR');
    ylabel('Percentage of foci');
    xlabel('Min distance to the closest heterochromatin')
    set(gca, 'XTick', 1:12, 'XTickLabel', {'0 - 0.25'; '0.25 - 0.5'; '0.5 - 0.75'; '0.75 - 1'; '1 - 1.25'; '1.25 - 1.5'; '1.5 - 1.75'; '1.75 - 2'; '2 - 2.25'; '2.25 - 2.5'; '2.5 - 2.75'; '2.75 - 3'});
    
    irMeansPerNuclei = vertcat(allMeanDistacesOfFociToHeterochromatin(1, :))';
    vp16MeansPerNuclei = vertcat(allMeanDistacesOfFociToHeterochromatin(2, :))';
    
    irMeanMeansPerNuclei = cellfun(@(x) mean(x), irMeansPerNuclei);
    vp16MeanMeansPerNuclei = cellfun(@(x) mean(x), vp16MeansPerNuclei);
    
    [hTTestMeanPerNuclei, pValueTTestMeanPerNuclei] = ttest2(irMeanMeansPerNuclei(~isnan(irMeanMeansPerNuclei)), vp16MeanMeansPerNuclei(~isnan(vp16MeanMeansPerNuclei)));
 
   
    
%     [h, p] = ttest2(IR_MinDistancesOfFociToHeterocrhomatin, VP16_MinDistancesOfFociToHeterocrhomatin, 'Vartype','unequal')
%     
%     IR_MeanDistancesOfFociToHeterocrhomatin = horzcat(allMeanDistacesOfFociToHeterochromatin{1, :});
%     VP16_MeanDistancesOfFociToHeterocrhomatin = horzcat(allMeanDistacesOfFociToHeterochromatin{2, :});
%     
%     [h, p] = ttest2(IR_MeanDistancesOfFociToHeterocrhomatin, VP16_MeanDistancesOfFociToHeterocrhomatin, 'Vartype','unequal')
% 
%     meanListDistributionIR = mean(listDistributionIR);
%     stdeviationIR = std(listDistributionIR);
%     standarderrorIR = stdeviationIR ./ sqrt(12);
%     
%     figure; histogram(horzcat(allMinDistacesOfFociToHeterochromatin{1, :}), 24,'BinLimits',[0,3],'Normalization','probability')
%     hold on;
%     histogram(horzcat(allMinDistacesOfFociToHeterochromatin{2, :}),  24,'BinLimits',[0,3],'Normalization','probability')
%     legend('IR', 'VP16');
%     ylabel('Percentage of foci');
%     xlabel('Min distance to the closest heterochromatin')
%     
%     figure; histogram(horzcat(allMeanDistacesOfFociToHeterochromatin{1, :}), 24,'BinLimits',[0,10],'Normalization','probability')
%     hold on;
%     histogram(horzcat(allMeanDistacesOfFociToHeterochromatin{2, :}),  24,'BinLimits',[0,10],'Normalization','probability')
%     ylabel('Percentage of foci');
%     xlabel('Mean distance to heterochromatin')
%     legend('IR', 'VP16');
    
    save('results\segmentation\characteristicsOfNetworks', 'networkTableInfo', 'networkTableOtherInfo', 'clusterTableInfo', 'VP16_MeanDistancesOfFociToHeterocrhomatin', 'IR_MeanDistancesOfFociToHeterocrhomatin', 'IR_MinDistancesOfFociToHeterocrhomatin', 'VP16_MinDistancesOfFociToHeterocrhomatin', 'hTTestMinPerNuclei', 'hTTestMeanPerNuclei', 'pValueTTestMinPerNuclei', 'pValueTTestMeanPerNuclei');
    %meanDistanceHeterchromatinPerFociDegree = padcat(networkTableOtherInfo{:, 1})';
    %meanMinDistanceHeterchromatinPerFociDegree = padcat(networkTableOtherInfo{:, 2})';
    %distanceHeterochromatinPerFociDegree = horzcat(meanDistanceHeterchromatinPerFociDegree, meanMinDistanceHeterchromatinPerFociDegree);
    %distanceHeterochromatinPerFociDegree(isnan(distanceHeterochromatinPerFociDegree)) = 0;
    %distanceHeterochromatinPerFociDegreeDS = mat2dataset(distanceHeterochromatinPerFociDegree);
    %distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(1:size(meanDistanceHeterchromatinPerFociDegree, 2)) = cellfun(@(x) strcat('mean', x), distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(1:size(meanDistanceHeterchromatinPerFociDegree, 2)), 'UniformOutput', false);
    %distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(size(meanDistanceHeterchromatinPerFociDegree, 2)+1 : size(meanDistanceHeterchromatinPerFociDegree, 2)+size(meanMinDistanceHeterchromatinPerFociDegree, 2)) = cellfun(@(x) strcat('meanMin', x), distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(size(meanDistanceHeterchromatinPerFociDegree, 2)+1 : size(meanDistanceHeterchromatinPerFociDegree, 2)+size(meanMinDistanceHeterchromatinPerFociDegree, 2)), 'UniformOutput', false);

    meanDistancesWithDegree1_2_Last = cellfun(@(x) [x(1); x(2); x(end)], networkTableOtherInfo(:, 1), 'UniformOutput', false);
    meanDistancesWithDegreeNoZeros = cellfun(@(x) x(x ~= 0), networkTableOtherInfo(:, 1), 'UniformOutput', false);
    meanDistancesWithDegreeFirst_Second_Last = cellfun(@(x) [x(1); x(2); x(end)], meanDistancesWithDegreeNoZeros, 'UniformOutput', false);
    
    meanDistancesWithDegree1_2_Last = [meanDistancesWithDegree1_2_Last{:}]';
    meanDistancesWithDegreeFirst_Second_Last = [meanDistancesWithDegreeFirst_Second_Last{:}]';
    
%     class1 = cellfun(@(x) isequal('IR_30min', x), networkTableInfo.classOfCell);
%     figure; hist(meanDistancesWithDegree1_2_Last(class1, 1));
%     figure; hist(meanDistancesWithDegree1_2_Last(class1==0, 1));
%     figure; hist(meanDistancesWithDegree1_2_Last(class1, 2));
%     figure; hist(meanDistancesWithDegree1_2_Last(class1==0, 2));
%     figure; hist(meanDistancesWithDegree1_2_Last(class1, 3));
%     figure; hist(meanDistancesWithDegree1_2_Last(class1==0, 3));
%     
%     figure; hist(meanDistancesWithDegreeFirst_Second_Last(class1, 1));
%     figure; hist(meanDistancesWithDegreeFirst_Second_Last(class1==0, 1));
%     figure; hist(meanDistancesWithDegreeFirst_Second_Last(class1, 2));
%     figure; hist(meanDistancesWithDegreeFirst_Second_Last(class1==0, 2));
%     figure; hist(meanDistancesWithDegreeFirst_Second_Last(class1, 3));
%     figure; hist(meanDistancesWithDegreeFirst_Second_Last(class1==0, 3));
    
    meanOfMeansDistanceHeterchromatinPerFoci = cellfun(@(x) mean(x), networkTableOtherInfo(:, 1));
    meanOfMinsDistanceHeterchromatinPerFoci = cellfun(@(x) mean(x), networkTableOtherInfo(:, 2));
    stdOfMeansDistanceHeterchromatinPerFoci = cellfun(@(x) std(x), networkTableOtherInfo(:, 1));
    stdOfMinsDistanceHeterchromatinPerFoci = cellfun(@(x) std(x), networkTableOtherInfo(:, 2));
    
    writetable(horzcat(networkTableInfo, clusterTableInfo, table(meanOfMeansDistanceHeterchromatinPerFoci, meanOfMinsDistanceHeterchromatinPerFoci, stdOfMeansDistanceHeterchromatinPerFoci, stdOfMinsDistanceHeterchromatinPerFoci)), 'results\segmentation\characteristicsOfNetworks.csv');
    writetable(horzcat(networkTableInfo, clusterTableInfo, table(meanOfMeansDistanceHeterchromatinPerFoci, meanOfMinsDistanceHeterchromatinPerFoci, stdOfMeansDistanceHeterchromatinPerFoci, stdOfMinsDistanceHeterchromatinPerFoci)), 'results\segmentation\characteristicsOfNetworks.xls');
end

