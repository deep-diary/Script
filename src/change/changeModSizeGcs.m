function changeModSizeGcs(varargin)
%CHANGEMODSIZEGCS 调整当前Simulink页面中子模型的大小和布局
%   CHANGEMODSIZEGCS() 使用默认参数调整模型大小和布局
%   CHANGEMODSIZEGCS('Parameter', Value, ...) 使用指定参数调整模型
%
%   输入参数（名值对）:
%      'wid'         - 子模型宽度 (正整数), 默认值: 400
%      'xStp'        - 水平间距 (正整数), 默认值: 400
%      'yStp'        - 垂直间距 (正整数), 默认值: 60
%      'rows'        - 布局行数 (正整数), 默认值: 0 (不进行行列布局)
%
%   示例:
%      changeModSizeGcs()
%      changeModSizeGcs('rows', 2)
%      changeModSizeGcs('wid', 500, 'rows', 2, 'xStp', 300, 'yStp', 100)
%
%   注意事项:
%      1. 使用前需要打开目标Simulink模型
%      2. 当rows=0时，只调整模型大小，不改变布局
%      3. 布局完成后会自动整理连线
%
%   参见: GET_PARAM, SET_PARAM, GCS
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 20231020

    %% 输入参数处理
    p = inputParser;
    addParameter(p, 'wid', 400, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    addParameter(p, 'xStp', 800, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    addParameter(p, 'yStp', 60, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    addParameter(p, 'rows', 0, @(x)validateattributes(x,{'numeric'},{'nonnegative','scalar'}));
    
    parse(p, varargin{:});
    
    wid = p.Results.wid;
    xStp = p.Results.xStp;
    yStp = p.Results.yStp;
    rows = p.Results.rows;

    %% 获取当前系统中的所有子系统
    subs = find_system(gcs, 'SearchDepth', 1, 'BlockType', 'SubSystem');
    
    % 如果不是根层级，移除当前系统本身
    if ~strcmp(gcs, bdroot)  
        subs = subs(2:end);
    end
    
    if isempty(subs)
        warning('未找到需要调整的子系统。');
        return;
    end

    firstSub = get_param(subs{1}, 'Handle');

    %% 调整所有子系统的大小
    for i = 1:length(subs)
        changeModSize(subs{i}, 'wid', wid);
    end

    %% 按行列重新布局子系统
    if rows > 0
        arrangeSubsystems(subs, firstSub, rows, wid, xStp, yStp);
    end

    %% 整理所有子系统的连线
    for i = 1:length(subs)
        changeLineArrange('path', subs{i});
    end
end

function arrangeSubsystems(subs, firstSub, rows, wid, xStp, yStp)
    % 获取基准位置
    posBase = get(firstSub).Position;
    modNums = length(subs);
    rosMods = ceil(modNums / rows);
    
    heightMax = 0;
    
    shiftY = 0;
    for i = 1:rows
        shiftX = 0;
        shiftY = shiftY + yStp + heightMax;
        pos = posBase + [shiftX shiftY shiftX shiftY];
        
        heightMax = 0;  % 重置当前行的最大高度
        for j = 1:rosMods
            idx = (i-1)*rosMods + j;
            if idx > modNums
                break
            end
            
            % 设置位置
            set_param(subs{idx}, 'Position', pos);
            
            % 更新X轴位置
            shiftX = wid + xStp;
            pos = pos + [shiftX 0 shiftX 0];
            
            % 更新当前行的最大高度
            curPos = get_param(subs{idx}, 'Position');
            height = curPos(4) - curPos(2);
            heightMax = max(heightMax, height);
        end
    end
end