function varargout = MainForm(varargin)
    clc;    
    disp('MainForm');
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @MainForm_OpeningFcn, ...
                       'gui_OutputFcn',  @MainForm_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end

function MainForm_OpeningFcn(hObject, eventdata, handles, varargin)
    disp('Opening');       
    handles.output = hObject;
    guidata(hObject, handles);
    
    
    % --- config --- %
    addpath ./algorithm/
    addpath ./util/
    addpath ./trash/
    addpath ./multicriteriality/
    addpath ./multicriteriality/lib/
end

function varargout = MainForm_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
end

% --------------------------- listeners --------------------------- %
function bisectionButton_Callback(hObject, eventdata, handles)   
    global NAMES% --- GLOBAL DEFINE   
    global PARAMETERS% --- GLOBAL DEFINE   
    global FUNCTION_EXPRESSION% --- GLOBAL DEFINE    
    
    % define symbolic variable  
    for i = 1 : max(size(NAMES))                 
        eval(sprintf('syms %s', NAMES{i}));
        eval(sprintf('%s = %d;', NAMES{i}, PARAMETERS(i, 1))); 
    end   
    minX = min(PARAMETERS(:, 2));
    maxX = max(PARAMETERS(:, 3));
    
    stepSize = str2double(get(handles.bisectionStepSizeEdit, 'String'));
    
    targetFunction = @(x) double( subs(FUNCTION_EXPRESSION, NAMES, x) );    
    [~, ~, xMin, yMin] = bisection(minX, maxX, stepSize, targetFunction);
    
    if(isequal(max(size(NAMES)), 1))
        set(handles.xMinEdit, 'String', xMin);
        set(handles.yMinEdit, 'String', yMin);
        set(handles.zMinEdit, 'String', '-');
    end
    
    hold on;
    plot(handles.mainAxes, xMin, yMin, 'rs');
    hold off;
end

