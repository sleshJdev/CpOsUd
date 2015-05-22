function [ squares, bestPointInSquare, bestValuesInSquare, i ] ...
       = improvedHypersquare( origin, size, limit, quantityPointPerSquare, scaleFactor, precession, targetFunction )
%HYPERSQUARE Represent implementation of hyper square method.
    squares = zeros(limit, 15);
    bestPointInSquare = [limit, 2];
    bestValuesInSquare = [limit, 1];
    
    dx = size / scaleFactor;
    dy = size / scaleFactor;
    
    left = origin(1) - dx;
    right = origin(1) + dx;
    top = origin(2) - dy;
    bottom = origin(2) + dy;
    
    for i = 1 : limit         
        fprintf('iteration %d\n', i);
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
               
        fprintf('\t best point: %s. best value %s\n', mat2str(bestPoint), bestValue);
        
        if i > 1
            if (abs(bestValuesInSquare(i) - bestValuesInSquare(i - 1))) < precession
                fprintf('\tbreak by precession condition\n');
                break;
            end        
        end
        
        xshift = abs(bestPoint(1) - origin(1));
        yshift = abs(bestPoint(2) - origin(2));
        
        % offset by 'x' more that offset by 'y'
        if xshift > yshift, factor = xshift / yshift;
        else factor = xshift / yshift; end      
        
        if factor > scaleFactor, factor = scaleFactor; end
        if factor < 1, factor = 1; end
        if factor == 0, factor = 1; end
        
        dy = dy / factor;   
        dx = dx * factor;     
        
        if sign(bestPoint(1) - origin(1)) >= 0
            left = bestPoint(1);
            right = bestPoint(1) + 2 * dx;            
        else
            left = bestPoint(1) - 2 * dx;
            right = bestPoint(1);
        end;
        
        if sign(bestPoint(2) - origin(2)) >= 0
            top = bestPoint(2);
            bottom = bestPoint(2) + 2 * dy;            
        else
            top = bestPoint(2) - 2 * dy;
            bottom = bestPoint(2);
        end               
        origin = bestPoint;
    end
end

function [vector] = generateInIntervale(a, b, quantity)
    vector = a + (b-a).*rand(quantity, 1);
end

