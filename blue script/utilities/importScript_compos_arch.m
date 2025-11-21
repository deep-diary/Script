function importScript_compos_arch
%% Import ARXML Files
arxmlList = {'CCM_Internal_swc.arxml'
    };
importerObj = arxml.importer(arxmlList) %#ok

%% Create new architectural model with interfaces and internal behavior

[~] = rmdir('compos_arch');
mkdir compos_arch
d = cd('compos_arch');

compos_name = importerObj.getComponentNames('Composition');
archModel = autosar.arch.createModel('tmpArch_mdl');
importFromARXML(archModel,importerObj,compos_name{1}, ...
    'ModelPeriodicRunnablesAs','FunctionCallSubsystem', ...
    'DataDictionary','import_arch_dd.sldd');

cd(d)