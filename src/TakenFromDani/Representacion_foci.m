function Diapositiva=Representacion_foci(nameFile, cell, rect, Diapositiva)

%% DATOS DEL PLANO VERDE
canal=num2str(0);

load(nameFile);

N_cortes = size(imagesOfSerieByChannel, 1);
nameFileSplitted = strsplit(nameFile, '\');
nameFileSplittedNoExtension = strsplit(nameFileSplitted{end}, '.');
nameFileSplittedNoExtension = nameFileSplittedNoExtension{1};
directory = strcat(nameFileSplitted{1}, '\segmentation\', nameFileSplitted{3}, '\', nameFileSplittedNoExtension);
fichero=strcat(directory, '\Deteccion_de_nodos_ch_',num2str(canal),'-Cell_',cell);
load(fichero);

% Datos de medida de la imagen
Tam_imagen_pix_x=1024; %pixeles
Tam_imagen_pix_y=1024; %pixeles
Tam_imagen_um_x=82.01; %umetro
Tam_imagen_um_y=82.01; %umetro
Height_recor=rect(4); %pixeles


Tam_imagen_um_z=0.21*N_cortes; %umetro

% Pasamos las medidas de picos de foci de pixeles a micrometro

Rel_dist_x=Tam_imagen_um_x/Tam_imagen_pix_x;
Rel_dist_y=Tam_imagen_um_y/Tam_imagen_pix_y;
Rel_dist_z=Tam_imagen_um_z/N_cortes;



% pos_seed=pos_seed';
% pos_seed=cell2mat(pos_seed);
eje_x_green=pos_seed(:,1)*Rel_dist_x;
eje_y_green=pos_seed(:,2)*Rel_dist_y;
eje_z_green=zeros(size(eje_x_green,1),1);
Tam_imagen_rect_um_y=Height_recor*Rel_dist_y;


%% Introducimos componente z
%Vemos el numero de objetos detectados
Objetos=unique(cell2mat(Matriz_resultado(:,1)));
recorre=size(Matriz_resultado,1);
%Asignamos a cada objeto el numero de picos asociados
for i=1:length(Objetos)
    nuevo=1;
    for j=1:recorre
        if Matriz_resultado{j,1}==i
            tam=size(Matriz_resultado{j,4},2);
            picos{i,1}(1,nuevo:nuevo-1+tam)=Matriz_resultado{j,4};
            nuevo=nuevo+tam;
        end
    end
    picos{i,1}=sort(unique(picos{i,1}'));
    picos{i,1}=picos{i,1}(picos{i,1}~=0);
end

% A cada pico se asigna corte primero y numero corte total
primera_vez=0;
cuenta=0;

for i=1:length(Objetos)
    npicos=length(picos{i,1});
    for j=1:npicos
        ind_pico=picos{i,1}(j,1);
        for k=1:recorre
            coin=find(Matriz_resultado{k,4}==ind_pico);
            if isempty(coin)==0
                if Matriz_resultado{k,1}==i
                    if primera_vez==0
                        primera_vez=1;
                        picos{i,1}(j,2)=Matriz_resultado{k,2};
                    end
                    cuenta=cuenta+1;
                end
                
            end
        end
        picos{i,1}(j,3)=cuenta;
        cuenta=0;
        primera_vez=0;
    end
end

%Recopilamos picos , para que no se repitan
fila=1;
aux=picos(1,1);
obj_del_2=0;

for i=2:size(picos,1)
    coincidencia=0;
    for j=1:length(aux)
        if size(picos{i,1},1)==size(aux{j,1},1)
            if picos{i,1}(:,1)==aux{j,1}(:,1)
                coincidencia=1;
                moment=j;
            end
        end
    end
    if coincidencia==0
        aux(fila+1,:)=picos(i,1);
        fila=fila+1;
    elseif picos{i,1}(:,2)-aux{moment,1}(:,2)<=2
        aux{moment,1}(:,3)=picos{i,1}(:,3)+aux{moment,1}(:,3)+1;
        obj_detec=0;
        for ll=1:size(picos,1)
            if picos{ll,1}(:,1)==aux{moment,1}(:,1)
                if obj_detec==0
                    obj_del_2=ll;
                    obj_detec=1;
                end
            end
        end
        obj_del=i; % Objeto a eliminar
        for corre=1:size(Matriz_resultado,1)
            if Matriz_resultado{corre,1}==obj_del
                Matriz_resultado{corre,1}=obj_del_2;
            end
        end
        
    else
        if picos{i,1}(:,3)>=3 && aux{moment,1}(:,3)<3
            aux{moment,1}= picos{i,1};
            obj_detec=0;
            for ll=1:size(picos,1)
                if picos{ll,1}(:,1)==aux{moment,1}(:,1)
                    if obj_detec==0
                        obj_del_2=ll;
                        obj_detec=1;
                    end
                end
            end
            obj_del=i; % Objeto a eliminar
            aux_mr=Matriz_resultado;
            count=0;
            for corre=1:size(Matriz_resultado,1)
                if  obj_del_2==Matriz_resultado{corre,1}
                    aux_mr(corre-count,:)=[];
                    count=count+1;
                end
            end
            Matriz_resultado=aux_mr;
            for corre=1:size(Matriz_resultado,1)
                if Matriz_resultado{corre,1}==obj_del
                    Matriz_resultado{corre,1}=obj_del_2;
                end
            end
            
        elseif picos{i,1}(:,3)<3 && aux{moment,1}(:,3)>=3
            aux{moment,1}=aux{moment,1}; %Se queda igual
            obj_del=i; % Objeto a eliminar
            aux_mr=Matriz_resultado;
            count=0;
            for corre=1:size(Matriz_resultado,1)
                if obj_del==Matriz_resultado{corre,1}
                    aux_mr(corre-count,:)=[];
                    count=count+1;
                end
            end
            Matriz_resultado=aux_mr;
        elseif picos{i,1}(:,3)>=3 && aux{moment,1}(:,3)>=3
            aux(fila+1,:)=picos(i,1);
            fila=fila+1;
        elseif picos{i,1}(:,3)<3 && aux{moment,1}(:,3)<3
            obj_detec=0;
            for ll=1:size(picos,1)
                if picos{ll,1}(:,1)==aux{moment,1}(:,1)
                    if obj_detec==0
                        obj_del_2=ll;
                        obj_detec=1;
                    end
                end
            end
            for counter=moment+1:size(aux,1)
                aux{counter-1}=aux{counter};
            end
            aux(end)=[];
            fila=fila-1;
            
            
            %%Reorganizamos Matriz resultado eliminando todos los objetos
            %%que contengan ese pico
            obj_del=i; % Objeto a eliminar
            aux_mr=Matriz_resultado;
            count=0;
            for corre=1:size(Matriz_resultado,1)
                if obj_del==Matriz_resultado{corre,1} || obj_del_2==Matriz_resultado{corre,1}
                    aux_mr(corre-count,:)=[];
                    count=count+1;
                end
            end
            Matriz_resultado=aux_mr;
        end
    end
end
Matriz_resultado=sortrows(Matriz_resultado,[1]);
%Renumeramos matriz resultado en orden ascendente
numera=1;
Matriz_resultado{1,1}=1;
aux_mat=Matriz_resultado;
for corre=2:size(Matriz_resultado,1)
    if Matriz_resultado{corre,1}==Matriz_resultado{corre-1,1}
        aux_mat{corre,1}=numera;
    else
        numera=numera+1;
        aux_mat{corre,1}=numera;
        
    end
end
Matriz_resultadov=aux_mat;
picos=aux;
picosv=picos;
%Asignamos altura z a cada pico en micrometro

for i=1:size(picos,1)
    npicos=size(picos{i,1},1);
    for j=1:npicos
        dist_ini=(picos{i,1}(j,2)-1)*Rel_dist_z;
        dist=dist_ini+((picos{i,1}(j,3)/2)*Rel_dist_z);
        eje_z_green(picos{i,1}(j,1),1)=dist;
    end
end




%% Calculamos bordes azules

%ajustamos los bordes al centro del pixel
borde_primero=1;
deja_de_escribir=0;
Begin=0;
for i=1:N_cortes
    if deja_de_escribir==0
        if isempty(Bordes{i,1}) == 0
            if length(Bordes{i,1})==1
                if borde_primero==1
                    Begin=i;
                    borde_primero=0;
                end
                Borde{i,1}(1,1)=ceil(Bordes{i,1}{1,1}(1,1));
                Borde{i,1}(1,2)=ceil(Bordes{i,1}{1,1}(1,2));
                Borde{i,1}(2,1)=floor(Bordes{i,1}{1,1}(2,1));
                Borde{i,1}(2,2)=ceil(Bordes{i,1}{1,1}(2,2));
                Borde{i,1}(3,1)=floor(Bordes{i,1}{1,1}(3,1));
                Borde{i,1}(3,2)=ceil(Bordes{i,1}{1,1}(3,2));
                Borde{i,1}(4,1)=floor(Bordes{i,1}{1,1}(4,1));
                Borde{i,1}(4,2)=floor(Bordes{i,1}{1,1}(4,2));
                Borde{i,1}(5,1)=floor(Bordes{i,1}{1,1}(5,1));
                Borde{i,1}(5,2)=floor(Bordes{i,1}{1,1}(5,2));
                Borde{i,1}(6,1)=ceil(Bordes{i,1}{1,1}(6,1));
                Borde{i,1}(6,2)=floor(Bordes{i,1}{1,1}(6,2));
                Borde{i,1}(7,1)=ceil(Bordes{i,1}{1,1}(7,1));
                Borde{i,1}(7,2)=floor(Bordes{i,1}{1,1}(7,2));
                Borde{i,1}(8,1)=ceil(Bordes{i,1}{1,1}(8,1));
                Borde{i,1}(8,2)=ceil(Bordes{i,1}{1,1}(8,2));
                Extremos{i,1}(1,:)=mean(Borde{i,1}(1:2,:));   %top
                Extremos{i,1}(2,:)=mean(Borde{i,1}(3:4,:));   %Right
                Extremos{i,1}(3,:)=mean(Borde{i,1}(5:6,:));  %bottom
                Extremos{i,1}(4,:)=mean(Borde{i,1}(7:8,:));   %Left
                puntos_R(i,:)=Extremos{i,1}(2,:);
                puntos_L(i,:)=Extremos{i,1}(4,:);
                puntos_T(i,:)=Extremos{i,1}(1,:);
                puntos_B(i,:)=Extremos{i,1}(3,:);
            else
                top=zeros(1,2);
                right=zeros(1,2);
                bottom=zeros(1,2);
                left=zeros(1,2);
                if borde_primero==1
                    Begin=i;
                    borde_primero=0;
                end
                for j=1:length(Bordes{i,1})
                    Borde{i,1}(1,1)=ceil(Bordes{i,1}{1,j}(1,1));
                    Borde{i,1}(1,2)=ceil(Bordes{i,1}{1,j}(1,2));
                    Borde{i,1}(2,1)=floor(Bordes{i,1}{1,j}(2,1));
                    Borde{i,1}(2,2)=ceil(Bordes{i,1}{1,j}(2,2));
                    Borde{i,1}(3,1)=floor(Bordes{i,1}{1,j}(3,1));
                    Borde{i,1}(3,2)=ceil(Bordes{i,1}{1,j}(3,2));
                    Borde{i,1}(4,1)=floor(Bordes{i,1}{1,j}(4,1));
                    Borde{i,1}(4,2)=floor(Bordes{i,1}{1,j}(4,2));
                    Borde{i,1}(5,1)=floor(Bordes{i,1}{1,j}(5,1));
                    Borde{i,1}(5,2)=floor(Bordes{i,1}{1,j}(5,2));
                    Borde{i,1}(6,1)=ceil(Bordes{i,1}{1,j}(6,1));
                    Borde{i,1}(6,2)=floor(Bordes{i,1}{1,j}(6,2));
                    Borde{i,1}(7,1)=ceil(Bordes{i,1}{1,j}(7,1));
                    Borde{i,1}(7,2)=floor(Bordes{i,1}{1,j}(7,2));
                    Borde{i,1}(8,1)=ceil(Bordes{i,1}{1,j}(8,1));
                    Borde{i,1}(8,2)=ceil(Bordes{i,1}{1,j}(8,2));
                    top(j,:)=mean(Borde{i,1}(1:2,:));   %top
                    right(j,:)=mean(Borde{i,1}(3:4,:)); %Right
                    bottom(j,:)=mean(Borde{i,1}(5:6,:));%bottom
                    left(j,:)=mean(Borde{i,1}(7:8,:));  %Left
                end
                Extremos{i,1}(1,:)=min(top);
                Extremos{i,1}(2,:)=max(right);
                Extremos{i,1}(3,:)=max(bottom);
                Extremos{i,1}(4,:)=min(left);
                puntos_R(i,:)=Extremos{i,1}(2,:);
                puntos_L(i,:)=Extremos{i,1}(4,:);
                puntos_T(i,:)=Extremos{i,1}(1,:);
                puntos_B(i,:)=Extremos{i,1}(3,:);
            end
        elseif borde_primero==0
            deja_de_escribir=1;
        end
    end
end


puntos_R(:,2)=[];
puntos_L(:,2)=[];
puntos_T(:,1)=[];
puntos_B(:,1)=[];
puntos_R=puntos_R*Rel_dist_x;
puntos_L=puntos_L*Rel_dist_x;
puntos_T=puntos_T*Rel_dist_y;
puntos_B=puntos_B*Rel_dist_y;

%% Ordeno puntos para representacion
puntos_R=puntos_R(Begin:end);
puntos_L=puntos_L(Begin:end);
puntos_T=puntos_T(Begin:end);
puntos_B=puntos_B(Begin:end);

% Plano X-Z ( punto mas a la izquierda y mas a la derecha )
planoxz=[puntos_L;flipud(puntos_R)];
maxxz=length(planoxz)/2;

% Plano Y-Z ( punto mas a la izquierda y mas a la derecha )
planoyz=[puntos_T;flipud(puntos_B)];
maxyz=length(planoyz)/2;
planoyz=Height_recor*Rel_dist_y-planoyz;


eje_z_cont=[Begin:maxxz+Begin-1 , maxxz+Begin-1:-1:Begin];
eje_z_cont=(eje_z_cont-1)*Rel_dist_z;

proyblue_rect=imcrop(masc_celulas,rect);
proyblue_rect=proyblue_rect.*mascara_validatoria;
p_proyblue_rect=bwperim(proyblue_rect);
%figure;imshow(p_proyblue_rect)

pos_seed_blue = regionprops(p_proyblue_rect, 'PixelList');
pos_seed_blue = struct2cell(pos_seed_blue);
pos_seed_blue = cell2mat(pos_seed_blue);

eje_x_blue=pos_seed_blue(:,1)*Rel_dist_x;
eje_y_blue=pos_seed_blue(:,2)*Rel_dist_y;

if Matriz_resultado{1,1}~=0
    
    
    %% Introducimos componente z
    %Vemos el numero de objetos detectados
    Objetos=unique(cell2mat(Matriz_resultado(:,1)));
    recorre=size(Matriz_resultado,1);
    
    %Asignamos a cada objeto el numero de picos asociados
    clear picos
    for i=1:length(Objetos)
        nuevo=1;
        for j=1:recorre
            if Matriz_resultado{j,1}==i
                tam=size(Matriz_resultado{j,4},2);
                picos{i,1}(1,nuevo:nuevo-1+tam)=Matriz_resultado{j,4};
                nuevo=nuevo+tam;
            end
        end
        
        
        picos{i,1}=sort(unique(picos{i,1}'));
        picos{i,1}=picos{i,1}(picos{i,1}~=0);
    end
    
    
    
    % A cada pico se asigna corte primero y numero corte total
    primera_vez=0;
    cuenta=0;
    
    for i=1:length(Objetos)
        npicos=length(picos{i,1});
        for j=1:npicos
            ind_pico=picos{i,1}(j,1);
            for k=1:recorre
                coin=find(Matriz_resultado{k,4}==ind_pico);
                if isempty(coin)==0
                    if Matriz_resultado{k,1}==i
                        if primera_vez==0
                            primera_vez=1;
                            picos{i,1}(j,2)=Matriz_resultado{k,2};
                        end
                        cuenta=cuenta+1;
                    end
                    
                end
            end
            picos{i,1}(j,3)=cuenta;
            cuenta=0;
            primera_vez=0;
        end
    end
    
    %Recopilamos picos , para que no se repitan
    fila=1;
    aux=picos(1,1);
    obj_del_2=0;
    
    for i=2:size(picos,1)
        coincidencia=0;
        for j=1:length(aux)
            if size(picos{i,1},1)==size(aux{j,1},1)
                if picos{i,1}(:,1)==aux{j,1}(:,1)
                    coincidencia=1;
                    moment=j;
                end
            end
        end
        if coincidencia==0
            aux(fila+1,:)=picos(i,1);
            fila=fila+1;
        elseif picos{i,1}(:,2)-aux{moment,1}(:,2)<=2
            aux{moment,1}(:,3)=picos{i,1}(:,3)+aux{moment,1}(:,3)+1;
            obj_detec=0;
            for ll=1:size(picos,1)
                if picos{ll,1}(:,1)==aux{moment,1}(:,1)
                    if obj_detec==0
                        obj_del_2=ll;
                        obj_detec=1;
                    end
                end
            end
            obj_del=i; % Objeto a eliminar
            for corre=1:size(Matriz_resultado,1)
                if Matriz_resultado{corre,1}==obj_del
                    Matriz_resultado{corre,1}=obj_del_2;
                end
            end
            
        else
            if picos{i,1}(:,3)>=3 && aux{moment,1}(:,3)<3
                aux{moment,1}= picos{i,1};
                obj_detec=0;
                for ll=1:size(picos,1)
                    if picos{ll,1}(:,1)==aux{moment,1}(:,1)
                        if obj_detec==0
                            obj_del_2=ll;
                            obj_detec=1;
                        end
                    end
                end
                obj_del=i; % Objeto a eliminar
                aux_mr=Matriz_resultado;
                count=0;
                for corre=1:size(Matriz_resultado,1)
                    if  obj_del_2==Matriz_resultado{corre,1}
                        aux_mr(corre-count,:)=[];
                        count=count+1;
                    end
                end
                Matriz_resultado=aux_mr;
                for corre=1:size(Matriz_resultado,1)
                    if Matriz_resultado{corre,1}==obj_del
                        Matriz_resultado{corre,1}=obj_del_2;
                    end
                end
                
            elseif picos{i,1}(:,3)<3 && aux{moment,1}(:,3)>=3
                aux{moment,1}=aux{moment,1}; %Se queda igual
                obj_del=i; % Objeto a eliminar
                aux_mr=Matriz_resultado;
                count=0;
                for corre=1:size(Matriz_resultado,1)
                    if obj_del==Matriz_resultado{corre,1}
                        aux_mr(corre-count,:)=[];
                        count=count+1;
                    end
                end
                Matriz_resultado=aux_mr;
            elseif picos{i,1}(:,3)>=3 && aux{moment,1}(:,3)>=3
                aux(fila+1,:)=picos(i,1);
                fila=fila+1;
            elseif picos{i,1}(:,3)<3 && aux{moment,1}(:,3)<3
                obj_detec=0;
                for ll=1:size(picos,1)
                    if picos{ll,1}(:,1)==aux{moment,1}(:,1)
                        if obj_detec==0
                            obj_del_2=ll;
                            obj_detec=1;
                        end
                    end
                end
                for counter=moment+1:size(aux,1)
                    aux{counter-1}=aux{counter};
                end
                aux(end)=[];
                fila=fila-1;
                
                %%Reorganizamos Matriz resultado eliminando todos los objetos
                %%que contengan ese pico
                obj_del=i; % Objeto a eliminar
                aux_mr=Matriz_resultado;
                count=0;
                for corre=1:size(Matriz_resultado,1)
                    if obj_del==Matriz_resultado{corre,1} || obj_del_2==Matriz_resultado{corre,1}
                        aux_mr(corre-count,:)=[];
                        count=count+1;
                    end
                end
                Matriz_resultado=aux_mr;
            end
        end
    end
    Matriz_resultado=sortrows(Matriz_resultado,[1]);
    %Renumeramos matriz resultado en orden ascendente
    numera=1;
    Matriz_resultado{1,1}=1;
    aux_mat=Matriz_resultado;
    for corre=2:size(Matriz_resultado,1)
        if Matriz_resultado{corre,1}==Matriz_resultado{corre-1,1}
            aux_mat{corre,1}=numera;
        else
            numera=numera+1;
            aux_mat{corre,1}=numera;
            
        end
    end
    Matriz_resultador=aux_mat;
    picos=aux;
    picosr=picos;
    
    %Asignamos altura z a cada pico en micrometro
    
    for i=1:size(picos,1)
        npicos=size(picos{i,1},1);
        for j=1:npicos
            dist_ini=(picos{i,1}(j,2)-1)*Rel_dist_z;
            dist=dist_ini+((picos{i,1}(j,3)/2)*Rel_dist_z);
            %eje_z_red(picos{i,1}(j,1),1)=dist;
        end
    end
    Datos_objeto{2,1}=Matriz_resultador;
else
    eje_x_red=[];
    eje_y_red=[];
    eje_z_red=[];
end


%% DATOS PARA LOS NODOS VERDES
canal=num2str(0);
cell=num2str(cell);
fichero=strcat(directory, '\Deteccion_de_nodos_ch_',num2str(canal),'-Cell_',cell);
load(fichero);

%%Reorganizamos nodos verdes eliminando nodos que pertenezcan a objetos
%%eliminados
picos=picosv;
aux=nodo_final;
count=0;

for i=1:size(nodo_final,1)
    coincidencia=0;
    for j=1:size(picos,1)
        if length(picos{j,1}(:,1))==length(nodo_final{i,2})
            if (picos{j,1}(:,1))' == nodo_final{i,2}
                coincidencia=1;
                peak=nodo_final{i,2};
            end
        end
    end
    if coincidencia==0
        aux(i-count,:)=[];
        count=count+1;
    else
        for go=1:size(Matriz_resultadov,1)
            if length(Matriz_resultadov{go,4})==length(peak)
                if Matriz_resultadov{go,4}==peak
                    objeto_renombrado=Matriz_resultadov{go,1};
                    break
                end
            end
        end
        aux{i-count,1}=objeto_renombrado;
    end
end
nodo_final=aux;

pos_node=cell2mat({nodo_final{:,3}}');
eje_x_green_node=pos_node(:,1)*Rel_dist_x;
eje_y_green_node=pos_node(:,2)*Rel_dist_y;
eje_z_green_node=zeros(size(eje_x_green_node,1),1);
Tam_imagen_rect_um_y=Height_recor*Rel_dist_y;



for i=1:size(nodo_final,1)
    varz=zeros(1,length(nodo_final{i,2}));
    for k=1:length(nodo_final{i,2})
        varz(k)=eje_z_green(nodo_final{i,2}(1,k),1);
    end
    eje_z_green_node(i,1)=mean(varz);
    nodo_final{i,4}=[eje_x_green_node(i,1) Tam_imagen_rect_um_y-eje_y_green_node(i,1) eje_z_green_node(i,1)];
end
nodo_verde=nodo_final;
Datos_objeto{1,1}=Matriz_resultadov;

if Matriz_resultado{1,1}~=0
    %%Reorganizamos nodos verdes eliminando nodos que pertenezcan a objetos
    %%eliminados
    picos=picosr;
    aux=nodo_final;
    count=0;
    for i=1:size(nodo_final,1)
        coincidencia=0;
        for j=1:size(picos,1)
            if length(picos{j,1}(:,1))==length(nodo_final{i,2})
                if (picos{j,1}(:,1))' == nodo_final{i,2}
                    coincidencia=1;
                    peak=nodo_final{i,2};
                end
            end
        end
        if coincidencia==0
            aux(i-count,:)=[];
            count=count+1;
        else
            for go=1:size(Matriz_resultador,1)
                if length(Matriz_resultador{go,4})==length(peak)
                    if Matriz_resultador{go,4}==peak
                        objeto_renombrado=Matriz_resultador{go,1};
                        break
                    end
                end
            end
                aux{i-count,1}=objeto_renombrado;
        end
    end
    nodo_final=aux;
    
    pos_node=cell2mat({nodo_final{:,3}}');

    nodo_verde(:,5)={[]};
else
    eje_x_red_node=[];
    eje_y_red_node=[];
    eje_z_red_node=[];
end

%%%%%%% Representaciones %%%%%%%%
numg=12;
numr=6;
color_nodos_verdes=[0 0.5 0];
color_nodos_rojos=[0.6 0 0];
% figure;plot3(eje_x_green,Tam_imagen_rect_um_y-eje_y_green,eje_z_green,'.g','MarkerSize', numg)
% hold on;plot3(eje_x_red,Tam_imagen_rect_um_y-eje_y_red,eje_z_red,'.r','MarkerSize', numr)
%
% plot3(eje_x_green_node,Tam_imagen_rect_um_y-eje_y_green_node,eje_z_green_node,'.','Color',color_nodos_verdes,'MarkerSize', numg)
%
% plot3(eje_x_red_node,Tam_imagen_rect_um_y-eje_y_red_node,eje_z_red_node,'.','Color',color_nodos_rojos,'MarkerSize', numr)
% grid on
% xlabel('Eje x'),
% ylabel('Eje y'),
% zlabel('Eje z')
% hold off
%
%
%
figure;subplot(1,2,1),plot(eje_x_green,Tam_imagen_rect_um_y-eje_y_green,'.g','MarkerSize', numg)
hold on;plot(eje_x_blue,Tam_imagen_rect_um_y-eje_y_blue,'.b')
%plot(eje_x_red,Tam_imagen_rect_um_y-eje_y_red,'.r','MarkerSize', numr);
axis ([ 0 rect(3)*Rel_dist_x 0 rect(4)*Rel_dist_y])
naa=strcat('Cell_',cell,'-rgb-Proyeccion X-Y');
title(naa)
xlabel('Eje x'),
ylabel('Eje y'),
grid on
hold off


subplot(1,2,2),plot(eje_x_green_node,Tam_imagen_rect_um_y-eje_y_green_node,'.','Color',color_nodos_verdes,'MarkerSize', numg)
hold on;plot(eje_x_blue,Tam_imagen_rect_um_y-eje_y_blue,'.b')

%plot(eje_x_red_node,Tam_imagen_rect_um_y-eje_y_red_node,'.','Color',color_nodos_rojos,'MarkerSize', numr)
nab=strcat('Cell_',cell,'-nodos-Proyeccion X-Y');
title(nab)
axis ([ 0 rect(3)*Rel_dist_x 0 rect(4)*Rel_dist_y])
xlabel('Eje x'),
ylabel('Eje y'),
grid on
hold off
nombre=strcat('Cell_',cell);
stringres=strcat(directory, '\', nombre,'_rgb_Proyeccion_X-Y.tiff');
Diapositiva=Diapositiva+1;
Diapositivach=num2str(Diapositiva);
numeracion=strcat('-f',Diapositivach);
print(numeracion,'-dtiff',stringres)
% 
% 
figure;subplot(1,2,1),plot(eje_x_green,eje_z_green,'.g','MarkerSize', numg)
hold on;plot(planoxz,eje_z_cont,'b')
nba=strcat('Cell_',cell,'-rgb-Proyeccion X-Z');
title(nba)
axis ([ 0 rect(3)*Rel_dist_x 0 N_cortes*Rel_dist_z])
xlabel('Eje x'),
ylabel('Eje z'),
grid on
hold off
subplot(1,2,2),plot(eje_x_green_node,eje_z_green_node,'.','Color',color_nodos_verdes,'MarkerSize', numg)
hold on;plot(planoxz,eje_z_cont,'b')
nbb=strcat('Cell_',cell,'-nodos-Proyeccion X-Z');
title(nbb)
axis ([ 0 rect(3)*Rel_dist_x 0 N_cortes*Rel_dist_z])
xlabel('Eje x'),
ylabel('Eje z'),
grid on
hold off
nombre=strcat('Cell_',cell);
stringres=strcat(directory, '\', nombre,'_rgb_Proyeccion_X-Z.tiff');

Diapositiva=Diapositiva+1;
Diapositivach=num2str(Diapositiva);
numeracion=strcat('-f',Diapositivach);
print(numeracion,'-dtiff',stringres)

figure;subplot(1,2,1),plot(Tam_imagen_rect_um_y-eje_y_green,eje_z_green,'.g','MarkerSize', numg)
hold on;plot(planoyz,eje_z_cont,'b')

nca=strcat('Cell_',cell,'-rgb-Proyeccion Y-Z');
title(nca)
axis ([ 0 rect(4)*Rel_dist_y 0 N_cortes*Rel_dist_z])
xlabel('Eje y'),
ylabel('Eje z'),
grid on
hold off

subplot(1,2,2),plot(Tam_imagen_rect_um_y-eje_y_green_node,eje_z_green_node,'.','Color',color_nodos_verdes,'MarkerSize', numg)
hold on;plot(planoyz,eje_z_cont,'b')

ncb=strcat('Cell_',cell,'-nodos-Proyeccion Y-Z');
title(ncb)
axis ([ 0 rect(4)*Rel_dist_y 0 N_cortes*Rel_dist_z])
xlabel('Eje y'),
ylabel('Eje z'),
grid on
hold off
stringres=strcat(directory, '\', nombre,'_rgb_Proyeccion_Y-Z.tiff');

Diapositiva=Diapositiva+1;
Diapositivach=num2str(Diapositiva);
numeracion=strcat('-f',Diapositivach);
print(numeracion,'-dtiff',stringres)




%%%% Representaciones Networks %%%%

for i=1:(size(nodo_verde,1))
    NV{i,1}=i;
    NV{i,2}=nodo_verde{i,4};
end

Distancia=zeros(size(NV,1));

%%Calculamos distancia de cada nodo al resto de nodos ..... PARA LOS VERDES

for i=1:size(NV,1)
  for j=1:size(NV,1) 
      DistanciaV(i,j)=sqrt(sum((NV{i,2}-NV{j,2}).^2));
  end
end

[Bv DistanciaV]=sort(DistanciaV,2);
DistanciaV(:,1)=[];
Bv(:,1)=[];
Pesos_g=Bv;

color_nodos_verdes=[0 0.5 0];
tamg=25;
tamr=25;
nombre2=strcat('Cell_',cell);

[h iteracion_ver Conectividad_dir_ver Conectividad_dir_k_1_ver Conectividad_dir_k_2_ver Conectividad]=Representacion_network(NV,12,DistanciaV,color_nodos_verdes,tamg);


Diapositiva=Diapositiva+1;
stringres=strcat(directory, '\',nombre2,'_network_green_XY.jpg');
saveas(h,stringres)


[h ,~, ~]=Representacion_network(NV,13,DistanciaV,color_nodos_verdes,tamg);

Diapositiva=Diapositiva+1;
stringres=strcat(directory, '\',nombre2,'_network_green_XZ.jpg');
saveas(h,stringres)

[h ,~ ,~]=Representacion_network(NV,23,DistanciaV,color_nodos_verdes,tamg);

Diapositiva=Diapositiva+1;
stringres=strcat(directory, '\',nombre2,'_network_green_YZ.jpg');
saveas(h,stringres)

[h ,~ ,~]=Representacion_network(NV,123,DistanciaV,color_nodos_verdes,tamg);

Diapositiva=Diapositiva+1;
stringres=strcat(directory, '\',nombre2,'_network_green_3D.jpg');
saveas(h,stringres)

if Matriz_resultado{1,1}~=0
    for i=1:size(nodo_verde,1)
        for j=1:6
            if j==1
                Datos{1,1}{i,j}=i;
            elseif j==2
                Datos{1,1}{i,j}=nodo_verde{i,4};
            elseif j==3
                Datos{1,1}{i,j}=nodo_verde{i,5};
            elseif j==4
                Datos{1,1}{i,j}=nodo_verde{i,1};
            elseif j==5
                Datos{1,1}{i,j}=nodo_verde{i,2};
            end
        end
    end
else
     for i=1:size(nodo_verde,1)
        for j=1:6
            if j==1
                Datos{1,1}{i,j}=i;
            elseif j==2
                Datos{1,1}{i,j}=nodo_verde{i,4};
            elseif j==3
                Datos{1,1}{i,j}=[];
            elseif j==4
                Datos{1,1}{i,j}=nodo_verde{i,1};
            elseif j==5
                Datos{1,1}{i,j}=nodo_verde{i,2};
            end
        end
    end
    
end

if Matriz_resultado{1,1}==0
    Matriz_resultador=Matriz_resultado;
end

nombre2=strcat('Cell_',cell);
stringres=strcat(directory, '\', nombre2,'_results.mat');
save (stringres,'Datos', 'Matriz_resultadov','Matriz_resultador','Datos_objeto','iteracion_ver','Conectividad','Conectividad_dir_ver','Conectividad_dir_k_1_ver','Conectividad_dir_k_2_ver','DistanciaV','Pesos_g','NV','eje_x_green_node','eje_y_green_node','eje_z_green_node')

end



