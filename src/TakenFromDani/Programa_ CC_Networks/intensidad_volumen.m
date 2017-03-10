function I=intensidad_volumen(pixeles, intensidades,rect)

i=1;
final=0;
obj=cell2mat(pixeles(:,1));
for num_obj=1:max(obj)
    cont=1;
    il=[];
    while pixeles{i,1}==num_obj && final==0
        corte=pixeles{i,2};
        p=intensidades{1,corte};
        p_rect=imcrop(p,rect);
        for j=1:size(pixeles{i,3},1)
            fila=j+cont-1;
            il(fila,1)=p_rect(pixeles{i,3}(j,2),pixeles{i,3}(j,1));
        end
        I{1,num_obj}=il;
        cont=cont+size(pixeles{i,3},1);
        if size(pixeles,1)==i
            final=1;
        else
            i=i+1;
        end
    end
end
