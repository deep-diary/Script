function varargout = findEnumTypes(varargin)
% findEnumTypes.m looks for loaded enumeration types in the current MATLAB
% session
if nargin > 1
    error('Too many inputs');
end
if nargout > 1
    error('Too many outputs');
end


if nargin == 0
    displaysetting = 'displayOn';
end
if nargin == 1
    allowed_strings = {'displayOff','displayOn'};
    if all(~strcmp(varargin{1},allowed_strings))
        error('Only allowed inputs are ''displayOff'' or ''displayOn''');
    end
    displaysetting = varargin{1};
end


%% Request all existing classes currently loaded:
allClasses = meta.class.getAllClasses;
allClasses = [allClasses{:}];

%% Search for classes using the EnumeratedValues property:
str = '';
counter = 1;
NameOfClass = cell(1,1);
for i = 1:length(allClasses)
    if ~isempty(allClasses(i).EnumeratedValues)
        [list,NameOfClass{counter}] = enumList(allClasses(i));
        str = sprintf('%s\n- %s\t%s\n', str, allClasses(i).Name, list);
        counter = counter + 1;
    end
end

if nargout == 1
    varargout{1} = NameOfClass;
elseif nargout > 1
    error('Too many outputs');
end

%% Create user information in command window:
if strcmp(displaysetting,'displayOn')
    if isempty(str)
        fprintf(1,'\n\tNO ENUM TYPE DEFINED\n\n');
    else
        fprintf(1,'Currently loaded Enum Types are: \n');
        fprintf(1,'%s\n\n',str);
    end
end

function [list,NameOfClass] = enumList(enumClass)
enums = enumClass.EnumeratedValues;
NameOfClass = enumClass.Name;
list = sprintf('\t');
try
    for str = [enums{:}]
        list = sprintf('%s\n\t%i\t->\t%s',list, eval(['int32(' enumClass.Name '.' str.Name ''')']), str.Name);
    end
catch
    fprintf(['Error displaying enumerated values for class ',enumClass.Name,'\n'])
end

% [EOF]
