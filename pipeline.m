function [] = pipeline( )
%PIPELINE Summary of this function goes here
%   Detailed explanation goes here
%
%   Developed by Pablo Vicente-Munuera
    

    cd 'D:\Pablo\PhD-miscelanious\DNA-Damage\'
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
        numCell=input('Introduzca el numero de la celula a capturar: ');
        numCell=num2str(numCell);
        firstOuputFile = strcat(directory, '\', 'Cell_',numCell, '_', 'Proyeccion_General_3D_FOCI-VERDE-2.tiff');
        if exist(firstOuputFile, 'file') ~= 2
            [numCell,rect]=selectCell(fullPathImage, numCell);
            Diapositiva=0;
            segmentacion_corte_canal_2(fullPathImage,1,numCell,rect);
            [Diapositiva, cellnoval] = segmentacion_corte_canal_1(fullPathImage,0,numCell,rect, Diapositiva);
            if cellnoval==0
                % %% Detection of green nodes
                deteccion_nodos(fullPathImage,0,numCell,rect)
                % % %Representacion y almacenamiento de datos
                Diapositiva=Representacion_foci(fullPathImage, numCell, rect, Diapositiva);
                Diapositiva=Representacion_Heterocromatina(fullPathImage, numCell, rect, Diapositiva);
                
                Compro_foci_hetero(fullPathImage, numCell, rect, Diapositiva);
            end
        end
        close all
    end
end