function hookeJeevesButton_Callback(hObject, eventdata, handles)
    global NAMES% --- GLOBAL DEFINE   
    global PARAMETERS% --- GLOBAL DEFINE   
    global FUNCTION_EXPRESSION% --- GLOBAL DEFINE   
    
    % define symbolic variable  
    for i = 1 : max(size(NAMES))                 
        eval(sprintf('syms %s', NAMES{i}));
        eval(sprintf('%s = %d;', NAMES{i}, PARAMETERS(i, 1))); 
    end       
    targetFunction = @(p) double( subs(FUNCTION_EXPRESSION, NAMES, p) );
    
    e  = str2double(get(handles.hookeJeevesPrecessionEdit, 'String'));%precession      
    s = str2double(get(handles.hookeJeevesStepSizeEdit, 'String'));%step size     
    mi = str2double(get(handles.hookeJeevesMaximumStepsEdit, 'String'));%max iterations
    ss = max(size(NAMES));%space size
    o = PARAMETERS(:, 1);%origin
    lb = PARAMETERS(:, 2);%lower border
    ub = PARAMETERS(:, 3);%upper border
    
    ms = zeros(ss, 1);
    sa = zeros(ss, 1);%steps
    
    ms = ms + 1e-5;% minimum step size
    sa = sa + s;% steps
    
    [X,BestF,Iters, path, values] = hookejeeves( ss, o, sa, ms, e, mi, lb, ub, targetFunction);  
    
    if(isequal(ss, 2))
        set(handles.xMinEdit, 'String', X(1));
        set(handles.yMinEdit, 'String', X(2));
        set(handles.zMinEdit, 'String', BestF);
    end
    
    disp('Result');
    disp(['Best point ', mat2str(X)]);
    disp(['Best value ', num2str(BestF)]);
    disp(['Iterations ', num2str(Iters)]);
    
    hold on;
    plot3(handles.mainAxes, path(1,:), path(2,:), values,...
                    '--rs','LineWidth',1,...
                    'MarkerEdgeColor','r',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',2)
    plot3(handles.mainAxes, X(1), X(2), BestF,...
                    '--rs','LineWidth',5,...
                    'MarkerEdgeColor','r',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',10)
    hold off;    
end

function hyperSquareCalculator(handles, isImprovedHyperSquareMethod)
    global NAMES% --- GLOBAL DEFINE   
    global PARAMETERS% --- GLOBAL DEFINE   
    global FUNCTION_EXPRESSION% --- GLOBAL DEFINE   
    
     % define symbolic variable  
    for i = 1 : max(size(NAMES))                 
        eval(sprintf('syms %s', NAMES{i}));
        eval(sprintf('%s = %d;', NAMES{i}, PARAMETERS(i, 1))); 
    end       
    targetFunction = @(p) double( subs(FUNCTION_EXPRESSION, NAMES, p) )
    
    squareSize = str2double(get(handles.hyperSquareStepSizeEdit, 'String'));
    maxIterations = str2double(get(handles.hyperSquareMaximumStepEdit, 'String'));
    quantityPoints = str2double(get(handles.hyperSquareQuantityPointsPerSquareEdit, 'String'));
    
    color = 'r';
    if isImprovedHyperSquareMethod
        color = 'y';
        scaleFactor = str2double(get(handles.improvedScaleFactorEdit, 'String'));
        precession = str2double(get(handles.improvedPrecessionEdit, 'String'));
        [squares, points, values, iterations] = improvedHypersquare(PARAMETERS(:, 1), squareSize, maxIterations, quantityPoints, scaleFactor, precession, targetFunction);
        maxIterations = iterations;
    else
       [squares, points, values] = hypersquare(PARAMETERS(:, 1), squareSize, maxIterations, quantityPoints, targetFunction);     
    end  
   
    [bestValue, index] = min(values);
    bestPoint = points(index, :);
    
    set(handles.xMinEdit, 'String', bestPoint(1));
    set(handles.yMinEdit, 'String', bestPoint(2));
    set(handles.zMinEdit, 'String', bestValue); 
    
    hold on;
    ps = zeros(3, maxIterations);
    for i = 1 : maxIterations
      for j = 1 : 5
          ps(1, j) = squares(i, 3 * (j - 1) + 1);
          ps(2, j) = squares(i, 3 * (j - 1) + 2);
          ps(3, j) = squares(i, 3 * (j - 1) + 3);
      end          
      
        plot3(handles.mainAxes, ps(1, :), ps(2, :), ps(3, :),...
                    color,'LineWidth',2,...
                    'MarkerEdgeColor',color,...
                    'MarkerFaceColor',color,...
                    'MarkerSize',2)       
        plot3(handles.mainAxes, points(i, 1), points(i, 2), values(i),...
                    '--rs','LineWidth',2,...
                    'MarkerEdgeColor','g',...
                    'MarkerFaceColor','g',...
                    'MarkerSize',2)
    end
    plot3(handles.mainAxes, bestPoint(1), bestPoint(2), bestValue,...
                    '--rs','LineWidth',3,...
                    'MarkerEdgeColor','r',...
                    'MarkerFaceColor','r',...
                    'MarkerSize',3)
    hold off;  
end

function hyperSquareButton_Callback(hObject, eventdata, handles)
     hyperSquareCalculator(handles, false);
end

function improvedHyperSquareButton_Callback(hObject, eventdata, handles)
    hyperSquareCalculator(handles, true);
end

function windowMenu_Callback(hObject, eventdata, handles)
    MulticriterialityForm();
end

function setButton_Callback(hObject, eventdata, handles)
    global NAMES% --- GLOBAL DEFINE   
    
    selectedParameterIndex = get(handles.parametersListbox, 'Value');
    
    name    = get(handles.parameterNameEdit, 'String');
    initial = get(handles.initialValueEdit, 'String');
    min     = get(handles.minValueEdit, 'String');
    max     = get(handles.maxValueEdit, 'String');        
    
    NAMES{selectedParameterIndex - 1} = char(name);
    setParameters(selectedParameterIndex - 1, initial, min, max);
    
    parameterString = format(name, initial, min, max);
    writeParameterToListbox(parameterString, handles.parametersListbox, selectedParameterIndex);
end     
    
function parametersListbox_Callback(hObject, eventdata, handles)
    global NAMES% --- GLOBAL DEFINE   
   
    index = get(hObject,'Value') - 1;% -1, without title
    if isequal(index, 0)
        return
    end
    
    name    = NAMES{index};
    [initial, min, max] = getParameters(index);   
    
    set(handles.parameterNameEdit, 'String', name);
    set(handles.initialValueEdit, 'String', initial);
    set(handles.minValueEdit, 'String', min);
    set(handles.maxValueEdit, 'String', max);    
end

function okFunctionExpressionButton_Callback(hObject, eventdata, handles)
    defineParameters(handles);
end

function buildGrapgicButton_Callback(hObject, eventdata, handles)
    global NAMES% --- GLOBAL DEFINE   
    global PARAMETERS% --- GLOBAL DEFINE   
    global FUNCTION_EXPRESSION% --- GLOBAL DEFINE    
     
    quantity = max(size(NAMES));
    if isequal(quantity, 1)
        rotate3d off;
        [xV, yV, ~] = graphicBuilder(FUNCTION_EXPRESSION, NAMES, PARAMETERS(:, 1), PARAMETERS(:, 2), PARAMETERS(:, 3));
        plot(handles.mainAxes, xV, yV);
    elseif isequal(quantity, 2)            
        selectedType = get(get(handles.viewTypePanel, 'SelectedObject'),'Tag'); 
        isGraphic = isequal(selectedType, 'graphicRadioButton');        
        [xM, yM, zM] = graphicBuilder(FUNCTION_EXPRESSION, NAMES, PARAMETERS(:, 1), PARAMETERS(:, 2), PARAMETERS(:, 3));
        if isGraphic           
            rotate3d on;     
            mesh(handles.mainAxes, xM, yM, zM); 
        else
            rotate3d off;
            [C, h] = contour(xM, yM, zM, [1, 10, 100, 1000]);
            clabel(C, h);
        end
    end           
end

function defineParameters(handles)
    global NAMES% --- GLOBAL DEFINE   
    global PARAMETERS% --- GLOBAL DEFINE   
    global FUNCTION_EXPRESSION% --- GLOBAL DEFINE
    
    % default
    minDefault = -5;
    maxDefault = 5;
    initialDefault = 2;
    
    FUNCTION_EXPRESSION = get(handles.expressionFunctionEdit, 'String'); 
%     FUNCTION_EXPRESSION = FUNCTION_EXPRESSION{1};
    if ~isempty(FUNCTION_EXPRESSION)        
        symbolicParameters = symvar(FUNCTION_EXPRESSION);
        quantity = max(size(symbolicParameters));

        NAMES = cell(quantity, 1);    
        PARAMETERS = zeros(quantity, 3);    
        
        parameterString = format('Name', 'Initial', 'Min', 'Max');
        set(handles.parametersListbox, 'String', []);                
        writeParameterToListbox(parameterString, handles.parametersListbox, -1); 
        
        for i = 1 : quantity
            parameterName = symbolicParameters(i);        
            
            % add to array
            NAMES{i} = char(parameterName);
            setParameters(i, initialDefault, minDefault, maxDefault);
            
            % add to listbox
            parameterString = buildParameterString(i);
            writeParameterToListbox(parameterString, handles.parametersListbox, -1);
        end 
    end
end

function writeParameterToListbox(parameterString, listbox, index)
    list =  get(listbox, 'String');        
    if isequal(index, -1)        
        list = [list; parameterString];        
    else
        list(index, :) = parameterString;     
    end
    set(listbox, 'String', list);
end

function [result] = calculate()
    global NAMES% --- GLOBAL DEFINE   
    global PARAMETERS% --- GLOBAL DEFINE   
    global FUNCTION_EXPRESSION% --- GLOBAL DEFINE
    
    symbolicParameters = symvar(FUNCTION_EXPRESSION);
    quantity = max(size(symbolicParameters));
    
    % define symbolic variable  
    for i = 1 : quantity                 
        eval(sprintf('syms %s', NAMES{i}));
        eval(sprintf('%s = %d;', NAMES{i}, PARAMETERS(i, 1))); 
    end   
    
    result = subs(FUNCTION_EXPRESSION, NAMES, PARAMETERS(:, 1));
end

function [parameterString] = buildParameterString(index)
    global NAMES% --- GLOBAL DEFINE      
    
    name    = char(NAMES(index));
    [initial, min, max] = getParameters(index);
    
    parameterString = format(name, initial, min, max);
end

function [initial, min, max] = getParameters(index)
    global PARAMETERS% --- GLOBAL DEFINE   

    initial = num2str(PARAMETERS(index, 1));
    min     = num2str(PARAMETERS(index, 2));    
    max     = num2str(PARAMETERS(index, 3));  
end

function setParameters(index, initial, min, max)
    global PARAMETERS% --- GLOBAL DEFINE   
    
    if ischar(initial),
        PARAMETERS(index, 1) = str2double(initial);
    else
        PARAMETERS(index, 1) = initial;
    end
    
    if ischar(min),
        PARAMETERS(index, 2) = str2double(min);
    else
        PARAMETERS(index, 2) = min;
    end
    
    if ischar(max),
        PARAMETERS(index, 3) = str2double(max);
    else
        PARAMETERS(index, 3) = max;
    end 
end

function [parameterString] = format(name, initial, min, max)
    parameterString = sprintf('%20s %20s %20s %20s\n', num2str(name), num2str(initial), num2str(min), num2str(max));
end
