function [ ] = recognitionAndProcessAllSequences( )
%recognitionAndProcessAllSequences Summary of this function goes here
%   Detailed explanation goes here

    allFiles = getAllFiles('results\images\');
    
    for numFile = 1:size(allFiles, 1)
        allFiles{numFile}
        fullPathImage = allFiles{numFile};
        
        nameFileSplitted = strsplit(fullPathImage, '\');
        nameFileSplittedNoExtension = strsplit(nameFileSplitted{end}, '.');
        nameFileSplittedNoExtension = nameFileSplittedNoExtension{1};
        
        directory = strcat(nameFileSplitted{1}, '\segmentation\', nameFileSplitted{3}, '\', nameFileSplittedNoExtension);
        if isdir(directory)~=1
            mkdir(directory)
        end
        %numCell=input('Introduzca el numero de la celula a capturar: ');
        %numCell=num2str(numCell);
        
        if exist(strcat(directory, '\recognizedCells.mat'), 'file') ~= 2
            infoCells = recognizeEveryCellInTheSequence(fullPathImage, directory);
            load(strcat(directory, '\recognizedCells.mat'));
        else
            load(strcat(directory, '\recognizedCells.mat'));
            infoCells = finalCells;
        end
        
        load(strcat(directory, '\recognizedCells.mat'));
        
        for numCell = 1:length(infoCells)
            firstOuputFile = strcat(directory, '\', 'Cell_', num2str(numCell), '_networkInfo.mat');
            if exist(firstOuputFile, 'file') ~= 2
                rect = infoCells{numCell, 1};
                rect(rect<1) = 1;
                if rect(1) + rect(3) >= size(imgBinaryNoSmallCells, 1)
                    rect(3) = size(imgBinaryNoSmallCells, 1) - 1 - rect(1);
                end
                if rect(2) + rect(4) >= size(imgBinaryNoSmallCells, 2)
                    rect(4) = size(imgBinaryNoSmallCells, 2) - 1 - rect(2);
                end
                %rect(rect>size(imgBinaryNoSmallCells, 1)) = size(imgBinaryNoSmallCells, 1);
                %rect = [rect(2) rect(1) rect(4) rect(3)];
                frames = infoCells{numCell, 2};
                frames = frames';
                %[numCell,rect]=selectCell(fullPathImage, numCell);
                Diapositiva=0;
                segmentacion_corte_canal_2(fullPathImage,1,numCell,rect, frames);
                [Diapositiva, cellnoval] = segmentacion_corte_canal_1(fullPathImage,0,numCell,rect, Diapositiva, frames);
                if cellnoval==0
                    % %% Detection of green nodes
                    deteccion_nodos(fullPathImage,0,num2str(numCell),rect)
                    % % %Representacion y almacenamiento de datos
                    Diapositiva=Representacion_foci(fullPathImage, num2str(numCell), rect, Diapositiva, frames);
                    Diapositiva=Representacion_Heterocromatina(fullPathImage, num2str(numCell), rect, Diapositiva, frames);

                    Compro_foci_hetero(fullPathImage, num2str(numCell), rect, Diapositiva, frames);
                   
                end
            end
            close all
        end
    end
end

