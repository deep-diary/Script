classdef smart_thermal < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        HelpMenu                        matlab.ui.container.Menu
        ScriptInstructionMenu           matlab.ui.container.Menu
        PCMUInstructionMenu             matlab.ui.container.Menu
        VCUInstructionMenu              matlab.ui.container.Menu
        AboutMenu                       matlab.ui.container.Menu
        Toolbar                         matlab.ui.container.Toolbar
        OpenTemplate                    matlab.ui.container.toolbar.PushTool
        LogTextArea                     matlab.ui.control.TextArea
        TabGroup                        matlab.ui.container.TabGroup
        HomeTab                         matlab.ui.container.Tab
        Image                           matlab.ui.control.Image
        ChangeLogPanel                  matlab.ui.container.Panel
        VersionTextArea                 matlab.ui.control.TextArea
        VersionTextAreaLabel            matlab.ui.control.Label
        ModelTab                        matlab.ui.container.Tab
        TabGroup2                       matlab.ui.container.TabGroup
        AddTab                          matlab.ui.container.Tab
        TabGroup3                       matlab.ui.container.TabGroup
        DefaultTab                      matlab.ui.container.Tab
        CreateDataStoreButton           matlab.ui.control.Button
        createEnumFromExcelButton       matlab.ui.control.Button
        createModelFromArxmlButton      matlab.ui.control.Button
        CreateSubmodInfoPanel           matlab.ui.container.Panel
        IncludeSubSystemCheckBox        matlab.ui.control.CheckBox
        createSubmodInfoButton          matlab.ui.control.Button
        createSubModPanel               matlab.ui.container.Panel
        ReqPrefixEditField              matlab.ui.control.EditField
        ReqPrefixEditFieldLabel         matlab.ui.control.Label
        FunPrefixEditField              matlab.ui.control.EditField
        FunPrefixEditFieldLabel         matlab.ui.control.Label
        SubModRowsSpinner               matlab.ui.control.Spinner
        SubModRowsSpinnerLabel          matlab.ui.control.Label
        createSubModButton              matlab.ui.control.Button
        createDebugButton               matlab.ui.control.Button
        CreateModTab                    matlab.ui.container.Tab
        GotoHalfLengthSpinner           matlab.ui.control.Spinner
        GotoHalfLengthSpinnerLabel      matlab.ui.control.Label
        createModeButton                matlab.ui.control.Button
        dispNameSwitch                  matlab.ui.control.Switch
        dispNameSwitchLabel             matlab.ui.control.Label
        testValueSwitch                 matlab.ui.control.Switch
        testValueSwitchLabel            matlab.ui.control.Label
        logValueSwitch                  matlab.ui.control.Switch
        logValueSwitchLabel             matlab.ui.control.Label
        resoveValueSwitch               matlab.ui.control.Switch
        resoveValueSwitchLabel          matlab.ui.control.Label
        EnableOutSwitch                 matlab.ui.control.Switch
        EnableOutSwitchLabel            matlab.ui.control.Label
        EnableInSwitch                  matlab.ui.control.Switch
        EnableInSwitchLabel             matlab.ui.control.Label
        InsertBlockDropDown             matlab.ui.control.DropDown
        InsertBlockDropDownLabel        matlab.ui.control.Label
        OutTypeDropDown                 matlab.ui.control.DropDown
        OutTypeDropDownLabel            matlab.ui.control.Label
        InTypeDropDown                  matlab.ui.control.DropDown
        InTypeDropDownLabel             matlab.ui.control.Label
        CreatePortTab                   matlab.ui.container.Tab
        createPortsGotoPanel            matlab.ui.container.Panel
        CreateRelatedCheckBox           matlab.ui.control.CheckBox
        gotoLengthSpinner               matlab.ui.control.Spinner
        gotoLengthSpinnerLabel          matlab.ui.control.Label
        createPortsGotoButton           matlab.ui.control.Button
        ReloadButton                    matlab.ui.control.Button
        EditInTemplateButton            matlab.ui.control.Button
        template                        matlab.ui.control.Table
        createPortsButton               matlab.ui.control.Button
        CreateGotoTab                   matlab.ui.container.Tab
        createPortsGotoUpdateLoopPanel_2  matlab.ui.container.Panel
        ResolveSigCheckBox              matlab.ui.control.CheckBox
        createPortsGotoUpdateLoopButton  matlab.ui.control.Button
        topLevEditField                 matlab.ui.control.EditField
        topLevEditFieldLabel            matlab.ui.control.Label
        createPortsGotoUpdatePanel      matlab.ui.container.Panel
        createPortsGotoUpdateTestValueSwitch  matlab.ui.control.Switch
        testValueSwitch_2Label_2        matlab.ui.control.Label
        createPortsGotoUpdateLogValueSwitch  matlab.ui.control.Switch
        logValueSwitch_2Label_2         matlab.ui.control.Label
        createPortsGotoUpdateResoveValueSwitch  matlab.ui.control.Switch
        resoveValueSwitch_2Label_2      matlab.ui.control.Label
        createPortsGotoUpdateEnableOutCheckBox  matlab.ui.control.CheckBox
        createPortsGotoUpdateEnableInCheckBox  matlab.ui.control.CheckBox
        NameOutModeDropDown             matlab.ui.control.DropDown
        NameOutModeDropDownLabel        matlab.ui.control.Label
        createPortsGotoUpdateButton     matlab.ui.control.Button
        createGotoBasedPortsButton_3    matlab.ui.control.Button
        createGotoUselessButton         matlab.ui.control.Button
        CreateBusTab                    matlab.ui.container.Tab
        createBusFromExcelButton        matlab.ui.control.Button
        CreateBusGotoButton             matlab.ui.control.Button
        CreateBusPortButton             matlab.ui.control.Button
        createSwitchCaseTab             matlab.ui.container.Tab
        createSwitchCaseButton          matlab.ui.control.Button
        RemoveButton                    matlab.ui.control.Button
        ClearAllButton                  matlab.ui.control.Button
        AddButton                       matlab.ui.control.Button
        CaseNameEditField               matlab.ui.control.EditField
        CaseNameEditFieldLabel          matlab.ui.control.Label
        CaseListEditField               matlab.ui.control.EditField
        CaseListEditFieldLabel          matlab.ui.control.Label
        CaseInTextArea                  matlab.ui.control.TextArea
        CaseInTextAreaLabel             matlab.ui.control.Label
        SigNamesTextArea                matlab.ui.control.TextArea
        SigNamesTextAreaLabel           matlab.ui.control.Label
        SwitchCaseTable                 matlab.ui.control.Table
        CreateInterfaceTab              matlab.ui.container.Tab
        creatTmBaseButton               matlab.ui.control.Button
        creatTmOutButton                matlab.ui.control.Button
        creatIFOutButton                matlab.ui.control.Button
        creatIFInButton                 matlab.ui.control.Button
        DeleteTab                       matlab.ui.container.Tab
        delLinesAttrPanel               matlab.ui.container.Panel
        delLinesAttrButton              matlab.ui.control.Button
        AffactAllevCheckBox             matlab.ui.control.CheckBox
        SigAttrDropDown                 matlab.ui.control.DropDown
        SigAttrDropDownLabel            matlab.ui.control.Label
        delUselessPortPanel             matlab.ui.container.Panel
        UselessOutBlockDropDown         matlab.ui.control.DropDown
        UselessOutBlockDropDownLabel    matlab.ui.control.Label
        UselessInBlockDropDown          matlab.ui.control.DropDown
        UselessInBlockDropDownLabel     matlab.ui.control.Label
        delUselessPortButton            matlab.ui.control.Button
        delGcsAllButton                 matlab.ui.control.Button
        ChangeTab                       matlab.ui.container.Tab
        ChangeAttrPanel                 matlab.ui.container.Panel
        changeModPortTypeButton         matlab.ui.control.Button
        changeGotoSizePanel             matlab.ui.container.Panel
        FontSpinner                     matlab.ui.control.Spinner
        FontSpinnerLabel                matlab.ui.control.Label
        changeGotoSizeButton            matlab.ui.control.Button
        changePortBlockPosAllButton     matlab.ui.control.Button
        ChangePortAttrButton            matlab.ui.control.Button
        ChangeGotoAttrButton            matlab.ui.control.Button
        ChangeModelNamePanel            matlab.ui.container.Panel
        UseLastNameCheckBox             matlab.ui.control.CheckBox
        changeModNameButton             matlab.ui.control.Button
        ScopeButtonGroup                matlab.ui.container.ButtonGroup
        bdrootButton                    matlab.ui.control.RadioButton
        gcsButton                       matlab.ui.control.RadioButton
        gcbButton                       matlab.ui.control.RadioButton
        ChangeLinesPortAttrPanel        matlab.ui.container.Panel
        DeleteNameCheckBox              matlab.ui.control.CheckBox
        changeLinesSelectedAttrButton   matlab.ui.control.Button
        EnableOutCheckBox               matlab.ui.control.CheckBox
        EnableInCheckBox                matlab.ui.control.CheckBox
        ChangeLinePortAffactAllevCheckBox  matlab.ui.control.CheckBox
        changeLinesPortAttrButton       matlab.ui.control.Button
        changeLinesPortTestValueSwitch  matlab.ui.control.Switch
        testValueSwitch_2Label          matlab.ui.control.Label
        changeLinesPortLogValueSwitch   matlab.ui.control.Switch
        logValueSwitch_2Label           matlab.ui.control.Label
        changeLinesPortResoveValueSwitch  matlab.ui.control.Switch
        resoveValueSwitch_2Label        matlab.ui.control.Label
        ChangeModSizePanel              matlab.ui.container.Panel
        changeModSizeButton             matlab.ui.control.Button
        ModSizeDropDown                 matlab.ui.control.DropDown
        ModSizeDropDownLabel            matlab.ui.control.Label
        GcsArrangeRowsSpinner           matlab.ui.control.Spinner
        GcsArrangeRowsSpinnerLabel      matlab.ui.control.Label
        changeModSizeGcsButton          matlab.ui.control.Button
        ChangeModPortNamePanel          matlab.ui.container.Panel
        NewNameEditField                matlab.ui.control.EditField
        NewNameEditFieldLabel           matlab.ui.control.Label
        OldNameEditField                matlab.ui.control.EditField
        OldNameEditFieldLabel           matlab.ui.control.Label
        changeModPortNameButton         matlab.ui.control.Button
        FindTab                         matlab.ui.container.Tab
        findEnumTypesButton             matlab.ui.control.Button
        PortTypeDropDown                matlab.ui.control.DropDown
        PortTypeDropDownLabel           matlab.ui.control.Label
        findModPortsButton              matlab.ui.control.Button
        SlddTab                         matlab.ui.container.Tab
        NoteTextArea                    matlab.ui.control.TextArea
        NoteTextAreaLabel               matlab.ui.control.Label
        ConfigPanel                     matlab.ui.container.Panel
        MCUTypeDropDown                 matlab.ui.control.DropDown
        MCUTypeDropDownLabel            matlab.ui.control.Label
        OpenRelatedDCMButton            matlab.ui.control.Button
        DcmFilePath                     matlab.ui.control.EditField
        SetDefaultDcmButton             matlab.ui.control.Button
        SlddDropDown                    matlab.ui.control.DropDown
        SubModDropDown_2Label_3         matlab.ui.control.Label
        FindDcmPanel                    matlab.ui.container.Panel
        findDCMValuesChangesButton      matlab.ui.control.Button
        findDCMNamesChangesButton       matlab.ui.control.Button
        findDCMNamesButton              matlab.ui.control.Button
        ChangeSlddPanel                 matlab.ui.container.Panel
        changeArchSlddButton            matlab.ui.control.Button
        changeSlddInitValueByTableButton  matlab.ui.control.Button
        changeSlddTableByInitValueButton  matlab.ui.control.Button
        LoadSlddPanel                   matlab.ui.container.Panel
        findSlddLoadButton              matlab.ui.control.Button
        OpenFileToLoadButton            matlab.ui.control.Button
        LoadAllSlddButton               matlab.ui.control.Button
        CreateExcelSlddPanel            matlab.ui.container.Panel
        createSlddSigGeeButton          matlab.ui.control.Button
        SlddOverwriteCheckBox           matlab.ui.control.CheckBox
        findSlddCombineButton           matlab.ui.control.Button
        changeExportedSlddButton        matlab.ui.control.Button
        openSlddButton                  matlab.ui.control.Button
        findSlddButton                  matlab.ui.control.Button
        findParametersButton            matlab.ui.control.Button
        AreaDropDown                    matlab.ui.control.DropDown
        AreaDropDownLabel               matlab.ui.control.Label
        CreateMatlabSlddPanel           matlab.ui.container.Panel
        createSlddButton                matlab.ui.control.Button
        createSlddDesignDataButton      matlab.ui.control.Button
        CheckTab                        matlab.ui.container.Tab
        findAlgebraicLoopsButton        matlab.ui.control.Button
        delUselessLineButton            matlab.ui.control.Button
        TestTab                         matlab.ui.container.Tab
        CaseListTree                    matlab.ui.container.Tree
        TestHarnessPanel                matlab.ui.container.Panel
        NextStepDropDown                matlab.ui.control.DropDown
        NextStepDropDownLabel           matlab.ui.control.Label
        LastStepDropDown                matlab.ui.control.DropDown
        LastStepDropDownLabel           matlab.ui.control.Label
        TestCaseTextArea                matlab.ui.control.TextArea
        TestCaseTextAreaLabel           matlab.ui.control.Label
        DemoButton                      matlab.ui.control.Button
        createHarnessButton             matlab.ui.control.Button
        GetPortsButton                  matlab.ui.control.Button
        AddCaseButton                   matlab.ui.control.Button
        TestManagerPanel                matlab.ui.container.Panel
        RefreshButton                   matlab.ui.control.Button
        CurrentModelEditField           matlab.ui.control.EditField
        CurrentModelEditFieldLabel      matlab.ui.control.Label
        TestManagerRunButton            matlab.ui.control.Button
        ExportReportCheckBox            matlab.ui.control.CheckBox
        RunAllHarnessCheckBox           matlab.ui.control.CheckBox
        ClearResultCheckBox             matlab.ui.control.CheckBox
        HarnessHistoryParamsPanel       matlab.ui.container.Panel
        HarnessParamsListBox            matlab.ui.control.ListBox
        CaseTreePanel                   matlab.ui.container.Panel
        CaseTable                       matlab.ui.control.Table
        IntegrationTab                  matlab.ui.container.Tab
        PCMUIntegrationPanel            matlab.ui.container.Panel
        VER_NAMEEditField               matlab.ui.control.EditField
        VER_NAMEEditFieldLabel          matlab.ui.control.Label
        DCM_NAMEEditField               matlab.ui.control.EditField
        DCM_NAMEEditFieldLabel          matlab.ui.control.Label
        SOFT_VERSIONEditField           matlab.ui.control.EditField
        SOFT_VERSIONEditFieldLabel      matlab.ui.control.Label
        INTERFACE_VERISONEditField      matlab.ui.control.EditField
        INTERFACE_VERISONEditFieldLabel  matlab.ui.control.Label
        STAGEEditField                  matlab.ui.control.EditField
        STAGEEditFieldLabel             matlab.ui.control.Label
        ArxmlToModelButton              matlab.ui.control.Button
        createIntegrationButton         matlab.ui.control.Button
        createCodePkgButton             matlab.ui.control.Button
        SingleModelProcessPanel         matlab.ui.container.Panel
        OpenModelButton                 matlab.ui.control.Button
        ActiveECUEditField              matlab.ui.control.EditField
        ActiveECUEditFieldLabel         matlab.ui.control.Label
        RefConfigEditField              matlab.ui.control.EditField
        RefConfigEditFieldLabel         matlab.ui.control.Label
        changeCfgRefButton              matlab.ui.control.Button
        changeCfgErtButton              matlab.ui.control.Button
        changeCfgAutosarButton          matlab.ui.control.Button
        createCodeRefModButton          matlab.ui.control.Button
        CreateRefModelButton            matlab.ui.control.Button
        SubModDropDown                  matlab.ui.control.DropDown
        SubModDropDownLabel             matlab.ui.control.Label
        ConfigTab                       matlab.ui.container.Tab
        PreferencesPanel                matlab.ui.container.Panel
        TemplateFilePath                matlab.ui.control.EditField
        SetDefaultTemplateButton        matlab.ui.control.Button
        CommonUsedContorlersTextArea    matlab.ui.control.TextArea
        CommonUsedContorlersTextAreaLabel  matlab.ui.control.Label
        CommonUsedModelsTextArea        matlab.ui.control.TextArea
        CommonUsedModelsTextAreaLabel   matlab.ui.control.Label
        SaveButton                      matlab.ui.control.Button
        OutportColorEditField           matlab.ui.control.EditField
        OutportColorEditFieldLabel      matlab.ui.control.Label
        InportColorEditField            matlab.ui.control.EditField
        InportColorEditFieldLabel       matlab.ui.control.Label
        PortHeightEditField             matlab.ui.control.EditField
        PortHeightEditFieldLabel        matlab.ui.control.Label
        PortWidEditField                matlab.ui.control.EditField
        PortWidEditFieldLabel           matlab.ui.control.Label
        FromColorEditField              matlab.ui.control.EditField
        FromColorEditFieldLabel         matlab.ui.control.Label
        GotoColorEditField              matlab.ui.control.EditField
        GotoColorEditFieldLabel         matlab.ui.control.Label
        GotoHeightEditField             matlab.ui.control.EditField
        GotoHeightEditFieldLabel        matlab.ui.control.Label
        GotoWidEditField                matlab.ui.control.EditField
        GotoWidEditFieldLabel           matlab.ui.control.Label
        ContextMenuCaseTab              matlab.ui.container.ContextMenu
        DelSelectMenu                   matlab.ui.container.Menu
        DelAllMenu                      matlab.ui.container.Menu
        ContextMenuHarnessParams        matlab.ui.container.ContextMenu
        DelParamMenu                    matlab.ui.container.Menu
        ContextMenuCaseTree             matlab.ui.container.ContextMenu
        DelCaseMenu                     matlab.ui.container.Menu
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            
            % 加载默认配置文件
            config = configGet();
            % 将app.DcmFilePath 的文本内容，设置成dcm_file
            app.DcmFilePath.Value = config.dcm_file;
            app.STAGEEditField.Value = config.stage;
            app.INTERFACE_VERISONEditField.Value = config.interface_version;
            app.SOFT_VERSIONEditField.Value = config.soft_version;
            app.VER_NAMEEditField.Value = config.vername;
            app.SlddDropDown.Items = config.com_used_model;
            app.SubModDropDown.Items = config.com_used_model;
            app.MCUTypeDropDown.Items = config.com_used_controllers;
            app.MCUTypeDropDown.Value = config.active_controller;


            app.GotoWidEditField.Value = config.GotoWid;
            app.GotoHeightEditField.Value = config.GotoHeight;
            app.GotoColorEditField.Value = config.GotoColor;
            app.FromColorEditField.Value = config.FromColor;
            
            app.PortWidEditField.Value = config.PortWid;
            app.PortHeightEditField.Value = config.PortHeight;
            app.InportColorEditField.Value = config.InportColor;
            app.OutportColorEditField.Value = config.OutportColor;

            app.CommonUsedModelsTextArea.Value = config.com_used_model;
            app.CommonUsedContorlersTextArea.Value = config.com_used_controllers;



            

        end

        % Button pushed function: SetDefaultDcmButton
        function SetDefaultDcmButtonPushed(app, event)
            % select file through gui
            dcm_file = uigetfile('*.dcm', 'Select DICOM File');
            if isequal(dcm_file, 0)
                % User cancelled the dialog box.
                return;
            end
            % 将app.DcmFilePath 的文本内容，设置成dcm_file
            app.DcmFilePath.Value = dcm_file;

            configSet('dcm_file',dcm_file);
        end

        % Button pushed function: createSubmodInfoButton
        function createSubmodInfoButtonPushed(app, event)
            dcm_file = app.DcmFilePath.Value;
            if app.IncludeSubSystemCheckBox.Value
                SearchDepth = 'all';
            else
                SearchDepth = 1;
            end
