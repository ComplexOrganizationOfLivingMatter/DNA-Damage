function [] = pipeline( )
%PIPELINE Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera
    

    cd 'D:\Pablo\DNA-Damage\'
    extractImages();
    
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
                    
                    %Create networks and get general network information
                    %about the relation between foci and heterochromatin
                    getNetworkInfo(directory, num2str(numCell));
                end
            end
            close all
        end
    end
    
    resultFiles = getAllFiles('results\segmentation\');
    networkTableInfo = [];
    networkTableOtherInfo = {};
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
                if isempty(networkTableInfo)
                    networkTableInfo = mainNetworksCCs(numCell, classOfCell, serieOfCell, distanceBetweenFoci, adjacencyMatrix);
                else
                    networkTableInfo(end+1, :) = mainNetworksCCs(numCell, classOfCell, serieOfCell, distanceBetweenFoci, adjacencyMatrix);
                end
                networkTableOtherInfo(end+1, :) = {meanDistanceHeterchromatinPerFociDegree, meanMinDistanceHeterchromatinPerFociDegree};
            end
        end
    end
    save('results\segmentation\characteristicsOfNetworks', 'networkTableInfo', 'networkTableOtherInfo');
    
    meanDistanceHeterchromatinPerFociDegree = padcat(networkTableOtherInfo{:, 1})';
    meanMinDistanceHeterchromatinPerFociDegree = padcat(networkTableOtherInfo{:, 2})';
    distanceHeterochromatinPerFociDegree = horzcat(meanDistanceHeterchromatinPerFociDegree, meanMinDistanceHeterchromatinPerFociDegree);
    distanceHeterochromatinPerFociDegreeDS = mat2dataset(distanceHeterochromatinPerFociDegree);
    distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(1:size(meanDistanceHeterchromatinPerFociDegree, 2)) = cellfun(@(x) strcat('mean', x), distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(1:size(meanDistanceHeterchromatinPerFociDegree, 2)), 'UniformOutput', false);
    distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(size(meanDistanceHeterchromatinPerFociDegree, 2)+1 : size(meanDistanceHeterchromatinPerFociDegree, 2)+size(meanMinDistanceHeterchromatinPerFociDegree, 2)) = cellfun(@(x) strcat('meanMin', x), distanceHeterochromatinPerFociDegreeDS.Properties.VarNames(size(meanDistanceHeterchromatinPerFociDegree, 2)+1 : size(meanDistanceHeterchromatinPerFociDegree, 2)+size(meanMinDistanceHeterchromatinPerFociDegree, 2)), 'UniformOutput', false);
    
    writetable(horzcat(networkTableInfo, dataset2table(distanceHeterochromatinPerFociDegreeDS)), 'results\segmentation\characteristicsOfNetworks.csv');
    writetable(horzcat(networkTableInfo, dataset2table(distanceHeterochromatinPerFociDegreeDS)), 'results\segmentation\characteristicsOfNetworks.xls');
end

