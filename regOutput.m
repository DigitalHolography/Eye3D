classdef regOutput
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        movie = [];
        data1 = [];
        data2 = [];
        error = [];
    end
    
    methods
        function regOutput = regOutput(regMovie,data1,data2,error)
            regOutput.movie = single(regMovie);
            regOutput.data1 = data1;
            regOutput.data2 = data2;
            regOutput.error = error;
        end
    end
end

