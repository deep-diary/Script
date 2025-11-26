function changeCfgMat2m(mdName, varargin)
%CHANGECFGMAT2M 将配置文件从MAT格式转换为M格式
%   CHANGECFGMAT2M(MDNAME, Name, Value, ...) 将指定模型的配置从MAT格式转换为M格式
%
%   必需参数:
%      mdName       - 模型名称 (字符串)
%
%   可选参数 (名称-值对):
%      'OutputFile' - 输出M文件名 (字符串, 默认: 基于模型名称自动生成)
%      'CloseModel' - 是否关闭模型 (逻辑值, 默认: false)
%
%   功能描述:
%      1. 获取模型中激活的配置集
%      2. 如果配置集是引用配置，则获取其引用的实际配置集
%      3. 将配置集保存为M格式文件
%      4. 根据参数决定是否关闭模型
%
%   示例:
%      % 基本用法
%      changeCfgMat2m('TmComprCtrl')
%      
%      % 指定输出文件名
%      changeCfgMat2m('TmComprCtrl', 'OutputFile', 'MyConfig.m')
%      
%      % 指定所有参数，转换后关闭模型
%      changeCfgMat2m('TmComprCtrl', 'OutputFile', 'MyConfig.m', 'CloseModel', true)
%
%   注意事项:
%      1. 使用前需要确保模型文件存在
%      2. 如果未指定输出文件名，将基于模型名称自动生成
%      3. 如果配置集是引用配置，将自动获取其引用的实际配置集
%      4. 输出文件将保存为MATLAB脚本格式(.m)
%
%   参见: SIMULINK.CONFIGSET, SIMULINK.CONFIGSETREF, GETACTIVECONFIGSET, INPUTPARSER
%
%   作者: Blue.ge
%   版本: 1.0
%   日期: 202501118

    %% 参数解析和验证
    % 验证必需参数
    validateattributes(mdName, {'char', 'string'}, {'scalartext'}, mfilename, 'mdName', 1);
    mdName = char(mdName);
    
    % 创建输入解析器
    p = inputParser;
    p.FunctionName = mfilename;
    
    % 生成默认输出文件名
    defaultOutputFile = [mdName '_Config.m'];
    
    % 添加可选参数
    addParameter(p, 'OutputFile', defaultOutputFile, @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'CloseModel', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    % 解析输入参数
    parse(p, varargin{:});
    
    % 提取参数值
    outputFile = char(p.Results.OutputFile);
    CloseModel = p.Results.CloseModel;
    
    % 确保输出文件扩展名为.m
    [~, ~, ext] = fileparts(outputFile);
    if isempty(ext) || ~strcmpi(ext, '.m')
        outputFile = [outputFile '.m'];
    end

    %% 加载模型
    try
        h = load_system(mdName);
    catch ME
        error('MATLAB:changeCfgMat2m:ModelLoadFailed', ...
              '无法加载模型 "%s": %s', mdName, ME.message);
    end

    %% 获取激活的配置集
    try
        cs_ref = getActiveConfigSet(mdName);
        
        % 判断是否是引用配置，如果是，先将其转换成实际的配置
        if isa(cs_ref, 'Simulink.ConfigSetRef')
            actual_cs = getRefConfigSet(cs_ref);
        else
            actual_cs = cs_ref;
        end
    catch ME
        if CloseModel
            close_system(h);
        end
        error('MATLAB:changeCfgMat2m:ConfigSetFailed', ...
              '获取配置集失败: %s', ME.message);
    end

    %% 将配置文件从MAT格式转换为M格式
    try
        % 将实际配置集保存为.m文件
        actual_cs.saveAs(outputFile);
        fprintf('配置已成功保存为: %s\n', outputFile);
    catch ME
        if CloseModel
            close_system(h);
        end
        error('MATLAB:changeCfgMat2m:SaveFailed', ...
              '保存配置文件失败: %s', ME.message);
    end

    %% 关闭模型（如果需要）
    if CloseModel
        try
            close_system(h);
            fprintf('模型 "%s" 已关闭\n', mdName);
        catch ME
            warning('MATLAB:changeCfgMat2m:CloseFailed', ...
                    '关闭模型失败: %s', ME.message);
        end
    end
end

% cs = Config_Climate
% cs.set_param('RemoveResetFunc', 'on');   % Remove reset function
% cs.set_param('ExistingSharedCode', '');   % Existing shared code
% cs.set_param('HardwareBoard', 'None');   % Hardware board
% cs.set_param('TargetLang', 'C');   % Language
% cs.set_param('Toolchain', 'Automatically locate an installed toolchain');   % Toolchain
% cs.set_param('BuildConfiguration', 'Faster Runs');   % Build configuration
% cs.set_param('ObjectivePriorities', {'Execution efficiency','ROM efficiency','RAM efficiency'});   % Prioritized objectives
% cs.set_param('CheckMdlBeforeBuild', 'Off');   % Check model before generating code
% cs.set_param('SILDebugging', 'off');   % Enable source-level debugging for SIL
% cs.set_param('GenCodeOnly', 'on');   % Generate code only
% cs.set_param('PackageGeneratedCodeAndArtifacts', 'off');   % Package code and artifacts
% cs.set_param('RTWVerbose', 'on');   % Verbose build
% cs.set_param('RetainRTWFile', 'off');   % Retain .rtw file
% cs.set_param('ProfileTLC', 'off');   % Profile TLC
% cs.set_param('TLCDebug', 'off');   % Start TLC debugger when generating code
% cs.set_param('TLCCoverage', 'off');   % Start TLC coverage when generating code
% cs.set_param('TLCAssert', 'off');   % Enable TLC assertion
% cs.set_param('RTWUseSimCustomCode', 'off');   % Use the same custom code settings as Simulation Target
% cs.set_param('CustomSourceCode', '');   % Source file
% cs.set_param('CustomHeaderCode', '');   % Header file
% cs.set_param('CustomInclude', '');   % Include directories
% cs.set_param('CustomSource', '');   % Source files
% cs.set_param('CustomLibrary', '');   % Libraries
% cs.set_param('CustomLAPACKCallback', '');   % Custom LAPACK library callback
% cs.set_param('CustomDefine', '');   % Defines
% cs.set_param('CustomInitializer', '');   % Initialize function
% cs.set_param('CustomTerminator', '');   % Terminate function
% cs.set_param('CodeExecutionProfiling', 'off');   % Measure task execution time
% cs.set_param('CodeProfilingInstrumentation', 'off');   % Measure function execution times
% cs.set_param('CodeCoverageSettings', coder.coverage.CodeCoverageSettings([],'off','off','None'));   % Code coverage tool
% cs.set_param('CreateSILPILBlock', 'None');   % Create block
% cs.set_param('PortableWordSizes', 'off');   % Enable portable word sizes
% cs.set_param('PostCodeGenCommand', '');   % Post code generation command
% cs.set_param('CompOptLevelCompliant', 'on');   % CompOptLevelCompliant
% cs.set_param('SaveLog', 'off');   % Save build log
% cs.set_param('TLCOptions', '');   % TLC command line options
% cs.set_param('GenerateReport', 'on');   % Create code generation report
% cs.set_param('LaunchReport', 'on');   % Open report automatically
% cs.set_param('IncludeHyperlinkInReport', 'on');   % Code-to-model
% cs.set_param('GenerateTraceInfo', 'on');   % Model-to-code
% cs.set_param('GenerateWebview', 'off');   % Generate model Web view
% cs.set_param('GenerateTraceReport', 'on');   % Eliminated / virtual blocks
% cs.set_param('GenerateTraceReportSl', 'on');   % Traceable Simulink blocks
% cs.set_param('GenerateTraceReportSf', 'on');   % Traceable Stateflow objects
% cs.set_param('GenerateTraceReportEml', 'on');   % Traceable MATLAB functions
% cs.set_param('GenerateCodeMetricsReport', 'on');   % Static code metrics
% cs.set_param('GenerateCodeReplacementReport', 'on');   % Summarize which blocks triggered code replacements
% cs.set_param('GenerateComments', 'on');   % Include comments
% cs.set_param('SimulinkBlockComments', 'on');   % Simulink block / Stateflow object comments
% cs.set_param('MATLABSourceComments', 'on');   % MATLAB source code as comments
% cs.set_param('ShowEliminatedStatement', 'on');   % Show eliminated blocks
% cs.set_param('ForceParamTrailComments', 'on');   % Verbose comments for SimulinkGlobal storage class
% cs.set_param('OperatorAnnotations', 'on');   % Operator annotations
% cs.set_param('InsertBlockDesc', 'on');   % Simulink block descriptions
% cs.set_param('SFDataObjDesc', 'on');   % Stateflow object descriptions
% cs.set_param('SimulinkDataObjDesc', 'on');   % Simulink data object descriptions
% cs.set_param('ReqsInCode', 'off');   % Requirements in block comments
% cs.set_param('EnableCustomComments', 'off');   % Custom comments (MPT objects only)
% cs.set_param('MATLABFcnDesc', 'on');   % MATLAB function help text
% cs.set_param('CustomSymbolStrGlobalVar', '$R$N$M');   % Global variables
% cs.set_param('CustomSymbolStrType', '$N$R$M_T');   % Global types
% cs.set_param('CustomSymbolStrField', '$N$M');   % Field name of global types
% cs.set_param('CustomSymbolStrFcn', '$R$N$M$F');   % Subsystem methods
% cs.set_param('CustomSymbolStrFcnArg', 'rt$I$N$M');   % Subsystem method arguments
% cs.set_param('CustomSymbolStrTmpVar', '$N$M');   % Local temporary variables
% cs.set_param('CustomSymbolStrBlkIO', 'rtb_$N$M');   % Local block output variables
% cs.set_param('CustomSymbolStrMacro', '$R$N$M');   % Constant macros
% cs.set_param('CustomSymbolStrUtil', '$N$C');   % Shared utilities
% cs.set_param('MangleLength', 4);   % Minimum mangle length
% cs.set_param('MaxIdLength', 127);   % Maximum identifier length
% cs.set_param('InternalIdentifier', 'Shortened');   % System-generated identifiers
% cs.set_param('InlinedPrmAccess', 'Literals');   % Generate scalar inlined parameters as
% cs.set_param('SignalNamingRule', 'None');   % Signal naming
% cs.set_param('ParamNamingRule', 'None');   % Parameter naming
% cs.set_param('DefineNamingRule', 'None');   % #define naming
% cs.set_param('UseSimReservedNames', 'off');   % Use the same reserved names as Simulation Target
% cs.set_param('ReservedNameArray', []);   % Reserved names
% cs.set_param('IgnoreCustomStorageClasses', 'off');   % Ignore custom storage classes
% cs.set_param('IgnoreTestpoints', 'off');   % Ignore test point signals
% cs.set_param('CommentStyle', 'Auto');   % Comment style
% cs.set_param('IncAutoGenComments', 'off');   % IncAutoGenComments
% cs.set_param('IncDataTypeInIds', 'off');   % IncDataTypeInIds
% cs.set_param('IncHierarchyInIds', 'off');   % IncHierarchyInIds
% cs.set_param('InsertPolySpaceComments', 'off');   % Insert Polyspace comments
% cs.set_param('PreserveName', 'off');   % PreserveName
% cs.set_param('PreserveNameWithParent', 'off');   % PreserveNameWithParent
% cs.set_param('CustomUserTokenString', '');   % Custom token text
% cs.set_param('TargetLangStandard', 'C99 (ISO)');   % Standard math library
% cs.set_param('CodeReplacementLibrary', 'None');   % Code replacement library
% cs.set_param('UtilityFuncGeneration', 'Shared location');   % Shared code placement
% cs.set_param('CodeInterfacePackaging', 'Nonreusable function');   % Code interface packaging
% cs.set_param('GRTInterface', 'off');   % Classic call interface
% cs.set_param('PurelyIntegerCode', 'off');   % Support floating-point numbers
% cs.set_param('SupportNonFinite', 'off');   % Support non-finite numbers
% cs.set_param('SupportComplex', 'off');   % Support complex numbers
% cs.set_param('SupportAbsoluteTime', 'on');   % Support absolute time
% cs.set_param('SupportContinuousTime', 'off');   % Support continuous time
% cs.set_param('SupportNonInlinedSFcns', 'off');   % Support non-inlined S-functions
% cs.set_param('SupportVariableSizeSignals', 'off');   % Support variable-size signals
% cs.set_param('ERTMultiwordTypeDef', 'System defined');   % Multiword type definitions
% cs.set_param('CombineOutputUpdateFcns', 'on');   % Single output/update function
% cs.set_param('IncludeMdlTerminateFcn', 'off');   % Terminate function required
% cs.set_param('MatFileLogging', 'off');   % MAT-file logging
% cs.set_param('SuppressErrorStatus', 'on');   % Remove error status field in real-time model data structure
% cs.set_param('CombineSignalStateStructs', 'on');   % Combine signal/state structures
% cs.set_param('ParenthesesLevel', 'Nominal');   % Parentheses level
% cs.set_param('CastingMode', 'Nominal');   % Casting modes
% cs.set_param('GenerateSampleERTMain', 'off');   % Generate an example main program
% cs.set_param('IncludeFileDelimiter', 'Auto');   % #include file delimiter
% cs.set_param('CPPClassGenCompliant', 'on');   % CPPClassGenCompliant
% cs.set_param('ConcurrentExecutionCompliant', 'on');   % ConcurrentExecutionCompliant
% cs.set_param('ERTCustomFileBanners', 'on');   % ERTCustomFileBanners
% cs.set_param('ERTFirstTimeCompliant', 'on');   % ERTFirstTimeCompliant
% cs.set_param('GenerateFullHeader', 'on');   % GenerateFullHeader
% cs.set_param('InferredTypesCompatibility', 'off');   % InferredTypesCompatibility
% cs.set_param('GenerateSharedConstants', 'on');   % Generate shared constants
% cs.set_param('ModelReferenceCompliant', 'on');   % ModelReferenceCompliant
% cs.set_param('ModelStepFunctionPrototypeControlCompliant', 'on');   % ModelStepFunctionPrototypeControlCompliant
% cs.set_param('MultiwordLength', 2048);   % MultiwordLength
% cs.set_param('ParMdlRefBuildCompliant', 'on');   % ParMdlRefBuildCompliant
% cs.set_param('TargetFcnLib', 'ansi_tfl_table_tmw.mat');   % TargetFcnLib
% cs.set_param('TargetLibSuffix', '');   % TargetLibSuffix
% cs.set_param('TargetPreCompLibLocation', '');   % TargetPreCompLibLocation
% cs.set_param('UseToolchainInfoCompliant', 'on');   % UseToolchainInfoCompliant
% cs.set_param('RemoveDisableFunc', 'off');   % Remove disable function
% %cs.set_param('MemSecPackage', 'GCSC');   % Memory sections package for model data and functions
% cs.set_param('GlobalDataDefinition', 'Auto');   % Data definition
% cs.set_param('GlobalDataReference', 'Auto');   % Data declaration
% cs.set_param('ExtMode', 'off');   % External mode
% cs.set_param('EnableUserReplacementTypes', 'off');   % Replace data type names in the generated code
% cs.set_param('ConvertIfToSwitch', 'on');   % Convert if-elseif-else patterns to switch-case statements
% cs.set_param('ERTCustomFileTemplate', 'example_file_process.tlc');   % File customization template
% cs.set_param('ERTDataHdrFileTemplate', 'ert_code_template.cgt');   % Header file template
% cs.set_param('ERTDataSrcFileTemplate', 'ert_code_template.cgt');   % Source file template
% cs.set_param('ERTFilePackagingFormat', 'Compact');   % File packaging format
% cs.set_param('ERTHdrFileBannerTemplate', 'ert_code_template.cgt');   % Header file template
% cs.set_param('ERTSrcFileBannerTemplate', 'ert_code_template.cgt');   % Source file template
% cs.set_param('EnableDataOwnership', 'off');   % Use owner from data object for data definition placement
% cs.set_param('GenerateASAP2', 'on');   % ASAP2 interface
% cs.set_param('IndentSize', '2');   % Indent size
% cs.set_param('IndentStyle', 'K&R');   % Indent style
% cs.set_param('InlinedParameterPlacement', 'NonHierarchical');   % Parameter structure
% cs.set_param('MemSecDataConstants', 'Default');   % Memory section for constants
% cs.set_param('MemSecDataIO', 'Default');   % Memory section for inputs/outputs
% cs.set_param('MemSecDataInternal', 'FastRam32bit');   % Memory section for internal data
% cs.set_param('MemSecDataParameters', 'Default');   % Memory section for parameters
% cs.set_param('MemSecFuncExecute', 'r10ms');   % Memory section for execution functions
% cs.set_param('MemSecFuncInitTerm', 'rini');   % Memory section for initialize/terminate functions
% cs.set_param('MemSecFuncSharedUtil', 'r10ms');   % Memory section for shared utility functions
% cs.set_param('ParamTuneLevel', 10);   % Parameter tune level
% cs.set_param('EnableSignedLeftShifts', 'on');   % Replace multiplications by powers of two with signed bitwise shifts
% cs.set_param('EnableSignedRightShifts', 'on');   % Allow right shifts on signed integers
% cs.set_param('PreserveExpressionOrder', 'off');   % Preserve operand order in expression
% cs.set_param('PreserveExternInFcnDecls', 'on');   % Preserve extern keyword in function declarations
% cs.set_param('PreserveIfCondition', 'off');   % Preserve condition expression in if statement
% cs.set_param('RTWCAPIParams', 'off');   % Generate C API for parameters
% cs.set_param('RTWCAPIRootIO', 'off');   % Generate C API for root-level I/O
% cs.set_param('RTWCAPISignals', 'off');   % Generate C API for signals
% cs.set_param('RTWCAPIStates', 'off');   % Generate C API for states
% cs.set_param('RateGroupingCode', 'on');   % RateGroupingCode
% cs.set_param('SignalDisplayLevel', 10);   % Signal display level
% cs.set_param('SuppressUnreachableDefaultCases', 'on');   % Suppress generation of default cases for Stateflow switch statements if unreachable
% cs.set_param('BooleanTrueId', 'true');   % Boolean true identifier.
% cs.set_param('BooleanFalseId', 'false');   % Boolean false identifier.
% cs.set_param('MaxIdInt32', 'MAX_int32_T');   % 32-bit integer maximum identifier
% cs.set_param('MinIdInt32', 'MIN_int32_T');   % 32-bit integer minimum identifier
% cs.set_param('MaxIdUint32', 'MAX_uint32_T');   % 32-bit unsigned integer maximum identifier
% cs.set_param('MaxIdInt16', 'MAX_int16_T');   % 16-bit integer maximum identifier
% cs.set_param('MinIdInt16', 'MIN_int16_T');   % 16-bit integer minimum identifier
% cs.set_param('MaxIdUint16', 'MAX_uint16_T');   % 16-bit unsigned integer maximum identifier
% cs.set_param('MaxIdInt8', 'MAX_int8_T');   % 8-bit integer maximum identifier
% cs.set_param('MinIdInt8', 'MIN_int8_T');   % 8-bit integer minimum identifier
% cs.set_param('MaxIdUint8', 'MAX_uint8_T');   % 8-bit unsigned integer maximum identifier
% cs.set_param('TypeLimitIdReplacementHeaderFile', '');   % Type limit identifier replacement header file
% Config_Climate = cs
