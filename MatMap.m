function Mout = MatMap(M,ymin,ymax)
% 将矩阵中元素的范围转换到 [ymin ymax] 范围内，返回double类型

data = M(:);
data = double(data);
mapdata = (ymax - ymin)*((data - min(data))/(max(data) - min(data)))...
    + ymin;

Mout = reshape(mapdata,size(M));