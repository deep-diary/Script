function [dataType, nameOutPort] = findNameMdOut(Name, varargin)
%%
    % 目的: 根据信号名，获取对应的信号类型
    % 输入：
    %       Name： 信号名称
    % 返回： dataType: 信号类型
    % 返回： nameOutPort: 带模型前缀的输出信号
    % 范例： [dataType, nameOutPort] = findNameMdOut('sTmComprCtrl_D_u32AcOffCode')
    % 说明： 比如当前模型名称是'CurrrentMode', 则如下函数输出为'sCurrrentMode_D_u32AcOffCode'
    % 作者： Blue.ge
    % 日期： 20231213
%%
        clc
        %% 输入参数处理
        p = inputParser;            % 函数的输入解析器
        addParameter(p,'mode','tail');      % pre: 将前缀替换成模型名称, tail：将模型名称添加到后缀
        
        parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值
    
        mode = p.Results.mode;
        %% 

%         Name = 'sSwitchRpm_n_u16CompRpmReq'
        [dataType, ~, ~, ~, ~] = findNameType(Name);
        nameMd = get_param(gcs,'Name');
        nameMdList = split(nameMd,'_');
        if length(nameMdList) > 2
            error('ModeName should format like ****_MdName or MdName')
        end
        nameMd = nameMdList{end};
        nameMd(1) = upper(nameMd(1));% 将首字母改成大写
        strList = split(Name,'_');
        %% 如果只有1个长度，则不进行解析
        if length(strList) == 1
            nameOutPort = Name;
            return
        end

        %% 如果有多个长度
        if strcmp(mode, 'pre') && length(strList) == 3
            if strcmp(get_param(gcs,'Name'), bdroot)  % 内部模型
                if strcmp(strList{2}, 'B')
                    prefix = 'y';
                else
                    prefix = 's';
                end        
            else
                if strcmp(strList{2}, 'B')  % 外部模型
                    prefix = 'x';
                else
                    prefix = 'r';
                end
            end

%             prefix = strList{1}(1);
            strList{1} = [prefix,nameMd];
            nameOutPort = join(strList,"_");
            nameOutPort = nameOutPort{1};
        elseif strcmp(mode, 'tail') 
            if ~strcmp(nameMd, bdroot)
                nameOutPort = [Name nameMd];
            else
                nameOutPort = Name;
            end
        elseif strcmp(mode, 'keep') 
            nameOutPort = Name;
        else
            nameOutPort = Name;
            warning('the mode only could be : pre or tail or keep, official name format is ModeName_X_SigName')
        end

end