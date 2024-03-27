function [color,aColor] = getColorPlot(Data, BinsSize, BinsNumber)
    startColor = [0 0 1];
    endColor = [1 0 0];
    m = mean(Data);
    color = zeros(length(Data),3);
    Reds = linspace(startColor(1),endColor(1),BinsNumber+2);
    Green = linspace(startColor(2),endColor(2),BinsNumber+2);
    Blue = linspace(startColor(3),endColor(3),BinsNumber+2);
    aColor = [Reds' Green' Blue'];
    k = find(Data>= m);
    for ii = 1:length(k)
        color(k(ii),:) = aColor(1,:);
    end
    for j = 1:BinsNumber+1
        k = find(Data<(m-BinsSize*(j-1)));
        for ii = 1:length(k)
            color(k(ii),:) = aColor(j+1,:);
        end
    end
end

