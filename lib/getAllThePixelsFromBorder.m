function [ wholeHeterochromatin ] = getAllThePixelsFromBorder( borders )
%GETALLTHEPIXELSFROMBORDER Summary of this function goes here
%   Detailed explanation goes here
    

    for numCell = 1:size(borders, 2)
        actualHeterochromatin = borders{numCell};
        heterochromatinChanged = [];
        for numPlane = 1:max(actualHeterochromatin(:, 3))
            img = zeros(max(borders{numCell}(:, 1)), max(borders{numCell}(:, 2)));
            for i = 1:size(actualHeterochromatin, 1)
                if actualHeterochromatin(i, 3) == numPlane
                    img(actualHeterochromatin(i, 1), actualHeterochromatin(i, 2)) = 1;
                end
            end
            imgSegmented = imfill(img);
            [x, y] = find(imgSegmented);
            planes = ones(size(x, 1), 1) * numPlane;
            heterochromatinChanged = vertcat(heterochromatinChanged, [x, y, planes]);
        end
        wholeHeterochromatin{numCell} = heterochromatinChanged;
    end
end