%             SearchDepth = 'all';
%             ,'SearchDepth', SearchDepth)
            [portsInNames, portsOutNames, calibParams, infoText] = createSubmodInfo('DCMfileName',dcm_file,'SearchDepth', SearchDepth);
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

        end

        % Button pushed function: createIntegrationButton
        function createIntegrationButtonPushed(app, event)
            % 加载现有配置
            existing_config = load('config.mat');

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
            existing_config.interface_version = INTERFACE_VERISON;
            % 保存更新后的配置
            save('config.mat', '-struct', 'existing_config');

            createIntegration(SOFT_VERSION, 'STAGE',STAGE, 'INTERFACE_VERISON',INTERFACE_VERISON , 'DCM_NAME',DCM_NAME)
        end

        % Button down function: IntegrationTab
        function IntegrationTabButtonDown(app, event)
            app.LogTextArea.Value = '';
            existing_config = configGet();
            app.ActiveECUEditField.Value = existing_config.active_controller;
            com_used_model = existing_config.com_used_model;
            app.SubModDropDown.Items = com_used_model;

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

        % Callback function
        function ControlChooseButtonGroupSelectionChanged(app, event)
            selectedButton = app.ControlChooseButtonGroup.SelectedObject;
            disp(selectedButton)
        end

        % Callback function
        function findSlddLoadPCMUButtonPushed(app, event)
            submod = app.SlddDropDown.Value;
            if(strcmp(submod,'bdroot'))
                submod = bdroot;
            end
            control_type = 'PCMU';
            findSlddLoad(submod,'mode',control_type)
%             findSlddLoad('TmSwArch','mode',control_type)
        end

        % Button pushed function: CreateRefModelButton
        function CreateRefModelButtonPushed(app, event)
            submod = app.SubModDropDown.Value;
            if strcmp(submod,'bdroot')
                submod = feval(submod);
            end
            control_type = app.ActiveECUEditField.Value;
            if strcmp(control_type,'PCMU')
                creatRefPCMU(submod)
            elseif strcmp(control_type,'VCU')
                creatRefVCU(submod)
            elseif strcmp(control_type,'XCU')
                creatRefXCU(submod)
            else
            end

        end

        % Callback function
        function LoadSlddAllButtonPushed(app, event)
            findSlddLoad('PCMU_SLDD_All.xlsx')
        end

        % Button pushed function: createCodeRefModButton
        function createCodeRefModButtonPushed(app, event)
            submod = app.SubModDropDown.Value;
            if strcmp(submod,'bdroot')
                submod = feval(submod);
            end
            
            control_type = app.ActiveECUEditField.Value;
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
                '[1 21]','SM1SM21';
                '[2 22]','SM2SM22';
                '[3 23]','SM3SM23';
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
            inType = app.InTypeDropDown.Value;
            outType = app.OutTypeDropDown.Value;
            add = app.InsertBlockDropDown.Value;

            isEnableIn = strcmp(app.EnableInSwitch.Value,'On');
            isEnableOut = strcmp(app.EnableOutSwitch.Value,'On');
            resoveValue = strcmp(app.resoveValueSwitch.Value,'On');
            logValue = strcmp(app.logValueSwitch.Value,'On');
            testValue = strcmp(app.testValueSwitch.Value,'On');
            dispName = strcmp(app.dispNameSwitch.Value,'On');

            bkHalfLength = app.GotoHalfLengthSpinner.Value;

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
            template_file = configGet('template_file');
            [inCnt, outCnt, inCntDel, outCntDel] = createPorts(template_file, gcs);
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
            template_file = configGet('template_file');
            createRelated = app.CreateRelatedCheckBox.Value;
            gotoLength = app.gotoLengthSpinner.Value;
            [numInputPorts, numOutputPorts] = createPortsGoto( ...
                'fromTemplate', true, ...
                'template', template_file, ...
                'createRelated', createRelated, ...
                'gotoLength', gotoLength);
            % 初始化logstr为空字符串
            logstr = sprintf('执行成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建输入端口: %d\n', logstr, numInputPorts);
            logstr = sprintf('%s  创建输出端口: %d\n', logstr, numOutputPorts); 

            app.LogTextArea.Value = logstr;
        end

        % Button down function: CreatePortTab
        function CreatePortTabButtonDown(app, event)
            template_file = configGet('template_file');
            temp=readtable(template_file,'sheet','Signals');
            app.template.Data = temp(:,2:4);
%             
        end

        % Button pushed function: EditInTemplateButton
        function EditInTemplateButtonPushed(app, event)
            template_file = configGet('template_file');
            winopen(template_file);
        end

        % Button pushed function: ReloadButton
        function ReloadButtonPushed(app, event)
            template_file = configGet('template_file');
            temp=readtable(template_file,'sheet','Signals');
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
            nameOutMod = app.NameOutModeDropDown.Value;

            resoveValue = app.createPortsGotoUpdateResoveValueSwitch.Value;
            logValue = app.createPortsGotoUpdateLogValueSwitch.Value;
            testValue = app.createPortsGotoUpdateTestValueSwitch.Value;

            enableIn = app.createPortsGotoUpdateEnableInCheckBox.Value;
            enableOut = app.createPortsGotoUpdateEnableOutCheckBox.Value;

            resoveValue = strcmp(resoveValue,'On');
            logValue = strcmp(logValue,'On');
            testValue = strcmp(testValue,'On');

            [inList, outList] = createPortsGotoUpdate( ...
                'mode', nameOutMod, ...
                "resoveValue",resoveValue, ...
                "logValue",logValue, ...
                "testValue",testValue, ...
                "enableIn",enableIn, ...
                "enableOut",enableOut ...
                );

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
            FunPrefix = app.FunPrefixEditField.Value;
            ReqPrefix = app.ReqPrefixEditField.Value;
            template_file = configGet('template_file');

            modNums = createSubMod('template' ,template_file,'rows', rows, 'FunPrefix',FunPrefix, 'ReqPrefix',ReqPrefix);

            % 初始化logstr为空字符串
            logstr = '';

            % 添加结果摘要
            logstr = sprintf('%s创建完成: %d 个子模型\n', ...
            logstr,modNums);
            
            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: creatIFInButton
        function creatIFInButtonPushed(app, event)

            templateF = configGet('template_file');
            numCreated = creatIFIn('template', templateF);
            % 初始化logstr为空字符串
            logstr = sprintf('执行接口输入模块成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建输入端口: %d\n', logstr, numCreated);

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: creatIFOutButton
        function creatIFOutButtonPushed(app, event)

            templateF = configGet('template_file');
            numCreated = creatIFOut('template', templateF);
            % 初始化logstr为空字符串
            logstr = sprintf('执行接口输出模块成功:\n');

            % 添加结果摘要
            logstr = sprintf('%s  创建输出端口: %d\n', logstr, numCreated);

            app.LogTextArea.Value = logstr;
        end

        % Button pushed function: creatTmOutButton
        function creatTmOutButtonPushed(app, event)

            templateF = configGet('template_file');
            numCreated = creatTmOut('template', templateF);
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
            wid = app.ModSizeDropDown.Value;
            changeModSize(gcb,'wid',str2double(wid))
        end

        % Button pushed function: changeModSizeGcsButton
        function changeModSizeGcsButtonPushed(app, event)
            rows = app.GcsArrangeRowsSpinner.Value
            changeModSizeGcs('rows', rows)
        end

        % Callback function
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
            [PathAll, ParamAll] = findParameters(path);
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
            overWrite = app.SlddOverwriteCheckBox.Value;
            project = app.MCUTypeDropDown.Value;
            [fSlddList, DataList] = findSldd(path,'overWrite',overWrite,'projectList', {project});
            logstr = sprintf('The exported sldd are as follows:\n');
            logstr = sprintf('%s the % sldd path is: %s\n', logstr, project,fSlddList{1});
            app.LogTextArea.Value = logstr;          
            rstPath.PCMU = fSlddList;
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
            % 加载默认配置文件
            template_file = configGet('template_file');
            if isempty(template_file)
                return
            end
            winopen(template_file);
        end

        % Button pushed function: ArxmlToModelButton
        function ArxmlToModelButtonPushed(app, event)
            Arxmlstart2mdl
        end

        % Callback function
        function HomeTabSizeChanged(app, event)
            position = app.HomeTab.Position;
            
        end

        % Menu selected function: ScriptInstructionMenu
        function ScriptInstructionMenuSelected(app, event)

            % 加载默认配置文件
            template_file = configGet('template_file');
            if isempty(template_file)
                return
            end
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

        % Callback function
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
            app.CaseTable.Data = cell(1, numel(Head));  % 创建 1 行 5 列的空 cell 数组
            cols= length(Head);


            % 获取树形结构中的所有节点
            rootNode = app.CaseListTree.Children;
            row = 1;
            
            % 遍历第一层节点
            for i = 1:length(rootNode)
                lev1Node = rootNode(i);
