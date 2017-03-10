function caracteristicas(serie,cell)
%% Ejemplo de llamada caracteristicas('009','2')
%%%%%% Funcion que extrae los datos necesarios de las variables ya
%%%%%% guardadas y extrae las caracteristicas de interes.

%Datos: Para ver relacion entre nodos rojos y verdes , tambien relaciona
%nodo con objeto.

%Matriz_resultado: Contiene la relacion entre objeto, corte ,area y
%perimetro.

% Tener lista de nodos rojos con su centroide y su nodo verde
% asociado(nodo_rojo).

% Tener lista de nodos verdes con su centroide y su nodo rojo
% asociado(nodo_verde).

% Tener lista de heterocromatina con sus cc y su nodo verde
% asociado.(Tenemos que crearlo).

%% informacion requerida

%Nodo_info(verde)=[Objeto_verde Nodo_rojo_asociado
%heterocromatina_mas_cercana Volumen_verde Volumen_rojo_asociado
%Volumen_heterocromatina_mas_cercana Superficie Esfericidad
%Intensidad_media Intensidad_maxima ] % DATOS POR AHORA

%% LLamada a informacion basica

string=strcat('info_basica_Serie_',serie,'_celula_',cell);
cd ('Informacion_basica')
load (string)
cd ..

%% LLamada lectura de imagenes
cd ..
archivo=strcat('Data\Lectura_Serie_',serie);
cd (archivo)
fichero=strcat('Lectura_Serie_',serie,'_ch1');
load (fichero)
cd ..
clear archivo fichero
im=imagen;
for i=1:corte_max
    imr{1,i}=im{1,i}(:,:,1);
    imv{1,i}=im{1,i}(:,:,2);
    ima{1,i}=im{1,i}(:,:,3);
end


%% LLamada a datos
%Datos intermedios azul
subfichero1=strcat('Datos_Serie_',serie,'_resultados_heterocromatina');
cd (subfichero1)
archivo1=strcat('Serie_',serie,'_celula_',cell,'_hetero_results');
load (archivo1)
cd ..

M_R_A=Matriz_resultado;
Pos_pix_perim_hetero=num_hetero_um;
clear Matriz_resultado Pos_x Pos_y Pos_z num_hetero num_hetero_um string subfichero1 archivo1


%Datos finales

subfichero1=strcat('Datos_Serie_',serie,'_resultados');
cd (subfichero1)
archivo1=strcat('Serie_',serie,'_celula_',cell,'_results');
load (archivo1)
cd ..
Dato_nodo=Datos;
M_R_V=Matriz_resultadov;
if Matriz_resultador{1,1}~=0
    M_R_R=Matriz_resultador;
else
    M_R_R{1,1}=0;
end
kg=iteracion_ver;
kr=iteracion_roj;
Union_nodos_rojo=Conectividad_dir_roj;
Union_nodos_verde=Conectividad_dir_ver;
Union_nodos_verde_k1=Conectividad_dir_k_1_ver;
Union_nodos_verde_k2=Conectividad_dir_k_2_ver;
clear eje_x_green_node eje_y_green_node eje_z_green_node Conectividad_dir_k_1_ver Conectividad_dir_k_2_ver Conectividad_dir_k_1_roj Conectividad_dir_k_2_roj Datos_objeto eje_x_red_node eje_y_red_node eje_z_red_node NV NR DistanciaV DistanciaR Pesos_g Pesos_r iteracion_ver Conectividad_dir_ver Conectividad iteracion_roj Conectividad_dir_roj Datos subfichero1 archivo1

