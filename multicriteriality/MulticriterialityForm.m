function varargout = MulticriterialityForm(varargin)
% MULTICRITERIALITYFORM MATLAB code for MulticriterialityForm.fig
%      MULTICRITERIALITYFORM, by itself, creates a new MULTICRITERIALITYFORM or raises the existing
%      singleton*.
%
%      H = MULTICRITERIALITYFORM returns the handle to a new MULTICRITERIALITYFORM or the handle to
%      the existing singleton*.
%
%      MULTICRITERIALITYFORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTICRITERIALITYFORM.M with the given input arguments.
%
%      MULTICRITERIALITYFORM('Property','Value',...) creates a new MULTICRITERIALITYFORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MulticriterialityForm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MulticriterialityForm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MulticriterialityForm

% Last Modified by GUIDE v2.5 22-May-2015 14:47:11

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @MulticriterialityForm_OpeningFcn, ...
                       'gui_OutputFcn',  @MulticriterialityForm_OutputFcn, ...
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
% End initialization code - DO NOT EDIT
end

% --- Executes just before MulticriterialityForm is made visible.
function MulticriterialityForm_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    
    clc;
    
    global G
    G = Properties();
end

function MulticriterialityForm_OutputFcn(hObject, eventdata, handles), end

function applyButton_Callback(hObject, eventdata, handles)
    global G
    
    G.globalOptimizationType = lower(get(get(handles.optimizationTypePanel, 'SelectedObject'), 'String'));
    G.quantityPoints = str2double(get(handles.quantityPointsEdit, 'String'));
    G.names = {'x1', 'x2', 'x3'};    
    G.points = zeros(G.quantityPoints, max(size(G.names)));
    G.bounds = [
        str2double(get(handles.from1Edit, 'String')), str2double(get(handles.to1Edit, 'String'));
        str2double(get(handles.from2Edit, 'String')), str2double(get(handles.to2Edit, 'String'));
        str2double(get(handles.from3Edit, 'String')), str2double(get(handles.to3Edit, 'String'));
    ];

    functionNames = [];
    counter = 0;    
    if get(handles.function1Checkbox, 'Value') == 1
        counter = counter + 1;
        G.functions{counter} = { @(point) double(subs(lower(get(handles.function1Edit, 'String')), G.names, point)) };
        G.optimizationTypesPerFunction = { lower(get(get(handles.function1OptimizationTypePanel, 'SelectedObject'), 'String')) };        
        functionNames{counter} = 'Функция 1';
    end
    
    if get(handles.function2Checkbox, 'Value') == 1
        counter = counter + 1;
        G.functions{counter} = { @(point) double(subs(lower(get(handles.function2Edit, 'String')), G.names, point)) };
        G.optimizationTypesPerFunction{counter} = { lower(get(get(handles.function2OptimizationTypePanel, 'SelectedObject'), 'String')) };
        functionNames{counter} = 'Функция 2';
    end
    
    if get(handles.function3Checkbox, 'Value') == 1
        counter = counter + 1;
        G.functions{counter} = { @(point) double(subs(lower(get(handles.function3Edit, 'String')), G.names, point)) };
        G.optimizationTypesPerFunction{counter} = { lower(get(get(handles.function3OptimizationTypePanel, 'SelectedObject'), 'String')) };
        functionNames{counter} = 'Функция 3';
    end
    
    if get(handles.function4Checkbox, 'Value') == 1
        counter = counter + 1;
        G.functions{counter} = { @(point) double(subs(lower(get(handles.function4Edit, 'String')), G.names, point)) };
        G.optimizationTypesPerFunction{counter} = { lower(get(get(handles.function4OptimizationTypePanel, 'SelectedObject'), 'String')) };
        functionNames{counter} = 'Функция 4';
    end
    
    G.values = zeros(G.quantityPoints, counter);
    
    [h, w1]  = size(G.points); % h  - quantity of points, w1 - quantity of parameters
    [~, w2]  = size(G.values); % w2 - quantity of function
    for i = 1 : h
        for j = 1 : w1
            G.points(i, j) = generateInIntervale(G.bounds(j, 1), G.bounds(j, 2), 1); 
        end        
        for j = 1 : w2
            f = G.functions{j}{1};
            p = G.points(i, :);
            G.values(i, j) = f(p);
        end
    end   
    rowNames = cell(h, 1);
    for i = 1 : h, rowNames{i} = sprintf('P%d', i); end;         
    set(handles.pointsTable, 'RowName', rowNames);
    set(handles.pointsTable, 'ColumnName', [G.names, functionNames]);
    set(handles.pointsTable, 'Data', [G.points, G.values]);  
    
    setEnable('on', 'off', 'off', 'off');
