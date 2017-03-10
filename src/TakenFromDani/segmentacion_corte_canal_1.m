function [Diapositiva,celulanovalida]=segmentacion_corte_canal_1(nameFile, canal, numCell, rect, Diapositiva)
%% Segmentacion por cortes y por celula del canal 1
%Para ejecutar este codigo primero hay que ejecutar
%segmentacion_cortes_canal_2

%% load data
load(nameFile);

nameFileSplitted = strsplit(nameFile, '\');
nameFileSplittedNoExtension = strsplit(nameFileSplitted{end}, '.');
nameFileSplittedNoExtension = nameFileSplittedNoExtension{1};
directory = strcat(nameFileSplitted{1}, '\segmentation\', nameFileSplitted{3}, '\', nameFileSplittedNoExtension);
fichero=strcat(directory, '\segmentacion_ch_', num2str(canal+1),'-Cell_', numCell);
load(fichero);

proyb=proyeccionb;
im=imagesOfSerieByChannel;
Long=length(im);
proyb=proyeccionb;
BWcelulas=masc_celulas;
pl=imagesOfSerieByChannel(:, canal+1);
recorte=rect;


canal=num2str(canal);

%% Proyeccion de todos los planos
proyecciong=pl{1};
for k=1:Long-1
    maximo = max(proyecciong,pl{1+k});
    proyecciong=maximo;
end
%figure, imshow(proyecciong),title('Proyeccion de todo los planos')
proyg=proyecciong;

% Recorte de la proteccion de la capa verde de la celula
proyg_rect1=imcrop(proyg,recorte);
proyg_rect1=proyg_rect1.*mascara_validatoria;
%figure, imshow(proyg_rect),title('Proyeccion del recorte')
h=fspecial('gaussian',[7 7], 1.5);
proyg_rect=imfilter(proyg_rect1,h);

% Binarizamos la imagen
umbral=graythresh(proyg_rect);
BW=im2bw(proyg_rect,umbral);
%figure, imshow(BW),title('Binarizamos la imagen')

% Eliminacion de objetos formados por 4 pixeles o menos
aux=bwareaopen(BW,4);
%figure,imshow(aux);title('Eliminacion de objetos formados por 4 pixeles o menos')

% Suavizamos contornos y rompemos conexiones debiles
h=strel('diamond',1);
aux=imopen(aux,h);
%figure,imshow(aux);title('Suavizamos contornos y rompemos conexiones debiles')

% Rellenamos huecos
aux=imfill(aux,'holes');
mascara=aux;
proy_bin=aux;
%figure,imshow(aux);title('Rellenamos los huecos verdes')

% Buscamos todos los picos sobre la imagen recortada
lo=logical(aux);
L = bwlabel(aux);
ind=unique(L);
ind=ind(2:end);
pix = regionprops(lo, 'PixelList');
pix = struct2cell(pix);
M_G = regionprops(lo, proyg_rect, 'MeanIntensity'); % centroides de G de las zonas conexas
M_G = struct2cell(M_G);
M_G = cell2mat(M_G);

h=fspecial('gaussian',[30 30], 0.5);
proyg_rect_suv=imfilter(proyg_rect,h);
celulanovalida=0;
picos=zeros(recorte(4)+1,recorte(3)+1);
for i=1:length(ind)
    for j=1:size(pix{1,i},1)
        fil=pix{1,i}(j,2);
        col=pix{1,i}(j,1);
        intmax=proyg_rect_suv(fil,col);
        if fil~=1 && fil~=recorte(4) && col~=1 && col~=recorte(3)
            if (proyg_rect_suv(fil-1,col-1)<=intmax && proyg_rect_suv(fil-1,col)<=intmax && proyg_rect_suv(fil-1,col+1)<=intmax && proyg_rect_suv(fil,col-1)<=intmax && proyg_rect_suv(fil,col+1)<=intmax && proyg_rect_suv(fil+1,col-1)<=intmax && proyg_rect_suv(fil+1,col)<=intmax && proyg_rect_suv(fil+1,col+1)<=intmax && intmax>=M_G(1,i))
                picos(fil,col)=1;
            end
        else
            celulanovalida=1;
            close all
            string=strcat('Alerta : Celula-',numCell,' no valida');
            disp(string)
            break
        end
        
    end
    if celulanovalida==1
        break
    end
    
end
if celulanovalida==0
    picos_proy=picos;
    %figure,imshow(picos_proy);title('picos de gH2AX')
    
    %Representaciones
    proy_bin1=proy_bin;
    proy_bin(picos_proy==1)=0;
    
    PR=zeros(recorte(4)+1,recorte(3)+1);
    PG=PR;
    PB=PG;
    PR(proy_bin==1)=1;
    PG(proy_bin1==1)=1;
    PB(proy_bin==1)=1;
    
    MSK_proy_bin=cat(3,PR,PG,PB);
    figure;subplot(1,2,1),imshow(proyg_rect1);title('Proyeccion del plano verde')
    subplot(1,2,2),imshow(MSK_proy_bin);title('Picos de gH2AX sobre proyeccion binarizada')
    
    %%%BORRAR EN CUANTO TERMINE %%%%%%
    
    P=proy_bin_azul;
    P1=proy_bin_azul;
    P(picos_proy==1)=1;
    PR=zeros(recorte(4)+1,recorte(3)+1);
    PG=PR;
    PB=PG;
    PR(P1==1)=1;
    PG(P==1)=1;
    PB(P1==1)=1;
    MSK_P=cat(3,PR,PG,PB);
    % figure,subplot(1,2,2);imshow(MSK_P);title('Picos de gH2AX sobre proyeccion binarizada azul')
    % subplot(1,2,1);imshow(proyb_rect);title('Proyeccion del plano azul')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fileNameNoExtension = strsplit(nameFileSplitted{end}, '.');
    stringres=strcat(directory, '\Proyeccion_General_Plano-verde', fileNameNoExtension{1} , '_cell_' , num2str(numCell), '.tiff');
    
    Diapositiva=Diapositiva+1;
    Diapositivach=num2str(Diapositiva);
    numeracion=strcat('-f',Diapositivach);
    print(numeracion,'-dtiff',stringres)
    
    aux1=zeros(recorte(4)+1,recorte(3)+1);
    
    for corte=1:Long
        capa=imcrop(pl{corte},rect);
        capa=capa .* mascara_validatoria;
        h=fspecial('gaussian',[7 7], 1.5);
        capa=imfilter(capa,h);
        capa=capa.*mascara;
        umbral(corte)=graythresh(capa);
    end
    % figure;plot(1:Long,umbral)
    umbral_fin=findpeaks(umbral,'SORTSTR','descend')
    umbral_fin=umbral_fin(umbral_fin > (max(umbral_fin) * 0.7));
    
    umbral_fin = min(umbral_fin)*1.2;

    
    
    for corte=1:Long
        % Recorte de la celula
        capa=imcrop(pl{corte},recorte);
        capa=capa.*mascara_validatoria;
        h=fspecial('gaussian',[7 7], 1.5);
        capa=imfilter(capa,h);
        capa=capa.*mascara;
        
        % Binarizamos la imagen

        BW=im2bw(capa,umbral_fin);
        %figure, imshow(BW),title('Binarizamos la imagen')
        
        % Eliminacion de objetos formados por 4 pixeles o menos
        aux=bwareaopen(BW,4);
        %figure,imshow(aux);title('Eliminacion de objetos formados por 4 pixeles o menos')
        
        % Suavizamos contornos y rompemos conexiones debiles
        h=strel('diamond',1);
        aux=imopen(aux,h);
        %figure,imshow(aux);title('Suavizamos contornos y rompemos conexiones debiles')
        
        % Rellenamos huecos
        aux=imfill(aux,'holes');
        mask=aux;
        %figure,imshow(aux);title('Rellenamos los huecos')
        
        mask1=mask;
        mask(picos_proy==1)=0;
        aux1=aux1+aux;
        
        PR=zeros(recorte(4)+1,recorte(3)+1);
        PG=PR;
        PB=PG;
        PR(mask1==1)=1;
        PG(mask==1)=1;
        PB(mask==1)=1;
        
        MSK=cat(3,PR,PG,PB);
        
        
        
        %Representaciones
        %             titulo=strcat('Picos de gH2AX sobre mascara en corte -', num2str(corte));
        %             figure;subplot(1,2,1),imshow(capa)
        %             subplot(1,2,2),imshow(MSK);title(titulo)
        %
        mask_fosi{1,corte}=aux;
        mask_fosi_pico{1,corte}=MSK;
        
    end
    
    %figure;imshow(aux1)
    
    % Eliminamos puntos adquiridos como picos de focis que no se encuentren
    % sobre ningun objeto de la imagen proyeccion de las distintas capas
    % segmentadas
    mask=aux1;
    %figure;imshow(picos_proy);title('antes')
    picos_proy(mask==0)=0;
    % figure;imshow(picos_proy);title('despues')
    
    PR=zeros(recorte(4)+1,recorte(3)+1);
    PR=PR+mask;
    PG=PR;
    PB=PG;
    
    PR(picos_proy==1)=1;
    PG(picos_proy==1)=0;
    PB(picos_proy==1)=0;
    
    MSK_general=cat(3,PR,PG,PB);
    
    %Representaciones
    %figure,imshow(MSK_general);title('Picos de gH2AX sobre mascara general')
    
    %Numeramos picos de la proyeccion
    picos_num = bwlabel(picos_proy);
    ind_picos=unique(picos_num);
    ind_picos=ind_picos(2:end);
    pos_seed = regionprops(picos_num, 'PixelList');
    pos_seed = struct2cell(pos_seed);
    objeto_primer=0;
    ocont=0;
    for N_corte=1:Long
        
        obj_num = bwlabel(mask_fosi{1,N_corte});
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
                
                peak=0;
                for j=1:length(ind_picos)
                    [p]=pos_seed{1,j};
                    if obj_num(p(1,2),p(1,1))==i
                        peak(1,col)=j;
                        col=col+1;
                    end
                    
                end
                
                
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
                        Recopilacion{ocont,3}=Area(i);
                        Recopilacion{ocont,4}=peak;
                        Recopilacion{ocont,5}=pos_obj{i};
                        Recopilacion{ocont,11}=PERIMETRO{i};
                    elseif repe==0
                        ocont=ocont+1;
                        Recopilacion{ocont,1}=max(cell2mat({Recopilacion{:,1}}))+1;
                        Recopilacion{ocont,2}=N_corte;
                        Recopilacion{ocont,3}=Area(i);
                        Recopilacion{ocont,4}=peak;
                        Recopilacion{ocont,5}=pos_obj{i};
                        Recopilacion{ocont,11}=PERIMETRO{i};
                    end
                else
                    ocont=ocont+1;
                    Recopilacion{ocont,1}=ind_obj(i); %indice del objeto
                    Recopilacion{ocont,2}=N_corte;
                    Recopilacion{ocont,3}=Area(i);
                    Recopilacion{ocont,4}=peak;
                    Recopilacion{ocont,5}=pos_obj{i};
                    Recopilacion{ocont,11}=PERIMETRO{i};
                    objeto_primer=0;
                end
            end
        elseif N_corte==1
            objeto_primer=1;
            
        end
    end
    Recopilacion_ord=sortrows(Recopilacion,[1 2]); %PARA ORDENAR LAS CELDAS ATENDIENDO AL OBJETO Y AL CORTE
    
    % Eliminamos todos los objetos que en ninguna de sus capas tengan un pico
    Nobj=unique(cell2mat({Recopilacion_ord{:,1}}));
    tam=length(Nobj);
    datos=cell2mat({Recopilacion_ord{:,1}});
    for x=1:tam
        valido=0;
        indices=find(Nobj(x)==datos);
        for y=1:length(indices)
            comp= find(cell2mat({Recopilacion_ord{indices(y),4}})==0);
            if isempty(comp)==1
                valido=1;
            end
        end
        if valido==0
            
            for i=indices(1):indices(end)
                Recopilacion_ord{i,1}=[];
                Recopilacion_ord{i,2}=[];
                Recopilacion_ord{i,3}=[];
                Recopilacion_ord{i,4}=[];
                Recopilacion_ord{i,5}=[];
                Recopilacion_ord{i,11}=[];
            end
        end
    end
    
    %Reordenamos objetos de la matriz
    Med=size(Recopilacion_ord,1);
    Ult_Numero=0;
    %Matriz_resultado=cell(1,1);
    clear Matriz_resultado
    for x=1:Med
        Numero=Recopilacion_ord{x,1};
        if isempty(Numero)==0
            
            Matriz_resultado{Ult_Numero+1,1}=Recopilacion_ord{x,1};
            Matriz_resultado{Ult_Numero+1,2}=Recopilacion_ord{x,2};
            Matriz_resultado{Ult_Numero+1,3}=Recopilacion_ord{x,3};
            Matriz_resultado{Ult_Numero+1,4}=Recopilacion_ord{x,4};
            Matriz_resultado{Ult_Numero+1,5}=Recopilacion_ord{x,5};
            Matriz_resultado{Ult_Numero+1,11}=Recopilacion_ord{x,11};
            Ult_Numero=Ult_Numero+1;
        end
        
    end
    
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
    
    fichero=strcat(directory, '\segmentacion_ch_', canal,'-Cell_', numCell);
    save (fichero,'mascara_validatoria','proyeccionb','proy_bin_azul','masc_celulas','proyecciong','mask_fosi','mask_fosi_pico','MSK_general','Matriz_resultado','pos_seed','Bordes','BWcell','picos_proy')
    
end
    
end
