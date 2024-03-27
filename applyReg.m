function Output = applyReg(movie,regParameters)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
scalingFactor = 1/1.48;
switch regParameters.type
    case 'translation'
        [regMovie,Data1,Data2,Error] = translationRegistration(movie, regParameters.referenceSize, regParameters.temporalFilter, 1, scalingFactor, regParameters.mode,regParameters.getMask(movie));
        Output = regOutput(regMovie,Data1,Data2,Error);
    case 'rotation'
        [regMovie, Data1] = movieRotation(movie,regParameters.mode,regParameters.getMask(movie), regParameters.temporalFilter, regParameters.referenceSize);
        Output = regOutput(regMovie,Data1,[],[]);
    case 'scaling'
        [regMovie, Data1] = movieStretching(movie, regParameters.temporalFilter, regParameters.referenceSize);
        Output = regOutput(regMovie,Data1,[],[]);
end
end

