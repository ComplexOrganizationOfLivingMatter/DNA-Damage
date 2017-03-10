function [ ] = extractImages( )
%EXTRACTIMAGES Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera
    allImages = getAllFiles('data/images/');

    %A big number because of the final if of the for
    previousNumChannel = 20;

    imagesOfSerieByChannel = {};
    numChannel = 0;
    for fileIndex = 1:size(allImages, 1)
        fullPathImage = allImages{fileIndex};
        fileNameSplitted = strsplit(fullPathImage, '\');
        fileName = fileNameSplitted{end};
        dirName = fileNameSplitted{end-1};
        outputDir = strcat('results\images\', dirName);
        
        if exist(strcat(outputDir, '\', fileName(1:9), '.mat'), 'file') ~= 2
            img = imread(fullPathImage);
            img = im2double(img);

            %Select the channel
            if isempty(strfind(lower(fileName), lower('ch00'))) == 0
                numChannel = 1;
            elseif isempty(strfind(lower(fileName), lower('ch01'))) == 0
                numChannel = 2;
            end

            if previousNumChannel < numChannel
                imagesOfSerieByChannel{end, numChannel} = img(:,:, numChannel+1); %green
            else
                imagesOfSerieByChannel{end+1, numChannel} = img(:,:, numChannel+1); %blue
            end
            previousNumChannel = numChannel;


            if fileIndex < size(allImages, 1)
                fullPathNextSerie = allImages{fileIndex+1};
                fileNameSplitted = strsplit(fullPathNextSerie, '\');
                nextSerie = fileNameSplitted{end};
                nextSerie = nextSerie(1:9);
            else
                nextSerie = '';
            end

            %Check if it's another Serie of images
            if isequal(nextSerie, fileName(1:9)) == 0
                mkdir(outputDir);
                save(strcat(outputDir, '\', fileName(1:9)), 'imagesOfSerieByChannel');
                imagesOfSerieByChannel = {};
                previousNumChannel = 20;
            end
        end
    end

end

