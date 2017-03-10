function [R]=asociar_nv_heterocromatina(D1,D2)

a=D1{1,1};
b=D2;
Num_nodos=size(a,1);
Num_objetos=size(b,2);
for i=1:Num_nodos
    C1=a{i,2};
    for j=1:Num_objetos
        C2=b{1,j};
        X=[C1;C2];
        distancia=pdist(X);
        dist_square = squareform(distancia);
        dist_vector=dist_square(1,:);
        dist=dist_vector(2:end);
        dist_min(j,1)=min(dist);
    end
    [distancia obj_cerca]=min(dist_min);
    R(i,1)=i;
    R(i,2)=obj_cerca;
    R(i,3)=distancia;
end