%%Renumeramos los objetos y los nodos para poder identificarlso visualmente
cd ('..\Programa_ CC_Networks')
[lista_nr lista_nv lista_or lista_ov lista_a]=reordenamos_numeracion(Dato_nodo,Pos_pix_perim_hetero,M_R_V,M_R_R,corte_max);
[M_R_A , Pos_pix_perim_hetero,M_R_V,M_R_R,Dato_nodo,Union_nodos_rojo,Union_nodos_verde,Union_nodos_verde_k1,Union_nodos_verde_k2]=cambiamos_numeracion(lista_nr, lista_nv, lista_or, lista_ov ,lista_a, M_R_A , Pos_pix_perim_hetero,M_R_V,M_R_R,Dato_nodo,Union_nodos_rojo,Union_nodos_verde,Union_nodos_verde_k1,Union_nodos_verde_k2);
%%Asociamos nodos verdes con objeto heterocromatina
NV_H=asociar_nv_heterocromatina(Dato_nodo,Pos_pix_perim_hetero);
%%Hallamos volumen , superficie y esfericidad de cada objeto de cada plano
if M_R_R{1,1}~=0
    R=[M_R_R(:,1:3),M_R_R(:,10)];
    [VR ,SR, ER]=volumen_superficie_esfericidad(R);
else
    VR=[];
    SR=[];
    ER=[];
end
V=[M_R_V(:,1:3),M_R_V(:,10)];
[VV ,SV,EV]=volumen_superficie_esfericidad(V);
A=[M_R_A(:,1:2),M_R_A(:,4),M_R_A(:,7)];
[VA ,SA,EA]=volumen_superficie_esfericidad(A);

%%Hallamos interseccion entre nodos verdes y objetos azules/rojos
RNO= Dato_nodo{1,1};
M_I_A=pixel_interseccion(M_R_A,M_R_V,NV_H,RNO);
if M_R_R{1,1}~=0
    RNO= Dato_nodo{1,1};
    for i=1:size(RNO,1)
        if isempty(RNO{i,3})==1
            RNO{i,3}=0;
        else
            %Intercambiamos la cc nodo por objeto
            Lon=length(RNO{i,3});
            for itiner=1:Lon
                RNO{i,3}(itiner,1)=Dato_nodo{2,1}{find(RNO{i,3}(itiner,1)==cell2mat(Dato_nodo{2,1}(:,1))),4};
            end
            
        end
    end
    NV_R=[RNO(1:end,1),RNO(1:end,3)];
    cont=1;
    for itiner=1:size(NV_R,1)
        Le=size(NV_R{itiner,2},1);
        
        for reco=1:Le
            NNV_R(cont,1)=NV_R{itiner,1};
            NNV_R(cont,2)=NV_R{itiner,2}(reco,1);
            cont=cont+1;
        end
        
    end
    NV_R=NNV_R;
    M_I_R=pixel_interseccion(M_R_R,M_R_V,NV_R,RNO);
else
    M_I_R=0;
end
%%Creamos matriz cc. nodo
%Nº NODOS VERDES
CC(1,1)=size(NV_H,1);
% PORCENTAJE NODOS CON DOBLE MARCAJE
N=Dato_nodo{1,1}(:,3);
Ndoble=0;
for i=1:size(N,1)
    if isempty(N{i,1})==0   
        Ndoble=Ndoble+1;
    end
end
CC(1,2)=100*Ndoble/size(NV_H,1);
% MEDIA Y STD DEL VOLUMEN VERDE
CC(1,3)=mean(VV);
CC(1,4)=std(VV);
% MEDIA Y STD DEL SUPERFICIE VERDE
CC(1,5)=mean(SV);
CC(1,6)=std(SV);
% MEDIA Y STD DEL ESFERICIDAD VERDE
CC(1,11)=mean(EV);
CC(1,12)=std(EV);
% MEDIA Y STD INTENSIDAD DEL VOLUMEN
V=[M_R_V(:,1:2),M_R_V(:,5)];
IV=intensidad_volumen(V, imv,rect);
for i=1:size(IV,2)
    IM(1,i)=mean(IV{1,i});
end
CC(1,13)=mean(IM);
CC(1,14)=std(IM);