%                 % 填充第一层节点数据
                app.CaseTable.Data{row,1} = lev1Node.Text;
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

        % Callback function
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
            logstr = sprintf('%s5. 确保模型无代数环\n', logstr);

            app.LogTextArea.Value = logstr;
        end

        % Callback function
        function findSlddLoadVCUButtonPushed(app, event)
            submod = app.SlddDropDown.Value;
            control_type = 'VCU';
            findSlddLoad(submod,'mode',control_type)
            findSlddLoad('TmSwArch','mode',control_type)
        end

        % Button down function: SlddTab
        function SlddTabButtonDown(app, event)
            com_used_model = configGet().com_used_model;
            app.SlddDropDown.Items = com_used_model;
            app.LogTextArea.Value = '';
        end

        % Button pushed function: openSlddButton
        function openSlddButtonPushed(app, event)

            slddType = app.MCUTypeDropDown.Value;
            overwrite = app.SlddOverwriteCheckBox.Value;

%             rstPath = app.findSlddButton.UserData;
%             if isempty(rstPath)
%                 return
%             end
%             if strcmp(slddType, 'PCMU')
%                 slddName = rstPath.PCMU;
%             else
%                 slddName = rstPath.VCU;
%             end

            if overwrite
                slddName = [bdroot '_DD_' slddType '.xlsx'];
            else
                slddName = [bdroot '_DD_' slddType '_EXPORT.xlsx'];
            end
