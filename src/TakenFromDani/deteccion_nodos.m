function deteccion_nodos(nameFile, canal, cell, rect)

%% Deteccion de nodos dentro de objetos en plano verde
nameFileSplitted = strsplit(nameFile, '\');
nameFileSplittedNoExtension = strsplit(nameFileSplitted{end}, '.');
nameFileSplittedNoExtension = nameFileSplittedNoExtension{1};
directory = strcat(nameFileSplitted{1}, '\segmentation\', nameFileSplitted{3}, '\', nameFileSplittedNoExtension);
fichero=strcat(directory, '\segmentacion_ch_', num2str(canal) ,'-Cell_', cell, '.mat');
load(fichero);

if Matriz_resultado{1,1}~=0
    n_obj=length(unique(cell2mat(Matriz_resultado(:,1))));
    n_datos=length(cell2mat(Matriz_resultado(:,1)));
    datos=cell2mat(Matriz_resultado(:,1));
    n_corte_obj=zeros(1,n_obj);
    %MSK_T=zeros(rect(4)+1,rect(3)+1);
    for fragmento=1:n_datos
        % obtenemos una representacion de cada objeto en los distintos cortes
        mask=zeros(rect(4)+1,rect(3)+1);
        coords=Matriz_resultado{fragmento,5};
        for i=1:size(coords,1)
            mask(coords(i,2),coords(i,1))=1;
        end
        mask=logical(mask);
        %MSK_T=MSK_T+mask;
        % obtenemos una medida de la redondez
        se = strel('diamond',1);
        maskD=imdilate(mask,se);
        
        Area = regionprops(mask, 'Area');
        Area = struct2cell(Area);
        Area = cell2mat(Area);
        
        Perimetro = regionprops(maskD, 'Perimeter');
        Perimetro = struct2cell(Perimetro);
        Perimetro = cell2mat(Perimetro);
        
        Redondez= (4*pi*Area)/(Perimetro^2);
        Matriz_resultado{fragmento,6}=Redondez;
        Matriz_resultado{fragmento,10}=Perimetro;
        %     % Comprobacion
        %     picos_proy1=picos_proy;
        %     picos_proy1(mask==0)=0;
        %     %figure;imshow(picos_proy)
        %
        %     PR=zeros(rect(4)+1,rect(3)+1);
        %     PR=PR+mask;
        %     PG=PR;
        %     PB=PG;
        %
        %     PR(picos_proy1==1)=0;
        %     PG(picos_proy1==1)=1;
        %     PB(picos_proy1==1)=0;
        %
        %     MSK_general=cat(3,PR,PG,PB);
        %
        %     %Representaciones
        %     figure,imshow(MSK_general);title('Picos de gH2AX sobre mascara general')
    end
    
    
    % % Comprobacion II
    %     picos_proy1=picos_proy;
    %     picos_proy1(MSK_T==0)=0;
    %     %figure;imshow(picos_proy)
    %
    %     PR=zeros(rect(4)+1,rect(3)+1);
    %     PR=PR+MSK_T;
    %     PG=PR;
    %     PB=PG;
    %
    %     PR(picos_proy1==1)=0;
    %     PG(picos_proy1==1)=1;
    %     PB(picos_proy1==1)=0;
    %
    %     MSK_Tl=cat(3,PR,PG,PB);
    %     figure;imshow(MSK_Tl)
    % ma=imcrop(proyecciong,rect);
    % figure,imshow(ma)
    
    
    
    umbral_area=40;
    umbral_redond=0.5;
    for objeto=1:n_obj
        ini=0;
        anchura=0;
        for fragmento=1:n_datos
            if Matriz_resultado{fragmento,1}==objeto
                if ini==0
                    ini=1;
                    anchura=anchura+1;
                    ini_corte(objeto,1)=Matriz_resultado{fragmento,2};
                    ini_corte(objeto,2)=fragmento;
                else
                    anchura=anchura+1;
                end
                if Matriz_resultado{fragmento,3}>=umbral_area
                    Matriz_resultado{fragmento,7}=1;
                    if Matriz_resultado{fragmento,6}>=umbral_redond
                        Matriz_resultado{fragmento,8}=1;
                    else
                        Matriz_resultado{fragmento,8}=0;
                    end
                else
                    Matriz_resultado{fragmento,7}=0;
                end
            end
        end
        ini_corte(objeto,3)=anchura;
    end
    %% Recordatorio  de formacion de matriz _resultado
    % Matriz_resultado=[ objeto - corte - area - picos - pixeles - redondez -
    % objeto pequeño/grande - objeto no redondo/redondo - datos no validos/validos para deteccion de nodo]
    
    % Primera criba
    for objeto=1:n_obj
        for fragmento=ini_corte(objeto,2):ini_corte(objeto,2)+ini_corte(objeto,3)-1
            datos=size(Matriz_resultado{fragmento,4},2);
            if datos>1
                multiple(fragmento,1)=1;
            else
                multiple(fragmento,1)=0;
                for comprobacion=ini_corte(objeto,2):ini_corte(objeto,2)+ini_corte(objeto,3)-1
                    if fragmento~=comprobacion
                        coinciden=find(Matriz_resultado{comprobacion,4}==Matriz_resultado{fragmento,4});
                        if isempty(coinciden)==0 && size(Matriz_resultado{comprobacion,4},2)>1
                            Matriz_resultado{fragmento,9}=0; % fragmentos no validos para deteccion de nodo
                        end
                    end
                end
                if Matriz_resultado{fragmento,4}==0
                    Matriz_resultado{fragmento,9}=0;
                end
            end
            if isempty(Matriz_resultado{fragmento,8})==1
                aux=fragmento;
                activa_no_validos=0;
                for objeto2=1:n_obj
                    for fragmento2=ini_corte(objeto,2):ini_corte(objeto,2)+ini_corte(objeto,3)-1
                        coinciden=0;
                        for k=1:length(Matriz_resultado{fragmento,4})
                            if isempty( find(Matriz_resultado{fragmento2,4}==Matriz_resultado{fragmento,4}(1,k)))==0
                                coinciden=1;
                            end
                        end
                        if coinciden==1 && isempty(Matriz_resultado{fragmento2,8})==1
                            aux=[aux fragmento2];
                        elseif coinciden==1 && isempty(Matriz_resultado{fragmento2,8})==0
                            activa_no_validos=1;       %Ponemos como no valido todas las
                            %direcciones contenidas en aux
                        end
                    end
                end
                if activa_no_validos==1
                    for x=1:length(aux)
                        Matriz_resultado{aux(x),9}=0;
                    end
                end
            end
        end
    end
    %% Obtenemos matriz nodo que tendra la siguiente forma
    % Nodo= [ objeto  - Pico de ese objeto - capas en la que aparece el pico - Redondez media -borde del objeto ]
    cont=1;
    for objeto=1:n_obj
        general=0;
        for fragmento=ini_corte(objeto,2):ini_corte(objeto,2)+ini_corte(objeto,3)-1
            if isempty(Matriz_resultado{fragmento,9})==1
                coinci=find(general==fragmento);
                if isempty(coinci)==1
                    nodo{cont,1}=objeto;
                    peak=Matriz_resultado{fragmento,4};
                    capa=fragmento;
                    cont2=2;
                    for comp_obj=1:n_obj
                        for contador=ini_corte(comp_obj,2):ini_corte(comp_obj,2)+ini_corte(comp_obj,3)-1
                            if  fragmento~=contador && length(peak)==length(Matriz_resultado{contador,4}) && isempty(Matriz_resultado{contador,9})==1
                                if logical(prod(double(Matriz_resultado{contador,4}==peak)))==1
                                    capa(1,cont2)=contador;
                                    cont2=cont2+1;
                                end
                            end
                            
                        end
                    end
                    general=[general capa];
                    general=sort(general);
                    nodo{cont,1}=objeto;
                    nodo{cont,2}=Matriz_resultado{fragmento,4};
                    nodo{cont,3}=sort(capa);
                    cont=cont+1;
                end
            end
        end
    end
    
    % Añadimos el valor medio de la redondez a la matriz nodo
    tam_mat_nodo=size(nodo,1);
    
    for i=1:tam_mat_nodo
        tam_mat_capa=size(nodo{i,3},2);
        med_redon=zeros(1,tam_mat_capa);
        for j=1:tam_mat_capa
            med_redon(1,j)=Matriz_resultado{ nodo{i,3}(1,j),6};
        end
        nodo{i,4}=mean(med_redon);
    end
    
    
    %%  Extraemos nodos finales a partir de los datos recopilados en la tabla nodo
    
    tam_mat_nodo=size(nodo,1);
    fila=1;
    coinciden=0;
    for i_actual=1:tam_mat_nodo;
        aux=nodo{i_actual,2};
        if length(nodo{i_actual,2})==1
            nodo_final{fila,1}=nodo{i_actual,1};
            nodo_final{fila,2}=nodo{i_actual,2};
            fila=fila+1;
        elseif nodo{i_actual,4}>=umbral_redond
            max1=length(nodo{i_actual,2});
            for k=1:max1
                for j_recorre=1:fila-1
                    rep= find(nodo_final{j_recorre,2}==nodo{i_actual,2}(1,k));
                    if isempty(rep)==0
                        coinciden=1;
                        momento=j_recorre;
                    end
                end
            end
            if coinciden==0
                nodo_final{fila,1}=nodo{i_actual,1};
                nodo_final{fila,2}=nodo{i_actual,2};
                fila=fila+1;
            elseif  length(nodo_final{momento,2})< length(nodo{i_actual,2})
                nodo_final{momento,2}=sort(unique([nodo_final{momento,2} nodo{i_actual,2}]));
            end
            coinciden=0;
        else
            max1=length(nodo{i_actual,2});
            for k=1:max1
                for j_recorre=1:fila-1
                    rep= find(nodo_final{j_recorre,2}==nodo{i_actual,2}(1,k));
                    if isempty(rep)==0
                        aux=aux(find(nodo{i_actual,2}(1,k)~=aux));
                        coinciden=1;
                        momento=j_recorre;
                    end
                end
            end
            if coinciden==0
                for k=1:max1
                    nodo_final{fila,1}=nodo{i_actual,1};
                    nodo_final{fila,2}=nodo{i_actual,2}(1,k);
                    fila=fila+1;
                end
            else
                if isempty(aux)== 0
                    nodo_final{fila,1}=nodo{i_actual,1};
                    nodo_final{fila,2}=aux;
                    fila=fila+1;
                end
            end
            coinciden=0;
        end
    end
    pos_seed=cell2mat(pos_seed');
    for i=1:size(nodo_final,1)
        varx=zeros(1,length(nodo_final{i,2}));
        vary=zeros(1,length(nodo_final{i,2}));
        for k=1:length(nodo_final{i,2})
            varx(k)=pos_seed(nodo_final{i,2}(1,k),1);
            vary(k)=pos_seed(nodo_final{i,2}(1,k),2);
        end
        nodo_x(i,1)=mean(varx);
        nodo_y(i,1)=mean(vary);
        nodo_final{i,3}=[nodo_x(i,1) nodo_y(i,1)];
    end
    
    %Reordenamos nodo final para eliminar posibles nodos repetidos
    %Este caso se da cuando se detecta un objeto, deja de detectarse y vuelve a
    %detectarse posteriormente.
    
    fila=1;
    aux=nodo_final(1,:);
    for i=2:size(nodo_final,1)
        coincidencia=0;
        for j=1:i-1
            if length(nodo_final{i,2})==length(nodo_final{j,2})
                if nodo_final{i,2}==nodo_final{j,2}
                    coincidencia=1;
                end
            end
        end
        if coincidencia==0
            aux(fila+1,:)=nodo_final(i,:);
            fila=fila+1;
        end
    end
    nodo_final=aux;
    aux{1,1}=1;
    num=2;
    for i=2:size(aux,1)
        if aux{i,1}==aux{i-1,1}
            nodo_final{i,1}=nodo_final{i-1,1};
        else
            nodo_final{i,1}=num;
            num=num+1;
        end
    end
else
    nodo_final{1,1}=0;
end

fichero=strcat(directory, '\Deteccion_de_nodos_ch_',num2str(canal),'-Cell_',cell);
save (fichero,'Matriz_resultado','pos_seed','masc_celulas','mascara_validatoria','Bordes','BWcell','picos_proy','nodo_final')
end