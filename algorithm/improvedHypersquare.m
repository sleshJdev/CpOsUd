function [ squares, bestPointInSquare, bestValuesInSquare ] ...
       = improvedHypersquare( origin, size, limit, quantityPointPerSquare, scaleFactor, targetFunction )
%HYPERSQUARE Represent implementation of hyper square method.
    squares = zeros(limit, 15);
    bestPointInSquare = [limit, 2];
    bestValuesInSquare = [limit, 1];
    
    dx = size / scaleFactor;
    dy = size / scaleFactor;
    
    for i = 1 : limit        
        left = origin(1) - dx;
        right = origin(1) + dx;
        top = origin(2) - dy;
        bottom = origin(2) + dy;
        
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
        
        % offset by 'x' more that offset by 'y'
        if abs(bestPoint(1) - origin(1)) > abs(bestPoint(2) - origin(2))
            dy = dy / scaleFactor;            
        else 
            dx = dx / scaleFactor;
        end       
        
        origin = bestPoint;
    end
end

function [vector] = generateInIntervale(a, b, quantity)
    vector = a + (b-a).*rand(quantity, 1);
end

