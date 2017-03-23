function [] = pipeline( )
%PIPELINE Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera
    

    cd 'D:\Pablo\DNA-Damage\'
    extractImages();
    
    recognitionAndProcessAllSequences();
    
    analyzeNetworksAndGetCharacteristics();
end

