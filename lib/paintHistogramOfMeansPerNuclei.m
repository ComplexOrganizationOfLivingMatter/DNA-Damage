function [ hTTestPerNuclei, pValueTTestPerNuclei ] = paintHistogramOfMeansPerNuclei( allDistacesFromFociToHeterochromatin, outputFile, numberOfBars, binLimits )
%PAINTHISTOGRAMOFMEANSPERNUCLEI Summary of this function goes here
%   Detailed explanation goes here

    emptyCells = cellfun(@(x) ~isempty(x), allDistacesFromFociToHeterochromatin);
    frequenciesIR = cellfun(@(x) histcounts(x, numberOfBars, 'BinLimits', binLimits), allDistacesFromFociToHeterochromatin(1, emptyCells(1, :)), 'UniformOutput', false);
    frequenciesVP16 = cellfun(@(x) histcounts(x, numberOfBars, 'BinLimits', binLimits), allDistacesFromFociToHeterochromatin(2, emptyCells(2, :)), 'UniformOutput', false);
    
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
    
    scrsz = get(groot,'ScreenSize');
    figMin = figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)]); barMin = bar([meanListDistributionVP16', meanListDistributionIR']);
    figMin.Colormap = colormap('copper');
    hold on;
    errorbar([0.85:numberOfBars-0.15; 1.15:numberOfBars+0.15]', [meanListDistributionVP16', meanListDistributionIR'], [standarderrorVP16', standarderrorIR'],'r.')
    legend('VP16', 'IR');
    ylabel('Percentage of foci');
    if isequal(binLimits, [0,3])
        xlabel('Min distance to the closest heterochromatin')
        set(gca, 'XTick', 1:numberOfBars, 'XTickLabel', {'0 - 0.25'; '0.25 - 0.5'; '0.5 - 0.75'; '0.75 - 1'; '1 - 1.25'; '1.25 - 1.5'; '1.5 - 1.75'; '1.75 - 2'; '2 - 2.25'; '2.25 - 2.5'; '2.5 - 2.75'; '2.75 - 3'});
    else
        xlabel('Mean distance to the closest heterochromatin')
        set(gca, 'XTick', 1:numberOfBars, 'XTickLabel', {'0 - 0.83'; '0.83 - 1.67'; '1.67 - 2.5'; '2.5 - 3.33'; '3.33 - 4.17'; '4.17 - 5'; '5 - 5.83'; '5.83 - 6.67'; '6.67 - 7.5'; '7.5 - 8.3'; '8.3 - 9.17'; '9.17 - 10'});
    end
    p = ylim;
    set(gca, 'ylim', [0 p(2)])
    export_fig(figMin, strcat('results/', outputFile), '-pdf');
    
    
    irPerNuclei = vertcat(allDistacesFromFociToHeterochromatin(1, :))';
    vp16MinsPerNuclei = vertcat(allDistacesFromFociToHeterochromatin(2, :))';
    
    irMeanPerNuclei = cellfun(@(x) mean(x), irPerNuclei);
    vp16MeanPerNuclei = cellfun(@(x) mean(x), vp16MinsPerNuclei);
    
    [hTTestPerNuclei, pValueTTestPerNuclei] = ttest2(irMeanPerNuclei(~isnan(irMeanPerNuclei)), vp16MeanPerNuclei(~isnan(vp16MeanPerNuclei)));
    close(figMin)
end

