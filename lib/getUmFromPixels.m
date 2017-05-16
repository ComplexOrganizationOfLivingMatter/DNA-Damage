function [ num_hetero_um ] = getUmFromPixels( num_hetero, rect )
%GETUMFROMPIXELS Summary of this function goes here
%   Detailed explanation goes here
    % Datos de medida de la imagen
    Tam_imagen_pix_x=1024; %pixeles
    Tam_imagen_pix_y=1024; %pixeles
    Tam_imagen_um_x=82.01; %umetro
    Tam_imagen_um_y=82.01; %umetro
    Tam_imagen_um_z=0.21; %umetro

    % Pasamos las medidas de picos de foci de pixeles a micrometro

    Rel_dist_x=Tam_imagen_um_x/Tam_imagen_pix_x;
    Rel_dist_y=Tam_imagen_um_y/Tam_imagen_pix_y;
    Rel_dist_z=Tam_imagen_um_z;
    
    Tam_imagen_rect_pix_y = rect(4); %pixeles
    Tam_imagen_rect_um_y=Tam_imagen_rect_pix_y*Rel_dist_y;

    for i=1:size(num_hetero, 2)
        num_hetero_um{i}(:,1)=num_hetero{i}(:,1)*Rel_dist_x;
        num_hetero_um{i}(:,2)=Tam_imagen_rect_um_y-(num_hetero{i}(:,2)*Rel_dist_y);
        num_hetero_um{i}(:,3)=(num_hetero{i}(:,3)-1)*Rel_dist_z;
    end

end

