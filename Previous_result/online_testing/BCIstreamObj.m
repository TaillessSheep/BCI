classdef BCIstreamObj < matlab.System & matlab.system.mixin.Propagates
    % Take in EEG stream from LSL and export a buffer window
    % channels = 14;  %number of sensors
    % buffer = 1000;  %number of samples to hold
    % sf = 128;       %sample frequency

    % Public, tunable properties
    properties
        channels = 14;  %number of sensors
        sf = 128;       %sample frequency
    end

    properties(DiscreteState)
        time
        time2
    end

    % Pre-computed constants
    properties(Access = private)
        lib
        result
        inlet
        data
    end

    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.lib = lsl_loadlib();
            obj.result = lsl_resolve_byprop(obj.lib,'type','EEG');
            obj.inlet = lsl_inlet(obj.result{1});
            obj.time = 0;
            obj.time2 = obj.time;
            obj.data = 0;
        end

        function y = stepImpl(obj,~)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            %y = u;
            while isempty(obj.data) || (obj.time2-obj.time)<(1/obj.sf)
                [obj.data,obj.time2] = obj.inlet.pull_sample(0);
            end
            obj.time = obj.time2;
            y = (obj.data(1:obj.channels))';
            pause(1/(3*obj.sf));
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
            obj.time = 0;
            obj.time2 = obj.time;
            obj.data = 0;
        end
    end
end
