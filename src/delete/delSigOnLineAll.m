function delSigOnLineAll(varargin)
%%
% 目的: 删掉被引用模型的所有的信号解析
% 输入：
%       mode: inport, outport, both
% 返回：已经成功创建的端口列表
% 范例：delSigOnLineAll(), 默认为both
% 范例：delSigOnLineAll('mode','inport'),
% 范例：delSigOnLineAll('mode','outport'),
% 范例：delSigOnLineAll('mode','both'),
% 说明：1. 打开架构模型，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20231018
%%
    clc
    %% 输入参数处理
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'mode','both');      % 设置变量名和默认参数
    
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    mode = p.Results.mode;

    %% 删除所有子模型的解析信号
    ModelReference = find_system(gcs,'SearchDepth',1,'BlockType','ModelReference');
    for i=1:length(ModelReference)
%         mdName = get_param(ModelReference{i}, 'ModelName');
%         delSigOnLine(mdName, mode);

        delSigOnLine(ModelReference{i}, mode);
    end
        
end
