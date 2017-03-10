function DNM=distancia(POS,NVI,rect)


% Relacion ud a um
Rel_dist=82.01/1024;
Tam_imagen_rect_pix_y=rect(4); %pixeles
Tam_imagen_rect_um_y=Tam_imagen_rect_pix_y*Rel_dist; 
Rel_dist_z=0.17;
eje_z=(cell2mat(POS(:,2))-1)*Rel_dist_z;
%Detectamos distancia del objeto
i=1;
final=0;
obj=cell2mat(POS(:,1));
for num_obj=1:max(obj)
    fila=1;
    alm=[];
    while POS{i,1}==num_obj && final==0
        Posicion_z=eje_z(i,1)*ones(size(POS{i,3},1),1);
        Posicion_um=[POS{i,3}*Rel_dist,Posicion_z];
        Posicion_um(:,2)= Tam_imagen_rect_um_y-Posicion_um(:,2);
        alm(fila:fila+size(POS{i,3},1)-1,:)=Posicion_um;
        fila=fila+size(POS{i,3},1);
        
        if size(POS,1)==i
            final=1;
        else
            i=i+1;
        end
    end
    alm_pos{1,num_obj}=alm;
end
% Formamos matriz que tenga [nodo objeto distancia]

for i=1:size(NVI,1)
    DNM(i,1)=i;
    DNM(i,2)=NVI{i,4};
    pix=alm_pos{1,DNM(i,2)};
    cpix=[NVI{i,2};pix];
    y=pdist(cpix);
    z = squareform(y);
    dist=z(1,2:end);
    DNM(i,3)=min(dist);
end
