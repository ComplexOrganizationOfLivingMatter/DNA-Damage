function [ hTTestPerNuclei, pValueTTestPerNuclei ] = paintHistogramOfMeansPerNuclei( allDistacesFromFociToHeterochromatin, outputFile, numberOfBars, binLimits, nameFirstRow, nameSecondRow )
%PAINTHISTOGRAMOFMEANSPERNUCLEI Summary of this function goes here
%   Detailed explanation goes here

    emptyCells = cellfun(@(x) ~isempty(x), allDistacesFromFociToHeterochromatin);
    frequenciesRow2 = cellfun(@(x) histcounts(x, numberOfBars, 'BinLimits', binLimits), allDistacesFromFociToHeterochromatin(1, emptyCells(1, :)), 'UniformOutput', false);
    frequenciesRow1 = cellfun(@(x) histcounts(x, numberOfBars, 'BinLimits', binLimits), allDistacesFromFociToHeterochromatin(2, emptyCells(2, :)), 'UniformOutput', false);
    
    listDistributionRow2 = cellfun(@(x) x/sum(x), frequenciesRow2, 'UniformOutput', false);
    listDistributionRow1 = cellfun(@(x) x/sum(x), frequenciesRow1, 'UniformOutput', false);
    
    meanListDistributionRow2 = mean(vertcat(listDistributionRow2{:}));
    meanListDistributionRow1 = mean(vertcat(listDistributionRow1{:}));
    stdeviationRow1 = std(vertcat(listDistributionRow1{:}));
    stdeviationRow2 = std(vertcat(listDistributionRow2{:}));
    standarderrorRow2 = stdeviationRow2 ./ sqrt(length(vertcat(listDistributionRow2{:})));
    standarderrorRow2(isnan(standarderrorRow2)) = 0;
    standarderrorRow1 = stdeviationRow1 ./ sqrt(length(vertcat(listDistributionRow1{:})));
    standarderrorRow1(isnan(standarderrorRow1)) = 0;
    
    scrsz = get(groot,'ScreenSize');
    figMin = figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)]); barMin = bar([meanListDistributionRow1', meanListDistributionRow2']);
    figMin.Colormap = colormap('copper');
    hold on;
    errorbar([0.85:numberOfBars-0.15; 1.15:numberOfBars+0.15]', [meanListDistributionRow1', meanListDistributionRow2'], [standarderrorRow1', standarderrorRow2'],'r.')
    legend(nameFirstRow, nameSecondRow);
    ylabel('Percentage of foci');
    if isequal(binLimits, [0,3])
        xlabel('Min distance to the closest heterochromatin')
        set(gca, 'XTick', 1:numberOfBars, 'XTickLabel', {'0 - 0.25'; '0.25 - 0.5'; '0.5 - 0.75'; '0.75 - 1'; '1 - 1.25'; '1.25 - 1.5'; '1.5 - 1.75'; '1.75 - 2'; '2 - 2.25'; '2.25 - 2.5'; '2.5 - 2.75'; '2.75 - 3'});
    else
        xlabel('Mean distance to heterochromatin')
        set(gca, 'XTick', 1:numberOfBars, 'XTickLabel', {'0 - 0.83'; '0.83 - 1.67'; '1.67 - 2.5'; '2.5 - 3.33'; '3.33 - 4.17'; '4.17 - 5'; '5 - 5.83'; '5.83 - 6.67'; '6.67 - 7.5'; '7.5 - 8.3'; '8.3 - 9.17'; '9.17 - 10'});
    end
    p = ylim;
    set(gca, 'ylim', [0 p(2)])
    export_fig(figMin, strcat('results/', outputFile, '_', date), '-pdf');
    
    
    Row2PerNuclei = vertcat(allDistacesFromFociToHeterochromatin(1, :))';
    Row1MinsPerNuclei = vertcat(allDistacesFromFociToHeterochromatin(2, :))';
    
    Row2MeanPerNuclei = cellfun(@(x) mean(x), Row2PerNuclei);
    Row1MeanPerNuclei = cellfun(@(x) mean(x), Row1MinsPerNuclei);
    
    [hTTestPerNuclei, pValueTTestPerNuclei] = ttest2(Row2MeanPerNuclei(~isnan(Row2MeanPerNuclei)), Row1MeanPerNuclei(~isnan(Row1MeanPerNuclei)));
    close(figMin)
end

