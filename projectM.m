function g2 = projectM(g,S)

G  = fftshift(fft2(g));
G2 = S .* (G ./ abs(G));
g2 = ifft2(ifftshift(G2));