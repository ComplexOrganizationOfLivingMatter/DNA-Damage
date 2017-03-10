function V_colocal=colocalizacion(M_I_R,DN,vol_obj)

% V_colocal=colocalizacion(M_I_R,Dato_nodo,VR)

%Definiciones generales
Area_un_pixel=(82.01/1024)^2; % En micrometro^2
rel_dist_z=0.17;              % En micrometro^2
V_colocal=zeros(1,5);

NV=DN{1,1};

cont=1;
cont2=1;
for i=1:size(NV,1)
    v_p=0;
    cuenta=1;
    while M_I_R{cont,1}==i
        Area=size(M_I_R{cont,5},1);
        v_p=v_p+(Area*Area_un_pixel*rel_dist_z);
        cuenta=cuenta+1;
        if size(M_I_R,1)== cont
            break
        end
        cont=cont+1;
    end
    if cuenta~=1
        V_colocal(cont2,1)=i;       %Nodo verde
        V_colocal(cont2,2)=NV{i,4}; %objeto verde relacionado
        V_colocal(cont2,3)=v_p;
        V_colocal(cont2,4)=vol_obj(1,NV{i,4});
        V_colocal(cont2,5)=(v_p/vol_obj(1,NV{i,4}))*100;
        cont2=cont2+1;
    end
end