%           
            logStr = sprintf('can not find the file: %s ', slddName);
            if ~exist(slddName,'file')
                app.LogTextArea.Value = logStr;
                return
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

        % Callback function
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
            [name, path] = uigetfile('*.dcm', 'Select old DCM File');
            dcm_file_old = fullfile(path,name);
            if isequal(dcm_file_old, 0)
                % User cancelled the dialog box.
                return;
            end
            [name, path] = uigetfile('*.dcm', 'Select new DCM File');
            dcm_file_new = fullfile(path,name);
            if isequal(dcm_file_new, 0)
                % User cancelled the dialog box.
                return;
            end

            changes = findDCMValuesChanges(dcm_file_old, dcm_file_new);


            %% 显示比较结果
            % 参数类型名称映射
            typeNames = {'常量', '轴定义', '值块', '一维表', '二维表'};
            logstr = sprintf('    %s    \n和\n    %s    \n的参数差异如下：\n\n', dcm_file_old,dcm_file_new);
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

        % Button pushed function: OpenRelatedDCMButton
        function OpenRelatedDCMButtonPushed(app, event)
            dcm_file = app.DcmFilePath.Value;
            winopen(dcm_file)
        end

        % Menu selected function: DelParamMenu
        function DelParamMenuSelected(app, event)
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

        % Menu selected function: DelCaseMenu
        function DelCaseMenuSelected(app, event)
            SelectedNode = app.CaseListTree.SelectedNodes;
            delete(SelectedNode)
        end

        % Button pushed function: TestManagerRunButton
        function TestManagerRunButtonPushed(app, event)
            modelName = app.CurrentModelEditField.Value;
            clear = app.ClearResultCheckBox.Value;
            run = app.RunAllHarnessCheckBox.Value;
            report = app.ExportReportCheckBox.Value;
            createTestManage(modelName, 'clear', clear, 'run', run, 'export', report)
        end

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
            app.CurrentModelEditField.Value = bdroot;
        end

        % Button pushed function: findAlgebraicLoopsButton
        function findAlgebraicLoopsButtonPushed(app, event)
            result = findAlgebraicLoops(bdroot);
            if isempty(result)
                logStr = sprintf('No algebraic loops found in %s\n', bdroot);
            else
                logStr = sprintf('Algebraic loops found in %s\n', bdroot);
            end
            app.LogTextArea.Value = logStr;
        end

        % Button pushed function: findSlddCombineButton
        function findSlddCombineButtonPushed(app, event)

            subPath = uigetdir('子模型存放目录', '子模型存放目录');
            SLDD_NAME = 'PCMU_SLDD_All.xlsx';

            outPath = findSlddCombine(subPath, SLDD_NAME);

            logStr = sprintf("合并sldd 成功，其输出路径是%s\n",outPath);
            app.LogTextArea.Value = logStr;
        end

        % Button pushed function: delLinesAttrButton
        function delLinesAttrButtonPushed(app, event)
            attr = app.SigAttrDropDown.Value;
            FindAll = app.AffactAllevCheckBox.Value; 
            delLinesAttr(gcs,'attr', attr, 'FindAll',FindAll)
        end

        % Button pushed function: changeLinesPortAttrButton
        function changeLinesPortAttrButtonPushed(app, event)
            scope = app.ScopeButtonGroup.SelectedObject.Text;
            if strcmp(scope,'gcb')
                scope = 'gcs';
            end
            valid_scopes = {'gcb', 'gcs', 'bdroot'};
            if ismember(scope, valid_scopes)
                path = feval(scope);  % 或者使用 path = eval(scope);
            else
                return
            end

            resoveValue = app.changeLinesPortResoveValueSwitch.Value;
            logValue = app.changeLinesPortLogValueSwitch.Value;
            testValue = app.changeLinesPortTestValueSwitch.Value;
            FindAll = app.ChangeLinePortAffactAllevCheckBox.Value;
            enableIn = app.EnableInCheckBox.Value;
            enableOut = app.EnableOutCheckBox.Value;

            resoveValue = strcmp(resoveValue,'On');
            logValue = strcmp(logValue,'On');
            testValue = strcmp(testValue,'On');

            changeLinesPortAttr(path, ...
                "resoveValue",resoveValue, ...
                "logValue",logValue, ...
                "testValue",testValue, ...
                "enableIn",enableIn, ...
                "enableOut",enableOut, ...
                "FindAll",FindAll)
        end

        % Value changed function: CommonUsedModelsTextArea
        function CommonUsedModelsTextAreaValueChanged(app, event)
            value = app.CommonUsedModelsTextArea.Value;
            configSet('com_used_model',value);
        end

        % Button pushed function: SetDefaultTemplateButton
        function SetDefaultTemplateButtonPushed(app, event)
            % select file through gui
            template_file = uigetfile('*.xlsx', 'Select Template File');
            if isequal(template_file, 0)
                % User cancelled the dialog box.
                return;
            end
            % 将app.DcmFilePath 的文本内容，设置成dcm_file
            app.TemplateFilePath.Value = template_file;

            configSet('template_file',template_file);
        end

        % Callback function
        function ConfigTabSizeChanged(app, event)
            position = app.ConfigTab.Position;
            
        end

        % Button down function: ConfigTab
        function ConfigTabButtonDown(app, event)

            app.LogTextArea.Value = '';

            config = configGet();

            com_used_model = config.com_used_model;
            template_file = config.template_file;

            app.CommonUsedModelsTextArea.Value = com_used_model;
            app.TemplateFilePath.Value = template_file;
        end

        % Button pushed function: changeGotoSizeButton
        function changeGotoSizeButtonPushed(app, event)
            font = app.FontSpinner.Value;
            scope = app.ScopeButtonGroup.SelectedObject.Text;

            valid_scopes = {'gcb', 'gcs', 'bdroot'};
            if ismember(scope, valid_scopes)
                path = feval(scope);  % 或者使用 path = eval(scope);
            else
                return
            end
            changeGotoSize(path,'font', font)

        end

        % Button pushed function: OpenFileToLoadButton
        function OpenFileToLoadButtonPushed(app, event)
            % select file through gui
            % 打印日志初始化
            logStr = '';
            app.LogTextArea.Value = logStr;

            % 通过GUI选择文件
            [sldd_file, sldd_path] = uigetfile({'*.xlsx;*.xlsm', 'Excel Files (*.xlsx, *.xlsm)'}, 'Select Sldd File');
            if isequal(sldd_file, 0)
                % 用户取消了对话框
                logStr = sprintf("%s用户取消了文件选择。\n", logStr);
                app.LogTextArea.Value = logStr;
                return;
            end
            sldd_file = fullfile(sldd_path, sldd_file);

            logStr = sprintf("%s已选择文件: %s\n", logStr, sldd_file);
            app.LogTextArea.Value = logStr;

            % 检查文件名是否包含Element_Management
            if contains(sldd_file, 'Element_Management')
                logStr = sprintf("%s检测到Element_Management模板，调用findSlddLoadGee处理...\n", logStr);
                app.LogTextArea.Value = logStr;
                % 调用gee模板
                [sigTable, paraTable, ~] = findSlddLoadGee(sldd_file);
                logStr = sprintf("%sfindSlddLoadGee处理完成，信号表%d条，参数表%d条。\n", logStr, height(sigTable), height(paraTable));
                app.LogTextArea.Value = logStr;
            else
                logStr = sprintf("%s调用findSlddLoad处理...\n", logStr);
                app.LogTextArea.Value = logStr;
                findSlddLoad(sldd_file)
                logStr = sprintf("%sfindSlddLoad处理完成。\n", logStr);
                app.LogTextArea.Value = logStr;
            end
        end

        % Value changing function: CommonUsedModelsTextArea
        function CommonUsedModelsTextAreaValueChanging(app, event)
            changingValue = event.Value;
            
        end

        % Value changed function: CommonUsedContorlersTextArea
        function CommonUsedContorlersTextAreaValueChanged(app, event)
            value = app.CommonUsedContorlersTextArea.Value;
            configSet('com_used_controllers',value);
        end

        % Value changed function: MCUTypeDropDown
        function MCUTypeDropDownValueChanged(app, event)
            value = app.MCUTypeDropDown.Value;
            configSet('active_controller',value);
        end

        % Button pushed function: findSlddLoadButton
        function findSlddLoadButtonPushed(app, event)
            submod = app.SlddDropDown.Value;
            active_controller = configGet('active_controller');
            findSlddLoad(submod,'mode',active_controller)
            findSlddLoad('TmSwArch','mode',active_controller)
        end

        % Button pushed function: changeModNameButton
        function changeModNameButtonPushed(app, event)
            scope = app.ScopeButtonGroup.SelectedObject.Text;
            if strcmp(scope,'gcb')
                scope = 'bdroot';
            end
            valid_scopes = {'gcb', 'gcs', 'bdroot'};
            if ismember(scope, valid_scopes)
                path = feval(scope);  % 或者使用 path = eval(scope);
            else
                return
            end

            UseLastName = app.UseLastNameCheckBox.Value;
            changeModName(path,'UseLastName',UseLastName)
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)

            configSet('GotoWid', app.GotoWidEditField.Value)
            configSet('GotoHeight', app.GotoHeightEditField.Value)
            configSet('GotoColor', app.GotoColorEditField.Value)
            configSet('FromColor', app.FromColorEditField.Value)
            
            configSet('PortWid', app.PortWidEditField.Value)
            configSet('PortHeight', app.PortHeightEditField.Value)
            configSet('InportColor', app.InportColorEditField.Value)
            configSet('OutportColor', app.OutportColorEditField.Value)

            configSet('com_used_model',app.CommonUsedModelsTextArea.Value);
            configSet('com_used_controllers',app.CommonUsedContorlersTextArea.Value);


        end

        % Button pushed function: ChangeGotoAttrButton
        function ChangeGotoAttrButtonPushed(app, event)
            scope = app.ScopeButtonGroup.SelectedObject.Text;
            valid_scopes = {'gcb', 'gcs', 'bdroot'};
            if ismember(scope, valid_scopes)
                path = feval(scope);  % 或者使用 path = eval(scope);
            else
                return
            end
            config = configGet();
            GotoWid = config.GotoWid;
            GotoHeight = config.GotoHeight;
            GotoColor = config.GotoColor;
            FromColor = config.FromColor;

            changeGotoAttr(path, 'Type', 'goto', ...
                'wid', str2double(GotoWid), ...
                'height', str2double(GotoHeight), ...
                'BackgroundColor', GotoColor...
                )

            changeGotoAttr(path, 'Type', 'from', ...
                'wid', str2double(GotoWid), ...
                'height', str2double(GotoHeight), ...
                'BackgroundColor', FromColor...
                )
        end

        % Button pushed function: ChangePortAttrButton
        function ChangePortAttrButtonPushed(app, event)
            scope = app.ScopeButtonGroup.SelectedObject.Text;
            valid_scopes = {'gcb', 'gcs', 'bdroot'};
            if ismember(scope, valid_scopes)
                path = feval(scope);  % 或者使用 path = eval(scope);
            else
                return
            end
            config = configGet();
            PortWid = config.PortWid;
            PortHeight = config.PortHeight;
            InportColor = config.InportColor;
            OutportColor = config.OutportColor;

            changePortAttr(path, 'Type', 'in', ...
                'wid', str2double(PortWid), ...
                'height', str2double(PortHeight), ...
                'BackgroundColor', InportColor...
                )

            changePortAttr(path, 'Type', 'out', ...
                'wid', str2double(PortWid), ...
                'height', str2double(PortHeight), ...
                'BackgroundColor', OutportColor...
                )
        end

        % Button pushed function: OpenModelButton
        function OpenModelButtonPushed(app, event)
            submod = app.SubModDropDown.Value;
            if strcmp(submod,'bdroot')
                warning('bdroot is not aviliable, you should assign a model name')
            end
            open_system(submod)
        end

        % Button pushed function: createModelFromArxmlButton
        function createModelFromArxmlButtonPushed(app, event)
            Arxmlstart2mdl
        end

        % Button pushed function: createBusFromExcelButton
        function createBusFromExcelButtonPushed(app, event)
            % 打印日志初始化
            logStr = '';
            app.LogTextArea.Value = logStr;
            
            templateF = configGet('template_file');
            createdBuses = createBusFromExcel('template', templateF);

            logStr = sprintf("%s已经创建的bus 信号如下：\n",logStr);
            for i=1:length(createdBuses)
                logStr = sprintf("%s%s\n",logStr,createdBuses{i});
            end
            app.LogTextArea.Value = logStr;
        end

        % Button pushed function: createEnumFromExcelButton
        function createEnumFromExcelButtonPushed(app, event)
            logStr = '';
            app.LogTextArea.Value = logStr;
            
            templateF = configGet('template_file');
            createdEnums = createEnumFromExcel('template',templateF);

            logStr = sprintf("%s已经创建的枚举信号如下：\n",logStr);
            for i=1:length(createdEnums)
                logStr = sprintf("%s%s\n",logStr,createdEnums{i});
            end
            app.LogTextArea.Value = logStr;
        end

        % Button pushed function: changeLinesSelectedAttrButton
        function changeLinesSelectedAttrButtonPushed(app, event)
            scope = app.ScopeButtonGroup.SelectedObject.Text;
            if strcmp(scope,'gcb')
                scope = 'gcs';
            end
            valid_scopes = {'gcb', 'gcs', 'bdroot'};
            if ismember(scope, valid_scopes)
                path = feval(scope);  % 或者使用 path = eval(scope);
            else
                return
            end

            resoveValue = app.changeLinesPortResoveValueSwitch.Value;
            logValue = app.changeLinesPortLogValueSwitch.Value;
            testValue = app.changeLinesPortTestValueSwitch.Value;
            FindAll = app.ChangeLinePortAffactAllevCheckBox.Value;
            deleteName = app.DeleteNameCheckBox.Value;

            resoveValue = strcmp(resoveValue,'On');
            logValue = strcmp(logValue,'On');
            testValue = strcmp(testValue,'On');

            changeLinesSelectedAttr(gcs, ...
                'logValue', logValue, ...
                'resoveValue', resoveValue, ...
                'testValue', testValue, ...
                'FindAll', FindAll,...
                'deleteName',deleteName)
        end

        % Button pushed function: findEnumTypesButton
        function findEnumTypesButtonPushed(app, event)
            findEnumTypes()
        end

        % Button pushed function: CreateDataStoreButton
        function CreateDataStoreButtonPushed(app, event)
            templateF = configGet('template_file');
            cnt = createDataStore('template', templateF,'createType', {'Memory', 'Write', 'Read'})
        end

        % Button pushed function: createSlddSigGeeButton
        function createSlddSigGeeButtonPushed(app, event)
            logStr = '';
            app.LogTextArea.Value = logStr;

            [sigTable, outputFile] = createSlddSigGee(bdroot);
            
            logStr = sprintf("%s已创建信号表%d条，输出文件%s。\n", logStr, height(sigTable), outputFile);
            app.LogTextArea.Value = logStr;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

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
            app.OpenTemplate.Icon = fullfile(pathToMLAPP, 'icon', 'file-open.png');

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.ButtonDownFcn = createCallbackFcn(app, @TabGroupButtonDown, true);
            app.TabGroup.Position = [1 301 1101 398];

            % Create HomeTab
            app.HomeTab = uitab(app.TabGroup);
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
            app.VersionTextArea.Value = {'Version: V0.1.10'; 'Release Date: 20250805'; '1. updated findSlddCombineButtonPushed, change the fix fold parameter to opened fold'; ''; ''; 'Version: V0.1.9'; 'Release Date: 20250805'; '1. updated the latest cfgAutosar42'; ''; 'Version: V0.1.8'; 'Release Date: 20250805'; '1. add createSigOut'; '2. Fixed Some Bugs'; ''; 'Version: V0.1.7 '; 'Release Date: 20250704'; '1. add createDataStore'; ''; 'Version: V0.1.6'; 'Release Date: 20250703'; '1. add changeLinesSelectAttr and findLineName'; '2. add findEnumTypes'; ''; 'Version: V0.1.5'; 'Release Date: 20250702'; 'Version:V0.1.5: add the function of createModSlddFromArxml'; ''; 'Version: V0.1.4'; 'Release Date: 20250630'; '1. add: create bus and enum from template'; '2. find enum'; '3. add change arxml to model'; ''; 'Version: V0.1.3 '; 'Release Date: 20250618'; '1. add choose of createsubmodel, add the function of including the submodel parameters'; '2. if the param not included in the DCM file, then using the original value defined in the sldd excel file, add the function of findSlddExcelValueByName'; '3. add the subsytem signals, and seperate the local signals and parameters'; '4. add a button to open the model'; '5. fix the harness database config. change the filename to which(filename), previous bug: harness.mat always store in the current fold instead of config fold'; ''; 'Version: V0.1.2'; 'Release Date: 20250613'; '1. fix the integration base on the active ECU'; '2. fix find DcmValueChange function: if the DCM not lcated in the malab path, it will be an error'; ''; 'Version: V0.1.0 alpha'; 'Release Date: 20250609'; 'Description:  '; '1. Add XCU relative working folw, including find the XCU stroage class based on the name, export and import the XCU sldd '; '2. add the function of block attr change, which include goto from and ports, all the attr have been saved to the config file'; '3. add the funtion of change model name'; ''; 'Version: V0.0.7'; 'Release Date: 20250604'; 'Description:  '; '1. add function of createPortsBySheet ， so it wil be much easier to create ports by calling this function'; '2. upgrade createPortsGotoUpdate, which could resolve the output signal'; '3. fix the bug: createPortsGotoUpdate, new created port position error'; ''; ''; 'Version: V0.0.6'; 'Release Date: 20250603'; 'Description:  '; '1. add defalt template config,'; '2. add config init, change setConfig and getConfig TO configSet & configGet'; '3. add function of changeGotoSize '; ''; ''; 'Version: V0.0.5'; 'Release Date: 20250523'; 'Description:  '; '1. add control params of createPortsGotoUpdate'; '2. add config sheet'; '3. add overwrite param of findSldd'; '4. findSldd not incude Bias block'; '5. update createPortsGoto with related goto and from'; ''; 'Version: V0.0.4'; 'Release Date: 20250522'; 'Description:'; '1. fixed some bug'; '2. add functions: indLinesPorts,findLines, changeLinesPortAttr, delLinesPortAttr'; '3. add wid param of changeModSize func'; ''; 'Version: V0.0.3'; 'Release Date: 20250514'; 'Description:'; '1. Add the Sldd and Check page'; '2. Add simple Desc. about each Tab'; '3. Add PCUM and VUM integration instruction'; ''; 'Version: V0.0.2'; 'Release Date: 20250512'; 'Description:'; '1. add the test function'; ''; 'Version: V0.0.1'; 'Release Date: 20250508'; 'Description:'; '1. add the most used funcions to apps'; ''};

            % Create Image
            app.Image = uiimage(app.HomeTab);
            app.Image.Position = [3 208 1095 165];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'smart_thermal_resources', 'smart_Logo_horizontal_regular_P_rgb.png');

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

            % Create createDebugButton
            app.createDebugButton = uibutton(app.DefaultTab, 'push');
            app.createDebugButton.ButtonPushedFcn = createCallbackFcn(app, @createDebugButtonPushed, true);
            app.createDebugButton.Tooltip = {'创建输出debug 模块'};
            app.createDebugButton.Position = [167 128 113 23];
            app.createDebugButton.Text = 'createDebug';

            % Create createSubModPanel
            app.createSubModPanel = uipanel(app.DefaultTab);
            app.createSubModPanel.Title = 'createSubMod';
            app.createSubModPanel.Position = [4 161 274 181];

            % Create createSubModButton
            app.createSubModButton = uibutton(app.createSubModPanel, 'push');
            app.createSubModButton.ButtonPushedFcn = createCallbackFcn(app, @createSubModButtonPushed, true);
            app.createSubModButton.Position = [151 20 113 23];
            app.createSubModButton.Text = 'createSubMod';

            % Create SubModRowsSpinnerLabel
            app.SubModRowsSpinnerLabel = uilabel(app.createSubModPanel);
            app.SubModRowsSpinnerLabel.HorizontalAlignment = 'right';
            app.SubModRowsSpinnerLabel.Position = [16 126 132 22];
            app.SubModRowsSpinnerLabel.Text = 'SubModRows';

            % Create SubModRowsSpinner
            app.SubModRowsSpinner = uispinner(app.createSubModPanel);
            app.SubModRowsSpinner.Limits = [1 5];
            app.SubModRowsSpinner.Position = [158 126 99 22];
            app.SubModRowsSpinner.Value = 2;

            % Create FunPrefixEditFieldLabel
            app.FunPrefixEditFieldLabel = uilabel(app.createSubModPanel);
            app.FunPrefixEditFieldLabel.HorizontalAlignment = 'right';
            app.FunPrefixEditFieldLabel.Tooltip = {'功能ID 前缀'};
            app.FunPrefixEditFieldLabel.Position = [87 94 56 22];
            app.FunPrefixEditFieldLabel.Text = 'FunPrefix';

            % Create FunPrefixEditField
            app.FunPrefixEditField = uieditfield(app.createSubModPanel, 'text');
            app.FunPrefixEditField.Position = [158 94 100 22];

            % Create ReqPrefixEditFieldLabel
            app.ReqPrefixEditFieldLabel = uilabel(app.createSubModPanel);
            app.ReqPrefixEditFieldLabel.HorizontalAlignment = 'right';
            app.ReqPrefixEditFieldLabel.Position = [85 63 58 22];
            app.ReqPrefixEditFieldLabel.Text = 'ReqPrefix';

            % Create ReqPrefixEditField
            app.ReqPrefixEditField = uieditfield(app.createSubModPanel, 'text');
            app.ReqPrefixEditField.Tooltip = {'需求ID 前缀'};
            app.ReqPrefixEditField.Position = [158 63 100 22];

            % Create CreateSubmodInfoPanel
            app.CreateSubmodInfoPanel = uipanel(app.DefaultTab);
            app.CreateSubmodInfoPanel.Title = 'CreateSubmodInfo';
            app.CreateSubmodInfoPanel.Position = [327 238 260 100];

            % Create createSubmodInfoButton
            app.createSubmodInfoButton = uibutton(app.CreateSubmodInfoPanel, 'push');
            app.createSubmodInfoButton.ButtonPushedFcn = createCallbackFcn(app, @createSubmodInfoButtonPushed, true);
            app.createSubmodInfoButton.Tooltip = {'为当前模型创建输入输出接口及标定量'};
            app.createSubmodInfoButton.Position = [10 17 113 23];
            app.createSubmodInfoButton.Text = 'createSubmodInfo';

            % Create IncludeSubSystemCheckBox
            app.IncludeSubSystemCheckBox = uicheckbox(app.CreateSubmodInfoPanel);
            app.IncludeSubSystemCheckBox.Tooltip = {'check means find the all the subsystem parameters'};
            app.IncludeSubSystemCheckBox.Text = 'Include SubSystem';
            app.IncludeSubSystemCheckBox.Position = [10 49 125 22];
            app.IncludeSubSystemCheckBox.Value = true;

            % Create createModelFromArxmlButton
            app.createModelFromArxmlButton = uibutton(app.DefaultTab, 'push');
            app.createModelFromArxmlButton.ButtonPushedFcn = createCallbackFcn(app, @createModelFromArxmlButtonPushed, true);
            app.createModelFromArxmlButton.Tooltip = {'根据arxml 创建模型'};
            app.createModelFromArxmlButton.Position = [9 129 140 23];
            app.createModelFromArxmlButton.Text = 'createModelFromArxml';

            % Create createEnumFromExcelButton
            app.createEnumFromExcelButton = uibutton(app.DefaultTab, 'push');
            app.createEnumFromExcelButton.ButtonPushedFcn = createCallbackFcn(app, @createEnumFromExcelButtonPushed, true);
            app.createEnumFromExcelButton.Position = [14 89 137 23];
            app.createEnumFromExcelButton.Text = 'createEnumFromExcel';

            % Create CreateDataStoreButton
            app.CreateDataStoreButton = uibutton(app.DefaultTab, 'push');
            app.CreateDataStoreButton.ButtonPushedFcn = createCallbackFcn(app, @CreateDataStoreButtonPushed, true);
            app.CreateDataStoreButton.Position = [172 88 105 23];
            app.CreateDataStoreButton.Text = 'CreateDataStore';

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
            app.createModeButton.Icon = 'smart_Logo_P_rgb.png';
            app.createModeButton.Tooltip = {'选中模型后点击此按键执行脚本'};
            app.createModeButton.Position = [413 240 100 23];
            app.createModeButton.Text = 'createMode';

            % Create GotoHalfLengthSpinnerLabel
            app.GotoHalfLengthSpinnerLabel = uilabel(app.CreateModTab);
            app.GotoHalfLengthSpinnerLabel.HorizontalAlignment = 'right';
            app.GotoHalfLengthSpinnerLabel.Position = [29 211 89 22];
            app.GotoHalfLengthSpinnerLabel.Text = 'GotoHalfLength';

            % Create GotoHalfLengthSpinner
            app.GotoHalfLengthSpinner = uispinner(app.CreateModTab);
            app.GotoHalfLengthSpinner.Step = 5;
            app.GotoHalfLengthSpinner.Limits = [15 150];
            app.GotoHalfLengthSpinner.Tooltip = {'Goto 长度参数'};
            app.GotoHalfLengthSpinner.Position = [133 211 100 22];
            app.GotoHalfLengthSpinner.Value = 15;

            % Create CreatePortTab
            app.CreatePortTab = uitab(app.TabGroup3);
            app.CreatePortTab.Title = 'CreatePort';
            app.CreatePortTab.ButtonDownFcn = createCallbackFcn(app, @CreatePortTabButtonDown, true);

            % Create createPortsButton
            app.createPortsButton = uibutton(app.CreatePortTab, 'push');
            app.createPortsButton.ButtonPushedFcn = createCallbackFcn(app, @createPortsButtonPushed, true);
            app.createPortsButton.Position = [25 302 100 23];
            app.createPortsButton.Text = 'createPorts';

            % Create template
            app.template = uitable(app.CreatePortTab);
            app.template.ColumnName = {'PortType'; 'Name'; 'DataType'};
            app.template.RowName = {};
            app.template.Position = [162 5 858 332];

            % Create EditInTemplateButton
            app.EditInTemplateButton = uibutton(app.CreatePortTab, 'push');
            app.EditInTemplateButton.ButtonPushedFcn = createCallbackFcn(app, @EditInTemplateButtonPushed, true);
            app.EditInTemplateButton.Position = [23 71 100 23];
            app.EditInTemplateButton.Text = 'EditInTemplate';

            % Create ReloadButton
            app.ReloadButton = uibutton(app.CreatePortTab, 'push');
            app.ReloadButton.ButtonPushedFcn = createCallbackFcn(app, @ReloadButtonPushed, true);
            app.ReloadButton.Position = [21 35 100 23];
            app.ReloadButton.Text = 'Reload';

            % Create createPortsGotoPanel
            app.createPortsGotoPanel = uipanel(app.CreatePortTab);
            app.createPortsGotoPanel.Title = 'createPortsGoto';
            app.createPortsGotoPanel.Position = [4 114 154 135];

            % Create createPortsGotoButton
            app.createPortsGotoButton = uibutton(app.createPortsGotoPanel, 'push');
            app.createPortsGotoButton.ButtonPushedFcn = createCallbackFcn(app, @createPortsGotoButtonPushed, true);
            app.createPortsGotoButton.Position = [20 14 102 23];
            app.createPortsGotoButton.Text = 'createPortsGoto';

            % Create gotoLengthSpinnerLabel
            app.gotoLengthSpinnerLabel = uilabel(app.createPortsGotoPanel);
            app.gotoLengthSpinnerLabel.HorizontalAlignment = 'right';
            app.gotoLengthSpinnerLabel.Position = [-1 79 65 22];
            app.gotoLengthSpinnerLabel.Text = 'gotoLength';

            % Create gotoLengthSpinner
            app.gotoLengthSpinner = uispinner(app.createPortsGotoPanel);
            app.gotoLengthSpinner.Step = 20;
            app.gotoLengthSpinner.Limits = [20 260];
            app.gotoLengthSpinner.Position = [78 79 72 22];
            app.gotoLengthSpinner.Value = 180;

            % Create CreateRelatedCheckBox
            app.CreateRelatedCheckBox = uicheckbox(app.createPortsGotoPanel);
            app.CreateRelatedCheckBox.Tooltip = {'是否创建匹配的goto from'};
            app.CreateRelatedCheckBox.Text = 'CreateRelated';
            app.CreateRelatedCheckBox.Position = [32 49 99 22];
            app.CreateRelatedCheckBox.Value = true;

            % Create CreateGotoTab
            app.CreateGotoTab = uitab(app.TabGroup3);
            app.CreateGotoTab.Title = 'CreateGoto';

            % Create createGotoUselessButton
            app.createGotoUselessButton = uibutton(app.CreateGotoTab, 'push');
            app.createGotoUselessButton.ButtonPushedFcn = createCallbackFcn(app, @createGotoUselessButtonPushed, true);
            app.createGotoUselessButton.Position = [26 269 117 23];
            app.createGotoUselessButton.Text = 'createGotoUseless';

            % Create createGotoBasedPortsButton_3
            app.createGotoBasedPortsButton_3 = uibutton(app.CreateGotoTab, 'push');
            app.createGotoBasedPortsButton_3.ButtonPushedFcn = createCallbackFcn(app, @createGotoBasedPortsButtonPushed, true);
            app.createGotoBasedPortsButton_3.Position = [27 312 136 23];
            app.createGotoBasedPortsButton_3.Text = 'createGotoBasedPorts';

            % Create createPortsGotoUpdatePanel
            app.createPortsGotoUpdatePanel = uipanel(app.CreateGotoTab);
            app.createPortsGotoUpdatePanel.Title = 'createPortsGotoUpdate';
            app.createPortsGotoUpdatePanel.Position = [253 71 364 248];

            % Create createPortsGotoUpdateButton
            app.createPortsGotoUpdateButton = uibutton(app.createPortsGotoUpdatePanel, 'push');
            app.createPortsGotoUpdateButton.ButtonPushedFcn = createCallbackFcn(app, @createPortsGotoUpdateButtonPushed, true);
            app.createPortsGotoUpdateButton.Position = [19 26 141 23];
            app.createPortsGotoUpdateButton.Text = 'createPortsGotoUpdate';

            % Create NameOutModeDropDownLabel
            app.NameOutModeDropDownLabel = uilabel(app.createPortsGotoUpdatePanel);
            app.NameOutModeDropDownLabel.HorizontalAlignment = 'right';
            app.NameOutModeDropDownLabel.Position = [18 192 86 22];
            app.NameOutModeDropDownLabel.Text = 'NameOutMode';

            % Create NameOutModeDropDown
            app.NameOutModeDropDown = uidropdown(app.createPortsGotoUpdatePanel);
            app.NameOutModeDropDown.Items = {'keep', 'pre', 'tail'};
            app.NameOutModeDropDown.Position = [119 192 100 22];
            app.NameOutModeDropDown.Value = 'keep';

            % Create createPortsGotoUpdateEnableInCheckBox
            app.createPortsGotoUpdateEnableInCheckBox = uicheckbox(app.createPortsGotoUpdatePanel);
            app.createPortsGotoUpdateEnableInCheckBox.Tooltip = {'勾选则对输入端口信号有影响'};
            app.createPortsGotoUpdateEnableInCheckBox.Text = 'EnableIn';
            app.createPortsGotoUpdateEnableInCheckBox.Position = [33 74 69 22];

            % Create createPortsGotoUpdateEnableOutCheckBox
            app.createPortsGotoUpdateEnableOutCheckBox = uicheckbox(app.createPortsGotoUpdatePanel);
            app.createPortsGotoUpdateEnableOutCheckBox.Tooltip = {'勾选对输出信号有影响'};
            app.createPortsGotoUpdateEnableOutCheckBox.Text = 'EnableOut';
            app.createPortsGotoUpdateEnableOutCheckBox.Position = [140 74 79 22];
            app.createPortsGotoUpdateEnableOutCheckBox.Value = true;

            % Create resoveValueSwitch_2Label_2
            app.resoveValueSwitch_2Label_2 = uilabel(app.createPortsGotoUpdatePanel);
            app.resoveValueSwitch_2Label_2.HorizontalAlignment = 'center';
            app.resoveValueSwitch_2Label_2.Position = [32 120 71 22];
            app.resoveValueSwitch_2Label_2.Text = 'resoveValue';

            % Create createPortsGotoUpdateResoveValueSwitch
            app.createPortsGotoUpdateResoveValueSwitch = uiswitch(app.createPortsGotoUpdatePanel, 'slider');
            app.createPortsGotoUpdateResoveValueSwitch.Position = [44 157 45 20];
            app.createPortsGotoUpdateResoveValueSwitch.Value = 'On';

            % Create logValueSwitch_2Label_2
            app.logValueSwitch_2Label_2 = uilabel(app.createPortsGotoUpdatePanel);
            app.logValueSwitch_2Label_2.HorizontalAlignment = 'center';
            app.logValueSwitch_2Label_2.Position = [270 120 51 22];
            app.logValueSwitch_2Label_2.Text = 'logValue';

            % Create createPortsGotoUpdateLogValueSwitch
            app.createPortsGotoUpdateLogValueSwitch = uiswitch(app.createPortsGotoUpdatePanel, 'slider');
            app.createPortsGotoUpdateLogValueSwitch.Position = [273 157 45 20];

            % Create testValueSwitch_2Label_2
            app.testValueSwitch_2Label_2 = uilabel(app.createPortsGotoUpdatePanel);
            app.testValueSwitch_2Label_2.HorizontalAlignment = 'center';
            app.testValueSwitch_2Label_2.Position = [153 120 54 22];
            app.testValueSwitch_2Label_2.Text = 'testValue';

            % Create createPortsGotoUpdateTestValueSwitch
            app.createPortsGotoUpdateTestValueSwitch = uiswitch(app.createPortsGotoUpdatePanel, 'slider');
            app.createPortsGotoUpdateTestValueSwitch.Position = [156 157 45 20];

            % Create createPortsGotoUpdateLoopPanel_2
            app.createPortsGotoUpdateLoopPanel_2 = uipanel(app.CreateGotoTab);
            app.createPortsGotoUpdateLoopPanel_2.Title = 'createPortsGotoUpdateLoop';
            app.createPortsGotoUpdateLoopPanel_2.Position = [749 195 260 122];

            % Create topLevEditFieldLabel
            app.topLevEditFieldLabel = uilabel(app.createPortsGotoUpdateLoopPanel_2);
            app.topLevEditFieldLabel.HorizontalAlignment = 'right';
            app.topLevEditFieldLabel.Position = [19 68 41 22];
            app.topLevEditFieldLabel.Text = 'topLev';

            % Create topLevEditField
            app.topLevEditField = uieditfield(app.createPortsGotoUpdateLoopPanel_2, 'text');
            app.topLevEditField.Position = [75 68 100 22];
            app.topLevEditField.Value = 'bdroot';

            % Create createPortsGotoUpdateLoopButton
            app.createPortsGotoUpdateLoopButton = uibutton(app.createPortsGotoUpdateLoopPanel_2, 'push');
            app.createPortsGotoUpdateLoopButton.ButtonPushedFcn = createCallbackFcn(app, @createPortsGotoUpdateLoopButtonPushed, true);
            app.createPortsGotoUpdateLoopButton.Position = [19 11 168 23];
            app.createPortsGotoUpdateLoopButton.Text = 'createPortsGotoUpdateLoop';

            % Create ResolveSigCheckBox
            app.ResolveSigCheckBox = uicheckbox(app.createPortsGotoUpdateLoopPanel_2);
            app.ResolveSigCheckBox.Tooltip = {'是否对顶层输入输出信号进行解析'};
            app.ResolveSigCheckBox.Text = 'ResolveSig';
            app.ResolveSigCheckBox.Position = [23 43 83 22];
            app.ResolveSigCheckBox.Value = true;

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
            app.CreateBusGotoButton.Position = [47 216 113 23];
            app.CreateBusGotoButton.Text = 'CreateBusGoto';

            % Create createBusFromExcelButton
            app.createBusFromExcelButton = uibutton(app.CreateBusTab, 'push');
            app.createBusFromExcelButton.ButtonPushedFcn = createCallbackFcn(app, @createBusFromExcelButtonPushed, true);
            app.createBusFromExcelButton.Position = [45 160 126 23];
            app.createBusFromExcelButton.Text = 'createBusFromExcel';

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

            % Create delGcsAllButton
            app.delGcsAllButton = uibutton(app.DeleteTab, 'push');
            app.delGcsAllButton.ButtonPushedFcn = createCallbackFcn(app, @delGcsAllButtonPushed, true);
            app.delGcsAllButton.Position = [11 340 93 23];
            app.delGcsAllButton.Text = 'delGcsAll';

            % Create delUselessPortPanel
            app.delUselessPortPanel = uipanel(app.DeleteTab);
            app.delUselessPortPanel.Title = 'delUselessPort';
            app.delUselessPortPanel.Position = [14 184 246 144];

            % Create delUselessPortButton
            app.delUselessPortButton = uibutton(app.delUselessPortPanel, 'push');
            app.delUselessPortButton.ButtonPushedFcn = createCallbackFcn(app, @delUselessPortButtonPushed, true);
            app.delUselessPortButton.Position = [27 19 93 23];
            app.delUselessPortButton.Text = 'delUselessPort';

            % Create UselessInBlockDropDownLabel
            app.UselessInBlockDropDownLabel = uilabel(app.delUselessPortPanel);
            app.UselessInBlockDropDownLabel.HorizontalAlignment = 'right';
            app.UselessInBlockDropDownLabel.Position = [27 84 93 23];
            app.UselessInBlockDropDownLabel.Text = 'UselessInBlock';

            % Create UselessInBlockDropDown
            app.UselessInBlockDropDown = uidropdown(app.delUselessPortPanel);
            app.UselessInBlockDropDown.Items = {'Terminator', 'Goto'};
            app.UselessInBlockDropDown.Position = [130 84 99 23];
            app.UselessInBlockDropDown.Value = 'Terminator';

            % Create UselessOutBlockDropDownLabel
            app.UselessOutBlockDropDownLabel = uilabel(app.delUselessPortPanel);
            app.UselessOutBlockDropDownLabel.HorizontalAlignment = 'right';
            app.UselessOutBlockDropDownLabel.Position = [27 52 93 22];
            app.UselessOutBlockDropDownLabel.Text = 'UselessOutBlock';

            % Create UselessOutBlockDropDown
            app.UselessOutBlockDropDown = uidropdown(app.delUselessPortPanel);
            app.UselessOutBlockDropDown.Items = {'Ground', 'From', 'Constant'};
            app.UselessOutBlockDropDown.Position = [130 52 99 22];
            app.UselessOutBlockDropDown.Value = 'Ground';

            % Create delLinesAttrPanel
            app.delLinesAttrPanel = uipanel(app.DeleteTab);
            app.delLinesAttrPanel.Title = 'delLinesAttr';
            app.delLinesAttrPanel.Position = [17 63 243 105];

            % Create SigAttrDropDownLabel
            app.SigAttrDropDownLabel = uilabel(app.delLinesAttrPanel);
            app.SigAttrDropDownLabel.HorizontalAlignment = 'right';
            app.SigAttrDropDownLabel.Position = [16 49 93 23];
            app.SigAttrDropDownLabel.Text = 'SigAttr';

            % Create SigAttrDropDown
            app.SigAttrDropDown = uidropdown(app.delLinesAttrPanel);
            app.SigAttrDropDown.Items = {'resoveValue', 'logValue', 'testValue'};
            app.SigAttrDropDown.Position = [119 49 99 23];
            app.SigAttrDropDown.Value = 'logValue';

            % Create AffactAllevCheckBox
            app.AffactAllevCheckBox = uicheckbox(app.delLinesAttrPanel);
            app.AffactAllevCheckBox.Text = 'AffactAllev';
            app.AffactAllevCheckBox.Position = [124 15 99 17];

            % Create delLinesAttrButton
            app.delLinesAttrButton = uibutton(app.delLinesAttrPanel, 'push');
            app.delLinesAttrButton.ButtonPushedFcn = createCallbackFcn(app, @delLinesAttrButtonPushed, true);
            app.delLinesAttrButton.Position = [13 12 93 23];
            app.delLinesAttrButton.Text = 'delLinesAttr';

            % Create ChangeTab
            app.ChangeTab = uitab(app.TabGroup2);
            app.ChangeTab.Tooltip = {'字体宽度'};
            app.ChangeTab.Title = 'Change';

            % Create ChangeModPortNamePanel
            app.ChangeModPortNamePanel = uipanel(app.ChangeTab);
            app.ChangeModPortNamePanel.Title = 'ChangeModPortName';
            app.ChangeModPortNamePanel.Position = [648 13 365 155];

            % Create changeModPortNameButton
            app.changeModPortNameButton = uibutton(app.ChangeModPortNamePanel, 'push');
            app.changeModPortNameButton.ButtonPushedFcn = createCallbackFcn(app, @changeModPortNameButtonPushed, true);
            app.changeModPortNameButton.Position = [76 28 193 23];
            app.changeModPortNameButton.Text = 'changeModPortName';

            % Create OldNameEditFieldLabel
            app.OldNameEditFieldLabel = uilabel(app.ChangeModPortNamePanel);
            app.OldNameEditFieldLabel.HorizontalAlignment = 'right';
            app.OldNameEditFieldLabel.Position = [7 104 121 22];
            app.OldNameEditFieldLabel.Text = 'OldName';

            % Create OldNameEditField
            app.OldNameEditField = uieditfield(app.ChangeModPortNamePanel, 'text');
            app.OldNameEditField.Placeholder = 'Replace Name';
            app.OldNameEditField.Position = [138 104 128 22];
            app.OldNameEditField.Value = 'TmComprCtrl';

            % Create NewNameEditFieldLabel
            app.NewNameEditFieldLabel = uilabel(app.ChangeModPortNamePanel);
            app.NewNameEditFieldLabel.HorizontalAlignment = 'right';
            app.NewNameEditFieldLabel.Position = [17 69 121 23];
            app.NewNameEditFieldLabel.Text = 'NewName';

            % Create NewNameEditField
            app.NewNameEditField = uieditfield(app.ChangeModPortNamePanel, 'text');
            app.NewNameEditField.Placeholder = 'Expect Name';
            app.NewNameEditField.Position = [139 68 125 23];
            app.NewNameEditField.Value = 'SM2SM22';

            % Create ChangeModSizePanel
            app.ChangeModSizePanel = uipanel(app.ChangeTab);
            app.ChangeModSizePanel.Title = 'ChangeModSize';
            app.ChangeModSizePanel.Position = [650 220 365 144];

            % Create changeModSizeGcsButton
            app.changeModSizeGcsButton = uibutton(app.ChangeModSizePanel, 'push');
            app.changeModSizeGcsButton.ButtonPushedFcn = createCallbackFcn(app, @changeModSizeGcsButtonPushed, true);
            app.changeModSizeGcsButton.Position = [190 34 132 23];
            app.changeModSizeGcsButton.Text = 'changeModSizeGcs';

            % Create GcsArrangeRowsSpinnerLabel
            app.GcsArrangeRowsSpinnerLabel = uilabel(app.ChangeModSizePanel);
            app.GcsArrangeRowsSpinnerLabel.HorizontalAlignment = 'right';
            app.GcsArrangeRowsSpinnerLabel.Position = [135 77 132 22];
            app.GcsArrangeRowsSpinnerLabel.Text = 'GcsArrangeRows';

            % Create GcsArrangeRowsSpinner
            app.GcsArrangeRowsSpinner = uispinner(app.ChangeModSizePanel);
            app.GcsArrangeRowsSpinner.Limits = [1 5];
            app.GcsArrangeRowsSpinner.Position = [277 77 52 22];
            app.GcsArrangeRowsSpinner.Value = 2;

            % Create ModSizeDropDownLabel
            app.ModSizeDropDownLabel = uilabel(app.ChangeModSizePanel);
            app.ModSizeDropDownLabel.HorizontalAlignment = 'right';
            app.ModSizeDropDownLabel.Position = [26 76 52 22];
            app.ModSizeDropDownLabel.Text = 'ModSize';

            % Create ModSizeDropDown
            app.ModSizeDropDown = uidropdown(app.ChangeModSizePanel);
            app.ModSizeDropDown.Items = {'200', '250', '300', '350', '400', '450', '500'};
            app.ModSizeDropDown.Position = [93 76 57 22];
            app.ModSizeDropDown.Value = '400';

            % Create changeModSizeButton
            app.changeModSizeButton = uibutton(app.ChangeModSizePanel, 'push');
            app.changeModSizeButton.ButtonPushedFcn = createCallbackFcn(app, @changeModSizeButtonPushed, true);
            app.changeModSizeButton.Position = [32 32 112 22];
            app.changeModSizeButton.Text = 'changeModSize';

            % Create ChangeAttrPanel
            app.ChangeAttrPanel = uipanel(app.ChangeTab);
            app.ChangeAttrPanel.Title = 'Change Attr';
            app.ChangeAttrPanel.Position = [10 6 632 361];

            % Create ChangeLinesPortAttrPanel
            app.ChangeLinesPortAttrPanel = uipanel(app.ChangeAttrPanel);
            app.ChangeLinesPortAttrPanel.Title = 'ChangeLinesPortAttr';
            app.ChangeLinesPortAttrPanel.Position = [13 152 369 176];

            % Create resoveValueSwitch_2Label
            app.resoveValueSwitch_2Label = uilabel(app.ChangeLinesPortAttrPanel);
            app.resoveValueSwitch_2Label.HorizontalAlignment = 'center';
            app.resoveValueSwitch_2Label.Position = [25 94 71 22];
            app.resoveValueSwitch_2Label.Text = 'resoveValue';

            % Create changeLinesPortResoveValueSwitch
            app.changeLinesPortResoveValueSwitch = uiswitch(app.ChangeLinesPortAttrPanel, 'slider');
            app.changeLinesPortResoveValueSwitch.Position = [37 124 45 20];

            % Create logValueSwitch_2Label
            app.logValueSwitch_2Label = uilabel(app.ChangeLinesPortAttrPanel);
            app.logValueSwitch_2Label.HorizontalAlignment = 'center';
            app.logValueSwitch_2Label.Position = [263 93 51 22];
            app.logValueSwitch_2Label.Text = 'logValue';

            % Create changeLinesPortLogValueSwitch
            app.changeLinesPortLogValueSwitch = uiswitch(app.ChangeLinesPortAttrPanel, 'slider');
            app.changeLinesPortLogValueSwitch.Position = [266 124 45 20];

            % Create testValueSwitch_2Label
            app.testValueSwitch_2Label = uilabel(app.ChangeLinesPortAttrPanel);
            app.testValueSwitch_2Label.HorizontalAlignment = 'center';
            app.testValueSwitch_2Label.Position = [146 93 54 22];
            app.testValueSwitch_2Label.Text = 'testValue';

            % Create changeLinesPortTestValueSwitch
            app.changeLinesPortTestValueSwitch = uiswitch(app.ChangeLinesPortAttrPanel, 'slider');
            app.changeLinesPortTestValueSwitch.Position = [149 124 45 20];

            % Create changeLinesPortAttrButton
            app.changeLinesPortAttrButton = uibutton(app.ChangeLinesPortAttrPanel, 'push');
            app.changeLinesPortAttrButton.ButtonPushedFcn = createCallbackFcn(app, @changeLinesPortAttrButtonPushed, true);
            app.changeLinesPortAttrButton.Position = [26 12 124 23];
            app.changeLinesPortAttrButton.Text = 'changeLinesPortAttr';

            % Create ChangeLinePortAffactAllevCheckBox
            app.ChangeLinePortAffactAllevCheckBox = uicheckbox(app.ChangeLinesPortAttrPanel);
            app.ChangeLinePortAffactAllevCheckBox.Text = 'AffactAllev';
            app.ChangeLinePortAffactAllevCheckBox.Position = [250 68 99 17];

            % Create EnableInCheckBox
            app.EnableInCheckBox = uicheckbox(app.ChangeLinesPortAttrPanel);
            app.EnableInCheckBox.Tooltip = {'勾选则对输入端口信号有影响'};
            app.EnableInCheckBox.Text = 'EnableIn';
            app.EnableInCheckBox.Position = [27 65 69 22];

            % Create EnableOutCheckBox
            app.EnableOutCheckBox = uicheckbox(app.ChangeLinesPortAttrPanel);
            app.EnableOutCheckBox.Tooltip = {'勾选对输出信号有影响'};
            app.EnableOutCheckBox.Text = 'EnableOut';
            app.EnableOutCheckBox.Position = [27 41 79 22];
            app.EnableOutCheckBox.Value = true;

            % Create changeLinesSelectedAttrButton
            app.changeLinesSelectedAttrButton = uibutton(app.ChangeLinesPortAttrPanel, 'push');
            app.changeLinesSelectedAttrButton.ButtonPushedFcn = createCallbackFcn(app, @changeLinesSelectedAttrButtonPushed, true);
            app.changeLinesSelectedAttrButton.Position = [194 11 148 23];
            app.changeLinesSelectedAttrButton.Text = 'changeLinesSelectedAttr';

            % Create DeleteNameCheckBox
            app.DeleteNameCheckBox = uicheckbox(app.ChangeLinesPortAttrPanel);
            app.DeleteNameCheckBox.Tooltip = {'当没有任何信号解析的时候，删除信号名'};
            app.DeleteNameCheckBox.Text = 'DeleteName';
            app.DeleteNameCheckBox.Position = [250 41 89 22];

            % Create ScopeButtonGroup
            app.ScopeButtonGroup = uibuttongroup(app.ChangeAttrPanel);
            app.ScopeButtonGroup.Title = 'Scope';
            app.ScopeButtonGroup.Position = [521 222 100 103];

            % Create gcbButton
            app.gcbButton = uiradiobutton(app.ScopeButtonGroup);
            app.gcbButton.Text = 'gcb';
            app.gcbButton.Position = [11 57 58 22];

            % Create gcsButton
            app.gcsButton = uiradiobutton(app.ScopeButtonGroup);
            app.gcsButton.Text = 'gcs';
            app.gcsButton.Position = [11 35 65 22];
            app.gcsButton.Value = true;

            % Create bdrootButton
            app.bdrootButton = uiradiobutton(app.ScopeButtonGroup);
            app.bdrootButton.Text = 'bdroot';
            app.bdrootButton.Position = [11 13 65 22];

            % Create ChangeModelNamePanel
            app.ChangeModelNamePanel = uipanel(app.ChangeAttrPanel);
            app.ChangeModelNamePanel.Title = 'ChangeModelName';
            app.ChangeModelNamePanel.Position = [37 30 260 77];

            % Create changeModNameButton
            app.changeModNameButton = uibutton(app.ChangeModelNamePanel, 'push');
            app.changeModNameButton.ButtonPushedFcn = createCallbackFcn(app, @changeModNameButtonPushed, true);
            app.changeModNameButton.Position = [16 25 110 23];
            app.changeModNameButton.Text = 'changeModName';

            % Create UseLastNameCheckBox
            app.UseLastNameCheckBox = uicheckbox(app.ChangeModelNamePanel);
            app.UseLastNameCheckBox.Text = 'UseLastName';
            app.UseLastNameCheckBox.Position = [146 25 98 22];
            app.UseLastNameCheckBox.Value = true;

            % Create ChangeGotoAttrButton
            app.ChangeGotoAttrButton = uibutton(app.ChangeAttrPanel, 'push');
            app.ChangeGotoAttrButton.ButtonPushedFcn = createCallbackFcn(app, @ChangeGotoAttrButtonPushed, true);
            app.ChangeGotoAttrButton.Tooltip = {'Change goto attr based on the config file'};
            app.ChangeGotoAttrButton.Position = [403 250 102 23];
            app.ChangeGotoAttrButton.Text = 'ChangeGotoAttr';

            % Create ChangePortAttrButton
            app.ChangePortAttrButton = uibutton(app.ChangeAttrPanel, 'push');
            app.ChangePortAttrButton.ButtonPushedFcn = createCallbackFcn(app, @ChangePortAttrButtonPushed, true);
            app.ChangePortAttrButton.Tooltip = {'Change port attr based on the config file'};
            app.ChangePortAttrButton.Position = [406 296 100 23];
            app.ChangePortAttrButton.Text = 'ChangePortAttr';

            % Create changePortBlockPosAllButton
            app.changePortBlockPosAllButton = uibutton(app.ChangeAttrPanel, 'push');
            app.changePortBlockPosAllButton.ButtonPushedFcn = createCallbackFcn(app, @changePortBlockPosAllButtonPushed, true);
            app.changePortBlockPosAllButton.Position = [397 153 193 23];
            app.changePortBlockPosAllButton.Text = 'changePortBlockPosAll';

            % Create changeGotoSizePanel
            app.changeGotoSizePanel = uipanel(app.ChangeAttrPanel);
            app.changeGotoSizePanel.Title = 'changeGotoSize';
            app.changeGotoSizePanel.Position = [358 30 260 79];

            % Create changeGotoSizeButton
            app.changeGotoSizeButton = uibutton(app.changeGotoSizePanel, 'push');
            app.changeGotoSizeButton.ButtonPushedFcn = createCallbackFcn(app, @changeGotoSizeButtonPushed, true);
            app.changeGotoSizeButton.Position = [140 19 112 28];
            app.changeGotoSizeButton.Text = 'changeGotoSize';

            % Create FontSpinnerLabel
            app.FontSpinnerLabel = uilabel(app.changeGotoSizePanel);
            app.FontSpinnerLabel.HorizontalAlignment = 'right';
            app.FontSpinnerLabel.Position = [13 22 29 22];
            app.FontSpinnerLabel.Text = 'Font';

            % Create FontSpinner
            app.FontSpinner = uispinner(app.changeGotoSizePanel);
            app.FontSpinner.Step = 0.5;
            app.FontSpinner.Limits = [6.5 8];
            app.FontSpinner.Position = [57 22 74 22];
            app.FontSpinner.Value = 7;

            % Create changeModPortTypeButton
            app.changeModPortTypeButton = uibutton(app.ChangeAttrPanel, 'push');
            app.changeModPortTypeButton.ButtonPushedFcn = createCallbackFcn(app, @changeModPortTypeButtonPushed, true);
            app.changeModPortTypeButton.Position = [399 193 121 23];
            app.changeModPortTypeButton.Text = 'changeModPortType';

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

            % Create findEnumTypesButton
            app.findEnumTypesButton = uibutton(app.FindTab, 'push');
            app.findEnumTypesButton.ButtonPushedFcn = createCallbackFcn(app, @findEnumTypesButtonPushed, true);
            app.findEnumTypesButton.Tooltip = {'打印log 详见matlab 命令终端'};
            app.findEnumTypesButton.Position = [36 176 100 23];
            app.findEnumTypesButton.Text = 'findEnumTypes';

            % Create SlddTab
            app.SlddTab = uitab(app.TabGroup);
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
            app.AreaDropDown.Position = [59 128 78 22];
            app.AreaDropDown.Value = 'bdroot';

            % Create findParametersButton
            app.findParametersButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.findParametersButton.ButtonPushedFcn = createCallbackFcn(app, @findParametersButtonPushed, true);
            app.findParametersButton.Position = [19 90 100 23];
            app.findParametersButton.Text = 'findParameters';

            % Create findSlddButton
            app.findSlddButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.findSlddButton.ButtonPushedFcn = createCallbackFcn(app, @findSlddButtonPushed, true);
            app.findSlddButton.Position = [145 87 100 23];
            app.findSlddButton.Text = 'findSldd';

            % Create openSlddButton
            app.openSlddButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.openSlddButton.ButtonPushedFcn = createCallbackFcn(app, @openSlddButtonPushed, true);
            app.openSlddButton.Position = [143 52 100 23];
            app.openSlddButton.Text = 'openSldd';

            % Create changeExportedSlddButton
            app.changeExportedSlddButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.changeExportedSlddButton.ButtonPushedFcn = createCallbackFcn(app, @changeExportedSlddButtonPushed, true);
            app.changeExportedSlddButton.Position = [4 12 121 23];
            app.changeExportedSlddButton.Text = 'changeExportedSldd';

            % Create findSlddCombineButton
            app.findSlddCombineButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.findSlddCombineButton.ButtonPushedFcn = createCallbackFcn(app, @findSlddCombineButtonPushed, true);
            app.findSlddCombineButton.Position = [15 52 106 23];
            app.findSlddCombineButton.Text = 'findSlddCombine';

            % Create SlddOverwriteCheckBox
            app.SlddOverwriteCheckBox = uicheckbox(app.CreateExcelSlddPanel);
            app.SlddOverwriteCheckBox.Tooltip = {'选中则会直接覆盖现有的sldd 文件'};
            app.SlddOverwriteCheckBox.Text = 'SlddOverwrite';
            app.SlddOverwriteCheckBox.Position = [146 128 97 22];

            % Create createSlddSigGeeButton
            app.createSlddSigGeeButton = uibutton(app.CreateExcelSlddPanel, 'push');
            app.createSlddSigGeeButton.ButtonPushedFcn = createCallbackFcn(app, @createSlddSigGeeButtonPushed, true);
            app.createSlddSigGeeButton.Position = [137 11 112 23];
            app.createSlddSigGeeButton.Text = 'createSlddSigGee';

            % Create LoadSlddPanel
            app.LoadSlddPanel = uipanel(app.SlddTab);
            app.LoadSlddPanel.Title = 'LoadSldd';
            app.LoadSlddPanel.Position = [270 186 260 184];

            % Create LoadAllSlddButton
            app.LoadAllSlddButton = uibutton(app.LoadSlddPanel, 'push');
            app.LoadAllSlddButton.ButtonPushedFcn = createCallbackFcn(app, @LoadAllSlddButtonPushed, true);
            app.LoadAllSlddButton.Tooltip = {'Load combined Sldd'};
            app.LoadAllSlddButton.Position = [18 60 100 23];
            app.LoadAllSlddButton.Text = 'LoadAllSldd';

            % Create OpenFileToLoadButton
            app.OpenFileToLoadButton = uibutton(app.LoadSlddPanel, 'push');
            app.OpenFileToLoadButton.ButtonPushedFcn = createCallbackFcn(app, @OpenFileToLoadButtonPushed, true);
            app.OpenFileToLoadButton.Tooltip = {'通过对话框打开文件并加载'};
            app.OpenFileToLoadButton.Position = [148 116 103 23];
            app.OpenFileToLoadButton.Text = 'OpenFileToLoad';

            % Create findSlddLoadButton
            app.findSlddLoadButton = uibutton(app.LoadSlddPanel, 'push');
            app.findSlddLoadButton.ButtonPushedFcn = createCallbackFcn(app, @findSlddLoadButtonPushed, true);
            app.findSlddLoadButton.Position = [14 116 100 23];
            app.findSlddLoadButton.Text = 'findSlddLoad';

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
            app.SubModDropDown_2Label_3.Position = [12 129 50 22];
            app.SubModDropDown_2Label_3.Text = 'SubMod';

            % Create SlddDropDown
            app.SlddDropDown = uidropdown(app.ConfigPanel);
            app.SlddDropDown.Items = {'TmRefriModeMgr', 'TmColtModeMgr', 'TmHvchCtrl', 'TmComprCtrl', 'TmRefriVlvCtrl', 'TmSovCtrl', 'TmSigProces', 'TmPumpCtrl', 'TmColtVlvCtrl', 'TmEnergyMgr', 'TmDiag', 'TmAfCtrl', 'bdroot'};
            app.SlddDropDown.Position = [12 106 147 22];
            app.SlddDropDown.Value = 'TmRefriModeMgr';

            % Create SetDefaultDcmButton
            app.SetDefaultDcmButton = uibutton(app.ConfigPanel, 'push');
            app.SetDefaultDcmButton.ButtonPushedFcn = createCallbackFcn(app, @SetDefaultDcmButtonPushed, true);
            app.SetDefaultDcmButton.Position = [9 17 100 23];
            app.SetDefaultDcmButton.Text = 'SetDefaultDcm';

            % Create DcmFilePath
            app.DcmFilePath = uieditfield(app.ConfigPanel, 'text');
            app.DcmFilePath.Placeholder = 'DCM File';
            app.DcmFilePath.Position = [9 59 323 24];

            % Create OpenRelatedDCMButton
            app.OpenRelatedDCMButton = uibutton(app.ConfigPanel, 'push');
            app.OpenRelatedDCMButton.ButtonPushedFcn = createCallbackFcn(app, @OpenRelatedDCMButtonPushed, true);
            app.OpenRelatedDCMButton.Position = [132 19 113 23];
            app.OpenRelatedDCMButton.Text = 'OpenRelatedDCM';

            % Create MCUTypeDropDownLabel
            app.MCUTypeDropDownLabel = uilabel(app.ConfigPanel);
            app.MCUTypeDropDownLabel.HorizontalAlignment = 'right';
            app.MCUTypeDropDownLabel.Position = [212 132 61 22];
            app.MCUTypeDropDownLabel.Text = 'MCU Type';

            % Create MCUTypeDropDown
            app.MCUTypeDropDown = uidropdown(app.ConfigPanel);
            app.MCUTypeDropDown.Items = {'PCMU', 'VCU', 'XCU'};
            app.MCUTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @MCUTypeDropDownValueChanged, true);
            app.MCUTypeDropDown.Position = [211 108 111 22];
            app.MCUTypeDropDown.Value = 'PCMU';

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
            app.delUselessLineButton.Position = [10 340 91 23];
            app.delUselessLineButton.Text = 'delUselessLine';

            % Create findAlgebraicLoopsButton
            app.findAlgebraicLoopsButton = uibutton(app.CheckTab, 'push');
            app.findAlgebraicLoopsButton.ButtonPushedFcn = createCallbackFcn(app, @findAlgebraicLoopsButtonPushed, true);
            app.findAlgebraicLoopsButton.Tooltip = {'删除无用连线'};
            app.findAlgebraicLoopsButton.Position = [8 302 117 23];
            app.findAlgebraicLoopsButton.Text = 'findAlgebraicLoops';

            % Create TestTab
            app.TestTab = uitab(app.TabGroup);
            app.TestTab.Title = 'Test';
            app.TestTab.ButtonDownFcn = createCallbackFcn(app, @TestTabButtonDown, true);

            % Create CaseTable
            app.CaseTable = uitable(app.TestTab);
            app.CaseTable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'; 'Column 4'};
            app.CaseTable.RowName = {};
            app.CaseTable.ColumnEditable = true;
            app.CaseTable.Position = [159 3 941 185];

            % Create CaseTreePanel
            app.CaseTreePanel = uipanel(app.TestTab);
            app.CaseTreePanel.Title = 'CaseTree';
            app.CaseTreePanel.Position = [4 193 154 178];

            % Create HarnessHistoryParamsPanel
            app.HarnessHistoryParamsPanel = uipanel(app.TestTab);
            app.HarnessHistoryParamsPanel.Title = 'Harness History Params';
            app.HarnessHistoryParamsPanel.Position = [4 0 156 188];

            % Create HarnessParamsListBox
            app.HarnessParamsListBox = uilistbox(app.HarnessHistoryParamsPanel);
            app.HarnessParamsListBox.Items = {};
            app.HarnessParamsListBox.ValueChangedFcn = createCallbackFcn(app, @HarnessParamsListBoxValueChanged, true);
            app.HarnessParamsListBox.ClickedFcn = createCallbackFcn(app, @HarnessParamsListBoxClicked, true);
            app.HarnessParamsListBox.Position = [1 1 152 167];
            app.HarnessParamsListBox.Value = {};

            % Create TestManagerPanel
            app.TestManagerPanel = uipanel(app.TestTab);
            app.TestManagerPanel.Title = 'TestManager';
            app.TestManagerPanel.Position = [627 192 469 179];

            % Create ClearResultCheckBox
            app.ClearResultCheckBox = uicheckbox(app.TestManagerPanel);
            app.ClearResultCheckBox.Text = 'ClearResult';
            app.ClearResultCheckBox.Position = [337 124 85 22];

            % Create RunAllHarnessCheckBox
            app.RunAllHarnessCheckBox = uicheckbox(app.TestManagerPanel);
            app.RunAllHarnessCheckBox.Text = 'RunAllHarness';
            app.RunAllHarnessCheckBox.Position = [337 101 102 22];

            % Create ExportReportCheckBox
            app.ExportReportCheckBox = uicheckbox(app.TestManagerPanel);
            app.ExportReportCheckBox.Text = 'ExportReport';
            app.ExportReportCheckBox.Position = [337 78 93 22];

            % Create TestManagerRunButton
            app.TestManagerRunButton = uibutton(app.TestManagerPanel, 'push');
            app.TestManagerRunButton.ButtonPushedFcn = createCallbackFcn(app, @TestManagerRunButtonPushed, true);
            app.TestManagerRunButton.Position = [334 32 106 23];
            app.TestManagerRunButton.Text = 'TestManagerRun';

            % Create CurrentModelEditFieldLabel
            app.CurrentModelEditFieldLabel = uilabel(app.TestManagerPanel);
            app.CurrentModelEditFieldLabel.HorizontalAlignment = 'right';
            app.CurrentModelEditFieldLabel.Position = [21 118 78 22];
            app.CurrentModelEditFieldLabel.Text = 'CurrentModel';

            % Create CurrentModelEditField
            app.CurrentModelEditField = uieditfield(app.TestManagerPanel, 'text');
            app.CurrentModelEditField.Position = [114 118 148 22];

            % Create RefreshButton
            app.RefreshButton = uibutton(app.TestManagerPanel, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPushed, true);
            app.RefreshButton.Tooltip = {'Click this After openning the target model '};
            app.RefreshButton.Position = [26 80 100 23];
            app.RefreshButton.Text = 'Refresh';

            % Create TestHarnessPanel
            app.TestHarnessPanel = uipanel(app.TestTab);
            app.TestHarnessPanel.Title = 'TestHarness';
            app.TestHarnessPanel.Position = [162 191 462 180];

            % Create AddCaseButton
            app.AddCaseButton = uibutton(app.TestHarnessPanel, 'push');
            app.AddCaseButton.ButtonPushedFcn = createCallbackFcn(app, @AddCaseButtonPushed, true);
            app.AddCaseButton.Position = [11 43 100 23];
            app.AddCaseButton.Text = 'AddCase';

            % Create GetPortsButton
            app.GetPortsButton = uibutton(app.TestHarnessPanel, 'push');
            app.GetPortsButton.ButtonPushedFcn = createCallbackFcn(app, @GetPortsButtonPushed, true);
            app.GetPortsButton.Position = [119 43 100 23];
            app.GetPortsButton.Text = 'GetPorts';

            % Create createHarnessButton
            app.createHarnessButton = uibutton(app.TestHarnessPanel, 'push');
            app.createHarnessButton.ButtonPushedFcn = createCallbackFcn(app, @createHarnessButtonPushed, true);
            app.createHarnessButton.Position = [229 43 100 23];
            app.createHarnessButton.Text = 'createHarness';

            % Create DemoButton
            app.DemoButton = uibutton(app.TestHarnessPanel, 'push');
            app.DemoButton.ButtonPushedFcn = createCallbackFcn(app, @DemoButtonPushed, true);
            app.DemoButton.Position = [341 43 100 23];
            app.DemoButton.Text = 'Demo';

            % Create TestCaseTextAreaLabel
            app.TestCaseTextAreaLabel = uilabel(app.TestHarnessPanel);
            app.TestCaseTextAreaLabel.HorizontalAlignment = 'right';
            app.TestCaseTextAreaLabel.Position = [8 121 55 22];
            app.TestCaseTextAreaLabel.Text = 'TestCase';

            % Create TestCaseTextArea
            app.TestCaseTextArea = uitextarea(app.TestHarnessPanel);
            app.TestCaseTextArea.Placeholder = 'test case that need to add to the tree';
            app.TestCaseTextArea.Position = [78 85 159 60];
            app.TestCaseTextArea.Value = {'LEV1'; 'LEV2'};

            % Create LastStepDropDownLabel
            app.LastStepDropDownLabel = uilabel(app.TestHarnessPanel);
            app.LastStepDropDownLabel.HorizontalAlignment = 'right';
            app.LastStepDropDownLabel.Position = [274 121 52 22];
            app.LastStepDropDownLabel.Text = 'LastStep';

            % Create LastStepDropDown
            app.LastStepDropDown = uidropdown(app.TestHarnessPanel);
            app.LastStepDropDown.Items = {'Initialize'};
            app.LastStepDropDown.Position = [341 121 100 22];
            app.LastStepDropDown.Value = 'Initialize';

            % Create NextStepDropDownLabel
            app.NextStepDropDownLabel = uilabel(app.TestHarnessPanel);
            app.NextStepDropDownLabel.HorizontalAlignment = 'right';
            app.NextStepDropDownLabel.Position = [272 88 54 22];
            app.NextStepDropDownLabel.Text = 'NextStep';

            % Create NextStepDropDown
            app.NextStepDropDown = uidropdown(app.TestHarnessPanel);
            app.NextStepDropDown.Items = {'None'};
            app.NextStepDropDown.Position = [341 88 100 22];
            app.NextStepDropDown.Value = 'None';

            % Create CaseListTree
            app.CaseListTree = uitree(app.TestTab);
            app.CaseListTree.Position = [4 190 152 160];

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

            % Create CreateRefModelButton
            app.CreateRefModelButton = uibutton(app.SingleModelProcessPanel, 'push');
            app.CreateRefModelButton.ButtonPushedFcn = createCallbackFcn(app, @CreateRefModelButtonPushed, true);
            app.CreateRefModelButton.Position = [23 182 120 23];
            app.CreateRefModelButton.Text = 'CreateRefModel';

            % Create createCodeRefModButton
            app.createCodeRefModButton = uibutton(app.SingleModelProcessPanel, 'push');
            app.createCodeRefModButton.ButtonPushedFcn = createCallbackFcn(app, @createCodeRefModButtonPushed, true);
            app.createCodeRefModButton.Position = [24 137 119 23];
            app.createCodeRefModButton.Text = 'createCodeRefMod';

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

            % Create ActiveECUEditFieldLabel
            app.ActiveECUEditFieldLabel = uilabel(app.SingleModelProcessPanel);
            app.ActiveECUEditFieldLabel.HorizontalAlignment = 'right';
            app.ActiveECUEditFieldLabel.Position = [350 307 63 22];
            app.ActiveECUEditFieldLabel.Text = 'ActiveECU';

            % Create ActiveECUEditField
            app.ActiveECUEditField = uieditfield(app.SingleModelProcessPanel, 'text');
            app.ActiveECUEditField.Tooltip = {'could change this value in SLDD panel'};
            app.ActiveECUEditField.Position = [428 307 100 22];
            app.ActiveECUEditField.Value = 'XCU';

            % Create OpenModelButton
            app.OpenModelButton = uibutton(app.SingleModelProcessPanel, 'push');
            app.OpenModelButton.ButtonPushedFcn = createCallbackFcn(app, @OpenModelButtonPushed, true);
            app.OpenModelButton.Tooltip = {'Open the selected model'};
            app.OpenModelButton.Position = [33 228 100 23];
            app.OpenModelButton.Text = 'OpenModel';

            % Create PCMUIntegrationPanel
            app.PCMUIntegrationPanel = uipanel(app.IntegrationTab);
            app.PCMUIntegrationPanel.Title = 'PCMU Integration';
            app.PCMUIntegrationPanel.Position = [10 6 534 366];

            % Create createCodePkgButton
            app.createCodePkgButton = uibutton(app.PCMUIntegrationPanel, 'push');
            app.createCodePkgButton.ButtonPushedFcn = createCallbackFcn(app, @createCodePkgButtonPushed, true);
            app.createCodePkgButton.Position = [28 50 105 23];
            app.createCodePkgButton.Text = 'createCodePkg';

            % Create createIntegrationButton
            app.createIntegrationButton = uibutton(app.PCMUIntegrationPanel, 'push');
            app.createIntegrationButton.ButtonPushedFcn = createCallbackFcn(app, @createIntegrationButtonPushed, true);
            app.createIntegrationButton.Position = [28 92 105 23];
            app.createIntegrationButton.Text = 'createIntegration';

            % Create ArxmlToModelButton
            app.ArxmlToModelButton = uibutton(app.PCMUIntegrationPanel, 'push');
            app.ArxmlToModelButton.ButtonPushedFcn = createCallbackFcn(app, @ArxmlToModelButtonPushed, true);
            app.ArxmlToModelButton.Position = [28 133 105 23];
            app.ArxmlToModelButton.Text = 'ArxmlToModel';

            % Create STAGEEditFieldLabel
            app.STAGEEditFieldLabel = uilabel(app.PCMUIntegrationPanel);
            app.STAGEEditFieldLabel.HorizontalAlignment = 'right';
            app.STAGEEditFieldLabel.Position = [111 302 45 22];
            app.STAGEEditFieldLabel.Text = 'STAGE';

            % Create STAGEEditField
            app.STAGEEditField = uieditfield(app.PCMUIntegrationPanel, 'text');
            app.STAGEEditField.Position = [171 302 100 22];
            app.STAGEEditField.Value = '23N7';

            % Create INTERFACE_VERISONEditFieldLabel
            app.INTERFACE_VERISONEditFieldLabel = uilabel(app.PCMUIntegrationPanel);
            app.INTERFACE_VERISONEditFieldLabel.HorizontalAlignment = 'right';
            app.INTERFACE_VERISONEditFieldLabel.Position = [23 271 133 22];
            app.INTERFACE_VERISONEditFieldLabel.Text = 'INTERFACE_VERISON';

            % Create INTERFACE_VERISONEditField
            app.INTERFACE_VERISONEditField = uieditfield(app.PCMUIntegrationPanel, 'text');
            app.INTERFACE_VERISONEditField.Position = [171 271 100 22];
            app.INTERFACE_VERISONEditField.Value = 'V136';

            % Create SOFT_VERSIONEditFieldLabel
            app.SOFT_VERSIONEditFieldLabel = uilabel(app.PCMUIntegrationPanel);
            app.SOFT_VERSIONEditFieldLabel.HorizontalAlignment = 'right';
            app.SOFT_VERSIONEditFieldLabel.Position = [58 241 98 22];
            app.SOFT_VERSIONEditFieldLabel.Text = 'SOFT_VERSION';

            % Create SOFT_VERSIONEditField
            app.SOFT_VERSIONEditField = uieditfield(app.PCMUIntegrationPanel, 'text');
            app.SOFT_VERSIONEditField.Position = [171 241 100 22];
            app.SOFT_VERSIONEditField.Value = '7070416';

            % Create DCM_NAMEEditFieldLabel
            app.DCM_NAMEEditFieldLabel = uilabel(app.PCMUIntegrationPanel);
            app.DCM_NAMEEditFieldLabel.HorizontalAlignment = 'right';
            app.DCM_NAMEEditFieldLabel.Position = [82 207 74 22];
            app.DCM_NAMEEditFieldLabel.Text = 'DCM_NAME';

            % Create DCM_NAMEEditField
            app.DCM_NAMEEditField = uieditfield(app.PCMUIntegrationPanel, 'text');
            app.DCM_NAMEEditField.Position = [171 207 257 22];
            app.DCM_NAMEEditField.Value = 'HY11_PCMU_Tm_OTA3_V6060416_All.DCM';

            % Create VER_NAMEEditFieldLabel
            app.VER_NAMEEditFieldLabel = uilabel(app.PCMUIntegrationPanel);
            app.VER_NAMEEditFieldLabel.HorizontalAlignment = 'right';
            app.VER_NAMEEditFieldLabel.Position = [85 174 71 22];
            app.VER_NAMEEditFieldLabel.Text = 'VER_NAME';

            % Create VER_NAMEEditField
            app.VER_NAMEEditField = uieditfield(app.PCMUIntegrationPanel, 'text');
            app.VER_NAMEEditField.Position = [171 174 257 22];

            % Create ConfigTab
            app.ConfigTab = uitab(app.TabGroup);
            app.ConfigTab.Title = 'Config';
            app.ConfigTab.ButtonDownFcn = createCallbackFcn(app, @ConfigTabButtonDown, true);

            % Create PreferencesPanel
            app.PreferencesPanel = uipanel(app.ConfigTab);
            app.PreferencesPanel.Title = 'Preferences';
            app.PreferencesPanel.Position = [5 3 1091 370];

            % Create GotoWidEditFieldLabel
            app.GotoWidEditFieldLabel = uilabel(app.PreferencesPanel);
            app.GotoWidEditFieldLabel.HorizontalAlignment = 'right';
            app.GotoWidEditFieldLabel.Position = [18 314 52 22];
            app.GotoWidEditFieldLabel.Text = 'GotoWid';

            % Create GotoWidEditField
            app.GotoWidEditField = uieditfield(app.PreferencesPanel, 'text');
            app.GotoWidEditField.Position = [85 314 100 22];
            app.GotoWidEditField.Value = '50';

            % Create GotoHeightEditFieldLabel
            app.GotoHeightEditFieldLabel = uilabel(app.PreferencesPanel);
            app.GotoHeightEditFieldLabel.HorizontalAlignment = 'right';
            app.GotoHeightEditFieldLabel.Position = [4 282 66 22];
            app.GotoHeightEditFieldLabel.Text = 'GotoHeight';

            % Create GotoHeightEditField
            app.GotoHeightEditField = uieditfield(app.PreferencesPanel, 'text');
            app.GotoHeightEditField.Position = [85 282 100 22];
            app.GotoHeightEditField.Value = '14';

            % Create GotoColorEditFieldLabel
            app.GotoColorEditFieldLabel = uilabel(app.PreferencesPanel);
            app.GotoColorEditFieldLabel.HorizontalAlignment = 'right';
            app.GotoColorEditFieldLabel.Position = [10 249 60 22];
            app.GotoColorEditFieldLabel.Text = 'GotoColor';

            % Create GotoColorEditField
            app.GotoColorEditField = uieditfield(app.PreferencesPanel, 'text');
            app.GotoColorEditField.Position = [85 249 100 22];
            app.GotoColorEditField.Value = 'green';

            % Create FromColorEditFieldLabel
            app.FromColorEditFieldLabel = uilabel(app.PreferencesPanel);
            app.FromColorEditFieldLabel.HorizontalAlignment = 'right';
            app.FromColorEditFieldLabel.Position = [8 217 62 22];
            app.FromColorEditFieldLabel.Text = 'FromColor';

            % Create FromColorEditField
            app.FromColorEditField = uieditfield(app.PreferencesPanel, 'text');
            app.FromColorEditField.Position = [85 217 100 22];
            app.FromColorEditField.Value = 'orange';

            % Create PortWidEditFieldLabel
            app.PortWidEditFieldLabel = uilabel(app.PreferencesPanel);
            app.PortWidEditFieldLabel.HorizontalAlignment = 'right';
            app.PortWidEditFieldLabel.Position = [259 314 48 22];
            app.PortWidEditFieldLabel.Text = 'PortWid';

            % Create PortWidEditField
            app.PortWidEditField = uieditfield(app.PreferencesPanel, 'text');
            app.PortWidEditField.Position = [322 314 100 22];
            app.PortWidEditField.Value = '30';

            % Create PortHeightEditFieldLabel
            app.PortHeightEditFieldLabel = uilabel(app.PreferencesPanel);
            app.PortHeightEditFieldLabel.HorizontalAlignment = 'right';
            app.PortHeightEditFieldLabel.Position = [245 282 62 22];
            app.PortHeightEditFieldLabel.Text = 'PortHeight';

            % Create PortHeightEditField
            app.PortHeightEditField = uieditfield(app.PreferencesPanel, 'text');
            app.PortHeightEditField.Position = [322 282 100 22];
            app.PortHeightEditField.Value = '14';

            % Create InportColorEditFieldLabel
            app.InportColorEditFieldLabel = uilabel(app.PreferencesPanel);
            app.InportColorEditFieldLabel.HorizontalAlignment = 'right';
            app.InportColorEditFieldLabel.Position = [243 249 64 22];
            app.InportColorEditFieldLabel.Text = 'InportColor';

            % Create InportColorEditField
            app.InportColorEditField = uieditfield(app.PreferencesPanel, 'text');
            app.InportColorEditField.Position = [322 249 100 22];
            app.InportColorEditField.Value = 'green';

            % Create OutportColorEditFieldLabel
            app.OutportColorEditFieldLabel = uilabel(app.PreferencesPanel);
            app.OutportColorEditFieldLabel.HorizontalAlignment = 'right';
            app.OutportColorEditFieldLabel.Position = [233 217 74 22];
            app.OutportColorEditFieldLabel.Text = 'OutportColor';

            % Create OutportColorEditField
            app.OutportColorEditField = uieditfield(app.PreferencesPanel, 'text');
            app.OutportColorEditField.Position = [322 217 100 22];
            app.OutportColorEditField.Value = 'orange';

            % Create SaveButton
            app.SaveButton = uibutton(app.PreferencesPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [168 48 100 23];
            app.SaveButton.Text = 'Save';

            % Create CommonUsedModelsTextAreaLabel
            app.CommonUsedModelsTextAreaLabel = uilabel(app.PreferencesPanel);
            app.CommonUsedModelsTextAreaLabel.HorizontalAlignment = 'right';
            app.CommonUsedModelsTextAreaLabel.Position = [513 316 127 22];
            app.CommonUsedModelsTextAreaLabel.Text = 'Common Used Models';

            % Create CommonUsedModelsTextArea
            app.CommonUsedModelsTextArea = uitextarea(app.PreferencesPanel);
            app.CommonUsedModelsTextArea.ValueChangedFcn = createCallbackFcn(app, @CommonUsedModelsTextAreaValueChanged, true);
            app.CommonUsedModelsTextArea.ValueChangingFcn = createCallbackFcn(app, @CommonUsedModelsTextAreaValueChanging, true);
            app.CommonUsedModelsTextArea.Placeholder = 'Common Used Models';
            app.CommonUsedModelsTextArea.Position = [508 157 186 155];
            app.CommonUsedModelsTextArea.Value = {'bdroot'; 'SigInSigOut'; 'Sensor'; 'DcMotor'; 'LoadCom'; 'CCMMem'; 'UDS'; 'TmSwArch'};

            % Create CommonUsedContorlersTextAreaLabel
            app.CommonUsedContorlersTextAreaLabel = uilabel(app.PreferencesPanel);
            app.CommonUsedContorlersTextAreaLabel.HorizontalAlignment = 'right';
            app.CommonUsedContorlersTextAreaLabel.Position = [733 312 144 22];
            app.CommonUsedContorlersTextAreaLabel.Text = 'Common Used Contorlers';

            % Create CommonUsedContorlersTextArea
            app.CommonUsedContorlersTextArea = uitextarea(app.PreferencesPanel);
            app.CommonUsedContorlersTextArea.ValueChangedFcn = createCallbackFcn(app, @CommonUsedContorlersTextAreaValueChanged, true);
            app.CommonUsedContorlersTextArea.Placeholder = 'Common Used Models';
            app.CommonUsedContorlersTextArea.Position = [745 158 186 150];
            app.CommonUsedContorlersTextArea.Value = {'PCMU'; 'VCU'; 'XCU'};

            % Create SetDefaultTemplateButton
            app.SetDefaultTemplateButton = uibutton(app.PreferencesPanel, 'push');
            app.SetDefaultTemplateButton.ButtonPushedFcn = createCallbackFcn(app, @SetDefaultTemplateButtonPushed, true);
            app.SetDefaultTemplateButton.Tooltip = {'Set the excel template filepath'};
            app.SetDefaultTemplateButton.Position = [508 115 120 23];
            app.SetDefaultTemplateButton.Text = 'SetDefaultTemplate';

            % Create TemplateFilePath
            app.TemplateFilePath = uieditfield(app.PreferencesPanel, 'text');
            app.TemplateFilePath.Placeholder = 'Template File';
            app.TemplateFilePath.Position = [686 115 323 24];

            % Create LogTextArea
            app.LogTextArea = uitextarea(app.UIFigure);
            app.LogTextArea.WordWrap = 'off';
            app.LogTextArea.Position = [3 3 1097 299];
            app.LogTextArea.Value = {'Welcom ! '; 'Welcom ! !'; 'Welcom ! ! !'};

            % Create ContextMenuCaseTab
            app.ContextMenuCaseTab = uicontextmenu(app.UIFigure);

            % Create DelSelectMenu
            app.DelSelectMenu = uimenu(app.ContextMenuCaseTab);
            app.DelSelectMenu.MenuSelectedFcn = createCallbackFcn(app, @DelSelectMenuSelected, true);
            app.DelSelectMenu.Text = 'DelSelect';

            % Create DelAllMenu
            app.DelAllMenu = uimenu(app.ContextMenuCaseTab);
            app.DelAllMenu.MenuSelectedFcn = createCallbackFcn(app, @DelAllMenuSelected, true);
            app.DelAllMenu.Text = 'DelAll';
            
            % Assign app.ContextMenuCaseTab
            app.CaseTable.ContextMenu = app.ContextMenuCaseTab;

            % Create ContextMenuHarnessParams
            app.ContextMenuHarnessParams = uicontextmenu(app.UIFigure);

            % Create DelParamMenu
            app.DelParamMenu = uimenu(app.ContextMenuHarnessParams);
            app.DelParamMenu.MenuSelectedFcn = createCallbackFcn(app, @DelParamMenuSelected, true);
            app.DelParamMenu.Tooltip = {'删除参数'};
            app.DelParamMenu.Text = 'DelParam';
            
            % Assign app.ContextMenuHarnessParams
            app.HarnessParamsListBox.ContextMenu = app.ContextMenuHarnessParams;

            % Create ContextMenuCaseTree
            app.ContextMenuCaseTree = uicontextmenu(app.UIFigure);

            % Create DelCaseMenu
            app.DelCaseMenu = uimenu(app.ContextMenuCaseTree);
            app.DelCaseMenu.MenuSelectedFcn = createCallbackFcn(app, @DelCaseMenuSelected, true);
            app.DelCaseMenu.Text = 'DelCase';
            
            % Assign app.ContextMenuCaseTree
            app.CaseTreePanel.ContextMenu = app.ContextMenuCaseTree;
            app.CaseListTree.ContextMenu = app.ContextMenuCaseTree;

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