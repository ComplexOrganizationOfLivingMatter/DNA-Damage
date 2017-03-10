function [M_R_A , Pos_pix_perim_hetero,M_R_V,M_R_R,Dato_nodo,Union_nodos_rojo,Union_nodos_verde,Union_nodos_verde_k1,Union_nodos_verde_k2]=cambiamos_numeracion(lista_nr, lista_nv, lista_or, lista_ov ,lista_a, M_R_A , Pos_pix_perim_hetero,M_R_V,M_R_R,Dato_nodo,Union_nodos_rojo,Union_nodos_verde,Union_nodos_verde_k1,Union_nodos_verde_k2)
%M_R_A reordeno objetos
for i=1:size(M_R_A,1)
   n_a_n=lista_a(M_R_A{i,1},2);
   M_R_A{i,1}=n_a_n;
end
M_R_A=sortrows(M_R_A,[1 2]);

%Pos_pix_perim_hetero
a=Pos_pix_perim_hetero;
for i=1:size(Pos_pix_perim_hetero,2)
    Pos_pix_perim_hetero(1,lista_a(i,2))=a(1,i);
end

%M_R_V reordeno objetos
for i=1:size(M_R_V,1)
   n_v_n=lista_ov(M_R_V{i,1},2);
   M_R_V{i,1}=n_v_n;
end
M_R_V=sortrows(M_R_V,[1 2]);

%M_R_R reordeno objetos
if M_R_R{1,1}~=0
    for i=1:size(M_R_R,1)
        n_r_n=lista_or(M_R_R{i,1},2);
        M_R_R{i,1}=n_r_n;
    end
    
    M_R_R=sortrows(M_R_R,[1 2]);
end
%Dato_nodo
Nodos_verdes=Dato_nodo{1,1};
for i=1:size(Nodos_verdes,1)
    Nodos_verdes{i,1}=lista_nv(i,2);
    if isempty(Nodos_verdes{i,3})==0
        n_ant=Nodos_verdes{i,3};
        n_nu=lista_nr(n_ant,2);
        Nodos_verdes{i,3}=n_nu;
    end
    o_ant=Nodos_verdes{i,4};
    o_nu=lista_ov(o_ant,2);
    Nodos_verdes{i,4}=o_nu;
end
Nodos_verdes=sortrows(Nodos_verdes,1);
Dato_nodo{1,1}=Nodos_verdes;
if M_R_R{1,1}~=0
    Nodos_rojos=Dato_nodo{2,1};
    for i=1:size(Nodos_rojos,1)
        Nodos_rojos{i,1}=lista_nr(i,2);
        if isempty(Nodos_rojos{i,3})==0
            n_ant=Nodos_rojos{i,3};
            n_nu=lista_nv(n_ant,2);
            Nodos_rojos{i,3}=n_nu;
        end
        o_ant=Nodos_rojos{i,4};
        o_nu=lista_or(o_ant,2);
        Nodos_rojos{i,4}=o_nu;
    end
    Nodos_rojos=sortrows(Nodos_rojos,1);
    Dato_nodo{2,1}=Nodos_rojos;
    
    %Union_nodos_rojo
    Conec_R=Union_nodos_rojo;
    [fil, col]=size(Conec_R);
    Conec_R_nu=zeros(fil, col);
    
    for i=1:fil
        for j=1:col
            if Conec_R(i,j)==1
                i_nu=lista_nr(i,2);
                j_nu=lista_nr(j,2);
                Conec_R_nu(i_nu,j_nu)=1;
            end
        end
    end
    Union_nodos_rojo=Conec_R_nu;
    
end

%Union_nodos_verde
Conec_V=Union_nodos_verde;
[fil, col]=size(Conec_V);
Conec_V_nu=zeros(fil, col);

for i=1:fil
    for j=1:col
        if Conec_V(i,j)==1
          i_nu=lista_nv(i,2);
          j_nu=lista_nv(j,2);
          Conec_V_nu(i_nu,j_nu)=1;
        end
    end
end
Union_nodos_verde=Conec_V_nu;

%Union_nodos_verde_k1
Conec_V_k1=Union_nodos_verde_k1;
[fil, col]=size(Conec_V_k1);
Conec_V_k1_nu=zeros(fil, col);

for i=1:fil
    for j=1:col
        if Conec_V_k1(i,j)==1
          i_nu=lista_nv(i,2);
          j_nu=lista_nv(j,2);
          Conec_V_k1_nu(i_nu,j_nu)=1;
        end
    end
end
Union_nodos_verde_k1=Conec_V_k1_nu;

%Union_nodos_verde_k2
Conec_V_k2=Union_nodos_verde_k2;
[fil, col]=size(Conec_V_k2);
Conec_V_k2_nu=zeros(fil, col);

for i=1:fil
    for j=1:col
        if Conec_V_k2(i,j)==1
          i_nu=lista_nv(i,2);
          j_nu=lista_nv(j,2);
          Conec_V_k2_nu(i_nu,j_nu)=1;
        end
    end
end
Union_nodos_verde_k2=Conec_V_k2_nu;

