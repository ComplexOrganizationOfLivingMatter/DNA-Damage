function [V ,S ,E]=volumen_superficie_esfericidad(a)
%Definiciones generales
Area_un_pixel=(82.01/1024)^2; % En micrometro^2
Mediada_peri=82.01/1024;      % En micrometro
rel_dist_z=0.17;              % En micrometro^2

a=cell2mat(a);
%Variables auxiliares
cont=1;
v_p=0;
s_p=0;
for i=1:size(a,1)
    v_p=v_p+(a(i,3)*Area_un_pixel*rel_dist_z);
    s_p=s_p+(a(i,4)*Mediada_peri*rel_dist_z);
    if i~=size(a,1)
        if a(i+1,1)~=cont
            V(1,cont)=v_p;
            S(1,cont)=s_p;
            v_p=0;
            s_p=0;
            cont=cont+1;
        end
    else
        V(1,cont)=v_p;
        S(1,cont)=s_p;
    end
end

E=(((3*V)./(4*pi)).^(2/3).*(4*pi))./S;




