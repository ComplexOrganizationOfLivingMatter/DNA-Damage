function [h saltos Conectividad_dir Conectividad_dir_k_1 Conectividad_dir_k_2 Conectividad]=Representacion_network(NV,planos,Distancia,color,tamg)

Conectividad=zeros(size(NV,1));
Conectividad_directa=zeros(size(NV,1));
tresD=0;
if planos==12 || planos==21
    for i=1:size(NV,1)
        X(i,1)=NV{i,2}(1,1);
        Y(i,1)=NV{i,2}(1,2);
    end
end
if planos==13 || planos==31
    for i=1:size(NV,1)
        X(i,1)=NV{i,2}(1,1);
        Y(i,1)=NV{i,2}(1,3);
    end
end
if planos==23 || planos==32
    for i=1:size(NV,1)
        X(i,1)=NV{i,2}(1,2);
        Y(i,1)=NV{i,2}(1,3);
    end
end
if planos==123 || planos==132 || planos==213 || planos==321 || planos==231 || planos==312
    tresD=1;
    for i=1:size(NV,1)
        X(i,1)=NV{i,2}(1,1);
        Y(i,1)=NV{i,2}(1,2);
        Z(i,1)=NV{i,2}(1,3);
    end
end
if tresD==0
    %%Representamos centroides
    figure;h=plot(X(1,1),Y(1,1),'.','Color',color,'Markersize',tamg);
    if  size(NV,1)~=1
        for i=2:size(NV,1)
            hold on; plot(X(i,1),Y(i,1),'.','Color',color,'Markersize',tamg)
        end
    end
    if planos==12 || planos==21
        
        xlabel('Eje x'),
        ylabel('Eje y'),
    end
    if planos==13 || planos==31
        xlabel('Eje x'),
        ylabel('Eje z'),
    end
    if planos==23 || planos==32
        xlabel('Eje y'),
        ylabel('Eje z'),
    end
    
    hold off, grid on
    
    paro=0;
    if size(NV,1)~=1
        for iteracion=1:size(NV,1)
            if paro==0      %Paro se vuelve 1 cuando todos los nodos esten conectados
                for i=1:size(NV,1)
                    Conectividad_directa(i,Distancia(i,iteracion))=1;
                    Conectividad(i,Distancia(i,iteracion))=1;
                    Conectividad(Distancia(i,iteracion),i)=1;
                end
                
                for x=1:size(NV,1)
                    for y=1:size(NV,1)
                        if Conectividad_directa(x,y)==1
                            hold on,
                            h=plot([X(x,1),X(y,1)], [Y(x,1),Y(y,1)],'Color','black');
                        end
                    end
                end
                
                % Calculamos si todos los nodos estan conectados entre si
                % (condicion de paro)
                for i=1:size(NV,1)
                    for j=1:size(NV,1)
                        if Conectividad(i,j)==1
                            Conectividad(j,i)=1;
                            for k=1:size(NV,1)
                                if Conectividad(j,k)==1
                                    Conectividad(i,k)=1;
                                elseif Conectividad(i,k)==1;
                                    Conectividad(j,k)=1;
                                end
                            end
                        end
                    end
                end
                Suma=sum(Conectividad,2);
                if Suma(1,1)==size(NV,1)
                    paro=1;
                    saltos=iteracion;
                end
                
            end
            
        end
    else
        saltos=0;
        
    end
    saltos1=num2str(saltos);
    ncb=strcat('Salto:',saltos1);
    title(ncb)
else
    %%Representamos centroides
    figure;h=plot3(X(1,1),Y(1,1),Z(1,1),'.','Color',color,'Markersize',tamg);
    if size(NV,1)~=1
        for i=2:size(NV,1)
            hold on; plot3(X(i,1),Y(i,1),Z(i,1),'.','Color',color,'Markersize',tamg)
        end
    end
    xlabel('Eje x'),
    ylabel('Eje y'),
    zlabel('Eje z'),
    hold off, grid on
    paro=0;
    if size(NV,1)~=1
        for iteracion=1:size(NV,1)
            if paro==0      %Paro se vuelve 1 cuando todos los nodos esten conectados
                for i=1:size(NV,1)
                    Conectividad_directa(i,Distancia(i,iteracion))=1;
                    Conectividad(i,Distancia(i,iteracion))=1;
                    Conectividad(Distancia(i,iteracion),i)=1;
                end
                
                for x=1:size(NV,1)
                    for y=1:size(NV,1)
                        if Conectividad_directa(x,y)==1
                            hold on,
                            h=plot3([X(x,1),X(y,1)], [Y(x,1),Y(y,1)],[Z(x,1),Z(y,1)],'Color','black');
                        end
                    end
                end
                
                % Calculamos si todos los nodos estan conectados entre si
                % (condicion de paro)
                for i=1:size(NV,1)
                    for j=1:size(NV,1)
                        if Conectividad(i,j)==1
                            Conectividad(j,i)=1;
                            for k=1:size(NV,1)
                                if Conectividad(j,k)==1
                                    Conectividad(i,k)=1;
                                elseif Conectividad(i,k)==1;
                                    Conectividad(j,k)=1;
                                end
                            end
                        end
                    end
                end
                Suma=sum(Conectividad,2);
                if Suma(1,1)==size(NV,1)
                    paro=1;
                    saltos=iteracion;
                end
                
            end
            
        end
    else
        saltos=0;
    end
end
Conectividad_dir=Conectividad_directa;
if size(NV,1)-saltos>=2
for i=1:size(NV,1)
    Conectividad_directa(i,Distancia(i,saltos+1))=1;
end
end
Conectividad_dir_k_1=Conectividad_directa;
if size(NV,1)-saltos>=3
for i=1:size(NV,1)
    Conectividad_directa(i,Distancia(i,saltos+2))=1;
end
end
Conectividad_dir_k_2=Conectividad_directa;
