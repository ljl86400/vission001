function [Es] = EchoGenerate(s1)

f=0:1:4095;
m1=[-436 -829 -2797 -4208 -17968 -11215 46150 34480 -10427 9049 -1309 -6320 ...
    390 -8191 -1751 -6051 -3796 -4055 -3948 -2557 -3372 -1808 -2259 -1300 ...
    -1098 -618 -340 -61 328 419 745 716 946 880 1014 976 1033 1091 1053 1042 ...
    794 831 899 716 390 313 304 304 73 -119 -109 -176 -359 -407 -512 -580 -704 ...
    -618 -685 -791 -772 -820 -839 -724];

L=length(m1);
M1=zeros(1,length(f));
size(M1);

for loop1=0:4095    
    for k=1:L
        M1(loop1+1)=M1(loop1+1)+m1(k)*exp(-2*1j*pi*loop1*k/8192);
    end
end

% figure
% plot(M1);
% title('M1');

K1=1/(max(abs(M1)));

delay=300;
gk1=zeros(1,L);
for k=1+delay:L+delay
    gk1(k)=(10^(-6/20)*K1)*m1(k-delay);
end

% figure
% plot(gk1(delay:delay+L));
% title('gk1');


s=s1';
Es=conv(gk1,s);
Es = Es(1:length(s1));




