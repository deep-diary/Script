function [SigMatch, SigDismatch] = createModBusSelector(mdPath, selectorPath, varargin)
%%
% 目的: 为模型生成输入Selector, 
% 输入：
%       模型路径
% 返回：None
% 范例：[SigMatch, SigDismatch] = createModBusSelector(gcb, 'NA');
% 说明：1. 鼠标点击在子模型上，2. 在命令窗口运行此函数
% 作者： Blue.ge
% 日期： 20240513
%%
    %% 参数处理
%      clc
    % 获取系统坐标
    p = inputParser;            % 函数的输入解析器
    addParameter(p,'prefix','in');  
    addParameter(p,'isEnPrefix',false);  
   
    % 输入参数处理   
    parse(p,varargin{:});       % 对输入变量进行解析，如果检测到前面的变量被赋值，则更新变量取值

    prefix = p.Results.prefix;
    isEnPrefix = p.Results.isEnPrefix;
    
    %% 处理Selector 路径

    ModelName = get_param(mdPath,'ModelName');
    disp('------------------------------------');
%     disp([ModelName ':']);
%     disp('Selector和模型连接开始');

    if strcmp(selectorPath, 'NA')
        ModelPath = get_param(mdPath,'Parent');
        busName = ModelName;
        selectorPath = [ModelPath,'/',busName];

        BusSelector_Handle=get_param(selectorPath,'Handle');
    else
        BusSelector_Handle=get_param(selectorPath,'Handle');
    end
    BusIpSigs_cells=get_param(BusSelector_Handle,"InputSignals");

    %% 找到模型输入端口
    
    load_system(ModelName);
    Inports_obj=find_system(ModelName,'SearchDepth',1,'BlockType','Inport');
    
    %% 信号名拼接赋值给BusSelect输出信号
    SigMatch = {};
    SigDismatch = {};
    FindNum =  0;
    NoFindNum = 0;
    MismatchStartIdent = 'Err------';

    Outport_Name0=get_param(Inports_obj{1},'Name');
    busOutSignal_list=['Tasks.Task_100ms_TmSw.' Outport_Name0];

%     K = matches(BusIpSigs_cells{1,1}{1,2}{2}{2},Outport_Name0)
%     a=find(K);

    for i=2:length(Inports_obj)
        findFlag = false;
        Outport_Name=get_param(Inports_obj{i},'Name');
        if isEnPrefix && endsWith(Outport_Name,prefix)
            Outport_Name=extractBefore(Outport_Name,length(Outport_Name)-length(prefix)+1);
        end
        busOutSignal_fullName = [MismatchStartIdent, Outport_Name];
        for n_cell=2:length(BusIpSigs_cells)
            K=matches(BusIpSigs_cells{n_cell,1}{1,2},Outport_Name);
            a=find(K);
            if ~isempty(a)
                busOutSignal_frontName=BusIpSigs_cells{n_cell,1}{1,1};
                busOutSignal_fullName=[busOutSignal_frontName '.' Outport_Name];
                % 可以找到匹配的信号
                findFlag = true;
                FindNum = FindNum + 1;
                SigMatch{FindNum,1} = ModelName;
                SigMatch{FindNum,2} = Outport_Name;
                break
            end
        end
        if ~findFlag
            NoFindNum = NoFindNum + 1;
            SigDismatch{NoFindNum,1} = ModelName;
            SigDismatch{NoFindNum,2} = Outport_Name;
        end
        busOutSignal=[',' busOutSignal_fullName];
        busOutSignal_list=[busOutSignal_list busOutSignal];
    end
    
    set_param(BusSelector_Handle,"OutputSignals",string(busOutSignal_list));

    %% 删除已有连线并重新连线
  %删除BusSelect和参考模型之间的已有连线
  BusLine = get_param(BusSelector_Handle,'LineHandles');
  LinToBeDele = BusLine.Outport;
  for ka = 1 :length(LinToBeDele)
      if(LinToBeDele(ka) > 0)
          delete_line(LinToBeDele(ka));
      end
  end

    %连接BusSelector Out和参考模型的Inport
  %参考模型Inport从上到下按照Port序号大小的顺序显示在参考模型上
  %BusSelector也是按照参考模型Inport的Port序号大小的顺序显示
  ModelPortHan = get_param(mdPath,'PortHandles');
  ModelInportHan = ModelPortHan.Inport;
  BusSelPortHan = get_param(BusSelector_Handle,'PortHandles');
  BusSelOutportHan = BusSelPortHan.Outport;
  
%   busNames = get_param(BusSelector_Handle,'OutputSignalNames');
  busNames = split(busOutSignal_list,',');
  for i = 1 :length(ModelInportHan)
      %获取在all中能找到的Port对应的句柄
      InPortHan = ModelInportHan(i);
      SelecOutPortHan = BusSelOutportHan(i);
      name = busNames{i};
      if startsWith(name, MismatchStartIdent)
          continue
      end
      add_line(ModelPath,SelecOutPortHan,InPortHan);
  end
  %% 调整bus尺寸
%   mdPath = gcb
%   BusSelector_Handle = gcbh
  posMd = get_param(mdPath,'Position');
  posSelector = [posMd(1)-300-15, posMd(2) posMd(1)-300+15 posMd(4)];
  set_param(BusSelector_Handle,'Position',posSelector);

  %% 显示结果信息
  fprintf('Selector和模型连接成功: 成功匹配%d个，未匹配%d个. \n',FindNum, NoFindNum);
  errSize = size(SigDismatch,1);
  if errSize
      warning('未匹配信号如下:\n');
      for i=1:size(SigDismatch,1)
          warning('%s---->%s\n',SigDismatch{1}, SigDismatch{2});
      end
  else
    fprintf('%s: 所有输入信号均已匹配连接成功!\n', ModelName);
  end
end
