% reference：
%  Marchesini  S.  A  unified  evaluation  of  iterative  projection  algorithms  for  phase 
%  retrieval  [J]. Rev Sci Instrum, 2007, 78(1):11301.

clear all;clc;close all;

N = 512; % size of the diffraction pattern image
m = 128; % size of the sample image
m2 = m/2;

sample = rgb2gray(imread('lena.jpg')); % read the lena.jpg as sample image
sample = imresize(sample,[m m]);
sample = MatMap(sample,0,1); % the sample matrix is normalized

figure;imshow(sample,'InitialMagnification',200);axis on;title('sample image');
%%
S = zeros(N,N);
% put the sample image into a zero background
S(N/2-(m2-1):N/2+1+(m2-1) ,N/2-(m2-1):N/2+1+(m2-1)) = sample; 

sup = circle_mask(N,m,N/2,N/2); % generate a circle support
% sup = triMask(N,m/2+8,N/2+10,N/2); % 要是换成一个三角形掩模效果会更好

S = S.*sup;
figure;imshow(S);axis on;title('样品被掩模遮挡部分后（支持域作用的效果）');

S = abs(fftshift(fft2(S))); % generate the modulus of the diffraction pattern
figure;
imagesc(log(1+S));
axis square;
title('The modulus of diffraction pattern (log)');
%%
itnum = 500; % iteration number
g = rand(N,N);
for i = 1:itnum
    %=================ER========================
%     g = projectM(projectSup(g,sup),S);

    %=================SF========================
%     g = projectM(rejectSup(g,sup),S);

    %=================HIO========================
%     g2 = projectM(g,S);
%     g2 = g2.*sup;
%     g = (g2>=0).*g2 + (g2<0).*(g-0.7.*g2);  % HIO

    %=================DM========================
    g = g + projectM(2*projectSup(g,sup)-g,S) - projectSup(g,sup);
%   

    %=================ASR========================
%     g = 0.5.*rejectM(rejectSup(g,sup),S) + 0.5.*g;   % ASR

    %=================HPR========================


    %=================RAAR========================
%     beta = 0.5;
%     g = beta.*( 0.5.*rejectM(rejectSup(g,sup),S) + 0.5.*g ) + (1-beta).*projectM(g,S);

    
    %==============display the reconstruct sample image===================
    imshow(g(N/2-(m2-1):N/2+1+(m2-1),N/2-(m2-1):N/2+1+(m2-1)),'InitialMagnification',200);
    title(strcat('迭代步数',num2str(i)));
    pause(0.01); % 每一步迭代结果的显示时间
    % 显示中间的迭代结果时只显示 N x N 大小重建图像中间的 m x m 大小的区域，旁边大片的黑色部分不显示
end