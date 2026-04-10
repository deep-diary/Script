function changeGotoSize(path, varargin)
%CHANGEGOTOSIZE 根据gotoTag 改变goto 尺寸
%   CHANGEGOTOSIZE(PATHMD) 使用默认宽度调整指定goto的大小
%   CHANGEGOTOSIZE(PATHMD, 'Parameter', Value, ...) 使用指定参数调整goto from大小
%
%   输入参数:
%      pathMd       - 模型路径或句柄 (字符串或数值)
%
%   可选参数（名值对）:
%      'wid'        - goto 高度 (正整数), 默认值: 14
%      'font'       - 每个字符占据的像素 (正整数), 默认值: 60
%
%   功能描述:
%      根据gotoTag 标签长度，自动改变goto 尺寸
%
%   示例:
%      changeGotoSize(gcb)
%      changeGotoSize(gcs)
%      changeGotoSize(bdroot)
%
%   注意事项:

%
%   参见: GET_PARAM, SET_PARAM, FINDMODPORTS, CHANGELINEARRANGE
%
%   作者: Blue.ge
%   版本: 1.1
%   日期: 20231020

    %% 输入参数处理
    p = inputParser;
    addParameter(p, 'wid', 14, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    addParameter(p, 'font', 7, @(x)validateattributes(x,{'numeric'},{'positive','scalar'}));

    
    parse(p, varargin{:});
    
    wid = p.Results.wid;
    font = p.Results.font;


    %% 获取所有的goto from 路径
    pathList = {}
    if strcmp(path, bdroot)
        fromBlocks = find_system(path, 'BlockType', 'From');
        gotoBlocks = find_system(path, 'BlockType', 'Goto');
        pathList = [fromBlocks;gotoBlocks]
    elseif strcmp(path, gcs)
        fromBlocks = find_system(path, 'SearchDepth',1,'BlockType', 'From');
        gotoBlocks = find_system(path, 'SearchDepth',1,'BlockType', 'Goto');
        pathList = [fromBlocks;gotoBlocks]
    else
        pathList{1} = path
    end
    %% 改变 goto 属性
    for i=1:length(pathList)
        pth = pathList{i};
        pos = get_param(pth,'Position');
        tag = get_param(pth,'GotoTag');
        pos_new = [pos(1:2) pos(1) + length(tag)*font pos(2) + wid];
        set_param(pth,'Position', pos_new)
    end
end