% MEDIA Y STD INTENSIDAD MAXIMA DEL VOLUMEN
V=[M_R_V(:,1:2),M_R_V(:,5)];
IV=intensidad_volumen(V, imv,rect);
for i=1:size(IV,2)
    IMax(1,i)=max(IV{1,i});
end
CC(1,17)=mean(IMax);
CC(1,18)=std(IMax);

% MEDIA Y STD DISTANCIA NUCLEO-MEMBRANA
POS=[M_R_V(:,1:2),M_R_V(:,11)];
DNM=distancia(POS,Dato_nodo{1,1},rect);
CC(1,19)=mean(DNM(:,3));
CC(1,20)=std(DNM(:,3));

% MEDIA Y STD DISTANCIA NODO-HETEROCROMATINA

CC(1,21)=mean(NV_H(:,3));
CC(1,22)=std(NV_H(:,3));

% PORCENTAJE DE COLOCALIZACION DE OBJETO VERDE CON OBJETO ROJO
if M_R_R{1,1}~=0  && M_I_R{1,1}~=0
    V_colocal=colocalizacion(M_I_R,Dato_nodo,VV);
    Por_vol_col_rojo=V_colocal(:,5);
    CC(1,23)=mean(Por_vol_col_rojo);
    CC(1,24)=std(Por_vol_col_rojo);
else
    CC(1,23)=0;
    CC(1,24)=0;
end

% INTENSIDAD DE COLOCALIZACION DE OBJETO VERDE CON OBJETO ROJO
if M_R_R{1,1}~=0 && M_I_R{1,1}~=0
    IMI=[];
    VI=[M_I_R(:,2),M_I_R(:,4:5)];
    VI=sortrows(VI,1);
    IVI=intensidad_volumen(VI, imv,rect);
    cuenta=1;
    for i=1:size(IVI,2)
        if isempty(IVI{1,i})~=1
            IMI(1,cuenta)=mean(IVI{1,i});
            cuenta=cuenta+1;
        end
    end
    if isempty(IMI)==0
        CC(1,25)=mean(IMI);
        CC(1,26)=std(IMI);
    else
        CC(1,25)=0;
        CC(1,26)=0;
    end
    
else
    CC(1,25)=0;
    CC(1,26)=0;
end
% % PORCENTAJE DE COLOCALIZACION DE OBJETO VERDE CON HETEROCROMATINA
V_colocal_Az=colocalizacion(M_I_A,Dato_nodo,VV);
Por_vol_col_Azul=V_colocal_Az(:,5);
CC(1,29)=mean(Por_vol_col_Azul);
CC(1,30)=std(Por_vol_col_Azul);

% INTENSIDAD DE COLOCALIZACION DE OBJETO VERDE CON HETEROCROMATINA
if CC(1,29)~=0
    VI=[M_I_A(:,2),M_I_A(:,4:5)];
    VI=sortrows(VI,1);
    IVI=intensidad_volumen(VI, imv,rect);
    cuenta=1;
    IMI(1,1)=0;
    for i=1:size(IVI,2)
        if isempty(IVI{1,i})~=1
            IMI(1,cuenta)=mean(IVI{1,i});
            cuenta=cuenta+1;
        end
    end
    CC(1,31)=mean(IMI);
    CC(1,32)=std(IMI);
else
    CC(1,31)=0;
    CC(1,32)=0;
end

%% Comenzamos a extraer las caracteristicas de Networks
if CC(1,1)==1
    CC(1,35:226)=zeros(1,226-35+1);
