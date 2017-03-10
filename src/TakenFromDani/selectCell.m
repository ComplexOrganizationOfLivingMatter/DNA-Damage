function [numCell,rect] = selectCell(fileName, numCell)
%Developed by Daniel Sanchez-Gutierrez
%Function known as recorte
%
% Modified by Pablo Vicente-Muneura

load (fileName)
nameFileSplitted = strsplit(fileName, '\');
nameFileSplittedNoExtension = strsplit(nameFileSplitted{end}, '.');
nameFileSplittedNoExtension = nameFileSplittedNoExtension{1};



im=imagesOfSerieByChannel;
pl=imagesOfSerieByChannel(:, 2);
[H,W,~]=size(im{1,1});
Long=size(im, 1);

%% Proyeccion de todos los planos
proyeccion=pl{1,1};
for k=1:Long-1
    maximo = max(proyeccion,pl{1+k});
    proyeccion=maximo;
end

figure, imshow(proyeccion),title('Proyeccion de todo los planos')
proy=proyeccion;

% Escogemos ROI

limite=2;
% figure, imshow(proy);
h = impositionrect(gca, [2 2 350 350]); % for older version of IP toolbox
api = iptgetapi(h);
fcn = makeConstrainToRectFcn('imrect',[limite W-limite],[limite H-limite]);
api.setPositionConstraintFcn(fcn);
%setResizable(h,0)
pause
[imageCropped, rect] = imcrop(proy,floor(api.getPosition())-1);
imwrite(proy, strcat('results\segmentation\', nameFileSplitted{end - 1}, '\', nameFileSplittedNoExtension,'\image', '.jpg'))
imwrite(imageCropped, strcat('results\segmentation\', nameFileSplitted{end - 1}, '\', nameFileSplittedNoExtension, '\image', '_Cell_', numCell, '.jpg'))
close;