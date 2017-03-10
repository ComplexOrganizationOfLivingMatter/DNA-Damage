function segmentacion_corte_canal_2(nameFile, canal,numCell,rect)

    %% Datos
    load(nameFile);

    Diapositiva = 0;
    im=imagesOfSerieByChannel;
    pl=imagesOfSerieByChannel(:, canal+1);
    [H,W,~]=size(im{1,1});
    Long=size(im, 1);

    canal=num2str(canal);

    %% Proyeccion de todos los planos
    proyeccionb=pl{1,1};
    for k=1:Long-1
        maximo = max(proyeccionb,pl{1+k});
        proyeccionb=maximo;
    end
    proyb=proyeccionb;
    %% Transformaciones morfologicas para obtener forma de cada celula(Se utilizará para detectar automaticamente el numero de celulas por imagen y asi evitar el recorte)

    % Binarizo la imagen proyeccion
    proyb_eq=histeq(proyb);
    BW=im2bw(proyb_eq,0.82);
    %figure;imshow(BW)
    % BW=im2bw(proyb,0.145);%%%%%%%%%%%%%%%%%%%%%%%%%% CAMBIO ESTE UMBRAL ANTES A 0.045
    %figure, imshow(BW), title('Binarizada')

    % Elimino pequeños objetos
    BW = bwareaopen(BW,10);
    %figure, imshow(BW), title('elimino pequeños')

    % Relleno huecos
    BW = imfill(BW,'holes');
    %figure, imshow(BW), title('relleno')


    %Apertura para eliminar puntos y dividir celulas
    se = strel('disk',10);
    BWcelulas = imopen(BW,se);
    %figure, imshow(BWcelulas), title('Celulas')
    masc_celulas=BWcelulas;

    L1 = bwlabel(BWcelulas,8);  % etiqueto zonas conexas
    L = label2rgb(L1);  %les doy color para representar
    %figure, imshow(L)

    mascara_validatoria=imcrop(L1,rect); % Si por proximidad tenemos la exigencia de coger un trozo pequeño de otra celula, aplicando esta máscara la eliminamos
    Area_cell_previo = regionprops(mascara_validatoria,'Area');
    Area_cell_previo = cat(1, Area_cell_previo.Area);

    [v ix]=max(Area_cell_previo);
    mascara_validatoria(mascara_validatoria~=ix)=0;
    mascara_validatoria=logical(mascara_validatoria);
    %%
    proyb_rect=imcrop(proyb,rect);
    proyb_rect=proyb_rect.*mascara_validatoria;
    h=fspecial('gaussian',[7 7], 1.5);
    imfilt=imfilter(proyb_rect,h);
    %figure, imshow(imfilt)
    BG=medfilt2(proyb_rect,[60 60]);%
    %figure, imshow(BG)

    dif=imfilt-BG;
    %figure, imshow(dif)
    umbral=graythresh(dif);
    BW=im2bw(dif,umbral*1.5);
    %figure, imshow(BW),title('Binarizamos la imagen')

    % Eliminacion de objetos formados por 4 pixeles o menos
    aux=bwareaopen(BW,5);
    %figure,imshow(aux);title('Eliminacion de objetos formados por 4 pixeles o menos')

    % Suavizamos contornos y rompemos conexiones debiles
    h=strel('diamond',1);
    aux=imopen(aux,h);
    %figure,imshow(aux);title('Suavizamos contornos y rompemos conexiones debiles')

    % Rellenamos huecos
    aux=imfill(aux,'holes');
    mascara=aux;
    proy_bin_azul=aux;
    %figure,imshow(aux);title('Rellenamos los huecos')


    %Umbral para detectar la heterocromatina de forma generalizada
    for corte=1:Long
        capa=imcrop(pl{corte},rect);
        capa=capa.*mascara_validatoria;
        h=fspecial('gaussian',[7 7], 1.5);
        capa=imfilter(capa,h);
        capa=capa.*mascara;
        umbral(corte)=graythresh(capa);
    end
    %plot(1:length(umbral),umbral)
    umbral_fin=max(umbral);
    umbral_fin=umbral_fin*0.75;


    for corte=1:Long
        % Detecta la heterocromatina de una celula determinada en cada uno de los cortes
        capa=imcrop(pl{corte},rect);
        capa=capa.*mascara_validatoria;
        capa=imadjust(capa,[0 max(max(capa))], [0 1]);
        h=fspecial('gaussian',[7 7], 1.5);
        capa=imfilter(capa,h);
        capa=capa.*mascara;
        % Binarizamos la imagen
        BW=im2bw(capa,umbral_fin);
        %figure, imshow(BW),title('Binarizamos la imagen')

        % Eliminacion de objetos formados por 15 pixeles o menos
        aux=bwareaopen(BW,15);
        %figure,imshow(aux);title('Eliminacion de objetos formados por 10 pixeles o menos')

        % Suavizamos contornos y rompemos conexiones debiles
        h=strel('diamond',1);
        aux=imopen(aux,h);
        %figure,imshow(aux);title('Suavizamos contornos y rompemos conexiones debiles')


        % Rellenamos huecos
        aux=imfill(aux,'holes');
        %     figure,subplot(1,2,1);imshow(capa);title('Heterocromatina')
        %     subplot(1,2,2);imshow(aux);title(strcat('Rellenamos los huecos-',num2str(corte)))
        mask_Hetero{1,corte}=aux;

        % Determina los bordes de una celula en cada uno de los cortes
        %% Tamaño de la celula en cada corte
        La=bwlabel(aux,8);
        med=unique(La);
        numobj=length(med)-1;
        capa=imcrop(pl{corte},rect);
        capa=capa.*mascara_validatoria;
        %figure;imshow(capa)
        % Binarizo la imagen proyeccion
        if numobj~=0
            umbral=graythresh(capa);
            BW=im2bw(capa,umbral*0.045);
        else
            BW=im2bw(capa,0.15);
        end


        % figure, imshow(BW), title(strcat('Binarizada-',num2str(corte)))

        se = strel('disk',5);
        BW = imclose(BW,se);

        % Elimino pequeños objetos
        BW = bwareaopen(BW,10);
        %figure, imshow(BW), title('elimino pequeños')

        % Relleno huecos
        BW = imfill(BW,'holes');
        %figure, imshow(BW), title('relleno')


        %Apertura para eliminar puntos y dividir celulas
        se = strel('disk',10);
        BWcell{1,corte} = imopen(BW,se);

        %         figure,subplot(1,2,1);imshow(capa);title('Celulas')
        %         subplot(1,2,2);imshow(BWcell{1,corte});title(strcat('Forma celula-', num2str(corte)))
        %
        Bord = regionprops(BWcell{1,corte}, 'Extrema'); % centroides de G de las zonas conexas
        Bordes{corte,1} = struct2cell(Bord);

    end

    objeto_primer=0;
    ocont=0;
    for N_corte=1:Long
        obj_num = bwlabel(mask_Hetero{1,N_corte});
        ind_obj=unique(obj_num);
        ind_obj=ind_obj(2:end);

        %Recopilacion de datos del corte N_corte para todos los objetos
        Area = regionprops(obj_num, 'Area'); % centroides de G de las zonas conexas
        Area = struct2cell(Area);
        Area = cell2mat(Area);

        Peri = bwperim(obj_num,4);
        PERIMETRO = regionprops(Peri, 'PixelList'); % centroides de G de las zonas conexas
        PERIMETRO = struct2cell(PERIMETRO);

        pos_obj = regionprops(obj_num, 'PixelList');
        pos_obj = struct2cell(pos_obj);
        if isempty(ind_obj)==0 % En caso de que en el corte N_corte haya objetos
            for i=1:length(ind_obj)
                col=1;
                repe=0;
                numero=1;
                objeto=0;
                %Recopilacion de datos del corte N_corte para el objeto i
                %Fase de comprobacion de repeticion de objetos
                if N_corte~=1 && objeto_primer==0
                    Pos_obj_actual=pos_obj{i};
                    for k=1:size(Recopilacion,1)
                        if Recopilacion{k,2}==(N_corte-1)
                            Pos_obj_ant = Recopilacion{k,5};
                            for npobact=1:size(Pos_obj_actual,1)
                                sit1=find(Pos_obj_actual(npobact,1)==Pos_obj_ant(:,1));
                                if isempty(sit1)==0
                                    sit2=find(Pos_obj_actual(npobact,2)==Pos_obj_ant(sit1,2));
                                    if isempty(sit2)==0
                                        repe=1;
                                        objeto(numero)=Recopilacion{k,1};
                                        numero=numero+1;
                                    end
                                end
                            end
                        end
                    end
                    objs=unique(objeto);
                    if repe==1
                        ocont=ocont+1;
                        if length(objs)==1
                            Recopilacion{ocont,1}=objs;
                        elseif length(objs)>=1
                            objs_min=min(objs);
                            Recopilacion{ocont,1}=objs_min;
                            for recorrer=1:ocont-1
                                for prosigue=1:length(objs)
                                    if Recopilacion{recorrer,1}==objs(prosigue)
                                        Recopilacion{recorrer,1}=objs_min;
                                    end
                                end
                            end


                        end
                        Recopilacion{ocont,2}=N_corte;
                        Recopilacion{ocont,3}=ind_obj(i);
                        Recopilacion{ocont,4}=Area(i);
                        Recopilacion{ocont,5}=pos_obj{i};
                        Recopilacion{ocont,6}=PERIMETRO{i};
                    elseif repe==0
                        ocont=ocont+1;
                        Recopilacion{ocont,1}=max(cell2mat({Recopilacion{:,1}}))+1;
                        Recopilacion{ocont,2}=N_corte;
                        Recopilacion{ocont,3}=ind_obj(i);
                        Recopilacion{ocont,4}=Area(i);
                        Recopilacion{ocont,5}=pos_obj{i};
                        Recopilacion{ocont,6}=PERIMETRO{i};
                    end
                else
                    ocont=ocont+1;
                    Recopilacion{ocont,1}=ind_obj(i); %indice del objeto
                    Recopilacion{ocont,2}=N_corte;
                    Recopilacion{ocont,3}=ind_obj(i);
                    Recopilacion{ocont,4}=Area(i);
                    Recopilacion{ocont,5}=pos_obj{i};
                    Recopilacion{ocont,6}=PERIMETRO{i};
                    objeto_primer=0;
                end
            end
        elseif N_corte==1
            objeto_primer=1;

        end

    end
    Matriz_resultado=sortrows(Recopilacion,[1 2]); %PARA ORDENAR LAS CELDAS ATENDIENDO AL OBJETO Y AL CORTE
    %Renumeramos los objetos

    objeto=1;
    cambio=0;
    Med=size(Matriz_resultado,1);
    for x=1:Med-1
        if  Matriz_resultado{x,1}~=Matriz_resultado{x+1,1}
            cambio=1;
        end
        Matriz_resultado{x,1}=objeto;
        if cambio==1
            objeto=objeto+1;
            cambio=0;
        end
    end
    Matriz_resultado{Med,1}=objeto;

    %Calculamos perimetro de cada objeto en cada corte
    n_obj=length(unique(cell2mat(Matriz_resultado(:,1))));
    n_datos=length(cell2mat(Matriz_resultado(:,1)));
    for fragmento=1:n_datos
        mask=zeros(rect(4)+1,rect(3)+1);
        coords=Matriz_resultado{fragmento,5};
        for i=1:size(coords,1)
            mask(coords(i,2),coords(i,1))=1;
        end
        mask=logical(mask);
        se = strel('diamond',1);
        maskD=imdilate(mask,se);
        Perimetro = regionprops(maskD, 'Perimeter');
        Perimetro = struct2cell(Perimetro);
        Perimetro = cell2mat(Perimetro);
        Matriz_resultado{fragmento,7}=Perimetro;
    end


    nameFileSplitted = strsplit(nameFile, '\');
    nameFileSplittedNoExtension = strsplit(nameFileSplitted{end}, '.');
    nameFileSplittedNoExtension = nameFileSplittedNoExtension{1};
    directory = strcat(nameFileSplitted{1}, '\segmentation\', nameFileSplitted{3}, '\', nameFileSplittedNoExtension);
    
    fichero=strcat(directory, '\segmentacion_ch_', canal,'-Cell_', numCell);
    save (fichero,'mascara_validatoria','proyeccionb','proyb_rect','proy_bin_azul','mask_Hetero','Matriz_resultado','masc_celulas','Bordes','BWcell')
end