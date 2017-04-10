function [ output_args ] = paintHistogramOfMeansPerNuclei( allDistacesFromFociToHeterochromatin )
%PAINTHISTOGRAMOFMEANSPERNUCLEI Summary of this function goes here
%   Detailed explanation goes here

    emptyCells = cellfun(@(x) ~isempty(x), allDistacesFromFociToHeterochromatin);
    frequenciesIR = cellfun(@(x) histcounts(x, 12, 'BinLimits', [0,3]), allDistacesFromFociToHeterochromatin(1, emptyCells(1, :)), 'UniformOutput', false);
    frequenciesVP16 = cellfun(@(x) histcounts(x, 12, 'BinLimits', [0,3]), allDistacesFromFociToHeterochromatin(2, emptyCells(2, :)), 'UniformOutput', false);
    
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
    
    figMin = figure; barMin = bar([meanListDistributionVP16', meanListDistributionIR']);
    figMin.Colormap = colormap('copper');
    hold on;
    errorbar([0.85:11.85; 1.15:12.15]', [meanListDistributionVP16', meanListDistributionIR'], [standarderrorVP16', standarderrorIR'],'r.')
    legend('VP16', 'IR');
    ylabel('Percentage of foci');
    xlabel('Min distance to the closest heterochromatin')
    set(gca, 'XTick', 1:12, 'XTickLabel', {'0 - 0.25'; '0.25 - 0.5'; '0.5 - 0.75'; '0.75 - 1'; '1 - 1.25'; '1.25 - 1.5'; '1.5 - 1.75'; '1.75 - 2'; '2 - 2.25'; '2.25 - 2.5'; '2.5 - 2.75'; '2.75 - 3'});
    
    irPerNuclei = vertcat(allMinDistacesOfFociToHeterochromatin(1, :))';
    vp16MinsPerNuclei = vertcat(allMinDistacesOfFociToHeterochromatin(2, :))';
    
    irMeanPerNuclei = cellfun(@(x) mean(x), irPerNuclei);
    vp16MeanPerNuclei = cellfun(@(x) mean(x), vp16MinsPerNuclei);
    
    [hTTestPerNuclei, pValueTTestPerNuclei] = ttest2(irMeanPerNuclei(~isnan(irMeanPerNuclei)), vp16MeanPerNuclei(~isnan(vp16MeanPerNuclei)));
end

