function pic = triMask(N,R,x,y)

x0 = [R/2 R/2 -R] + N/2;
y0 = [-sqrt(3)*R/2 sqrt(3)*R/2 0] + N/2;
x0 = round(x0);
y0 = round(y0);
pic = zeros(N,N);

pic = bitmapplot(x0,y0,pic);
pic = bitmapplot([x0(1),x0(3)],[y0(1),y0(3)],pic);
pic = (pic>0);
pic = imfill(pic,'holes');
pic = circshift(pic,[x-N/2,y-N/2]);
pic = double(pic);