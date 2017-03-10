function dibujo(num_hetero_um,color)
h=1;
%Dibujamos heterocromatina
if color==2
    figure;
else
    hold on
end
for recorre=1:length(num_hetero_um)
    %Extraccion de datos
    x=num_hetero_um{recorre}(:,1);
    y=num_hetero_um{recorre}(:,2);
    z=num_hetero_um{recorre}(:,3);
    
    %Reordenamos datos para facilitar la representacion
    z_ini=z(1,1);
    X(1,1)=x(1,1);
    Y(1,1)=y(1,1);
    Z(1,1)=z(1,1);
    cont=2;
    tramos=1;
    for i=2:length(x)
        d=0;
        if z(i,1)==z_ini 
            for j=1:length(x)
                d(j)=sqrt((X(i-1)-x(j))^2+(Y(i-1)-y(j))^2+(Z(i-1)-z(j))^2);
            end
            d(find(d==0))=99;
            [min_d,ind]=min(d);
            for k=1:length(X)
                if x(ind,1)==X(k,1) && y(ind,1)==Y(k,1) && z(ind,1)==Z(k,1)
                    d(ind)=99;
                end
            end
            if d(ind)==99
                [min_d,ind]=min(d);
            end
            X(i,1)=x(ind,1);
            Y(i,1)=y(ind,1);
            Z(i,1)=z(ind,1);
        else
            tramos(cont)=i;
            cont=cont+1;
            z_ini=z(i,1);
            X(i,1)=x(i,1);
            Y(i,1)=y(i,1);
            Z(i,1)=z(i,1);
        end
    end
    tramos(cont)=length(x)+1;
    % Partimos en bloques
    if color==2
        plot3(X,Y,Z,'.b')
    elseif color==1
        plot3(X,Y,Z,'.g')
    end
    for i=1:length(tramos)-1
        Xi{i}=[X(tramos(i):tramos(i+1)-1);X(tramos(i))];
        Yi{i}=[Y(tramos(i):tramos(i+1)-1);Y(tramos(i))];
        Zi{i}=[Z(tramos(i):tramos(i+1)-1);Z(tramos(i))];
    end
    
    for i=1:length(tramos)-1
        hold on;plot3(Xi{i},Yi{i},Zi{i},'Color','black');
        
        grid on
    end
    
end


