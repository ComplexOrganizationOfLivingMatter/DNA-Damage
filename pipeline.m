function [] = pipeline( )
%PIPELINE Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera
    
    cd 'D:\Pablo\DNA-Damage\'
    addpath(genpath('src'));
    addpath(genpath('lib'));
    
    
    %extractImages();
    
    %recognitionAndProcessAllSequences();
%     
%     resultFiles = getAllFiles('results\segmentation\');
%     for numFile = 1:size(resultFiles, 1)
%         fullPathFile = resultFiles{numFile};
%         if ~isempty(strfind(resultFiles{numFile}, '_MappingInfoHeterochromatinAndFoci.mat')) && isempty(strfind(resultFiles{numFile}, 'C_30min'))
%             nameFileSplitted = strsplit(fullPathFile, '\');
% 
%             numCell = strsplit(nameFileSplitted{end}, '_');
%             numCell = numCell{2};
% 
%             %Create networks and get general network information
%             %about the relation between foci and heterochromatin
%             getNetworkInfo(strcat(strjoin(nameFileSplitted(1:end-1), '\'), '\'), num2str(numCell));
%         end
%     end
%     
%     %analyzeNetworksAndGetCharacteristics();
%     
%     %createRandomFociWithinNuclei(1000);
%     
%     %analyzeRandomFoci();
    
    
    load('D:\Pablo\DNA-Damage\results\randomization\distances.mat')
    allRandomMin = {allMinDistacesOfFociToHeterochromatinRandom{:}};
    allRandomMean = {allMeanDistacesOfFociToHeterochromatinRandom{:}};
    
    load('D:\Pablo\DNA-Damage\results\segmentation\characteristicsOfNetworks.mat')
    
    allMinDistacesOfFociToHeterochromatinVsRandom = {};
    allMinDistacesOfFociToHeterochromatinVsRandom(1, 1:size(allMinDistacesOfFociToHeterochromatinRandom, 2)) = {allMinDistacesOfFociToHeterochromatinRandom{2, :}};
    allMinDistacesOfFociToHeterochromatinVsRandom(2, 1:size(allMinDistacesOfFociToHeterochromatin, 2)) = {allMinDistacesOfFociToHeterochromatin{2, :}};
    [hTTestMinPerNuclei, pValueTTestMinPerNuclei] = paintHistogramOfMeansPerNuclei(allMinDistacesOfFociToHeterochromatinVsRandom, 'minDistanceToHeterochromatin_VP16vsRandomVP16', 12, [0,3], 'RandomVP16', 'VP16');
    
    allMeanDistacesOfFociToHeterochromatinVsRandom = {};
    allMeanDistacesOfFociToHeterochromatinVsRandom(1, 1:size(allRandomMean, 2)) = allRandomMean;
    allMeanDistacesOfFociToHeterochromatinVsRandom(2, 1:size(allMeanDistacesOfFociToHeterochromatin, 2)) = {allMeanDistacesOfFociToHeterochromatin{1, :}};
    [hTTestMinPerNuclei, pValueTTestMinPerNuclei] = paintHistogramOfMeansPerNuclei(allMeanDistacesOfFociToHeterochromatinVsRandom, 'meanDistanceToHeterochromatin_IRvsRandom', 12, [0,10], 'Random', 'IR');
end

