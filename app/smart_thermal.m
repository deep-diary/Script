classdef smart_thermal < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        FileMenu                      matlab.ui.container.Menu
        HelpMenu                      matlab.ui.container.Menu
        ScriptInstructionMenu         matlab.ui.container.Menu
        PCMUInstructionMenu           matlab.ui.container.Menu
        VCUInstructionMenu            matlab.ui.container.Menu
        AboutMenu                     matlab.ui.container.Menu
        Toolbar                       matlab.ui.container.Toolbar
        OpenTemplate                  matlab.ui.container.toolbar.PushTool
        LogTextArea                   matlab.ui.control.TextArea
        TabGroup                      matlab.ui.container.TabGroup
        HomeTab                       matlab.ui.container.Tab
        Image                         matlab.ui.control.Image
        ChangeLogPanel                matlab.ui.container.Panel
        VersionTextArea               matlab.ui.control.TextArea
        VersionTextAreaLabel          matlab.ui.control.Label
        ModelTab                      matlab.ui.container.Tab
        TabGroup2                     matlab.ui.container.TabGroup
        AddTab                        matlab.ui.container.Tab
        TabGroup3                     matlab.ui.container.TabGroup
        DefaultTab                    matlab.ui.container.Tab
        SubModRowsSpinner             matlab.ui.control.Spinner
        SubModRowsSpinnerLabel        matlab.ui.control.Label
        createDebugButton             matlab.ui.control.Button
        createSubModButton            matlab.ui.control.Button
        createSubmodInfoButton        matlab.ui.control.Button
        CreateModTab                  matlab.ui.container.Tab
        Label                         matlab.ui.control.Label
        createModeButton              matlab.ui.control.Button
        dispNameSwitch                matlab.ui.control.Switch
        dispNameSwitchLabel           matlab.ui.control.Label
        testValueSwitch               matlab.ui.control.Switch
        testValueSwitchLabel          matlab.ui.control.Label
        logValueSwitch                matlab.ui.control.Switch
        logValueSwitchLabel           matlab.ui.control.Label
        resoveValueSwitch             matlab.ui.control.Switch
        resoveValueSwitchLabel        matlab.ui.control.Label
        EnableOutSwitch               matlab.ui.control.Switch
        EnableOutSwitchLabel          matlab.ui.control.Label
        EnableInSwitch                matlab.ui.control.Switch
        EnableInSwitchLabel           matlab.ui.control.Label
        InsertBlockDropDown           matlab.ui.control.DropDown
        InsertBlockDropDownLabel      matlab.ui.control.Label
        GotoHalfLengthSlider          matlab.ui.control.Slider
        GotoHalfLengthSliderLabel     matlab.ui.control.Label
        OutTypeDropDown               matlab.ui.control.DropDown
        OutTypeDropDownLabel          matlab.ui.control.Label
        InTypeDropDown                matlab.ui.control.DropDown
        InTypeDropDownLabel           matlab.ui.control.Label
        CreatePortTab                 matlab.ui.container.Tab
        ReloadButton                  matlab.ui.control.Button
        EditInTemplateButton          matlab.ui.control.Button
        template                      matlab.ui.control.Table
        createPortsGotoButton         matlab.ui.control.Button
        createPortsButton             matlab.ui.control.Button
        CreateGotoTab                 matlab.ui.container.Tab
        createGotoBasedPortsButton_3  matlab.ui.control.Button
        topLevEditField               matlab.ui.control.EditField
        topLevEditFieldLabel          matlab.ui.control.Label
        createPortsGotoUpdateLoopButton  matlab.ui.control.Button
        createPortsGotoUpdateButton   matlab.ui.control.Button
        createGotoUselessButton       matlab.ui.control.Button
        CreateBusTab                  matlab.ui.container.Tab
        CreateBusGotoButton           matlab.ui.control.Button
        CreateBusPortButton           matlab.ui.control.Button
        createSwitchCaseTab           matlab.ui.container.Tab
        createSwitchCaseButton        matlab.ui.control.Button
        RemoveButton                  matlab.ui.control.Button
        ClearAllButton                matlab.ui.control.Button
        AddButton                     matlab.ui.control.Button
        CaseNameEditField             matlab.ui.control.EditField
        CaseNameEditFieldLabel        matlab.ui.control.Label
        CaseListEditField             matlab.ui.control.EditField
        CaseListEditFieldLabel        matlab.ui.control.Label
        CaseInTextArea                matlab.ui.control.TextArea
        CaseInTextAreaLabel           matlab.ui.control.Label
        SigNamesTextArea              matlab.ui.control.TextArea
        SigNamesTextAreaLabel         matlab.ui.control.Label
        SwitchCaseTable               matlab.ui.control.Table
        CreateInterfaceTab            matlab.ui.container.Tab
        creatTmBaseButton             matlab.ui.control.Button
        creatTmOutButton              matlab.ui.control.Button
        creatIFOutButton              matlab.ui.control.Button
        creatIFInButton               matlab.ui.control.Button
        DeleteTab                     matlab.ui.container.Tab
        GridLayout                    matlab.ui.container.GridLayout
        UselessOutBlockDropDown       matlab.ui.control.DropDown
        UselessOutBlockDropDownLabel  matlab.ui.control.Label
        UselessInBlockDropDown        matlab.ui.control.DropDown
        UselessInBlockDropDownLabel   matlab.ui.control.Label
        delGcsAllButton               matlab.ui.control.Button
        delUselessPortButton          matlab.ui.control.Button
        ChangeTab                     matlab.ui.container.Tab
        SigNeedChgTypeEditField       matlab.ui.control.EditField
        SigNeedChgTypeEditFieldLabel  matlab.ui.control.Label
        GcsArrangeRowsSpinner         matlab.ui.control.Spinner
        GcsArrangeRowsSpinnerLabel    matlab.ui.control.Label
        NewNameEditField              matlab.ui.control.EditField
        NewNameEditFieldLabel         matlab.ui.control.Label
        OldNameEditField              matlab.ui.control.EditField
        OldNameEditFieldLabel         matlab.ui.control.Label
        changeSigTypeButton           matlab.ui.control.Button
        changeModSizeGcsButton        matlab.ui.control.Button
        changeModSizeButton           matlab.ui.control.Button
        changeModPortTypeButton       matlab.ui.control.Button
        changeModPortNameButton       matlab.ui.control.Button
        changePortBlockPosAllButton   matlab.ui.control.Button
        FindTab                       matlab.ui.container.Tab
        PortTypeDropDown              matlab.ui.control.DropDown
        PortTypeDropDownLabel         matlab.ui.control.Label
        findModPortsButton            matlab.ui.control.Button
        TestTab                       matlab.ui.container.Tab
        HarnessHistoryParamsPanel     matlab.ui.container.Panel
        HarnessParamsListBox          matlab.ui.control.ListBox
        CaseTreePanel                 matlab.ui.container.Panel
        CaseListTree                  matlab.ui.container.Tree
        DelParamButton                matlab.ui.control.Button
        DemoButton                    matlab.ui.control.Button
        createHarnessButton           matlab.ui.control.Button
        GetPortsButton                matlab.ui.control.Button
        CaseTable                     matlab.ui.control.Table
        NextStepDropDown              matlab.ui.control.DropDown
        NextStepDropDownLabel         matlab.ui.control.Label
        LastStepDropDown              matlab.ui.control.DropDown
        LastStepDropDownLabel         matlab.ui.control.Label
        DelCaseButton                 matlab.ui.control.Button
        AddCaseButton                 matlab.ui.control.Button
        TestCaseTextArea              matlab.ui.control.TextArea
        TestCaseTextAreaLabel         matlab.ui.control.Label
        SlddTab                       matlab.ui.container.Tab
        NoteTextArea                  matlab.ui.control.TextArea
        NoteTextAreaLabel             matlab.ui.control.Label
        ConfigPanel                   matlab.ui.container.Panel
        SlddTypeButtonGroup           matlab.ui.container.ButtonGroup
        VCUButton_2                   matlab.ui.control.RadioButton
        PCMUButton_2                  matlab.ui.control.RadioButton
        DcmFilePath                   matlab.ui.control.EditField
        DefaultDcmButton              matlab.ui.control.Button
        SlddDropDown                  matlab.ui.control.DropDown
        SubModDropDown_2Label_3       matlab.ui.control.Label
        FindDcmPanel                  matlab.ui.container.Panel
        findDCMValuesChangesButton    matlab.ui.control.Button
        findDCMNamesChangesButton     matlab.ui.control.Button
        findDCMNamesButton            matlab.ui.control.Button
        ChangeSlddPanel               matlab.ui.container.Panel
        changeArchSlddButton          matlab.ui.control.Button
        changeSlddInitValueByTableButton  matlab.ui.control.Button
        changeSlddTableByInitValueButton  matlab.ui.control.Button
        LoadSlddPanel                 matlab.ui.container.Panel
        LoadAllSlddButton             matlab.ui.control.Button
        findSlddLoadPCMUButton        matlab.ui.control.Button
        findSlddLoadVCUButton         matlab.ui.control.Button
        CreateExcelSlddPanel          matlab.ui.container.Panel
        changeExportedSlddButton      matlab.ui.control.Button
        openSlddButton                matlab.ui.control.Button
        findSlddButton                matlab.ui.control.Button
        findParametersButton          matlab.ui.control.Button
        AreaDropDown                  matlab.ui.control.DropDown
        AreaDropDownLabel             matlab.ui.control.Label
        CreateMatlabSlddPanel         matlab.ui.container.Panel
        createSlddButton              matlab.ui.control.Button
        createSlddDesignDataButton    matlab.ui.control.Button
        CheckTab                      matlab.ui.container.Tab
        delUselessLineButton          matlab.ui.control.Button
        IntegrationTab                matlab.ui.container.Tab
        ThernalIntegrationPanel       matlab.ui.container.Panel
        VER_NAMEEditField             matlab.ui.control.EditField
        VER_NAMEEditFieldLabel        matlab.ui.control.Label
        DCM_NAMEEditField             matlab.ui.control.EditField
        DCM_NAMEEditFieldLabel        matlab.ui.control.Label
        SOFT_VERSIONEditField         matlab.ui.control.EditField
        SOFT_VERSIONEditFieldLabel    matlab.ui.control.Label
        INTERFACE_VERISONEditField    matlab.ui.control.EditField
        INTERFACE_VERISONEditFieldLabel  matlab.ui.control.Label
        STAGEEditField                matlab.ui.control.EditField
        STAGEEditFieldLabel           matlab.ui.control.Label
        ArxmlToModelButton            matlab.ui.control.Button
        createIntegrationButton       matlab.ui.control.Button
        createCodePkgButton           matlab.ui.control.Button
        SingleModelProcessPanel       matlab.ui.container.Panel
        RefConfigEditField            matlab.ui.control.EditField
        RefConfigEditFieldLabel       matlab.ui.control.Label
        changeCfgRefButton            matlab.ui.control.Button
        changeCfgErtButton            matlab.ui.control.Button
        changeCfgAutosarButton        matlab.ui.control.Button
        createCodeSubModButton        matlab.ui.control.Button
        CreateSubModelButton          matlab.ui.control.Button
        ControlChooseButtonGroup      matlab.ui.container.ButtonGroup
        VCUButton                     matlab.ui.control.RadioButton
        PCMUButton                    matlab.ui.control.RadioButton
        SubModDropDown                matlab.ui.control.DropDown
        SubModDropDownLabel           matlab.ui.control.Label
        ContextMenu                   matlab.ui.container.ContextMenu
        DelSelectMenu                 matlab.ui.container.Menu
        DelAllMenu                    matlab.ui.container.Menu
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % 加载默认配置文件
            load('config.mat');
            % 将app.DcmFilePath 的文本内容，设置成dcm_file
            app.DcmFilePath.Value = dcm_file;

            app.STAGEEditField.Value = stage;
            app.INTERFACE_VERISONEditField.Value = interface_version;
            app.SOFT_VERSIONEditField.Value = soft_version;
            app.VER_NAMEEditField.Value = vername;


            

        end

        % Button pushed function: DefaultDcmButton
        function DefaultDcmButtonPushed(app, event)
            % select file through gui
            dcm_file = uigetfile('*.dcm', 'Select DICOM File');
            if isequal(dcm_file, 0)
                % User cancelled the dialog box.
                return;
            end
            % 将app.DcmFilePath 的文本内容，设置成dcm_file
            app.DcmFilePath.Value = dcm_file;

            % 将这个配置文件保存到本地，便于下次运行app的时候自动加载
            % 检查是否存在配置文件
            if exist('config.mat', 'file')
                % 加载现有配置
                existing_config = load('config.mat');
                % 更新dcm_file
                existing_config.dcm_file = dcm_file;
                % 保存更新后的配置
                save('config.mat', '-struct', 'existing_config');
            else
                % 如果配置文件不存在,创建新的
                save('config.mat', 'dcm_file');
            end
        end

        % Button pushed function: createSubmodInfoButton
        function createSubmodInfoButtonPushed(app, event)
            dcm_file = app.DcmFilePath.Value;
            [portsInNames, portsOutNames, calibParams, infoText] = createSubmodInfo('DCMfileName',dcm_file);
            app.LogTextArea.Value = infoText;
        end

        % Button pushed function: CreateBusGotoButton
        function CreateBusGotoButtonPushed(app, event)
            createBusGoto()
            % 初始化logstr为空字符串
            logstr = sprintf('执行创建总线端Goto成功:\n');
            % 添加结果摘要
%             logstr = sprintf('%s  创建输入端口: %d\n', logstr, inCnt);
            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: CreateBusPortButton
        function CreateBusPortButtonPushed(app, event)
            createBusPort()

            % 初始化logstr为空字符串
            logstr = sprintf('执行创建总线端口成功:\n');
            % 添加结果摘要