end

function reverseButton_Callback(hObject, eventdata, handles)
    global G
    
    [h, w] = size(G.values);
    for i = 1 : w
        if ~isequal(G.globalOptimizationType, G.optimizationTypesPerFunction{i})
            for j = 1 : h
                G.values(j, i) = -G.values(j, i);
            end
        end
    end        
    
    data = [num2cell(G.points), num2cell(G.values)];
    set(handles.pointsTable, 'Data', data);
    
    setEnable('off', 'on', 'off', 'off');
end

function classificationButton_Callback(hObject, eventdata, handles)
    global G    
    
    [h, w] = size(G.values);% h - количество проектных точек, w - количество функций 
    compromises = zeros(h, 1);
    power = zeros(h, 1);   
    
    for i = 1 : h - 1
        row1 = G.values(i, :);
        for j = i + 1 : h        
            row2 = G.values(j, :);
            count = 0;
            for k = 1 : w
                if (isequal(char(G.optimizationTypesPerFunction{k}), 'max'))
                    if (row2(k) > row1(k))
                        count = count + 1;
                    end;
                else
                    if (row2(k) < row1(k))
                        count = count + 1;
                    end;
                end;
            end;
            if count == w
                compromises(i) = 1;
                if compromises(j) ~= 1
                    power(j) = power(j) + 1;
                end;
                power(i) = 0;
            else
                if count == 0
                   compromises(j) = 1;
                   if compromises(i) ~= 1
                        power(i) = power(i) + 1;
                   end;
                   power(j) = 0;
                else
                    if compromises(i) == 0 
                        compromises(i) = 0;
                    end;
                end;
            end;
        end;
    end;
    
    quantityCompromises = 0;
    
    rowNames = [];
    
    % запись в главную таблицу
    G.power = power;
    G.compromisesChar = cell(h, 1); 
    for i = 1 : h
        if compromises(i) == 1 
            G.compromisesChar{i} = 'C';
        else
            quantityCompromises = quantityCompromises + 1; 
            G.compromisesChar{i} = 'К'; 
            rowNames{quantityCompromises} = sprintf('P%d', i);            
        end
    end     
    
    header = get(handles.pointsTable, 'ColumnName');
    header = [{'К/С'}; {'Мощность'}; header];
    set(handles.pointsTable, 'ColumnName', header);

    data = [G.compromisesChar, num2cell(G.power), num2cell(G.points), num2cell(G.values)];
    set(handles.pointsTable, 'Data', data);
    
    % запись в таблицу компромиссов
    [~, w1]  = size(G.points);    
    [~, w2]  = size(G.values); 
    compromisesColumn = cell(quantityCompromises, 1);    
    power = zeros(quantityCompromises, 1);
    points = zeros(quantityCompromises, w1);
    values = zeros(quantityCompromises, w2);
    counter = 1;
    for i = 1 : h
        if compromises(i) == 0
            compromisesColumn{counter} = 'K';
            power(counter, :) = G.power(i, :);
            values(counter, :) = G.values(i, :);
            points(counter, :) = G.points(i, :);
            counter = counter + 1;
        end
    end
    G.power = power;
    G.points = points;
    G.values = values;
    data = [compromisesColumn, num2cell(G.power), num2cell(G.points), num2cell(G.values)];
    set(handles.compomisesTable, 'Data', data);
    
    header = get(handles.pointsTable, 'ColumnName');
    header(1) = {'К'};
    set(handles.compomisesTable, 'ColumnName', header, 'RowName', rowNames);
    
    width = get(handles.pointsTable, 'ColumnWidth');
    width{1} = 30;
    width{2} = 50;
    set(handles.pointsTable, 'ColumnWidth', width);
    set(handles.compomisesTable, 'ColumnWidth', width);
    
    setEnable('off', 'off', 'on', 'off');
