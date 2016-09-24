function maski = circle_mask(N,m,x,y)
% 四个参数均是整数，不考虑亚像素移动
% 给出一个 N x N 尺寸的零矩阵，在 (x,y) 处 画出一个半径为 m 的圆
% (x,y)为圆心点
% 采用图片坐标系，从上到下为 x ，从左至右为 y
% m 必须为偶数
% 
% 返回这个画了圆的矩阵

mOKflag = 1;
if mod(m,2)==1
    disp('直径m不是偶数！');
    mOKflag = 0;
end

r = m/2;

xyOKflag = 1;
if (x>=r)&(x<=(N-r))&(y>=r)&(y<=(N-r))
%     disp('x y ok');
    xyOKflag = 1;
else
    disp('x y error.画出来的圆将会触边！');
    xyOKflag = 0;
end

if (xyOKflag == 1)&(mOKflag == 1)
    % 开始画圆 并将其移动到指定位置上
    [xx yy] = meshgrid(-N/2:N/2-1);
    z = sqrt(xx.^2 + yy.^2);
    clear xx yy xyOKflag;
    z = (z<r);       % 还是z<=r 使得 sum(sum(z)) 更接近于 round(pi*r*r)
    z = circshift(z,[x-N/2,y-N/2]);
else
    disp('PIEmask something is wrong!');
    z = [];
end

maski = double(z);