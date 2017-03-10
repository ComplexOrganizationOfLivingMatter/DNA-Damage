function [ recognizedCells ] = recognizeEveryCellInTheSequence( sequenceFile )
%RECOGNIZEEVERYCELLINTHESEQUENCE Summary of this function goes here
%   Detailed explanation goes here
    
    recognizedCells = {};
    load(sequenceFile);
    
    imagesOfSerieByChannelCh0 = imagesOfSerieByChannel{:, 1};
    
    for i = 1:length(imagesOfSerieByChannelCh0)
        cells = regionProps(imagesOfSerieByChannelCh0{i});
    end
end