else
    %Verde iteracion k
    for bucle=1:3
        if bucle==1
            U=Union_nodos_verde;
        elseif bucle==2
            U=Union_nodos_verde_k1;
        else
            U=Union_nodos_verde_k2;
        end
        nodosg=1:size(Dato_nodo{1,1},1);
        grafo_binario=U;
        grafo=zeros(length(nodosg));
        for i=1:length(nodosg)
            for j=1:length(nodosg)
                if grafo_binario(i,j)==1
                    grafo_binario(j,i)=1;
                    grafo(i,j)=sqrt((Dato_nodo{1,1}{i,2}(1,1)-Dato_nodo{1,1}{j,2}(1,1))^2+(Dato_nodo{1,1}{i,2}(1,2)-Dato_nodo{1,1}{j,2}(1,2))^2+(Dato_nodo{1,1}{i,2}(1,3)-Dato_nodo{1,1}{j,2}(1,3))^2);
                    grafo(j,i)=grafo(i,j);
                end
            end
        end
        
        cd Codigo_BCT
        [n_conexiones_cada_nodos, Suma_pesos_cada_nodo, Correlacion_entre_grados_nodos, Densidad_conexiones, Coef_cluster, T, estructura_optima,modularidad_maximizada, Matriz_distancias_mas_cortas_de_todos_nodos,lambda,efficiency,ecc,radius,diameter, BC]=Prueba_brain(grafo,grafo_binario,nodosg);
        cd ..;
        
        Suma_pesos=Suma_pesos_cada_nodo(nodosg);
        
        cd Gergana_Bounova
        [prs, a, s]=Prueba_Bounova(grafo,grafo_binario,nodosg);
        cd ..
        Coef_pearson=prs;
        conectividad_algebraica=a;
        Metrica_s=s;
        
        Assortattivity=Correlacion_entre_grados_nodos;
        Densidad_conexiones;
        Transitivity=T;
        modularidad_maximizada;
        
        for j=1:length(nodosg)
            objv=Dato_nodo{1,1}{j,4};
            [no ve]=find(grafo_binario(j,:)==1);
            ve=ve';
            for h=1:length(ve)
                veci(h)=Dato_nodo{1,1}{ve(h),4};
            end
            relacion_vol_vecinos(j)=VV(objv)/(mean(VV(veci))+std(VV(veci)));
            relacion_Pix_region_convexa_vecinos(j)=EV(objv)/(mean(EV(veci))+std(EV(veci)));
        end
        M=triu(Matriz_distancias_mas_cortas_de_todos_nodos(nodosg(1:end),nodosg(1:end)));% me quedo solo con los valores de una celula a otra y no viceversa, ya que es una matriz simetriica
        
        if bucle==1
            CC(1,35)=mean(n_conexiones_cada_nodos);
            CC(1,36)=std(n_conexiones_cada_nodos);
            CC(1,47)=mean(relacion_vol_vecinos);
            CC(1,48)=std(relacion_vol_vecinos);
            CC(1,95)=mean(relacion_Pix_region_convexa_vecinos);
            CC(1,96)=std(relacion_Pix_region_convexa_vecinos);
            CC(1,107)=mean(Suma_pesos);
            CC(1,108)=std(Suma_pesos);
            CC(1,119)=mean(Coef_cluster);
            CC(1,120)=std(Coef_cluster);
            CC(1,131)=mean(ecc);
            CC(1,132)=std(ecc);
            CC(1,143)=mean(BC);
            CC(1,144)=std(BC);
            CC(1,155)=mean(M(find(M~=0)));
            CC(1,156)=std(M(find(M~=0)));
            CC(1,167)=radius;
            CC(1,173)=diameter;
            CC(1,179)=efficiency;
            CC(1,185)=Coef_pearson;
            CC(1,191)=conectividad_algebraica;
            CC(1,197)=Metrica_s;
            CC(1,203)=Assortattivity;
            CC(1,209)=Densidad_conexiones;
            CC(1,215)=Transitivity;
            CC(1,221)=modularidad_maximizada;
        elseif bucle==2
            CC(1,37)=mean(n_conexiones_cada_nodos);
            CC(1,38)=std(n_conexiones_cada_nodos);
            CC(1,49)=mean(relacion_vol_vecinos);
            CC(1,50)=std(relacion_vol_vecinos);
            CC(1,97)=mean(relacion_Pix_region_convexa_vecinos);
            CC(1,98)=std(relacion_Pix_region_convexa_vecinos);
            CC(1,109)=mean(Suma_pesos);
            CC(1,110)=std(Suma_pesos);
            CC(1,121)=mean(Coef_cluster);
            CC(1,122)=std(Coef_cluster);
            CC(1,133)=mean(ecc);
            CC(1,134)=std(ecc);
            CC(1,145)=mean(BC);
            CC(1,146)=std(BC);
            CC(1,157)=mean(M(find(M~=0)));
            CC(1,158)=std(M(find(M~=0)));
            CC(1,168)=radius;
            CC(1,174)=diameter;
            CC(1,180)=efficiency;
            CC(1,186)=Coef_pearson;
            CC(1,192)=conectividad_algebraica;
            CC(1,198)=Metrica_s;
            CC(1,204)=Assortattivity;
            CC(1,210)=Densidad_conexiones;
            CC(1,216)=Transitivity;
            CC(1,222)=modularidad_maximizada;
        else
            CC(1,39)=mean(n_conexiones_cada_nodos);
            CC(1,40)=std(n_conexiones_cada_nodos);
            CC(1,51)=mean(relacion_vol_vecinos);
            CC(1,52)=std(relacion_vol_vecinos);
            CC(1,99)=mean(relacion_Pix_region_convexa_vecinos);
            CC(1,100)=std(relacion_Pix_region_convexa_vecinos);
            CC(1,111)=mean(Suma_pesos);
            CC(1,112)=std(Suma_pesos);
            CC(1,123)=mean(Coef_cluster);
            CC(1,124)=std(Coef_cluster);
            CC(1,135)=mean(ecc);
            CC(1,136)=std(ecc);
            CC(1,147)=mean(BC);
            CC(1,148)=std(BC);
            CC(1,159)=mean(M(find(M~=0)));
            CC(1,160)=std(M(find(M~=0)));
            CC(1,169)=radius;
            CC(1,175)=diameter;
            CC(1,181)=efficiency;
            CC(1,187)=Coef_pearson;
            CC(1,193)=conectividad_algebraica;
            CC(1,199)=Metrica_s;
            CC(1,205)=Assortattivity;
            CC(1,211)=Densidad_conexiones;
            CC(1,217)=Transitivity;
            CC(1,223)=modularidad_maximizada;
        end
    end
    for bucle=1:3
        if bucle==1
            CC(1,41)=CC(1,37)-CC(1,35);
            CC(1,42)=CC(1,38)-CC(1,36);
            CC(1,53)=CC(1,49)-CC(1,47);
            CC(1,54)=CC(1,50)-CC(1,48);
            CC(1,101)=CC(1,97)-CC(1,95);
            CC(1,102)=CC(1,98)-CC(1,96);
            CC(1,113)=CC(1,109)-CC(1,107);
            CC(1,114)=CC(1,110)-CC(1,108);
            CC(1,125)=CC(1,121)-CC(1,119);
            CC(1,126)=CC(1,122)-CC(1,120);
            CC(1,137)=CC(1,133)-CC(1,131);
            CC(1,138)=CC(1,134)-CC(1,132);
            CC(1,149)=CC(1,145)-CC(1,143);
            CC(1,150)=CC(1,146)-CC(1,144);
            CC(1,161)=CC(1,157)-CC(1,155);
            CC(1,162)=CC(1,158)-CC(1,156);
            CC(1,170)=CC(1,168)-CC(1,167);
            CC(1,176)=CC(1,174)-CC(1,173);
            CC(1,182)=CC(1,180)-CC(1,179);
            CC(1,188)=CC(1,186)-CC(1,185);
            CC(1,194)=CC(1,192)-CC(1,191);
            CC(1,200)=CC(1,198)-CC(1,197);
            CC(1,206)=CC(1,204)-CC(1,203);
            CC(1,212)=CC(1,210)-CC(1,209);
            CC(1,218)=CC(1,216)-CC(1,215);
            CC(1,224)=CC(1,222)-CC(1,221);
            
        elseif bucle==2
            CC(1,43)=CC(1,39)-CC(1,35);
            CC(1,44)=CC(1,40)-CC(1,36);
            CC(1,55)=CC(1,51)-CC(1,47);
            CC(1,56)=CC(1,52)-CC(1,48);
            CC(1,103)=CC(1,99)-CC(1,95);
            CC(1,104)=CC(1,100)-CC(1,96);
            CC(1,115)=CC(1,111)-CC(1,107);
            CC(1,116)=CC(1,112)-CC(1,108);
            CC(1,127)=CC(1,123)-CC(1,119);
            CC(1,128)=CC(1,124)-CC(1,120);
            CC(1,139)=CC(1,135)-CC(1,131);
            CC(1,140)=CC(1,136)-CC(1,132);
            CC(1,151)=CC(1,147)-CC(1,143);
            CC(1,152)=CC(1,148)-CC(1,144);
            CC(1,163)=CC(1,159)-CC(1,155);
            CC(1,164)=CC(1,160)-CC(1,156);
            CC(1,171)=CC(1,169)-CC(1,167);
            CC(1,177)=CC(1,175)-CC(1,173);
            CC(1,183)=CC(1,181)-CC(1,179);
            CC(1,189)=CC(1,187)-CC(1,185);
            CC(1,195)=CC(1,193)-CC(1,191);
            CC(1,201)=CC(1,199)-CC(1,197);
            CC(1,207)=CC(1,205)-CC(1,203);
            CC(1,213)=CC(1,211)-CC(1,209);
            CC(1,219)=CC(1,217)-CC(1,215);
            CC(1,225)=CC(1,223)-CC(1,221);
        else
            CC(1,45)=CC(1,39)-CC(1,37);
            CC(1,46)=CC(1,40)-CC(1,38);
            CC(1,57)=CC(1,51)-CC(1,49);
            CC(1,58)=CC(1,52)-CC(1,50);
            CC(1,105)=CC(1,99)-CC(1,97);
            CC(1,106)=CC(1,100)-CC(1,98);
            CC(1,117)=CC(1,111)-CC(1,109);
            CC(1,118)=CC(1,112)-CC(1,110);
            CC(1,129)=CC(1,123)-CC(1,121);
            CC(1,130)=CC(1,124)-CC(1,122);
            CC(1,141)=CC(1,135)-CC(1,133);
            CC(1,142)=CC(1,136)-CC(1,134);
            CC(1,153)=CC(1,147)-CC(1,145);
            CC(1,154)=CC(1,148)-CC(1,146);
            CC(1,165)=CC(1,159)-CC(1,157);
            CC(1,166)=CC(1,160)-CC(1,158);
            CC(1,172)=CC(1,169)-CC(1,168);
            CC(1,178)=CC(1,175)-CC(1,174);
            CC(1,184)=CC(1,181)-CC(1,180);
            CC(1,190)=CC(1,187)-CC(1,186);
            CC(1,196)=CC(1,193)-CC(1,192);
            CC(1,202)=CC(1,199)-CC(1,198);
            CC(1,208)=CC(1,205)-CC(1,204);
            CC(1,214)=CC(1,211)-CC(1,210);
            CC(1,220)=CC(1,217)-CC(1,216);
            CC(1,226)=CC(1,223)-CC(1,222);
        end
    end
end
CC(:,[7:10,15:16,27:28,33:34,59:94])=[];
string=strcat('..\Data\Datos_extraccion_CC\caracteristica_serie_',serie,'_celula_',cell);
save(string,'CC');

