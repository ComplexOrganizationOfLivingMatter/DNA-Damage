function [] = pipeline( )
%PIPELINE Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera
    
    addpath(genpath('src'));
    addpath(genpath('lib'));
    
    cd 'D:\Pablo\DNA-Damage\'
    extractImages();
    
    recognitionAndProcessAllSequences();
    
    resultFiles = getAllFiles('results\segmentation\');
    for numFile = 1:size(resultFiles, 1)
        fullPathFile = resultFiles{numFile};
        if ~isempty(strfind(resultFiles{numFile}, '_MappingInfoHeterochromatinAndFoci.mat')) && isempty(strfind(resultFiles{numFile}, 'C_30min'))
            nameFileSplitted = strsplit(fullPathFile, '\');

            numCell = strsplit(nameFileSplitted{end}, '_');
            numCell = numCell{2};

            %Create networks and get general network information
            %about the relation between foci and heterochromatin
            getNetworkInfo(strcat(strjoin(nameFileSplitted(1:end-1), '\'), '\'), num2str(numCell));
        end
    end
    
    analyzeNetworksAndGetCharacteristics();
end

