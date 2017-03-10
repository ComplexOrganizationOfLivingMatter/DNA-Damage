function M_R_I=pixel_interseccion(a,b,c,d)
%MRI=[NODO OBJETO_NODO OBJETO_ROJO/OBJETO_HETEROCROMATINA CORTE POSICION]

% a= Matriz resultado de un grupo 
% b= Matriz resultado de otro grupo
% c= Relacion entre ambos grupos

C1=[a(:,1:2),a(:,5)];
C2=[b(:,1:2),b(:,5)];
RNO= d; % Relacion Nodo Objeto
fil=1; 
M_R_I{1,1}=0;
for i=1:size(c,1) 
    Hr=c(i,2);      %identificacion del objeto del primer conjunto
    if Hr~=0 %Si el nodo verde tiene asociado algo
        node=c(i,1);
        Or=RNO{node,4};    %identificacion de nodo verde con su objeto del 2º conjunto)
        %% Recorremos las matrices de datos hasta colocarnos en el primer elemento del objeto
        cont1=1;
        cont2=1;
        while Hr~=C1{cont1,1}
            cont1=cont1+1;
        end
        while Or~=C2{cont2,1}
            cont2=cont2+1;
        end
        %% Coordinamos los cortes de cada objeto
        if C1{cont1,2}>C2{cont2,2}  
            while C1{cont1,2}~=C2{cont2,2} && C1{cont1,1}==Hr && C2{cont2,1}==Or && cont2<size(C2,1)
                cont2=cont2+1;
            end
        elseif C1{cont1,2}<C2{cont2,2}
            while C1{cont1,2}~=C2{cont2,2} && C1{cont1,1}==Hr && C2{cont2,1}==Or && cont1<size(C1,1)
                cont1=cont1+1;  
            end
        end
        
        %% Obtenemos posicion de los pixeles interseccion
        incr1=0;
        incr2=0;
        salida=0;
        while C1{cont1+incr1,1}==Hr && C2{cont2+incr2,1}==Or && salida==0
            
            %Si los cortes se desajustan ajustamos el corte maximo al minimo
            if C1{cont1+incr1,2} ~= C2{cont2+incr2,2}
                [~, id] = max([C1{cont1+incr1,2} C2{cont2+incr2,2}]);
                if id==1 && cont1+incr1~=1
                    incr1=incr1-1;
                else
                    incr2=incr2-1;
                end
                
            end
            M_R_I{fil,1}=i;             %Nodo
            M_R_I{fil,2}=Or;            %Objeto_verde
            M_R_I{fil,3}=Hr;            %Objeto primer conjunto
            M_R_I{fil,4}=C2{cont2+incr2,2};   %Corte en el que se produce la relacion
            pos_1=C1{cont1+incr1,3};
            pos_2=C2{cont2+incr2,3};
            num_pix=1;
            pos_I=[];
            for x=1:size(pos_1,1)
                indi=find(pos_1(x,1)==pos_2(:,1));
                if isempty(indi)==0
                    for y=1:length(indi)
                        if pos_1(x,2)==pos_2(indi(y),2)
                            pos_I(num_pix,1:2)=[pos_1(x,1) pos_1(x,2)];
                            num_pix=num_pix+1;
                        end
                    end
                end
            end
            
            
            M_R_I{fil,5}=pos_I;         %Posicion de los pixeles coincidentes
            
            %incrementamos indices
            fil=fil+1;
            
            if size(C1,1)==cont1+incr1 || size(C2,1)==cont2+incr2
                salida=1;
            else
                incr1=incr1+1;
                incr2=incr2+1;
            end
        end
    end
end







