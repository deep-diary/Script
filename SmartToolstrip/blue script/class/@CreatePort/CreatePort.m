classdef CreatePort < handle
    properties
        temp_path = 'Template_PortsCreate'
        sheet = 'TmComprCtrl'

    end
    
    methods(Static)
        createPortsTemp(template, portPath, varargin);
        createPortsTagUpdate(varargin);
        
    end
   methods
       
   end
end