end

function [vector] = generateInIntervale(a, b, quantity)
    vector = a + (b-a).*rand(quantity, 1);
end

function normButton_Callback(hObject, eventdata, handles)
    global G    
    
    [~, w] = size(G.values);
    for i = 1 : w
        minValue = min(G.values(:, i));
        maxValue = max(G.values(:, i));      
        G.values(:, i) = (G.values(:, i) - minValue) / (maxValue - minValue);
    end
    
    data = get(handles.compomisesTable, 'Data');
    data = [data(:, 1), num2cell(G.power), num2cell(G.points), num2cell(G.values)];
    set(handles.compomisesTable, 'Data', data);
    
    setEnable('off', 'off', 'off', 'on');
end

function additiveButton_Callback(hObject, eventdata, handles)
    global G
    
    [h, ~] = size(G.values);
    sumValues = zeros(h, 1);
    for i =  1 : h, sumValues(i) = sum(G.values(i, :)); end
    
    header = get(handles.compomisesTable, 'ColumnName');
    header = [header; {'Сумма'}];
    set(handles.compomisesTable, 'ColumnName', header);
    
    data = get(handles.compomisesTable, 'Data');
    data = [data(:, 1), num2cell(G.power), num2cell(G.points), num2cell(G.values), num2cell(sumValues)];
    set(handles.compomisesTable, 'Data', data);
    
    header = get(handles.compomisesTable, 'ColumnName');
    data = get(handles.compomisesTable, 'Data');
    rowNames = get(handles.compomisesTable, 'RowName');
    number = str2double(get(handles.quantityPointsToGetEdit, 'String'));
    [~, w] = size(data);
    result = cell(number, w) ;    
    resultRowNames = cell(number, 1);
    for i = 1 : number
        if isequal(char(G.globalOptimizationType), 'max')
            [~, index] = max(sumValues);
        else
            [~, index] = min(sumValues);
        end
        result(i, :) = data(index, :);
        resultRowNames(i) = rowNames(index);
        sumValues(index) = [];
    end
    
    set(handles.resultTable, 'ColumnName', header);
    set(handles.resultTable, 'RowName', resultRowNames);
    set(handles.resultTable, 'Data', result);
    width = get(handles.pointsTable, 'ColumnWidth');
    width{1} = 30;
    width{2} = 50;
    set(handles.resultTable, 'ColumnWidth', width);
    
    setEnable('off', 'off', 'off', 'off');
end

function setEnable(reverseButtonEnable, classificationButtonEnable, normButtonEnable, additiveButtonEnable)
    handles = guihandles();   
    set(handles.reverseButton, 'Enable', reverseButtonEnable);
    set(handles.classificationButton, 'Enable', classificationButtonEnable);
    set(handles.normButton, 'Enable', normButtonEnable);
    set(handles.additiveButton, 'Enable', additiveButtonEnable);
end

function [state] = enable(statuCode)
    if statuCode == 1, state = 'on';
    else state = 'off'; end;
end

function function1Checkbox_Callback(hObject, eventdata, handles)
    set(handles.function1Edit, 'Enable', enable(get(hObject, 'Value')));
end

function function2Checkbox_Callback(hObject, eventdata, handles)
    set(handles.function2Edit, 'Enable', enable(get(hObject, 'Value')));
end

function function3Checkbox_Callback(hObject, eventdata, handles)
    set(handles.function3Edit, 'Enable', enable(get(hObject, 'Value')));
end

function function4Checkbox_Callback(hObject, eventdata, handles)
    set(handles.function4Edit, 'Enable', enable(get(hObject, 'Value')));
end