%             logstr = sprintf('%s  创建输入端口: %d\n', logstr, inCnt);
            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: createCodePkgButton
        function createCodePkgButtonPushed(app, event)
            SOFT_VERSION = app.SOFT_VERSIONEditField.Value;

            % save param
            % 加载现有配置
            existing_config = load('config.mat');
            existing_config.soft_version = SOFT_VERSION;
            % 保存更新后的配置
            save('config.mat', '-struct', 'existing_config');

            createCodePkg(app.VER_NAMEEditField.Value)

            createCodePkg(app.VER_NAMEEditField.Value)
        end

        % Button pushed function: createIntegrationButton
        function createIntegrationButtonPushed(app, event)
            % 加载现有配置


            STAGE = app.STAGEEditField.Value;
            INTERFACE_VERISON = app.INTERFACE_VERISONEditField.Value;
            DCM_NAME = app.DCM_NAMEEditField.Value;
            SOFT_VERSION = app.SOFT_VERSIONEditField.Value;
            VER_NAME = ['VcThermal_' STAGE '_' INTERFACE_VERISON '_' SOFT_VERSION];
            app.VER_NAMEEditField.Value = VER_NAME;

            % 不保存软件版本，回头等软件生成后整理代码的时候再保存
            existing_config.stage = STAGE;
            existing_config.vername = VER_NAME;
            existing_config.dcm_name = DCM_NAME;
            % 保存更新后的配置
            save('config.mat', '-struct', 'existing_config');

            createIntegration(SOFT_VERSION, 'STAGE',STAGE, 'INTERFACE_VERISON',INTERFACE_VERISON , 'DCM_NAME',DCM_NAME)
        end

        % Button down function: IntegrationTab
        function IntegrationTabButtonDown(app, event)
            app.LogTextArea.Value = '';
            existing_config = load('config.mat');
            soft_version_previous = existing_config.soft_version;
            % 期望提取SOFT_VERSION的前三位再和当前日期重新组成一个SOFT_VERSION
            current_date = datestr(now, 'mmdd');
            % 提取SOFT_VERSION的前三位并转换为数字
            soft_version_prefix = str2double(soft_version_previous(1:3));
            % 前缀数字加1
            soft_version_prefix = soft_version_prefix + 1;
            % 转回字符串格式
            soft_version_prefix = num2str(soft_version_prefix);
            % 重新组成新的SOFT_VERSION
            SOFT_VERSION = [soft_version_prefix, current_date];
            app.SOFT_VERSIONEditField.Value = SOFT_VERSION;

            STAGE = app.STAGEEditField.Value;
            INTERFACE_VERISON = app.INTERFACE_VERISONEditField.Value;
            VER_NAME = ['VcThermal_' STAGE '_' INTERFACE_VERISON '_' SOFT_VERSION];
            app.VER_NAMEEditField.Value = VER_NAME;

            logStr = sprintf('备注：\n');
            logStr = [logStr sprintf('函数功能简述如下，具体使用说明，请打开帮助手册（Help -> Sript Instrcution ，快捷键 Ctrl + h）\n')];
            logStr = [logStr sprintf('----------------------------------------------------------------------------------------------------------------------------------\n')];
            logStr = [logStr sprintf('ArxmlToModel: 将arxml 文件转换成autosar 框架模型\n')];
            logStr = [logStr sprintf('createIntegration：创建集成模型及所有相关配置，具体流程，详见Help -> PCMU Instrcution，快捷键 Ctrl + p\n')];
            logStr = [logStr sprintf('createCodePkg: 将生成好的代码进行文件提取并打包\n')];
            logStr = [logStr sprintf('SOFT_VERSION： 正常阶段不变的情况下，这个值不用改，小版本会根据之前的版本号自动递增，其后四位的日期也会被设置成当天日期\n')];
            logStr = [logStr sprintf('----------------------------------------------------------------------------------------------------------------------------------\n')];
            logStr = [logStr sprintf('CreateSubModel： 根据SubMod 参数，创建子模型的引用模型，并配置好相关参数\n')];
            logStr = [logStr sprintf('createCodeSubMod： 将生成好的代码进行文件提取并打包\n')];
            logStr = [logStr sprintf('changeCfgRef: 改变模型的引用配置，配置值为 RefConfig\n')];
            logStr = [logStr sprintf('changeCfgAutosar: 将模型配置成Autosar 配置\n')];
            logStr = [logStr sprintf('changeCfgErt： 将模型配置成ERT配置, 详见Help -> VCU Instrcution，快捷键 Ctrl + u\n')];

            app.LogTextArea.Value = logStr;

        end

        % Value changed function: SubModDropDown
        function SubModDropDownValueChanged(app, event)
            value = app.SubModDropDown.Value;
            disp(value)
        end

        % Selection changed function: ControlChooseButtonGroup
        function ControlChooseButtonGroupSelectionChanged(app, event)
            selectedButton = app.ControlChooseButtonGroup.SelectedObject;
            disp(selectedButton)
        end

        % Button pushed function: findSlddLoadPCMUButton
        function findSlddLoadPCMUButtonPushed(app, event)
            submod = app.SlddDropDown.Value;
            control_type = 'PCMU';
            findSlddLoad(submod,'mode',control_type)
            findSlddLoad('TmSwArch','mode',control_type)
        end

        % Button pushed function: CreateSubModelButton
        function CreateSubModelButtonPushed(app, event)
            submod = app.SubModDropDown.Value;
            control_type = app.ControlChooseButtonGroup.SelectedObject;
            if strcmp(control_type.Text,'PCMU')
                creatRefPCMU(submod)
            elseif strcmp(control_type.Text,'VCU')
                creatRefVCU(submod)
            else
            end

        end

        % Callback function: not associated with a component
        function LoadSlddAllButtonPushed(app, event)
            findSlddLoad('PCMU_SLDD_All.xlsx')
        end

        % Button pushed function: createCodeSubModButton
        function createCodeSubModButtonPushed(app, event)
            submod = app.SubModDropDown.Value;
            control_type = app.ControlChooseButtonGroup.SelectedObject;
            createCodeSubMod(submod, 'type', control_type)
        end

        % Button pushed function: createDebugButton
        function createDebugButtonPushed(app, event)
            portsOutNames = createDebug(gcs);

            % 初始化logstr为空字符串
            logstr = '';

            % 添加结果摘要
            logstr = sprintf('%s创建完成: %d 个输入端口\n', ...
            logstr,length(portsOutNames));
            for i=1:length(portsOutNames)
                logstr = sprintf('%s%s\n',logstr,portsOutNames{i});
            end

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: createGotoBasedPortsButton_3
        function createGotoBasedPortsButtonPushed(app, event)
            [numInputPorts, numOutputPorts] = createGotoBasedPorts(gcs);

            % 初始化logstr为空字符串
            logstr = '';

            % 添加结果摘要
            logstr = sprintf('%s创建完成: %d 个输入端口, %d 个输出端口\n', ...
            logstr,numInputPorts, numOutputPorts');

            
            app.LogTextArea.Value = logstr;
        end

        % Button down function: createSwitchCaseTab
        function createSwitchCaseTabButtonDown(app, event)
            desc = {'0','SM0';
                '[1 21]','SM1_SM21';
                '[2 22]','SM2_SM22';
                '[3 23]','SM3_SM23';
                '4','SM4';
                '5','SM5';
                '6','SM6';
                '7','SM7';
                };
            app.SwitchCaseTable.Data = desc;
        end

        % Button pushed function: AddButton
        function AddButtonPushed(app, event)
            case_num = app.CaseListEditField.Value;
            case_name = app.CaseNameEditField.Value;
            data = app.SwitchCaseTable.Data;
            app.SwitchCaseTable.Data = [data;{case_num,case_name}];
        end

        % Button pushed function: RemoveButton
        function RemoveButtonPushed(app, event)
            data = app.SwitchCaseTable.Data;
            data(end,:) = '';
            app.SwitchCaseTable.Data = data;
        end

        % Button pushed function: ClearAllButton
        function ClearAllButtonPushed(app, event)
            app.SwitchCaseTable.Data = '';
        end

        % Button pushed function: createSwitchCaseButton
        function createSwitchCaseButtonPushed(app, event)
            caseIn = app.CaseInTextArea.Value;
            % 去掉caseIn中的空字符串行
            caseIn = caseIn(~cellfun(@isempty, caseIn));
            sigNames = app.SigNamesTextArea.Value;
            sigNames = sigNames(~cellfun(@isempty, sigNames))

            data = app.SwitchCaseTable.Data;
            caseList = strcat('{',strjoin(data(:,1),','),'}');
            caseNames = data(:,2);
            
            createSwitchCase( ...
                'caseIn',caseIn{1}, ...
                'caseList',caseList, ...
                'caseNames',caseNames, ...
                'sigNames',sigNames...
            );

            % 初始化logstr为空字符串
            logstr = sprintf('执行创建Switch Case成功:\n');
            % 添加结果摘要
%             logstr = sprintf('%s  创建输入端口: %d\n', logstr, inCnt);
            app.LogTextArea.Value = logstr;

        end

        % Button pushed function: createModeButton
        function createModeButtonPushed(app, event)
            inType = app.InTypeDropDown.Value
            outType = app.OutTypeDropDown.Value
            add = app.InsertBlockDropDown.Value

            isEnableIn = strcmp(app.EnableInSwitch.Value,'On')
            isEnableOut = strcmp(app.EnableOutSwitch.Value,'On')
            resoveValue = strcmp(app.resoveValueSwitch.Value,'On')
            logValue = strcmp(app.logValueSwitch.Value,'On')
            testValue = strcmp(app.testValueSwitch.Value,'On')
            dispName = strcmp(app.dispNameSwitch.Value,'On')

            bkHalfLength = app.GotoHalfLengthSlider.Value

            createMode(gcb, ...
                'inType',inType, ...      % 可选参数 port, ground, from, const, none
                'outType',outType, ...       % 可选参数 port, term, goto, disp, none
                'suffixStr','',...
                ...                         % 创建 ports 相关配置
                'add', add,...           % 可选参数 blockType, None, etc：SignalConversion
                ...                         % 创建 goto from 相关配置
                'bkHalfLength', bkHalfLength,...
                ...                         % 创建 信号解析 相关配置
                'isEnableIn',isEnableIn,...
                'isEnableOut',isEnableOut,...
                'resoveValue',resoveValue,...
                'logValue',logValue,...
                'testValue',testValue,...
                'dispName', dispName...
                )
            % 初始化logstr为空字符串
%             logstr = '';

            % 添加结果摘要
            logstr = sprintf('创建模型端口成功\n');

            
            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: createPortsButton
        function createPortsButtonPushed(app, event)
            [inCnt, outCnt, inCntDel, outCntDel] = createPorts('Template.xlsx', gcs);
            % 初始化logstr为空字符串
            logstr = sprintf('执行成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建输入端口: %d\n', logstr, inCnt);
            logstr = sprintf('%s  创建输出端口: %d\n', logstr, outCnt); 
            logstr = sprintf('%s  删除输入端口: %d\n', logstr, inCntDel);
            logstr = sprintf('%s  删除输出端口: %d\n', logstr, outCntDel);

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: createPortsGotoButton
        function createPortsGotoButtonPushed(app, event)
            [numInputPorts, numOutputPorts] = createPortsGoto('fromTemplate', true);
            % 初始化logstr为空字符串
            logstr = sprintf('执行成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建输入端口: %d\n', logstr, numInputPorts);
            logstr = sprintf('%s  创建输出端口: %d\n', logstr, numOutputPorts); 

            app.LogTextArea.Value = logstr;
        end

        % Button down function: CreatePortTab
        function CreatePortTabButtonDown(app, event)
            temp=readtable('Template.xlsx','sheet','Signals')
            app.template.Data = temp(:,2:4);
%             
        end

        % Button pushed function: EditInTemplateButton
        function EditInTemplateButtonPushed(app, event)
            winopen('Template.xlsx');
        end

        % Button pushed function: ReloadButton
        function ReloadButtonPushed(app, event)
            temp=readtable('Template.xlsx','sheet','Signals');
            app.template.Data = temp(:,2:4);
            % 初始化logstr为空字符串
            logstr = sprintf('重载成功:\n');

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: createGotoUselessButton
        function createGotoUselessButtonPushed(app, event)
            [numGoto, numFrom] = createGotoUseless()

            % 初始化logstr为空字符串
            logstr = sprintf('执行成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  完成创建，共创建 %d 个Goto模块和 %d 个From模块\n',logstr, numGoto, numFrom);

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: createPortsGotoUpdateButton
        function createPortsGotoUpdateButtonPushed(app, event)
            [inList, outList] = createPortsGotoUpdate();

            % 初始化logstr为空字符串
            logstr = sprintf('执行成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建的输入信号如下：\n',logstr);
            logstr = sprintf('%s  %s\n',logstr, strjoin(inList,'\n  '));

            logstr = sprintf('%s  创建的输出信号如下：\n',logstr);
            logstr = sprintf('%s  %s\n',logstr, strjoin(outList,'\n  '));
            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: createPortsGotoUpdateLoopButton
        function createPortsGotoUpdateLoopButtonPushed(app, event)
            topLev = app.topLevEditField.Value;
            if strcmp(topLev,'bdroot')
                topLev = bdroot;
            end
            [inList, outList] = createPortsGotoUpdateLoop('topLev', topLev);


            % 初始化logstr为空字符串
            logstr = sprintf('执行成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建的输入信号如下：\n',logstr);
            logstr = sprintf('%s  %s\n',logstr, strjoin(inList,'\n  '));

            logstr = sprintf('%s  创建的输出信号如下：\n',logstr);
            logstr = sprintf('%s  %s\n',logstr, strjoin(outList,'\n  '));
            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: createSubModButton
        function createSubModButtonPushed(app, event)
            rows = app.SubModRowsSpinner.Value;
            modNums = createSubMod('rows', rows);

            % 初始化logstr为空字符串
            logstr = '';

            % 添加结果摘要
            logstr = sprintf('%s创建完成: %d 个子模型\n', ...
            logstr,modNums);
            
            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: creatIFInButton
        function creatIFInButtonPushed(app, event)
            numCreated = creatIFIn();
            % 初始化logstr为空字符串
            logstr = sprintf('执行接口输入模块成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建输入端口: %d\n', logstr, numCreated);

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: creatIFOutButton
        function creatIFOutButtonPushed(app, event)
            numCreated = creatIFOut();
            % 初始化logstr为空字符串
            logstr = sprintf('执行接口输出模块成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建输出端口: %d\n', logstr, numCreated);

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: creatTmOutButton
        function creatTmOutButtonPushed(app, event)
            numCreated = creatTmOut()
            % 初始化logstr为空字符串
            logstr = sprintf('执行热管理输出转换模块成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建输出端口: %d\n', logstr, numCreated);

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: creatTmBaseButton
        function creatTmBaseButtonPushed(app, event)
            creatTmBase()
        end

        % Button pushed function: createSlddButton
        function createSlddButtonPushed(app, event)
            modeName = app.SlddDropDown.Value;
            if strcmp(modeName,'bdroot')
                modeName = bdroot;
            end
            createSldd(modeName)

            % 初始化logstr为空字符串
            logstr = sprintf('创建sldd成功:\n');

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: createSlddDesignDataButton
        function createSlddDesignDataButtonPushed(app, event)
            modeName = app.SlddDropDown.Value;
            if strcmp(modeName,'bdroot')
                modeName = bdroot;
            end
            createSlddDesignData(modeName)

            % 初始化logstr为空字符串
            logstr = sprintf('成功创建sldd 并将变量导入到sldd 的DesignData中:\n');

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: changePortBlockPosAllButton
        function changePortBlockPosAllButtonPushed(app, event)
            changePortBlockPosAll(gcs)
        end

        % Button pushed function: changeArchSlddButton
        function changeArchSlddButtonPushed(app, event)
            app.LogTextArea.Value = '';
            sldd_file = 'PCMU_SLDD_All.xlsx';
            dcm_file = app.DcmFilePath.Value;
            if ~exist(sldd_file,'file')
                app.LoadAllSlddButtonPushed(event);
            else
                changeArchSldd(dcm_file, sldd_file)
            end

            % 初始化logstr为空字符串
            logstr = sprintf('执行成功:\n');
            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: changeCfgAutosarButton
        function changeCfgAutosarButtonPushed(app, event)
            model = app.SubModDropDown.Value
            changeCfgAutosar(model)
        end

        % Button pushed function: changeCfgErtButton
        function changeCfgErtButtonPushed(app, event)
            model = app.SubModDropDown.Value
            changeCfgErt(model)   
        end

        % Button pushed function: changeCfgRefButton
        function changeCfgRefButtonPushed(app, event)
            refCfg = app.RefConfigEditField.Value
            model = app.SubModDropDown.Value
            changeCfgRef(model, refCfg)
        end

        % Button pushed function: changeModPortNameButton
        function changeModPortNameButtonPushed(app, event)
            oldName = app.OldNameEditField
            newName = app.NewNameEditField
            changeModPortName(gcb, oldName, newName)
        end

        % Button pushed function: changeModPortTypeButton
        function changeModPortTypeButtonPushed(app, event)
            changeModPortType(gcs)
        end

        % Button pushed function: changeModSizeButton
        function changeModSizeButtonPushed(app, event)
            changeModSize(gcb)
        end

        % Button pushed function: changeModSizeGcsButton
        function changeModSizeGcsButtonPushed(app, event)
            rows = app.GcsArrangeRowsSpinner.Value
            changeModSizeGcs('rows', rows)
        end

        % Button pushed function: changeSigTypeButton
        function changeSigTypeButtonPushed(app, event)
            sig = app.SigNeedChgTypeEditField.Value
            changeSigType(sig)
        end

        % Callback function
        function OpenSlddFileButtonPushed(app, event)
            % select file through gui
            sldd_file = uigetfile('*.xlsx', 'Select SLDD File');
            if isequal(sldd_file, 0)
                % User cancelled the dialog box.
                return;
            end
            % 将app.SlddFilePath 的文本内容，设置成dcm_file
            app.SlddFilePath.Value = sldd_file;
        end

        % Button pushed function: changeSlddTableByInitValueButton
        function changeSlddTableByInitValueButtonPushed(app, event)
            % select file through gui
            sldd_file = uigetfile('*.xlsx', 'Select SLDD File');
            if isequal(sldd_file, 0)
                % User cancelled the dialog box.
                return;
            end  
            changeSlddTableByInitValue(sldd_file)
        end

        % Button pushed function: changeSlddInitValueByTableButton
        function changeSlddInitValueByTableButtonPushed(app, event)
            % select file through gui
            sldd_file = uigetfile('*.xlsx', 'Select SLDD File');
            if isequal(sldd_file, 0)
                % User cancelled the dialog box.
                return;
            end 
            changeSlddInitValueByTable(sldd_file)
        end

        % Button pushed function: findDCMNamesButton
        function findDCMNamesButtonPushed(app, event)
            % selectt file through gui
            dcm_file = uigetfile('*.dcm', 'Select DICOM File');
            if isequal(dcm_file, 0)
                % User cancelled the dialog box.
                return;
            end
            paramNames = findDCMNames(dcm_file);
            app.LogTextArea.Value = paramNames;
        end

        % Button pushed function: findDCMNamesChangesButton
        function findDCMNamesChangesButtonPushed(app, event)
            dcm_file_first = uigetfile('*.dcm', 'Select first DCM File');
            if isequal(dcm_file_first, 0)
                % User cancelled the dialog box.
                return;
            end
            dcm_file_second= uigetfile('*.dcm', 'Select second DCM File');
            if isequal(dcm_file_second, 0)
                % User cancelled the dialog box.
                return;
            end

            diff = findDCMNamesChanges(dcm_file_first, dcm_file_second);


            added = diff.added;
            removed = diff.removed;
            common = diff.common;

            % 初始化logstr为空字符串
            logstr = '';

            % 添加结果摘要
            logstr = sprintf('%s比较结果摘要:\n', logstr);
            logstr = sprintf('%s  共有参数: %d\n', logstr, length(common));
            logstr = sprintf('%s  添加参数: %d\n', logstr, length(added));
            logstr = sprintf('%s  删除参数: %d\n', logstr, length(removed));
        
            % 添加具体的added和removed参数
            logstr = sprintf('%s------------------------------:\n', logstr);
            logstr = sprintf('%s具体变化信息:\n', logstr);
            if ~isempty(added)
                logstr = sprintf('%s  添加参数:\n', logstr);
                for i = 1:length(added)
                    logstr = sprintf('%s    %s\n', logstr, added{i});
                end
            end
            logstr = sprintf('%s-------------:\n', logstr);
            if ~isempty(removed)
                logstr = sprintf('%s  删除参数:\n', logstr); 
                for i = 1:length(removed)
                    logstr = sprintf('%s    %s\n', logstr, removed{i});
                end
            end
            logstr = sprintf('%s------------------------------', logstr);
            app.LogTextArea.Value = logstr;

        end

        % Button pushed function: findModPortsButton
        function findModPortsButtonPushed(app, event)
            getType = app.PortTypeDropDown.Value
            [name, PortsIn, PortsOut] = findModPorts(gcb, 'getType', getType);
            logstr = '';

            % 显示提示信息
            logstr = sprintf('%smodel name is:%s\n', logstr, name);
            logstr = sprintf('%s----------------------------------------:\n', logstr);
            logstr = sprintf('%s输入端口:\n', logstr);
            for i = 1:length(PortsIn)
                logstr = sprintf('%s    %s\n', logstr, PortsIn{i});
            end
            logstr = sprintf('%s-----------------------------:\n', logstr);
            logstr = sprintf('%s输出端口:\n', logstr);
            for i = 1:length(PortsOut)
                logstr = sprintf('%s    %s\n', logstr, PortsOut{i});
            end
            logstr = sprintf('%s----------------------------------------', logstr);

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: findParametersButton
        function findParametersButtonPushed(app, event)
            path = app.AreaDropDown.Value;
            if strcmp(path,'gcs')
                path = gcs;
            elseif strcmp(path,'bdroot')
                path = bdroot;
            else
                disp('wrong path')
            end
            [PathAll, ParamAll] = findParameters(path)
            app.LogTextArea.Value = ParamAll;
        end

        % Button pushed function: findSlddButton
        function findSlddButtonPushed(app, event)
            app.findSlddButton.UserData = '';
            
            path = app.AreaDropDown.Value;
            if strcmp(path,'gcs')
                path = gcs;
            elseif strcmp(path,'bdroot')
                path = bdroot;
            else
                disp('wrong path')
            end
            [fPCMU, fVCU] = findSldd(path);
            logstr = sprintf('The exported sldd are as follows:\n');
            logstr = sprintf('%s the PCMU sldd path is: %s\n', logstr, fPCMU);
            logstr = sprintf('%s the VCU sldd path is: %s\n', logstr, fVCU);
            app.LogTextArea.Value = logstr;
            
            rstPath.PCMU = fPCMU;
            rstPath.VCU = fVCU;
            app.findSlddButton.UserData = rstPath;
        end

        % Button down function: HomeTab
        function HomeTabButtonDown(app, event)
            logStr = '';
            logStr = [logStr sprintf('Welcome to use smart thermal app!：\n')];
            logStr = [logStr sprintf('具体使用说明，请打开帮助手册（Help -> Sript Instrcution ，快捷键 Ctrl + h）\n')];
            logStr = [logStr sprintf('----------------------------------------------------------------------------------------------------------------------------------\n')];

            app.LogTextArea.Value = logStr;    
        end

        % Button pushed function: delUselessLineButton
        function delUselessLineButtonPushed(app, event)
            delUselessLine(bdroot)
        end

        % Button pushed function: delUselessPortButton
        function delUselessPortButtonPushed(app, event)
            UselessInBlock = app.UselessInBlockDropDown.Value;
            UselessOutBlock = app.UselessOutBlockDropDown.Value;
            delUselessPort(gcs,'UselessInBlock', UselessInBlock, 'UselessOutBlock', UselessOutBlock);
        end

        % Button pushed function: delGcsAllButton
        function delGcsAllButtonPushed(app, event)
            delGcsAll()
        end

        % Menu selected function: AboutMenu
        function AboutMenuSelected(app, event)
            % 点击About 菜单，弹出框显示一些文字信息：
            % 软件版本：V1.0
            % 发布如期：2025.5.7
            % 维护人员：Blue.ge @ Smart Therm.Dept.
            msgbox({'软件版本：V1.0','发布如期：2025.5.7','维护人员：Blue.ge @ Smart Therm.Dept.'});
        end

        % Callback function: OpenTemplate
        function OpenTemplateClicked(app, event)
            winopen('Template.xlsx');
        end

        % Button pushed function: ArxmlToModelButton
        function ArxmlToModelButtonPushed(app, event)
            Arxmlstart2mdl
        end

        % Size changed function: HomeTab
        function HomeTabSizeChanged(app, event)
            position = app.HomeTab.Position;
            
        end

        % Menu selected function: ScriptInstructionMenu
        function ScriptInstructionMenuSelected(app, event)
            winopen('Script Instruction.pdf')
            
        end

        % Button pushed function: AddCaseButton
        function AddCaseButtonPushed(app, event)
            caseList = app.TestCaseTextArea.Value;
            SelectedNode = app.CaseListTree.SelectedNodes;

            if isempty(SelectedNode)
                % 如果没有选中节点，添加到根节点下
                for i = 1:length(caseList)
                    uitreenode(app.CaseListTree, 'Text', caseList{i});
                end
            else
                % 添加到选中节点下
                for i = 1:length(caseList)
                    uitreenode(SelectedNode, 'Text', caseList{i});
                end
            end
        end

        % Button pushed function: DelCaseButton
        function DelCaseButtonPushed(app, event)
            SelectedNode = app.CaseListTree.SelectedNodes;
            delete(SelectedNode)
        end

        % Button pushed function: GetPortsButton
        function GetPortsButtonPushed(app, event)
            % 初始化空数据
%             app.CaseTable.Data = cell(0,0);

            [ModelName,PortsIn,PortsOut] = findModPorts(gcb, 'getType', 'Name');
            Head = {'Lev1','Lev2'};
            Head = [Head PortsIn PortsOut];
            app.CaseTable.ColumnName = Head;
            cols= length(Head);



            % 获取树形结构中的所有节点
            rootNode = app.CaseListTree.Children;
            row = 1;
            
            % 遍历第一层节点
            for i = 1:length(rootNode)
                lev1Node = rootNode(i);
%                 % 填充第一层节点数据
%                 app.CaseTable.Data{row,1} = lev1Node.Text;
%                 
                % 遍历第二层节点
                if ~isempty(lev1Node.Children)
                    for j = 1:length(lev1Node.Children)
                        lev2Node = lev1Node.Children(j);
                        % 填充第二层节点数据
                        app.CaseTable.Data{row,1} = lev1Node.Text;
                        app.CaseTable.Data{row,2} = lev2Node.Text;
                        row = row + 1;
                    end
                else
                    row = row + 1;
                end
            end
     
            % 设置输出端口列的背景色为绿色
            app.CaseTable.BackgroundColor = [1 1 1; 0.9 1 0.9]; % 设置输出端口列的背景色为浅绿色

        end

        % Button pushed function: createHarnessButton
        function createHarnessButtonPushed(app, event)
            % 获取下拉框的值
            lastStep = app.LastStepDropDown.Value;
            nextStep = app.NextStepDropDown.Value;
            
            % 获取树形结构数据
            rootNodes = app.CaseListTree.Children;
            lev1 = {rootNodes.Text};
            
            % 构建lev2数据结构
            lev2 = cell(1,length(rootNodes));
            for i = 1:length(rootNodes)
                if ~isempty(rootNodes(i).Children)
                    lev2{i} = {rootNodes(i).Children.Text};
                else
                    lev2{i} = {};
                end
            end
            
            % 获取端口信息
            [modelName,PortsIn,PortsOut] = findModPorts(gcb, 'getType', 'Name');
            
            caseCls = length(lev1);
            inName=cell(1,caseCls);
            rstName=cell(1,caseCls);
            for i=1:caseCls
                inName{i} = PortsIn;
            end
            for i=1:caseCls
                rstName{i} = PortsOut;
            end
            
            % 从表格中获取输入值
            tableData = app.CaseTable.Data;
            inValue = cell(1,length(lev1));
            for i = 1:length(lev1)
                inValue{i} = cell(1,length(lev2{i}));
                for j = 1:length(lev2{i})
                    rowIdx = find(strcmp(tableData(:,1), lev1{i}) & strcmp(tableData(:,2), lev2{i}{j}));
                    if ~isempty(rowIdx)
                        inValue{i}{j} = tableData(rowIdx,3:2+length(PortsIn));
                    end
                end
            end
            
            % 从表格中获取输出值
            rstValue = cell(1,length(lev1));
            for i = 1:length(lev1)
                rstValue{i} = cell(1,length(lev2{i}));
                for j = 1:length(lev2{i})
                    rowIdx = find(strcmp(tableData(:,1), lev1{i}) & strcmp(tableData(:,2), lev2{i}{j}));
                    if ~isempty(rowIdx)
                        rstValue{i}{j} = tableData(rowIdx,3+length(PortsIn):end);
                    end
                end
            end

            % 创建结构体保存所有变量
            saveHarnessParams('modelName', modelName, ...
            'PortsIn', PortsIn, ...
            'PortsOut', PortsOut, ...
            'lastStep', lastStep, ...
            'nextStep', nextStep, ...
            'lev1', lev1, ...
            'lev2', lev2, ...
            'inName', inName, ...
            'rstName', rstName, ...
            'inValue', inValue, ...
            'rstValue', rstValue);

            createHarness(gcb, ...
                'lastStep',lastStep,...  % Initialize
                'nextStep',nextStep,...  % Initialize
                'lev1',lev1, ...
                'lev2',lev2, ...
                'inName',inName,...
                'rstName',rstName,...
                'inValue',inValue,...
                'rstValue',rstValue...
                )
        end

        % Button pushed function: DemoButton
        function DemoButtonPushed(app, event)
            [ModelName,PortsIn,PortsOut] = findModPorts(gcb, 'getType', 'Name');
            Head = {'Lev1','Lev2'};
            Head = [Head PortsIn PortsOut]
            cols = length(Head);
            app.CaseTable.ColumnName = Head;


            LEV1 = {'NHP','HP'};
            LEV2 = { ...
                        {'NoLimit','Limit'},...
                        {'NoLimit','Limit','Limit2','Limit3'},...
                    };
            cases = {
                'NHP','NoLimit';
                'NHP','Limit';
                'HP','NoLimit';
                'HP','Limit';
                'HP','Limit2';
                'HP','Limit3';
            };

%             data={
%                 '0','0','0','1','0','8000','false';
%                 '0','0','0','1','[1 2 3]','3000','true';
%                 '0','0','0','2','0','8000','false';
%                 '0','1','0','2','0','3000','true';
%                 '0','0','1','2','0','3000','true';
%                 '1','0','0','2','0','3000','true'
%                 };

            data={
                '0','0','0','1','0','8000','0';
                '0','0','0','1','[1 2 3]','3000','1';
                '0','0','0','2','0','8000','0';
                '0','1','0','2','0','3000','1';
                '0','0','1','2','0','3000','1';
                '1','0','0','2','0','3000','1'
                };

            % 如果没有选中节点，添加到根节点下
            app.CaseListTree.Children.delete
            rows=0;
            for i = 1:length(LEV1)
                node = uitreenode(app.CaseListTree, 'Text', LEV1{i});
                for j = 1:length(LEV2{i})
                    uitreenode(node, 'Text', LEV2{i}{j});
                    rows = rows + 1;
                end
            end

            % 初始化空数据
            app.CaseTable.Data = cell(rows,cols);

            app.CaseTable.Data(1:6,1:2) = cases;
            app.CaseTable.Data(1:6,3:9) = data;
        end

        % Value changed function: HarnessParamsListBox
        function HarnessParamsListBoxValueChanged(app, event)
            % 初始化空数据
            app.CaseTable.Data = cell(0,0);
            
            value = app.HarnessParamsListBox.Value;

            logstr = sprintf('准备加载模型%s的测试参数\n', value);

            app.LogTextArea.Value = logstr;

            params =  load('harness.mat');
            harnessDataArray = params.harnessDataArray;
            data='';
            for i=1:length(harnessDataArray)
                data  = harnessDataArray(i);
                if strcmp(data.modelName,value)
                    break;
                end
            end

            
            %% 填充输入输出信号
            PortsIn = data.PortsIn;
            PortsOut = data.PortsOut;
            Head = ['Lev1','Lev2' PortsIn PortsOut];
            app.CaseTable.ColumnName = Head;



            %% 填充测试用例
            LEV1 = data.lev1
            LEV2 = data.lev2
            % 清空uitreenode
            app.CaseListTree.Children.delete;
            for i = 1:length(LEV1)
                node = uitreenode(app.CaseListTree, 'Text', LEV1{i});
                for j = 1:length(LEV2{i})
                    uitreenode(node, 'Text', LEV2{i}{j});
                end
            end

            %% 填充测试数据
            % 获取树形结构中的所有节点，并填充测试用例区域
            rootNode = app.CaseListTree.Children;
            row = 1;
            
            % 遍历第一层节点
            for i = 1:length(rootNode)
                lev1Node = rootNode(i);
                % 遍历第二层节点
                if ~isempty(lev1Node.Children)
                    for j = 1:length(lev1Node.Children)
                        lev2Node = lev1Node.Children(j);
                        % 填充第一层节点数据  
                        app.CaseTable.Data{row,1} = lev1Node.Text;
                        % 填充第二层节点数据
                        app.CaseTable.Data{row,2} = lev2Node.Text;
                        row = row + 1;
                    end
                else
                    row = row + 1;
                end
            end

            % 获取数据区域中的data.inValue 和 data.rstValue, 并填充数据区域
            % 计算总行数
            totalRows = 0;
            for i = 1:length(data.lev2)
                totalRows = totalRows + length(data.lev2{i});
            end
            
            % 初始化dataValue矩阵
            dataValue = cell(totalRows, length(PortsIn) + length(PortsOut));
            
            % 填充inValue和rstValue
            row = 1;
            for i = 1:length(data.inValue)
                for j = 1:length(data.inValue{i})
                    % 填充输入值
                    dataValue(row, 1:length(PortsIn)) = data.inValue{i}{j};
                    % 填充输出值
                    dataValue(row, length(PortsIn)+1:end) = data.rstValue{i}{j}(1:length(PortsOut));
                    row = row + 1;
                end
            end
            
            % 将合并后的数据填充到表格中
            app.CaseTable.Data(1:totalRows, 3:3+length(PortsIn) + length(PortsOut)-1) = dataValue;

        end

        % Button down function: TestTab
        function TestTabButtonDown(app, event)
            app.LogTextArea.Value = '';
            if ~exist('harness.mat', 'file')
                return
            end
            load('harness.mat')
            len = length(harnessDataArray);
            list = cell(1,len);
            for i=1:len
                list{i} = harnessDataArray(i).modelName;
            end
            app.HarnessParamsListBox.Items = list;

            logStr = '';
            logStr = [logStr sprintf('备注：\n')];
            logStr = [logStr sprintf('函数功能简述如下，具体使用说明，请打开帮助手册（Help -> Sript Instrcution ，快捷键 Ctrl + h）\n')];
            logStr = [logStr sprintf('----------------------------------------------------------------------------------------------------------------------------------\n')];
            logStr = [logStr sprintf('AddCase: 将TestCase中的内容添加到根目录CaseTree中，作为当前harness的测试大类， 如果需要添加子类，需要先选中大类，再点此按键\n')];
            logStr = [logStr sprintf('DelCase：将CaseTree中的测试用例删除\n')];
            logStr = [logStr sprintf('GetPorts: 点击子模型，生成对应的输入输出信号，同时根据CaseTree, 生成测试用例个数，然后就可以对其进行填充\n')];
            logStr = [logStr sprintf('createHarness： 根据测试用例，生成harness\n')];
            logStr = [logStr sprintf('Demo: 快速生成demo CaseTree, 需要打开并点击模型：ScriptDemo/createHarness/Demo\n')];
            logStr = [logStr sprintf('DelParam: 删除Harness Histroy Params 选中的参数\n')];
            logStr = [logStr sprintf('在表格上单击右键，可以快速删除全部数据或者选中数据\n')];

            app.LogTextArea.Value = logStr;

        end

        % Clicked callback: HarnessParamsListBox
        function HarnessParamsListBoxClicked(app, event)
            item = event.InteractionInformation.Item
            
        end

        % Button pushed function: DelParamButton
        function DelParamButtonPushed(app, event)
            item = app.HarnessParamsListBox.Value;
            if isempty(item)
                app.LogTextArea.Value = '未选中相关参数';
                return
            end

            % 删除数据库中的参数
            load('harness.mat')
            len = length(harnessDataArray);
            for i=1:len
                if strcmp(harnessDataArray(i).modelName,item)
                    % 删除这个配置项并重新保存
                    harnessDataArray(i) = [];  % 删除该元素
                    save('harness.mat', 'harnessDataArray');  % 保存更新后的数据
                    break
                end
            end

            % 删除这个列表项中的item
            items = app.HarnessParamsListBox.Items;
            idx = find(strcmp(items, item));
            if ~isempty(idx)
                items(idx) = [];  % 从列表中删除该项
                app.HarnessParamsListBox.Items = items;  % 更新列表框
            end
        end

        % Callback function
        function DelDataAllButtonPushed(app, event)
            % 将table 中的数据，全部置为空字符串
            app.CaseTable.Data = cell(size(app.CaseTable.Data));
        end

        % Callback function
        function DelDataSelectButtonPushed(app, event)
            % 删除CaseTable中鼠标选中的数据
            if isempty(app.CaseTable.Selected)
                app.LogTextArea.Value = '未选中任何数据';
                return;
            end
            app.CaseTable.Data(app.CaseTable.Selected,:) = [];
            app.LogTextArea.Value = '已删除选中的数据';
        end

        % Menu selected function: DelSelectMenu
        function DelSelectMenuSelected(app, event)
            % 删除CaseTable中鼠标选中的数据
            selection = app.CaseTable.Selection;
            
            % 检查是否有选中的数据
            if isempty(selection)
                app.LogTextArea.Value = '未选中任何数据';
                return;
            end
            
            % 获取当前表格数据
            currentData = app.CaseTable.Data;
            
            % 将选中位置的数据置为空字符串
            for i = 1:size(selection, 1)
                row = selection(i, 1);
                col = selection(i, 2);
                currentData{row, col} = '';
            end
            
            % 更新表格数据
            app.CaseTable.Data = currentData;
            app.LogTextArea.Value = '已清空选中的数据';
        end

        % Menu selected function: DelAllMenu
        function DelAllMenuSelected(app, event)
            % 将table 中的数据，全部置为空字符串
            app.CaseTable.Data = cell(size(app.CaseTable.Data));
        end

        % Button down function: CheckTab
        function CheckTabButtonDown(app, event)
            logstr =sprintf('一般需要检查点如下：\n');

            % 显示提示信息
            logstr = sprintf('%s1. 删除无用的连线\n', logstr);
            logstr = sprintf('%s1. 确保所有的goto, from 都有配对\n', logstr);
            logstr = sprintf('%s2. 确保一维查表及二维查表，中间是线性插值，两端是截至clip\n', logstr);
            logstr = sprintf('%s3. 确保除数模块的被除数不为0\n', logstr);
            logstr = sprintf('%s4. 确保无符号整数的减法不会溢出\n', logstr);

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: findSlddLoadVCUButton
        function findSlddLoadVCUButtonPushed(app, event)
            submod = app.SlddDropDown.Value;
            control_type = 'VCU';
            findSlddLoad(submod,'mode',control_type)
            findSlddLoad('TmSwArch','mode',control_type)
        end

        % Button down function: SlddTab
        function SlddTabButtonDown(app, event)
            app.LogTextArea.Value = '';
        end

        % Button pushed function: openSlddButton
        function openSlddButtonPushed(app, event)
            slddType = app.SlddTypeButtonGroup.SelectedObject.Text;
%             slddName = [bdroot '_DD_' slddType '_EXPORT.xlsx'];
            rstPath = app.findSlddButton.UserData;
            if isempty(rstPath)
                return
            end

            if strcmp(slddType, 'PCMU')
                slddName = rstPath.PCMU;
            else
                slddName = rstPath.VCU;
            end
            winopen(slddName)
        end

        % Button pushed function: changeExportedSlddButton
        function changeExportedSlddButtonPushed(app, event)
            slddType = app.SlddTypeButtonGroup.SelectedObject.Text;

            %             slddName = [bdroot '_DD_' slddType '_EXPORT.xlsx'];

            rstPath = app.findSlddButton.UserData;
            if isempty(rstPath)
                return
            end
            
            if strcmp(slddType, 'PCMU')
                slddName = rstPath.PCMU;
            else
                slddName = rstPath.VCU;
            end

            dcm_file = app.DcmFilePath.Value;
            changeArchSldd(dcm_file, slddName);
        end

        % Button pushed function: LoadAllSlddButton
        function LoadAllSlddButtonPushed(app, event)
            SLDD_NAME = 'PCMU_SLDD_All.xlsx';
            DCM_NAME = app.DcmFilePath.Value;
            if ~exist('PCMU_SLDD_All.xlsx','file')
                app.LogTextArea.Value = sprintf('file of %s not existed. will create first\n',SLDD_NAME);

                proj = currentProject; 
                rootPath = proj.RootFolder;
                subPath = fullfile(rootPath,'SubModel');
                if ~exist(subPath, 'dir')
                    error('wrong sub model path')
                end
                
                findSlddCombine(subPath, SLDD_NAME);
            end
            changeArchSldd(DCM_NAME, SLDD_NAME);
            findSlddLoad(SLDD_NAME)
        end

        % Size changed function: SlddTab
        function SlddTabSizeChanged(app, event)
            position = app.SlddTab.Position;
            
        end

        % Button down function: ModelTab
        function ModelTabButtonDown(app, event)
            logStr = '';
            logStr = [logStr sprintf('备注：\n')];
            logStr = [logStr sprintf('具体使用说明，请打开帮助手册（Help -> Sript Instrcution ，快捷键 Ctrl + h）\n')];
            logStr = [logStr sprintf('----------------------------------------------------------------------------------------------------------------------------------\n')];

            app.LogTextArea.Value = logStr;    
        end

        % Button pushed function: findDCMValuesChangesButton
        function findDCMValuesChangesButtonPushed(app, event)
            dcm_file_first = uigetfile('*.dcm', 'Select first DCM File');
            if isequal(dcm_file_first, 0)
                % User cancelled the dialog box.
                return;
            end
            dcm_file_second= uigetfile('*.dcm', 'Select second DCM File');
            if isequal(dcm_file_second, 0)
                % User cancelled the dialog box.
                return;
            end

            changes = findDCMValuesChanges(dcm_file_first, dcm_file_second);


            %% 显示比较结果
            % 参数类型名称映射
            typeNames = {'常量', '轴定义', '值块', '一维表', '二维表'};
            logstr = sprintf('    %s    \n和\n    %s    \n的参数差异如下：\n\n', dcm_file_first,dcm_file_second);
            if isempty(changes)
                logstr = sprintf('%s未发现参数值的变化。\n', logstr);
            else
                logstr = sprintf('%s发现 %d 个参数值有变化:\n', logstr, length(changes));
                
                logstr = sprintf('%s--------------------------------------------------------------\n', logstr);
                logstr = sprintf('%s%-30s %-15s %-30s\n', logstr, '参数名称', '类型', '变化描述');
                logstr = sprintf('%s--------------------------------------------------------------\n', logstr);
                
                for i = 1:length(changes)
                    change = changes(i);
                    typeName = typeNames{change.type};
                    
                    % 根据参数类型格式化变化描述
                    switch change.type
                        case 1 % 常量
                            if ischar(change.diff)
                                diffDesc = change.diff;
                            else
                                diffDesc = sprintf('%.6g -> %.6g (变化: %.6g)', ...
                                            change.oldValue, change.newValue, change.diff);
                            end
                            
                        case {2, 3, 4, 5} % 轴定义、值块、一维表或二维表
                            diffDesc = change.diff;
                    end
                    
                    logstr = sprintf('%s%-30s %-15s %-30s\n', logstr, change.name, typeName, diffDesc);
                end
                logstr = sprintf('%s--------------------------------------------------------------\n', logstr);

            end
            app.LogTextArea.Value = logstr;
        end

        % Menu selected function: PCMUInstructionMenu
        function PCMUInstructionMenuSelected(app, event)
            winopen('PCMU Instruction.pdf')
        end

        % Menu selected function: VCUInstructionMenu
        function VCUInstructionMenuSelected(app, event)
            winopen('HY11 VCU1自研软件集成指南-陈远飞20240130_V3.pdf')
        end

        % Button down function: TabGroup
        function TabGroupButtonDown(app, event)
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1101 698];
            app.UIFigure.Name = 'MATLAB App';

            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = 'File';

            % Create HelpMenu
            app.HelpMenu = uimenu(app.UIFigure);
            app.HelpMenu.Text = 'Help';

            % Create ScriptInstructionMenu
            app.ScriptInstructionMenu = uimenu(app.HelpMenu);
            app.ScriptInstructionMenu.MenuSelectedFcn = createCallbackFcn(app, @ScriptInstructionMenuSelected, true);
            app.ScriptInstructionMenu.Separator = 'on';
            app.ScriptInstructionMenu.Accelerator = 'h';
            app.ScriptInstructionMenu.Text = 'Script Instruction';

            % Create PCMUInstructionMenu
            app.PCMUInstructionMenu = uimenu(app.HelpMenu);
            app.PCMUInstructionMenu.MenuSelectedFcn = createCallbackFcn(app, @PCMUInstructionMenuSelected, true);
            app.PCMUInstructionMenu.Separator = 'on';
            app.PCMUInstructionMenu.Accelerator = 'p';
            app.PCMUInstructionMenu.Text = 'PCMU Instruction';

            % Create VCUInstructionMenu
            app.VCUInstructionMenu = uimenu(app.HelpMenu);
            app.VCUInstructionMenu.MenuSelectedFcn = createCallbackFcn(app, @VCUInstructionMenuSelected, true);
            app.VCUInstructionMenu.Accelerator = 'u';
            app.VCUInstructionMenu.Text = 'VCU Instruction';

            % Create AboutMenu
            app.AboutMenu = uimenu(app.HelpMenu);
            app.AboutMenu.MenuSelectedFcn = createCallbackFcn(app, @AboutMenuSelected, true);
            app.AboutMenu.Separator = 'on';
            app.AboutMenu.Text = 'About';

            % Create Toolbar
            app.Toolbar = uitoolbar(app.UIFigure);

            % Create OpenTemplate
            app.OpenTemplate = uipushtool(app.Toolbar);
            app.OpenTemplate.Tag = 'Template';
            app.OpenTemplate.Tooltip = {'Template File'};
            app.OpenTemplate.ClickedCallback = createCallbackFcn(app, @OpenTemplateClicked, true);

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.ButtonDownFcn = createCallbackFcn(app, @TabGroupButtonDown, true);
            app.TabGroup.Position = [1 301 1101 398];

            % Create HomeTab
            app.HomeTab = uitab(app.TabGroup);
            app.HomeTab.SizeChangedFcn = createCallbackFcn(app, @HomeTabSizeChanged, true);
            app.HomeTab.Title = 'Home';
            app.HomeTab.ButtonDownFcn = createCallbackFcn(app, @HomeTabButtonDown, true);

            % Create ChangeLogPanel
            app.ChangeLogPanel = uipanel(app.HomeTab);
            app.ChangeLogPanel.Title = 'Change Log';
            app.ChangeLogPanel.Position = [3 0 1099 209];

            % Create VersionTextAreaLabel
            app.VersionTextAreaLabel = uilabel(app.ChangeLogPanel);
            app.VersionTextAreaLabel.HorizontalAlignment = 'right';
            app.VersionTextAreaLabel.Position = [4 161 45 22];
            app.VersionTextAreaLabel.Text = 'Version';

            % Create VersionTextArea
            app.VersionTextArea = uitextarea(app.ChangeLogPanel);
            app.VersionTextArea.Position = [64 2 1031 183];
            app.VersionTextArea.Value = {'Version: V0.0.3'; 'Release Date: 20250514'; 'Description:'; '1. Add the Sldd and Check page'; '2. Add simple Desc. about each Tab'; '3. Add PCUM and VUM integration instruction'; ''; 'Version: V0.0.2'; 'Release Date: 20250512'; 'Description:'; '1. add the test function'; ''; 'Version: V0.0.1'; 'Release Date: 20250508'; 'Description:'; '1. add the most used funcions to apps'; ''};

            % Create Image
            app.Image = uiimage(app.HomeTab);
            app.Image.Position = [3 208 1095 165];
            app.Image.ImageSource = 'smart_Logo_horizontal_regular_P_rgb.png';

            % Create ModelTab
            app.ModelTab = uitab(app.TabGroup);
            app.ModelTab.Title = 'Model';
            app.ModelTab.ButtonDownFcn = createCallbackFcn(app, @ModelTabButtonDown, true);

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.ModelTab);
            app.TabGroup2.TabLocation = 'left';
            app.TabGroup2.Position = [1 0 1099 374];

            % Create AddTab
            app.AddTab = uitab(app.TabGroup2);
            app.AddTab.Title = 'Add';

            % Create TabGroup3
            app.TabGroup3 = uitabgroup(app.AddTab);
            app.TabGroup3.Position = [1 1 1021 372];

            % Create DefaultTab
            app.DefaultTab = uitab(app.TabGroup3);
            app.DefaultTab.Title = 'Default';

            % Create createSubmodInfoButton
            app.createSubmodInfoButton = uibutton(app.DefaultTab, 'push');
            app.createSubmodInfoButton.ButtonPushedFcn = createCallbackFcn(app, @createSubmodInfoButtonPushed, true);
            app.createSubmodInfoButton.Position = [20 223 113 23];
            app.createSubmodInfoButton.Text = 'createSubmodInfo';

            % Create createSubModButton
            app.createSubModButton = uibutton(app.DefaultTab, 'push');
            app.createSubModButton.ButtonPushedFcn = createCallbackFcn(app, @createSubModButtonPushed, true);
            app.createSubModButton.Position = [19 304 113 23];
            app.createSubModButton.Text = 'createSubMod';

            % Create createDebugButton
            app.createDebugButton = uibutton(app.DefaultTab, 'push');
            app.createDebugButton.ButtonPushedFcn = createCallbackFcn(app, @createDebugButtonPushed, true);
            app.createDebugButton.Position = [19 262 113 23];
            app.createDebugButton.Text = 'createDebug';

            % Create SubModRowsSpinnerLabel
            app.SubModRowsSpinnerLabel = uilabel(app.DefaultTab);
            app.SubModRowsSpinnerLabel.HorizontalAlignment = 'right';
            app.SubModRowsSpinnerLabel.Position = [116 306 132 22];
            app.SubModRowsSpinnerLabel.Text = 'SubModRows';

            % Create SubModRowsSpinner
            app.SubModRowsSpinner = uispinner(app.DefaultTab);
            app.SubModRowsSpinner.Limits = [1 5];
            app.SubModRowsSpinner.Position = [258 306 126 22];
            app.SubModRowsSpinner.Value = 2;

            % Create CreateModTab
            app.CreateModTab = uitab(app.TabGroup3);
            app.CreateModTab.Title = 'CreateMod';

            % Create InTypeDropDownLabel
            app.InTypeDropDownLabel = uilabel(app.CreateModTab);
            app.InTypeDropDownLabel.HorizontalAlignment = 'right';
            app.InTypeDropDownLabel.Position = [26 296 41 22];
            app.InTypeDropDownLabel.Text = 'InType';

            % Create InTypeDropDown
            app.InTypeDropDown = uidropdown(app.CreateModTab);
            app.InTypeDropDown.Items = {'port', 'ground', 'from', 'const', 'none'};
            app.InTypeDropDown.Position = [82 296 100 22];
            app.InTypeDropDown.Value = 'port';

            % Create OutTypeDropDownLabel
            app.OutTypeDropDownLabel = uilabel(app.CreateModTab);
            app.OutTypeDropDownLabel.HorizontalAlignment = 'right';
            app.OutTypeDropDownLabel.Position = [204 296 50 22];
            app.OutTypeDropDownLabel.Text = 'OutType';

            % Create OutTypeDropDown
            app.OutTypeDropDown = uidropdown(app.CreateModTab);
            app.OutTypeDropDown.Items = {'port', 'term', 'goto', 'disp', 'none'};
            app.OutTypeDropDown.Position = [269 296 100 22];
            app.OutTypeDropDown.Value = 'port';

            % Create GotoHalfLengthSliderLabel
            app.GotoHalfLengthSliderLabel = uilabel(app.CreateModTab);
            app.GotoHalfLengthSliderLabel.HorizontalAlignment = 'right';
            app.GotoHalfLengthSliderLabel.Position = [26 219 89 22];
            app.GotoHalfLengthSliderLabel.Text = 'GotoHalfLength';

            % Create GotoHalfLengthSlider
            app.GotoHalfLengthSlider = uislider(app.CreateModTab);
            app.GotoHalfLengthSlider.Limits = [15 100];
            app.GotoHalfLengthSlider.Position = [133 237 150 3];
            app.GotoHalfLengthSlider.Value = 15;

            % Create InsertBlockDropDownLabel
            app.InsertBlockDropDownLabel = uilabel(app.CreateModTab);
            app.InsertBlockDropDownLabel.HorizontalAlignment = 'right';
            app.InsertBlockDropDownLabel.Position = [26 259 64 22];
            app.InsertBlockDropDownLabel.Text = 'InsertBlock';

            % Create InsertBlockDropDown
            app.InsertBlockDropDown = uidropdown(app.CreateModTab);
            app.InsertBlockDropDown.Items = {'None', 'SignalConversion'};
            app.InsertBlockDropDown.Position = [105 259 100 22];
            app.InsertBlockDropDown.Value = 'None';

            % Create EnableInSwitchLabel
            app.EnableInSwitchLabel = uilabel(app.CreateModTab);
            app.EnableInSwitchLabel.HorizontalAlignment = 'center';
            app.EnableInSwitchLabel.Position = [49 129 52 22];
            app.EnableInSwitchLabel.Text = 'EnableIn';

            % Create EnableInSwitch
            app.EnableInSwitch = uiswitch(app.CreateModTab, 'slider');
            app.EnableInSwitch.Position = [52 166 45 20];
            app.EnableInSwitch.Value = 'On';

            % Create EnableOutSwitchLabel
            app.EnableOutSwitchLabel = uilabel(app.CreateModTab);
            app.EnableOutSwitchLabel.HorizontalAlignment = 'center';
            app.EnableOutSwitchLabel.Position = [44 61 62 22];
            app.EnableOutSwitchLabel.Text = 'EnableOut';

            % Create EnableOutSwitch
            app.EnableOutSwitch = uiswitch(app.CreateModTab, 'slider');
            app.EnableOutSwitch.Position = [52 98 45 20];
            app.EnableOutSwitch.Value = 'On';

            % Create resoveValueSwitchLabel
            app.resoveValueSwitchLabel = uilabel(app.CreateModTab);
            app.resoveValueSwitchLabel.HorizontalAlignment = 'center';
            app.resoveValueSwitchLabel.Position = [150 61 71 22];
            app.resoveValueSwitchLabel.Text = 'resoveValue';

            % Create resoveValueSwitch
            app.resoveValueSwitch = uiswitch(app.CreateModTab, 'slider');
            app.resoveValueSwitch.Position = [162 98 45 20];

            % Create logValueSwitchLabel
            app.logValueSwitchLabel = uilabel(app.CreateModTab);
            app.logValueSwitchLabel.HorizontalAlignment = 'center';
            app.logValueSwitchLabel.Position = [160 129 51 22];
            app.logValueSwitchLabel.Text = 'logValue';

            % Create logValueSwitch
            app.logValueSwitch = uiswitch(app.CreateModTab, 'slider');
            app.logValueSwitch.Position = [162 166 45 20];

            % Create testValueSwitchLabel
            app.testValueSwitchLabel = uilabel(app.CreateModTab);
            app.testValueSwitchLabel.HorizontalAlignment = 'center';
            app.testValueSwitchLabel.Position = [280 128 54 22];
            app.testValueSwitchLabel.Text = 'testValue';

            % Create testValueSwitch
            app.testValueSwitch = uiswitch(app.CreateModTab, 'slider');
            app.testValueSwitch.Position = [283 165 45 20];

            % Create dispNameSwitchLabel
            app.dispNameSwitchLabel = uilabel(app.CreateModTab);
            app.dispNameSwitchLabel.HorizontalAlignment = 'center';
            app.dispNameSwitchLabel.Position = [278 61 59 22];
            app.dispNameSwitchLabel.Text = 'dispName';

            % Create dispNameSwitch
            app.dispNameSwitch = uiswitch(app.CreateModTab, 'slider');
            app.dispNameSwitch.Position = [283 98 45 20];

            % Create createModeButton
            app.createModeButton = uibutton(app.CreateModTab, 'push');
            app.createModeButton.ButtonPushedFcn = createCallbackFcn(app, @createModeButtonPushed, true);
            app.createModeButton.Position = [413 240 100 23];
            app.createModeButton.Text = 'createMode';

            % Create Label
            app.Label = uilabel(app.CreateModTab);
            app.Label.Position = [389 294 173 22];
            app.Label.Text = '选中模型后点击此按键执行脚本';

            % Create CreatePortTab
            app.CreatePortTab = uitab(app.TabGroup3);
            app.CreatePortTab.Title = 'CreatePort';
            app.CreatePortTab.ButtonDownFcn = createCallbackFcn(app, @CreatePortTabButtonDown, true);

            % Create createPortsButton
            app.createPortsButton = uibutton(app.CreatePortTab, 'push');
            app.createPortsButton.ButtonPushedFcn = createCallbackFcn(app, @createPortsButtonPushed, true);
            app.createPortsButton.Position = [25 302 100 23];
            app.createPortsButton.Text = 'createPorts';

            % Create createPortsGotoButton
            app.createPortsGotoButton = uibutton(app.CreatePortTab, 'push');
            app.createPortsGotoButton.ButtonPushedFcn = createCallbackFcn(app, @createPortsGotoButtonPushed, true);
            app.createPortsGotoButton.Position = [23 244 102 23];
            app.createPortsGotoButton.Text = 'createPortsGoto';

            % Create template
            app.template = uitable(app.CreatePortTab);
            app.template.ColumnName = {'PortType'; 'Name'; 'DataType'};
            app.template.RowName = {};
            app.template.Position = [162 5 858 332];

            % Create EditInTemplateButton
            app.EditInTemplateButton = uibutton(app.CreatePortTab, 'push');
            app.EditInTemplateButton.ButtonPushedFcn = createCallbackFcn(app, @EditInTemplateButtonPushed, true);
            app.EditInTemplateButton.Position = [24 184 100 23];
            app.EditInTemplateButton.Text = 'EditInTemplate';

            % Create ReloadButton
            app.ReloadButton = uibutton(app.CreatePortTab, 'push');
            app.ReloadButton.ButtonPushedFcn = createCallbackFcn(app, @ReloadButtonPushed, true);
            app.ReloadButton.Position = [25 124 100 23];
            app.ReloadButton.Text = 'Reload';

            % Create CreateGotoTab
            app.CreateGotoTab = uitab(app.TabGroup3);
            app.CreateGotoTab.Title = 'CreateGoto';

            % Create createGotoUselessButton
            app.createGotoUselessButton = uibutton(app.CreateGotoTab, 'push');
            app.createGotoUselessButton.ButtonPushedFcn = createCallbackFcn(app, @createGotoUselessButtonPushed, true);
            app.createGotoUselessButton.Position = [26 269 117 23];
            app.createGotoUselessButton.Text = 'createGotoUseless';

            % Create createPortsGotoUpdateButton
            app.createPortsGotoUpdateButton = uibutton(app.CreateGotoTab, 'push');
            app.createPortsGotoUpdateButton.ButtonPushedFcn = createCallbackFcn(app, @createPortsGotoUpdateButtonPushed, true);
            app.createPortsGotoUpdateButton.Position = [26 227 141 23];
            app.createPortsGotoUpdateButton.Text = 'createPortsGotoUpdate';

            % Create createPortsGotoUpdateLoopButton
            app.createPortsGotoUpdateLoopButton = uibutton(app.CreateGotoTab, 'push');
            app.createPortsGotoUpdateLoopButton.ButtonPushedFcn = createCallbackFcn(app, @createPortsGotoUpdateLoopButtonPushed, true);
            app.createPortsGotoUpdateLoopButton.Position = [24 183 168 23];
            app.createPortsGotoUpdateLoopButton.Text = 'createPortsGotoUpdateLoop';

            % Create topLevEditFieldLabel
            app.topLevEditFieldLabel = uilabel(app.CreateGotoTab);
            app.topLevEditFieldLabel.HorizontalAlignment = 'right';
            app.topLevEditFieldLabel.Position = [258 186 41 22];
            app.topLevEditFieldLabel.Text = 'topLev';

            % Create topLevEditField
            app.topLevEditField = uieditfield(app.CreateGotoTab, 'text');
            app.topLevEditField.Position = [314 186 100 22];
            app.topLevEditField.Value = 'After';

            % Create createGotoBasedPortsButton_3
            app.createGotoBasedPortsButton_3 = uibutton(app.CreateGotoTab, 'push');
            app.createGotoBasedPortsButton_3.ButtonPushedFcn = createCallbackFcn(app, @createGotoBasedPortsButtonPushed, true);
            app.createGotoBasedPortsButton_3.Position = [27 312 136 23];
            app.createGotoBasedPortsButton_3.Text = 'createGotoBasedPorts';

            % Create CreateBusTab
            app.CreateBusTab = uitab(app.TabGroup3);
            app.CreateBusTab.Title = 'CreateBus';

            % Create CreateBusPortButton
            app.CreateBusPortButton = uibutton(app.CreateBusTab, 'push');
            app.CreateBusPortButton.ButtonPushedFcn = createCallbackFcn(app, @CreateBusPortButtonPushed, true);
            app.CreateBusPortButton.Position = [47 266 113 23];
            app.CreateBusPortButton.Text = 'CreateBusPort';

            % Create CreateBusGotoButton
            app.CreateBusGotoButton = uibutton(app.CreateBusTab, 'push');
            app.CreateBusGotoButton.ButtonPushedFcn = createCallbackFcn(app, @CreateBusGotoButtonPushed, true);
            app.CreateBusGotoButton.Position = [45 215 113 23];
            app.CreateBusGotoButton.Text = 'CreateBusGoto';

            % Create createSwitchCaseTab
            app.createSwitchCaseTab = uitab(app.TabGroup3);
            app.createSwitchCaseTab.Title = 'createSwitchCase';
            app.createSwitchCaseTab.ButtonDownFcn = createCallbackFcn(app, @createSwitchCaseTabButtonDown, true);

            % Create SwitchCaseTable
            app.SwitchCaseTable = uitable(app.createSwitchCaseTab);
            app.SwitchCaseTable.ColumnName = {'caseList'; 'caseNames'};
            app.SwitchCaseTable.ColumnRearrangeable = 'on';
            app.SwitchCaseTable.RowName = {};
            app.SwitchCaseTable.ColumnSortable = true;
            app.SwitchCaseTable.ColumnEditable = true;
            app.SwitchCaseTable.Position = [31 82 284 253];

            % Create SigNamesTextAreaLabel
            app.SigNamesTextAreaLabel = uilabel(app.createSwitchCaseTab);
            app.SigNamesTextAreaLabel.HorizontalAlignment = 'right';
            app.SigNamesTextAreaLabel.Position = [376 184 60 22];
            app.SigNamesTextAreaLabel.Text = 'SigNames';

            % Create SigNamesTextArea
            app.SigNamesTextArea = uitextarea(app.createSwitchCaseTab);
            app.SigNamesTextArea.Placeholder = 'each case output signal';
            app.SigNamesTextArea.Position = [451 72 238 136];
            app.SigNamesTextArea.Value = {'rTmComprCtrl_Te_s32TempError'; 'rTmComprCtrl_n_u16ComprRpmFF'; 'rTmComprCtrl_n_u16ComprRpmKp'; 'rTmComprCtrl_n_u16ComprRpmKi'; 'rTmComprCtrl_n_i16KpLowLimit'; 'rTmComprCtrl_n_i16KpUpLimit'; 'rTmComprCtrl_n_i16KiLowLimit'; 'rTmComprCtrl_n_i16KiUpLimit'; 'xTmComprCtrl_B_Enable'; 'rTmComprCtrl_t_u16PIPeriod'; 'rTmComprCtrl_Te_s32LowErrStop'; 'rTmComprCtrl_Te_s32UpErrStop'; 'rTmComprCtrl_n_u16DisOverrideValue'};

            % Create CaseInTextAreaLabel
            app.CaseInTextAreaLabel = uilabel(app.createSwitchCaseTab);
            app.CaseInTextAreaLabel.HorizontalAlignment = 'right';
            app.CaseInTextAreaLabel.Position = [393 302 43 22];
            app.CaseInTextAreaLabel.Text = 'CaseIn';

            % Create CaseInTextArea
            app.CaseInTextArea = uitextarea(app.createSwitchCaseTab);
            app.CaseInTextArea.Placeholder = 'each case input signal';
            app.CaseInTextArea.Position = [451 217 238 109];
            app.CaseInTextArea.Value = {'sTmRefriModeMgr_D_u8HPCurMode'};

            % Create CaseListEditFieldLabel
            app.CaseListEditFieldLabel = uilabel(app.createSwitchCaseTab);
            app.CaseListEditFieldLabel.HorizontalAlignment = 'right';
            app.CaseListEditFieldLabel.Position = [743 296 52 22];
            app.CaseListEditFieldLabel.Text = 'CaseList';

            % Create CaseListEditField
            app.CaseListEditField = uieditfield(app.createSwitchCaseTab, 'text');
            app.CaseListEditField.Placeholder = 'Case value';
            app.CaseListEditField.Position = [810 296 100 22];
            app.CaseListEditField.Value = '0';

            % Create CaseNameEditFieldLabel
            app.CaseNameEditFieldLabel = uilabel(app.createSwitchCaseTab);
            app.CaseNameEditFieldLabel.HorizontalAlignment = 'right';
            app.CaseNameEditFieldLabel.Position = [730 255 65 22];
            app.CaseNameEditFieldLabel.Text = 'CaseName';

            % Create CaseNameEditField
            app.CaseNameEditField = uieditfield(app.createSwitchCaseTab, 'text');
            app.CaseNameEditField.Placeholder = 'Case Name';
            app.CaseNameEditField.Position = [810 255 100 22];
            app.CaseNameEditField.Value = 'SM0';

            % Create AddButton
            app.AddButton = uibutton(app.createSwitchCaseTab, 'push');
            app.AddButton.ButtonPushedFcn = createCallbackFcn(app, @AddButtonPushed, true);
            app.AddButton.Position = [738 205 100 23];
            app.AddButton.Text = 'Add';

            % Create ClearAllButton
            app.ClearAllButton = uibutton(app.createSwitchCaseTab, 'push');
            app.ClearAllButton.ButtonPushedFcn = createCallbackFcn(app, @ClearAllButtonPushed, true);
            app.ClearAllButton.Position = [738 158 271 23];
            app.ClearAllButton.Text = 'ClearAll';

            % Create RemoveButton
            app.RemoveButton = uibutton(app.createSwitchCaseTab, 'push');
            app.RemoveButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveButtonPushed, true);
            app.RemoveButton.Position = [909 205 100 23];
            app.RemoveButton.Text = 'Remove';

            % Create createSwitchCaseButton
            app.createSwitchCaseButton = uibutton(app.createSwitchCaseTab, 'push');
            app.createSwitchCaseButton.ButtonPushedFcn = createCallbackFcn(app, @createSwitchCaseButtonPushed, true);
            app.createSwitchCaseButton.Position = [111 39 112 23];
            app.createSwitchCaseButton.Text = 'createSwitchCase';

            % Create CreateInterfaceTab
            app.CreateInterfaceTab = uitab(app.TabGroup3);
            app.CreateInterfaceTab.Title = 'CreateInterface';

            % Create creatIFInButton
            app.creatIFInButton = uibutton(app.CreateInterfaceTab, 'push');
            app.creatIFInButton.ButtonPushedFcn = createCallbackFcn(app, @creatIFInButtonPushed, true);
            app.creatIFInButton.Position = [49 301 100 23];
            app.creatIFInButton.Text = 'creatIFIn';

            % Create creatIFOutButton
            app.creatIFOutButton = uibutton(app.CreateInterfaceTab, 'push');
            app.creatIFOutButton.ButtonPushedFcn = createCallbackFcn(app, @creatIFOutButtonPushed, true);
            app.creatIFOutButton.Position = [49 255 100 23];
            app.creatIFOutButton.Text = 'creatIFOut';

            % Create creatTmOutButton
            app.creatTmOutButton = uibutton(app.CreateInterfaceTab, 'push');
            app.creatTmOutButton.ButtonPushedFcn = createCallbackFcn(app, @creatTmOutButtonPushed, true);
            app.creatTmOutButton.Position = [47 205 100 23];
            app.creatTmOutButton.Text = 'creatTmOut';

            % Create creatTmBaseButton
            app.creatTmBaseButton = uibutton(app.CreateInterfaceTab, 'push');
            app.creatTmBaseButton.ButtonPushedFcn = createCallbackFcn(app, @creatTmBaseButtonPushed, true);
            app.creatTmBaseButton.Position = [48 158 100 23];
            app.creatTmBaseButton.Text = 'creatTmBase';

            % Create DeleteTab
            app.DeleteTab = uitab(app.TabGroup2);
            app.DeleteTab.Title = 'Delete';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.DeleteTab);
            app.GridLayout.ColumnWidth = {'fit', 'fit', '2.25x'};
            app.GridLayout.RowHeight = {'fit', 23, '1.24x', 22, 23, 23, '9.59x'};

            % Create delUselessPortButton
            app.delUselessPortButton = uibutton(app.GridLayout, 'push');
            app.delUselessPortButton.ButtonPushedFcn = createCallbackFcn(app, @delUselessPortButtonPushed, true);
            app.delUselessPortButton.Layout.Row = 5;
            app.delUselessPortButton.Layout.Column = 1;
            app.delUselessPortButton.Text = 'delUselessPort';

            % Create delGcsAllButton
            app.delGcsAllButton = uibutton(app.GridLayout, 'push');
            app.delGcsAllButton.ButtonPushedFcn = createCallbackFcn(app, @delGcsAllButtonPushed, true);
            app.delGcsAllButton.Layout.Row = 1;
            app.delGcsAllButton.Layout.Column = 1;
            app.delGcsAllButton.Text = 'delGcsAll';

            % Create UselessInBlockDropDownLabel
            app.UselessInBlockDropDownLabel = uilabel(app.GridLayout);
            app.UselessInBlockDropDownLabel.HorizontalAlignment = 'right';
            app.UselessInBlockDropDownLabel.Layout.Row = 3;
            app.UselessInBlockDropDownLabel.Layout.Column = 1;
            app.UselessInBlockDropDownLabel.Text = 'UselessInBlock';

            % Create UselessInBlockDropDown
            app.UselessInBlockDropDown = uidropdown(app.GridLayout);
            app.UselessInBlockDropDown.Items = {'Terminator', 'Goto'};
            app.UselessInBlockDropDown.Layout.Row = 3;
            app.UselessInBlockDropDown.Layout.Column = 2;
            app.UselessInBlockDropDown.Value = 'Terminator';

            % Create UselessOutBlockDropDownLabel
            app.UselessOutBlockDropDownLabel = uilabel(app.GridLayout);
            app.UselessOutBlockDropDownLabel.HorizontalAlignment = 'right';
            app.UselessOutBlockDropDownLabel.Layout.Row = 4;
            app.UselessOutBlockDropDownLabel.Layout.Column = 1;
            app.UselessOutBlockDropDownLabel.Text = 'UselessOutBlock';

            % Create UselessOutBlockDropDown
            app.UselessOutBlockDropDown = uidropdown(app.GridLayout);
            app.UselessOutBlockDropDown.Items = {'Ground', 'From', 'Constant'};
            app.UselessOutBlockDropDown.Layout.Row = 4;
            app.UselessOutBlockDropDown.Layout.Column = 2;
            app.UselessOutBlockDropDown.Value = 'Ground';

            % Create ChangeTab
            app.ChangeTab = uitab(app.TabGroup2);
            app.ChangeTab.Title = 'Change';

            % Create changePortBlockPosAllButton
            app.changePortBlockPosAllButton = uibutton(app.ChangeTab, 'push');
            app.changePortBlockPosAllButton.ButtonPushedFcn = createCallbackFcn(app, @changePortBlockPosAllButtonPushed, true);
            app.changePortBlockPosAllButton.Position = [32 159 193 23];
            app.changePortBlockPosAllButton.Text = 'changePortBlockPosAll';

            % Create changeModPortNameButton
            app.changeModPortNameButton = uibutton(app.ChangeTab, 'push');
            app.changeModPortNameButton.ButtonPushedFcn = createCallbackFcn(app, @changeModPortNameButtonPushed, true);
            app.changeModPortNameButton.Position = [31 263 193 23];
            app.changeModPortNameButton.Text = 'changeModPortName';

            % Create changeModPortTypeButton
            app.changeModPortTypeButton = uibutton(app.ChangeTab, 'push');
            app.changeModPortTypeButton.ButtonPushedFcn = createCallbackFcn(app, @changeModPortTypeButtonPushed, true);
            app.changeModPortTypeButton.Position = [690 292 121 23];
            app.changeModPortTypeButton.Text = 'changeModPortType';

            % Create changeModSizeButton
            app.changeModSizeButton = uibutton(app.ChangeTab, 'push');
            app.changeModSizeButton.ButtonPushedFcn = createCallbackFcn(app, @changeModSizeButtonPushed, true);
            app.changeModSizeButton.Position = [322 301 112 28];
            app.changeModSizeButton.Text = 'changeModSize';

            % Create changeModSizeGcsButton
            app.changeModSizeGcsButton = uibutton(app.ChangeTab, 'push');
            app.changeModSizeGcsButton.ButtonPushedFcn = createCallbackFcn(app, @changeModSizeGcsButtonPushed, true);
            app.changeModSizeGcsButton.Position = [446 304 132 23];
            app.changeModSizeGcsButton.Text = 'changeModSizeGcs';

            % Create changeSigTypeButton
            app.changeSigTypeButton = uibutton(app.ChangeTab, 'push');
            app.changeSigTypeButton.ButtonPushedFcn = createCallbackFcn(app, @changeSigTypeButtonPushed, true);
            app.changeSigTypeButton.Position = [887 292 100 23];
            app.changeSigTypeButton.Text = 'changeSigType';

            % Create OldNameEditFieldLabel
            app.OldNameEditFieldLabel = uilabel(app.ChangeTab);
            app.OldNameEditFieldLabel.HorizontalAlignment = 'right';
            app.OldNameEditFieldLabel.Position = [-35 335 121 22];
            app.OldNameEditFieldLabel.Text = 'OldName';

            % Create OldNameEditField
            app.OldNameEditField = uieditfield(app.ChangeTab, 'text');
            app.OldNameEditField.Placeholder = 'Replace Name';
            app.OldNameEditField.Position = [96 335 151 22];
            app.OldNameEditField.Value = 'TmComprCtrl';

            % Create NewNameEditFieldLabel
            app.NewNameEditFieldLabel = uilabel(app.ChangeTab);
            app.NewNameEditFieldLabel.HorizontalAlignment = 'right';
            app.NewNameEditFieldLabel.Position = [-35 302 121 23];
            app.NewNameEditFieldLabel.Text = 'NewName';

            % Create NewNameEditField
            app.NewNameEditField = uieditfield(app.ChangeTab, 'text');
            app.NewNameEditField.Placeholder = 'Expect Name';
            app.NewNameEditField.Position = [96 302 151 23];
            app.NewNameEditField.Value = 'SM2SM22';

            % Create GcsArrangeRowsSpinnerLabel
            app.GcsArrangeRowsSpinnerLabel = uilabel(app.ChangeTab);
            app.GcsArrangeRowsSpinnerLabel.HorizontalAlignment = 'right';
            app.GcsArrangeRowsSpinnerLabel.Position = [302 337 132 22];
            app.GcsArrangeRowsSpinnerLabel.Text = 'GcsArrangeRows';

            % Create GcsArrangeRowsSpinner
            app.GcsArrangeRowsSpinner = uispinner(app.ChangeTab);
            app.GcsArrangeRowsSpinner.Limits = [1 5];
            app.GcsArrangeRowsSpinner.Position = [444 337 126 22];
            app.GcsArrangeRowsSpinner.Value = 1;

            % Create SigNeedChgTypeEditFieldLabel
            app.SigNeedChgTypeEditFieldLabel = uilabel(app.ChangeTab);
            app.SigNeedChgTypeEditFieldLabel.HorizontalAlignment = 'right';
            app.SigNeedChgTypeEditFieldLabel.Position = [666 335 100 22];
            app.SigNeedChgTypeEditFieldLabel.Text = 'SigNeedChgType';

            % Create SigNeedChgTypeEditField
            app.SigNeedChgTypeEditField = uieditfield(app.ChangeTab, 'text');
            app.SigNeedChgTypeEditField.Placeholder = 'Signal that need to change the type';
            app.SigNeedChgTypeEditField.Position = [776 335 229 22];
            app.SigNeedChgTypeEditField.Value = 'rTmComprCtrl_n_s32CompRpmReq';

            % Create FindTab
            app.FindTab = uitab(app.TabGroup2);
            app.FindTab.Title = 'Find';

            % Create findModPortsButton
            app.findModPortsButton = uibutton(app.FindTab, 'push');
            app.findModPortsButton.ButtonPushedFcn = createCallbackFcn(app, @findModPortsButtonPushed, true);
            app.findModPortsButton.Position = [36 223 100 23];
            app.findModPortsButton.Text = 'findModPorts';

            % Create PortTypeDropDownLabel
            app.PortTypeDropDownLabel = uilabel(app.FindTab);
            app.PortTypeDropDownLabel.HorizontalAlignment = 'right';
            app.PortTypeDropDownLabel.Position = [177 223 53 22];
            app.PortTypeDropDownLabel.Text = 'PortType';

            % Create PortTypeDropDown
            app.PortTypeDropDown = uidropdown(app.FindTab);
            app.PortTypeDropDown.Items = {'Path', 'Name', 'OutDataTypeStr'};
            app.PortTypeDropDown.Position = [245 223 100 22];
            app.PortTypeDropDown.Value = 'Path';

            % Create TestTab
            app.TestTab = uitab(app.TabGroup);
            app.TestTab.Title = 'Test';
            app.TestTab.ButtonDownFcn = createCallbackFcn(app, @TestTabButtonDown, true);

            % Create TestCaseTextAreaLabel
            app.TestCaseTextAreaLabel = uilabel(app.TestTab);
            app.TestCaseTextAreaLabel.HorizontalAlignment = 'right';
            app.TestCaseTextAreaLabel.Position = [171 333 55 22];
            app.TestCaseTextAreaLabel.Text = 'TestCase';

            % Create TestCaseTextArea
            app.TestCaseTextArea = uitextarea(app.TestTab);
            app.TestCaseTextArea.Placeholder = 'test case that need to add to the tree';
            app.TestCaseTextArea.Position = [241 297 228 60];
            app.TestCaseTextArea.Value = {'LEV1'; 'LEV2'};

            % Create AddCaseButton
            app.AddCaseButton = uibutton(app.TestTab, 'push');
            app.AddCaseButton.ButtonPushedFcn = createCallbackFcn(app, @AddCaseButtonPushed, true);
            app.AddCaseButton.Position = [174 261 100 23];
            app.AddCaseButton.Text = 'AddCase';

            % Create DelCaseButton
            app.DelCaseButton = uibutton(app.TestTab, 'push');
            app.DelCaseButton.ButtonPushedFcn = createCallbackFcn(app, @DelCaseButtonPushed, true);
            app.DelCaseButton.Position = [283 259 100 23];
            app.DelCaseButton.Text = 'DelCase';

            % Create LastStepDropDownLabel
            app.LastStepDropDownLabel = uilabel(app.TestTab);
            app.LastStepDropDownLabel.HorizontalAlignment = 'right';
            app.LastStepDropDownLabel.Position = [511 333 52 22];
            app.LastStepDropDownLabel.Text = 'LastStep';

            % Create LastStepDropDown
            app.LastStepDropDown = uidropdown(app.TestTab);
            app.LastStepDropDown.Items = {'Initialize'};
            app.LastStepDropDown.Position = [578 333 100 22];
            app.LastStepDropDown.Value = 'Initialize';

            % Create NextStepDropDownLabel
            app.NextStepDropDownLabel = uilabel(app.TestTab);
            app.NextStepDropDownLabel.HorizontalAlignment = 'right';
            app.NextStepDropDownLabel.Position = [510 300 54 22];
            app.NextStepDropDownLabel.Text = 'NextStep';

            % Create NextStepDropDown
            app.NextStepDropDown = uidropdown(app.TestTab);
            app.NextStepDropDown.Items = {'None'};
            app.NextStepDropDown.Position = [579 300 100 22];
            app.NextStepDropDown.Value = 'None';

            % Create CaseTable
            app.CaseTable = uitable(app.TestTab);
            app.CaseTable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.CaseTable.RowName = {};
            app.CaseTable.ColumnEditable = true;
            app.CaseTable.Position = [159 3 941 227];

            % Create GetPortsButton
            app.GetPortsButton = uibutton(app.TestTab, 'push');
            app.GetPortsButton.ButtonPushedFcn = createCallbackFcn(app, @GetPortsButtonPushed, true);
            app.GetPortsButton.Position = [400 259 100 23];
            app.GetPortsButton.Text = 'GetPorts';

            % Create createHarnessButton
            app.createHarnessButton = uibutton(app.TestTab, 'push');
            app.createHarnessButton.ButtonPushedFcn = createCallbackFcn(app, @createHarnessButtonPushed, true);
            app.createHarnessButton.Position = [522 260 100 23];
            app.createHarnessButton.Text = 'createHarness';

            % Create DemoButton
            app.DemoButton = uibutton(app.TestTab, 'push');
            app.DemoButton.ButtonPushedFcn = createCallbackFcn(app, @DemoButtonPushed, true);
            app.DemoButton.Position = [647 260 100 23];
            app.DemoButton.Text = 'Demo';

            % Create DelParamButton
            app.DelParamButton = uibutton(app.TestTab, 'push');
            app.DelParamButton.ButtonPushedFcn = createCallbackFcn(app, @DelParamButtonPushed, true);
            app.DelParamButton.Position = [779 260 100 23];
            app.DelParamButton.Text = 'DelParam';

            % Create CaseTreePanel
            app.CaseTreePanel = uipanel(app.TestTab);
            app.CaseTreePanel.Title = 'CaseTree';
            app.CaseTreePanel.Position = [4 179 154 189];

            % Create CaseListTree
            app.CaseListTree = uitree(app.CaseTreePanel);
            app.CaseListTree.Position = [1 0 152 170];

            % Create HarnessHistoryParamsPanel
            app.HarnessHistoryParamsPanel = uipanel(app.TestTab);
            app.HarnessHistoryParamsPanel.Title = 'Harness History Params';
            app.HarnessHistoryParamsPanel.Position = [4 1 156 179];

            % Create HarnessParamsListBox
            app.HarnessParamsListBox = uilistbox(app.HarnessHistoryParamsPanel);
            app.HarnessParamsListBox.Items = {};
            app.HarnessParamsListBox.ValueChangedFcn = createCallbackFcn(app, @HarnessParamsListBoxValueChanged, true);
            app.HarnessParamsListBox.ClickedFcn = createCallbackFcn(app, @HarnessParamsListBoxClicked, true);
            app.HarnessParamsListBox.Position = [1 1 152 158];
            app.HarnessParamsListBox.Value = {};

            % Create SlddTab
            app.SlddTab = uitab(app.TabGroup);
            app.SlddTab.SizeChangedFcn = createCallbackFcn(app, @SlddTabSizeChanged, true);
            app.SlddTab.Title = 'Sldd';
            app.SlddTab.ButtonDownFcn = createCallbackFcn(app, @SlddTabButtonDown, true);

            % Create CreateMatlabSlddPanel
            app.CreateMatlabSlddPanel = uipanel(app.SlddTab);
            app.CreateMatlabSlddPanel.Title = 'CreateMatlabSldd';
            app.CreateMatlabSlddPanel.Position = [4 186 266 185];

            % Create createSlddDesignDataButton
            app.createSlddDesignDataButton = uibutton(app.CreateMatlabSlddPanel, 'push');
            app.createSlddDesignDataButton.ButtonPushedFcn = createCallbackFcn(app, @createSlddDesignDataButtonPushed, true);
            app.createSlddDesignDataButton.Position = [6 75 148 23];
            app.createSlddDesignDataButton.Text = 'createSlddDesignData';

            % Create createSlddButton
            app.createSlddButton = uibutton(app.CreateMatlabSlddPanel, 'push');
            app.createSlddButton.ButtonPushedFcn = createCallbackFcn(app, @createSlddButtonPushed, true);
            app.createSlddButton.Position = [6 116 149 23];
            app.createSlddButton.Text = 'createSldd';

            % Create CreateExcelSlddPanel
            app.CreateExcelSlddPanel = uipanel(app.SlddTab);
            app.CreateExcelSlddPanel.Title = 'CreateExcelSldd';
            app.CreateExcelSlddPanel.Position = [6 6 264 181];

            % Create AreaDropDownLabel
            app.AreaDropDownLabel = uilabel(app.CreateExcelSlddPanel);
            app.AreaDropDownLabel.HorizontalAlignment = 'right';
            app.AreaDropDownLabel.Position = [14 128 30 22];
            app.AreaDropDownLabel.Text = 'Area';

            % Create AreaDropDown
            app.AreaDropDown = uidropdown(app.CreateExcelSlddPanel);
            app.AreaDropDown.Items = {'bdroot', 'gcs'};
            app.AreaDropDown.Position = [59 128 147 22];
            app.AreaDropDown.Value = 'bdroot';

            % Create findParametersButton
            app.findParametersButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.findParametersButton.ButtonPushedFcn = createCallbackFcn(app, @findParametersButtonPushed, true);
            app.findParametersButton.Position = [19 90 100 23];
            app.findParametersButton.Text = 'findParameters';

            % Create findSlddButton
            app.findSlddButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.findSlddButton.ButtonPushedFcn = createCallbackFcn(app, @findSlddButtonPushed, true);
            app.findSlddButton.Position = [19 52 100 23];
            app.findSlddButton.Text = 'findSldd';

            % Create openSlddButton
            app.openSlddButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.openSlddButton.ButtonPushedFcn = createCallbackFcn(app, @openSlddButtonPushed, true);
            app.openSlddButton.Position = [143 52 100 23];
            app.openSlddButton.Text = 'openSldd';

            % Create changeExportedSlddButton
            app.changeExportedSlddButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.changeExportedSlddButton.ButtonPushedFcn = createCallbackFcn(app, @changeExportedSlddButtonPushed, true);
            app.changeExportedSlddButton.Position = [20 12 165 23];
            app.changeExportedSlddButton.Text = 'changeExportedSldd';

            % Create LoadSlddPanel
            app.LoadSlddPanel = uipanel(app.SlddTab);
            app.LoadSlddPanel.Title = 'LoadSldd';
            app.LoadSlddPanel.Position = [270 186 260 184];

            % Create findSlddLoadVCUButton
            app.findSlddLoadVCUButton = uibutton(app.LoadSlddPanel, 'push');
            app.findSlddLoadVCUButton.ButtonPushedFcn = createCallbackFcn(app, @findSlddLoadVCUButtonPushed, true);
            app.findSlddLoadVCUButton.Position = [17 118 116 23];
            app.findSlddLoadVCUButton.Text = 'findSlddLoadVCU';

            % Create findSlddLoadPCMUButton
            app.findSlddLoadPCMUButton = uibutton(app.LoadSlddPanel, 'push');
            app.findSlddLoadPCMUButton.ButtonPushedFcn = createCallbackFcn(app, @findSlddLoadPCMUButtonPushed, true);
            app.findSlddLoadPCMUButton.Position = [16 82 120 23];
            app.findSlddLoadPCMUButton.Text = 'findSlddLoadPCMU';

            % Create LoadAllSlddButton
            app.LoadAllSlddButton = uibutton(app.LoadSlddPanel, 'push');
            app.LoadAllSlddButton.ButtonPushedFcn = createCallbackFcn(app, @LoadAllSlddButtonPushed, true);
            app.LoadAllSlddButton.Position = [28 42 100 23];
            app.LoadAllSlddButton.Text = 'LoadAllSldd';

            % Create ChangeSlddPanel
            app.ChangeSlddPanel = uipanel(app.SlddTab);
            app.ChangeSlddPanel.Title = 'ChangeSldd';
            app.ChangeSlddPanel.Position = [271 6 259 179];

            % Create changeSlddTableByInitValueButton
            app.changeSlddTableByInitValueButton = uibutton(app.ChangeSlddPanel, 'push');
            app.changeSlddTableByInitValueButton.ButtonPushedFcn = createCallbackFcn(app, @changeSlddTableByInitValueButtonPushed, true);
            app.changeSlddTableByInitValueButton.Position = [17 124 167 23];
            app.changeSlddTableByInitValueButton.Text = 'changeSlddTableByInitValue';

            % Create changeSlddInitValueByTableButton
            app.changeSlddInitValueByTableButton = uibutton(app.ChangeSlddPanel, 'push');
            app.changeSlddInitValueByTableButton.ButtonPushedFcn = createCallbackFcn(app, @changeSlddInitValueByTableButtonPushed, true);
            app.changeSlddInitValueByTableButton.Position = [17 92 167 23];
            app.changeSlddInitValueByTableButton.Text = 'changeSlddInitValueByTable';

            % Create changeArchSlddButton
            app.changeArchSlddButton = uibutton(app.ChangeSlddPanel, 'push');
            app.changeArchSlddButton.ButtonPushedFcn = createCallbackFcn(app, @changeArchSlddButtonPushed, true);
            app.changeArchSlddButton.Position = [17 56 165 22];
            app.changeArchSlddButton.Text = 'changeArchSldd';

            % Create FindDcmPanel
            app.FindDcmPanel = uipanel(app.SlddTab);
            app.FindDcmPanel.Title = 'FindDcm';
            app.FindDcmPanel.Position = [532 188 231 181];

            % Create findDCMNamesButton
            app.findDCMNamesButton = uibutton(app.FindDcmPanel, 'push');
            app.findDCMNamesButton.ButtonPushedFcn = createCallbackFcn(app, @findDCMNamesButtonPushed, true);
            app.findDCMNamesButton.Position = [18 118 145 23];
            app.findDCMNamesButton.Text = 'findDCMNames';

            % Create findDCMNamesChangesButton
            app.findDCMNamesChangesButton = uibutton(app.FindDcmPanel, 'push');
            app.findDCMNamesChangesButton.ButtonPushedFcn = createCallbackFcn(app, @findDCMNamesChangesButtonPushed, true);
            app.findDCMNamesChangesButton.Position = [18 80 148 23];
            app.findDCMNamesChangesButton.Text = 'findDCMNamesChanges';

            % Create findDCMValuesChangesButton
            app.findDCMValuesChangesButton = uibutton(app.FindDcmPanel, 'push');
            app.findDCMValuesChangesButton.ButtonPushedFcn = createCallbackFcn(app, @findDCMValuesChangesButtonPushed, true);
            app.findDCMValuesChangesButton.Position = [19 40 146 23];
            app.findDCMValuesChangesButton.Text = 'findDCMValuesChanges';

            % Create ConfigPanel
            app.ConfigPanel = uipanel(app.SlddTab);
            app.ConfigPanel.Title = 'Config';
            app.ConfigPanel.Position = [764 187 338 181];

            % Create SubModDropDown_2Label_3
            app.SubModDropDown_2Label_3 = uilabel(app.ConfigPanel);
            app.SubModDropDown_2Label_3.HorizontalAlignment = 'right';
            app.SubModDropDown_2Label_3.Position = [14 121 50 22];
            app.SubModDropDown_2Label_3.Text = 'SubMod';

            % Create SlddDropDown
            app.SlddDropDown = uidropdown(app.ConfigPanel);
            app.SlddDropDown.Items = {'TmRefriModeMgr', 'TmColtModeMgr', 'TmHvchCtrl', 'TmComprCtrl', 'TmRefriVlvCtrl', 'TmSovCtrl', 'TmSigProces', 'TmPumpCtrl', 'TmColtVlvCtrl', 'TmEnergyMgr', 'TmDiag', 'TmAfCtrl', 'bdroot'};
            app.SlddDropDown.Position = [14 98 147 22];
            app.SlddDropDown.Value = 'TmRefriModeMgr';

            % Create DefaultDcmButton
            app.DefaultDcmButton = uibutton(app.ConfigPanel, 'push');
            app.DefaultDcmButton.ButtonPushedFcn = createCallbackFcn(app, @DefaultDcmButtonPushed, true);
            app.DefaultDcmButton.Position = [9 9 100 23];
            app.DefaultDcmButton.Text = 'DefaultDcm';

            % Create DcmFilePath
            app.DcmFilePath = uieditfield(app.ConfigPanel, 'text');
            app.DcmFilePath.Placeholder = 'DCM File';
            app.DcmFilePath.Position = [9 39 323 24];

            % Create SlddTypeButtonGroup
            app.SlddTypeButtonGroup = uibuttongroup(app.ConfigPanel);
            app.SlddTypeButtonGroup.Title = 'SlddType';
            app.SlddTypeButtonGroup.Position = [200 74 123 74];

            % Create PCMUButton_2
            app.PCMUButton_2 = uiradiobutton(app.SlddTypeButtonGroup);
            app.PCMUButton_2.Text = 'PCMU';
            app.PCMUButton_2.Position = [11 28 58 22];
            app.PCMUButton_2.Value = true;

            % Create VCUButton_2
            app.VCUButton_2 = uiradiobutton(app.SlddTypeButtonGroup);
            app.VCUButton_2.Text = 'VCU';
            app.VCUButton_2.Position = [11 6 65 22];

            % Create NoteTextAreaLabel
            app.NoteTextAreaLabel = uilabel(app.SlddTab);
            app.NoteTextAreaLabel.HorizontalAlignment = 'right';
            app.NoteTextAreaLabel.Position = [533 161 30 22];
            app.NoteTextAreaLabel.Text = 'Note';

            % Create NoteTextArea
            app.NoteTextArea = uitextarea(app.SlddTab);
            app.NoteTextArea.Position = [532 6 566 151];
            app.NoteTextArea.Value = {'备注：'; '函数功能简述如下，具体使用说明，请打开帮助手册（Help -> Sript Instrcution, 快捷键 Ctrl + h）'; '-------------------------------------------------------------------------------------------------------'; 'createSldd： 创建matlab sldd 并绑定模型(Config->SubMod)'; 'createSlddDesignData: 创建matlab sldd 并绑定模型, 同时将有用的工作空间变量，导入到sldd文件中，这个脚本的前提条件是仿真需要通过'; 'findParameters：可以找出当前界面或者模型的所有标定量，可选参数是bdroot 和 gcs'; 'findSldd:  导出当前模型的所有标定量，信号量到excel 格式的sldd中'; 'openSldd： 打开已经导出的sldd excel 文件，可选参数： Config -> SlddType '; 'changeExportedSldd:  根据最新的DCM文件，对导出 的变量进行赋初值'; 'findSlddLoadVCU： 将excel  变量导入到工作空间中'; 'findSlddLoadPCMU： 将excel  变量导入到工作空间中'; 'LoadAllSldd：  导入所有子模块的变量'; 'changeSlddTableByInitValue： 根据sldd 初值，改变对应的table变量'; 'changeSlddInitValueByTable： 根据sldd table变量，改变对应的初值'; 'changeArchSldd： 根据最新的DCM文件，对汇总后的标定量进行赋初值'; 'findDCMNames： 导出DCM文件中所有的标定量'; 'findDCMNamesChanges： 比较两个不同时期的DCM 标定量变化'; 'findDCMValuesChanges： 比较两个不同时期的DCM 标定值变化'};

            % Create CheckTab
            app.CheckTab = uitab(app.TabGroup);
            app.CheckTab.Title = 'Check';
            app.CheckTab.ButtonDownFcn = createCallbackFcn(app, @CheckTabButtonDown, true);

            % Create delUselessLineButton
            app.delUselessLineButton = uibutton(app.CheckTab, 'push');
            app.delUselessLineButton.ButtonPushedFcn = createCallbackFcn(app, @delUselessLineButtonPushed, true);
            app.delUselessLineButton.Tooltip = {'删除无用连线'};
            app.delUselessLineButton.Position = [8 342 91 23];
            app.delUselessLineButton.Text = 'delUselessLine';

            % Create IntegrationTab
            app.IntegrationTab = uitab(app.TabGroup);
            app.IntegrationTab.Title = 'Integration';
            app.IntegrationTab.ButtonDownFcn = createCallbackFcn(app, @IntegrationTabButtonDown, true);

            % Create SingleModelProcessPanel
            app.SingleModelProcessPanel = uipanel(app.IntegrationTab);
            app.SingleModelProcessPanel.Title = 'SingleModelProcess';
            app.SingleModelProcessPanel.Position = [546 6 540 367];

            % Create SubModDropDownLabel
            app.SubModDropDownLabel = uilabel(app.SingleModelProcessPanel);
            app.SubModDropDownLabel.HorizontalAlignment = 'right';
            app.SubModDropDownLabel.Position = [24 310 50 22];
            app.SubModDropDownLabel.Text = 'SubMod';

            % Create SubModDropDown
            app.SubModDropDown = uidropdown(app.SingleModelProcessPanel);
            app.SubModDropDown.Items = {'TmRefriModeMgr', 'TmColtModeMgr', 'TmHvchCtrl', 'TmComprCtrl', 'TmRefriVlvCtrl', 'TmSovCtrl', 'TmSigProces', 'TmPumpCtrl', 'TmColtVlvCtrl', 'TmEnergyMgr', 'TmDiag', 'TmAfCtrl'};
            app.SubModDropDown.ValueChangedFcn = createCallbackFcn(app, @SubModDropDownValueChanged, true);
            app.SubModDropDown.Position = [89 310 147 22];
            app.SubModDropDown.Value = 'TmRefriModeMgr';

            % Create ControlChooseButtonGroup
            app.ControlChooseButtonGroup = uibuttongroup(app.SingleModelProcessPanel);
            app.ControlChooseButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ControlChooseButtonGroupSelectionChanged, true);
            app.ControlChooseButtonGroup.Title = 'ControlChoose';
            app.ControlChooseButtonGroup.Position = [387 260 123 74];

            % Create PCMUButton
            app.PCMUButton = uiradiobutton(app.ControlChooseButtonGroup);
            app.PCMUButton.Text = 'PCMU';
            app.PCMUButton.Position = [11 28 58 22];
            app.PCMUButton.Value = true;

            % Create VCUButton
            app.VCUButton = uiradiobutton(app.ControlChooseButtonGroup);
            app.VCUButton.Text = 'VCU';
            app.VCUButton.Position = [11 6 65 22];

            % Create CreateSubModelButton
            app.CreateSubModelButton = uibutton(app.SingleModelProcessPanel, 'push');
            app.CreateSubModelButton.ButtonPushedFcn = createCallbackFcn(app, @CreateSubModelButtonPushed, true);
            app.CreateSubModelButton.Position = [21 228 120 23];
            app.CreateSubModelButton.Text = 'CreateSubModel';

            % Create createCodeSubModButton
            app.createCodeSubModButton = uibutton(app.SingleModelProcessPanel, 'push');
            app.createCodeSubModButton.ButtonPushedFcn = createCallbackFcn(app, @createCodeSubModButtonPushed, true);
            app.createCodeSubModButton.Position = [21 184 122 23];
            app.createCodeSubModButton.Text = 'createCodeSubMod';

            % Create changeCfgAutosarButton
            app.changeCfgAutosarButton = uibutton(app.SingleModelProcessPanel, 'push');
            app.changeCfgAutosarButton.ButtonPushedFcn = createCallbackFcn(app, @changeCfgAutosarButtonPushed, true);
            app.changeCfgAutosarButton.Position = [209 184 114 23];
            app.changeCfgAutosarButton.Text = 'changeCfgAutosar';

            % Create changeCfgErtButton
            app.changeCfgErtButton = uibutton(app.SingleModelProcessPanel, 'push');
            app.changeCfgErtButton.ButtonPushedFcn = createCallbackFcn(app, @changeCfgErtButtonPushed, true);
            app.changeCfgErtButton.Position = [209 137 114 23];
            app.changeCfgErtButton.Text = 'changeCfgErt';

            % Create changeCfgRefButton
            app.changeCfgRefButton = uibutton(app.SingleModelProcessPanel, 'push');
            app.changeCfgRefButton.ButtonPushedFcn = createCallbackFcn(app, @changeCfgRefButtonPushed, true);
            app.changeCfgRefButton.Position = [209 228 114 23];
            app.changeCfgRefButton.Text = 'changeCfgRef';

            % Create RefConfigEditFieldLabel
            app.RefConfigEditFieldLabel = uilabel(app.SingleModelProcessPanel);
            app.RefConfigEditFieldLabel.HorizontalAlignment = 'right';
            app.RefConfigEditFieldLabel.Position = [18 277 58 22];
            app.RefConfigEditFieldLabel.Text = 'RefConfig';

            % Create RefConfigEditField
            app.RefConfigEditField = uieditfield(app.SingleModelProcessPanel, 'text');
            app.RefConfigEditField.Position = [91 277 204 22];
            app.RefConfigEditField.Value = 'TmVcThermal_Configuration_sub';

            % Create ThernalIntegrationPanel
            app.ThernalIntegrationPanel = uipanel(app.IntegrationTab);
            app.ThernalIntegrationPanel.Title = 'Thernal Integration';
            app.ThernalIntegrationPanel.Position = [10 6 534 366];

            % Create createCodePkgButton
            app.createCodePkgButton = uibutton(app.ThernalIntegrationPanel, 'push');
            app.createCodePkgButton.ButtonPushedFcn = createCallbackFcn(app, @createCodePkgButtonPushed, true);
            app.createCodePkgButton.Position = [28 50 105 23];
            app.createCodePkgButton.Text = 'createCodePkg';

            % Create createIntegrationButton
            app.createIntegrationButton = uibutton(app.ThernalIntegrationPanel, 'push');
            app.createIntegrationButton.ButtonPushedFcn = createCallbackFcn(app, @createIntegrationButtonPushed, true);
            app.createIntegrationButton.Position = [28 92 105 23];
            app.createIntegrationButton.Text = 'createIntegration';

            % Create ArxmlToModelButton
            app.ArxmlToModelButton = uibutton(app.ThernalIntegrationPanel, 'push');
            app.ArxmlToModelButton.ButtonPushedFcn = createCallbackFcn(app, @ArxmlToModelButtonPushed, true);
            app.ArxmlToModelButton.Position = [28 133 105 23];
            app.ArxmlToModelButton.Text = 'ArxmlToModel';

            % Create STAGEEditFieldLabel
            app.STAGEEditFieldLabel = uilabel(app.ThernalIntegrationPanel);
            app.STAGEEditFieldLabel.HorizontalAlignment = 'right';
            app.STAGEEditFieldLabel.Position = [111 302 45 22];
            app.STAGEEditFieldLabel.Text = 'STAGE';

            % Create STAGEEditField
            app.STAGEEditField = uieditfield(app.ThernalIntegrationPanel, 'text');
            app.STAGEEditField.Position = [171 302 100 22];
            app.STAGEEditField.Value = '23N7';

            % Create INTERFACE_VERISONEditFieldLabel
            app.INTERFACE_VERISONEditFieldLabel = uilabel(app.ThernalIntegrationPanel);
            app.INTERFACE_VERISONEditFieldLabel.HorizontalAlignment = 'right';
            app.INTERFACE_VERISONEditFieldLabel.Position = [23 271 133 22];
            app.INTERFACE_VERISONEditFieldLabel.Text = 'INTERFACE_VERISON';

            % Create INTERFACE_VERISONEditField
            app.INTERFACE_VERISONEditField = uieditfield(app.ThernalIntegrationPanel, 'text');
            app.INTERFACE_VERISONEditField.Position = [171 271 100 22];
            app.INTERFACE_VERISONEditField.Value = 'V136';

            % Create SOFT_VERSIONEditFieldLabel
            app.SOFT_VERSIONEditFieldLabel = uilabel(app.ThernalIntegrationPanel);
            app.SOFT_VERSIONEditFieldLabel.HorizontalAlignment = 'right';
            app.SOFT_VERSIONEditFieldLabel.Position = [58 241 98 22];
            app.SOFT_VERSIONEditFieldLabel.Text = 'SOFT_VERSION';

            % Create SOFT_VERSIONEditField
            app.SOFT_VERSIONEditField = uieditfield(app.ThernalIntegrationPanel, 'text');
            app.SOFT_VERSIONEditField.Position = [171 241 100 22];
            app.SOFT_VERSIONEditField.Value = '7070416';

            % Create DCM_NAMEEditFieldLabel
            app.DCM_NAMEEditFieldLabel = uilabel(app.ThernalIntegrationPanel);
            app.DCM_NAMEEditFieldLabel.HorizontalAlignment = 'right';
            app.DCM_NAMEEditFieldLabel.Position = [82 207 74 22];
            app.DCM_NAMEEditFieldLabel.Text = 'DCM_NAME';

            % Create DCM_NAMEEditField
            app.DCM_NAMEEditField = uieditfield(app.ThernalIntegrationPanel, 'text');
            app.DCM_NAMEEditField.Position = [171 207 257 22];
            app.DCM_NAMEEditField.Value = 'HY11_PCMU_Tm_OTA3_V6060416_All.DCM';

            % Create VER_NAMEEditFieldLabel
            app.VER_NAMEEditFieldLabel = uilabel(app.ThernalIntegrationPanel);
            app.VER_NAMEEditFieldLabel.HorizontalAlignment = 'right';
            app.VER_NAMEEditFieldLabel.Position = [85 174 71 22];
            app.VER_NAMEEditFieldLabel.Text = 'VER_NAME';

            % Create VER_NAMEEditField
            app.VER_NAMEEditField = uieditfield(app.ThernalIntegrationPanel, 'text');
            app.VER_NAMEEditField.Position = [171 174 257 22];

            % Create LogTextArea
            app.LogTextArea = uitextarea(app.UIFigure);
            app.LogTextArea.WordWrap = 'off';
            app.LogTextArea.Position = [3 3 1097 299];
            app.LogTextArea.Value = {'Welcom ! '; 'Welcom ! !'; 'Welcom ! ! !'};

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create DelSelectMenu
            app.DelSelectMenu = uimenu(app.ContextMenu);
            app.DelSelectMenu.MenuSelectedFcn = createCallbackFcn(app, @DelSelectMenuSelected, true);
            app.DelSelectMenu.Text = 'DelSelect';

            % Create DelAllMenu
            app.DelAllMenu = uimenu(app.ContextMenu);
            app.DelAllMenu.MenuSelectedFcn = createCallbackFcn(app, @DelAllMenuSelected, true);
            app.DelAllMenu.Text = 'DelAll';
            
            % Assign app.ContextMenu
            app.CaseTable.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = smart_thermal

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end