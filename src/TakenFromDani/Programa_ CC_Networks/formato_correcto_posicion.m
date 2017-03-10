function posicion=formato_correcto_posicion(D)
for i=1:size(D,1)
    posicion(i,1)=D{i,2}(1,1);
    posicion(i,2)=D{i,2}(1,2);
    posicion(i,3)=D{i,2}(1,3);
end