function [lista_r lista_v lista_or lista_ov lista_a]=reordenamos_numeracion(Dato_nodo,Pos_pix_perim_hetero,M_R_V,M_R_R,corte_max)

%%%%lista [numeracion_antigua numeracion_nueva]%%%%%%%

% Pasamos los datos del area a um
Rel_dist_x=82.01/1024;
Rel_dist_y=82.01/1024;
Rel_dist_z=0.17;
if M_R_R{1,1}~=0
    a=Dato_nodo{2,1}; %Nodos_rojos
else
    a=0;
end
b=Dato_nodo{1,1}; %Nodos_verdes
c=Pos_pix_perim_hetero; %Heterocromatina
d=M_R_R; %objetos rojos
e=M_R_V; %objetos verdes

Num_a=size(a,1);
Num_b=size(b,1);
Num_c=size(c,2);
Num_d=max(cell2mat(d(:,1)));
Num_e=max(cell2mat(e(:,1)));

%Obtenemos posiciones para cada heterocromatina
for i=1:Num_c
    TD=c{1,i};
    posiciones3(i,:)=median(TD,1);
end
%Obtenemos lista que relacionan nodo verde y rojo antiguos con la nueva
%numeracion, ademas del objeto heterocromatina
lista_r=(1:Num_a)';
lista_v=(1:Num_b)';
lista_a=(1:Num_c)';
lista_or=(1:Num_d)';
lista_ov=(1:Num_e)';

if M_R_R{1,1}~=0
    posiciones1=a(:,2);
    posiciones1=cell2mat(posiciones1);
    provisional1=[lista_r,posiciones1];
    Nuevo_orden_r=sortrows(provisional1,[2 -3]);
    lista_r(:,2)=Nuevo_orden_r(:,1);
    lista_r=sortrows(lista_r,2);
    lista_r=fliplr(lista_r);
else
    lista_r=0;
end

posiciones2=b(:,2);
posiciones2=cell2mat(posiciones2);
provisional2=[lista_v,posiciones2];
Nuevo_orden_v=sortrows(provisional2,[2 -3]);
lista_v(:,2)=Nuevo_orden_v(:,1);
lista_v=sortrows(lista_v,[2]);
lista_v=fliplr(lista_v);


provisional3=[lista_a,posiciones3];
Nuevo_orden_a=sortrows(provisional3,[2 -3]);
lista_a(:,2)=Nuevo_orden_a(:,1);
lista_a=sortrows(lista_a,[2]);
lista_a=fliplr(lista_a);

% Obtenemos lista que relaciona objetos rojos antiguos con la
% nueva numeración
if M_R_R{1,1}~=0
    cont=1;
    caja=[];
    for i=1:size(d,1)
        if d{i,1}==cont && size(d,1)~=i
            n=d{i,2};
            t=size(d{i,5},1);
            alt=n*ones(t,1);
            junt=[d{i,5},alt];
            caja=[caja; junt];
        elseif d{i,1}~=cont && size(d,1)~=i
            Pos_pix_area_or{1,cont}=caja;
            cont=cont+1;
            caja=[];
            n=d{i,2};
            t=size(d{i,5},1);
            alt=n*ones(t,1);
            junt=[d{i,5},alt];
            caja=[caja; junt];
        elseif d{i,1}==cont && size(d,1)==i
            n=d{i,2};
            t=size(d{i,5},1);
            alt=n*ones(t,1);
            junt=[d{i,5},alt];
            caja=[caja; junt];
            Pos_pix_area_or{1,cont}=caja;
        elseif d{i,1}~=cont && size(d,1)==i
            Pos_pix_area_or{1,cont}=caja;
            cont=cont+1;
            caja=[];
            n=d{i,2};
            t=size(d{i,5},1);
            alt=n*ones(t,1);
            junt=[d{i,5},alt];
            caja=[caja; junt];
            Pos_pix_area_or{1,cont}=caja;
        end
    end
    
    
    for i=1:size(Pos_pix_area_or,2)
        Pos_pix_area_or_um{i}(:,1)=Pos_pix_area_or{i}(:,1)*Rel_dist_x;
        Pos_pix_area_or_um{i}(:,2)=Pos_pix_area_or{i}(:,2)*Rel_dist_y;
        Pos_pix_area_or_um{i}(:,3)=(Pos_pix_area_or{i}(:,3)-1)*Rel_dist_z;
    end
    
    %Obtenemos posiciones para cada objeto rojo
    for i=1:Num_d
        TDR=Pos_pix_area_or_um{1,i};
        posiciones4(i,:)=median(TDR,1);
    end
    %ordenamos
    provisional4=[lista_or,posiciones4];
    Nuevo_orden_d=sortrows(provisional4,[2 -3]);
    lista_or(:,2)=Nuevo_orden_d(:,1);
    lista_or=sortrows(lista_or,2);
    lista_or=fliplr(lista_or);
else
    lista_or=0;
end

% Obtenemos lista que relaciona objetos verdes  antiguos con la
% nueva numeración
cont=1;
caja=[];
for i=1:size(e,1)
    if e{i,1}==cont && size(e,1)~=i
        n=e{i,2};
        t=size(e{i,5},1);
        alt=n*ones(t,1);
        junt=[e{i,5},alt];
        caja=[caja; junt];
    elseif e{i,1}~=cont && size(e,1)~=i
        Pos_pix_area_ov{1,cont}=caja;
        cont=cont+1;
        caja=[];
        n=e{i,2};
        t=size(e{i,5},1);
        alt=n*ones(t,1);
        junt=[e{i,5},alt];
        caja=[caja; junt];
    elseif e{i,1}==cont && size(e,1)==i
        n=e{i,2};
        t=size(e{i,5},1);
        alt=n*ones(t,1);
        junt=[e{i,5},alt];
        caja=[caja; junt];
        Pos_pix_area_ov{1,cont}=caja;
    elseif e{i,1}~=cont && size(e,1)==i
        Pos_pix_area_ov{1,cont}=caja;
        cont=cont+1;
        caja=[];
        n=e{i,2};
        t=size(e{i,5},1);
        alt=n*ones(t,1);
        junt=[e{i,5},alt];
        caja=[caja; junt];
        Pos_pix_area_ov{1,cont}=caja;
    end    
end


for i=1:size(Pos_pix_area_ov,2)
    Pos_pix_area_ov_um{i}(:,1)=Pos_pix_area_ov{i}(:,1)*Rel_dist_x;
    Pos_pix_area_ov_um{i}(:,2)=Pos_pix_area_ov{i}(:,2)*Rel_dist_y;
    Pos_pix_area_ov_um{i}(:,3)=(Pos_pix_area_ov{i}(:,3)-1)*Rel_dist_z;
end

%Obtenemos posiciones para cada objeto rojo
for i=1:Num_e
    TDV=Pos_pix_area_ov_um{1,i};
    posiciones5(i,:)=median(TDV,1);
end
%ordenamos
provisional5=[lista_ov,posiciones5];
Nuevo_orden_e=sortrows(provisional5,[2 -3]);
lista_ov(:,2)=Nuevo_orden_e(:,1);
lista_ov=sortrows(lista_ov,2);
lista_ov=fliplr(lista_ov);

