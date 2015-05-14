function [ squares, bestPointInSquare, bestValuesInSquare ] ...
       = hypersquare( origin, size, limit, quantityPointPerSquare, targetFunction )
%HYPERSQUARE Represent implementation of hyper square method.
    squares = zeros(limit, 15);
    bestPointInSquare = [limit, 2];
    bestValuesInSquare = [limit, 1];
    
    for i = 1 : limit
        d = size / 2;
        left = origin(1) - d;
        right = origin(1) + d;
        top = origin(2) - d;
        bottom = origin(2) + d;
        
        square = [left, top, targetFunction([left, top]), ...
                  right, top, targetFunction([right, top]), ...
                  right, bottom, targetFunction([right, bottom]), ...
                  left, bottom, targetFunction([left, bottom]), ...
                  left, top, targetFunction([left, top])];
        squares(i, :) = square;
        
        xs = generateInIntervale(left, right, quantityPointPerSquare);
        ys = generateInIntervale(top, bottom, quantityPointPerSquare);
        
        points = [xs, ys];
        values = zeros(quantityPointPerSquare, 1);
        for j = 1 : quantityPointPerSquare
            values(j) = targetFunction(points(j, :));
        end        
        
        [bestValue, index] = min(values);
        bestPoint = points(index, :);         
    
        bestPointInSquare(i, :) = bestPoint;
        bestValuesInSquare(i) = bestValue;
        
        origin = bestPoint;
        
        size = size / 2;
    end
end

function [vector] = generateInIntervale(a, b, quantity)
    vector = a + (b-a).*rand(quantity, 1);
end

