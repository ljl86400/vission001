% 固定方向波束形成，波束朝向thetaMainlobe

function [audioBFout] = MMSEBF(audioDataArray,ULAmicArray,thetaMainlobe,frameLength)

thetaMainlobe = thetaMainlobe * pi/180;
% w = exp(1j*2*pi*sin(thetaMainlobe)*ULAmicArray.distanceVactor');     % 4*1 权向量
Rxx = (audioDataArray*audioDataArray')/frameLength;
Rxxinv = pinv(Rxx);
aMain = exp(1j*2*pi*sin(thetaMainlobe)*ULAmicArray.distanceVactor');
totalInv = pinv(aMain'*Rxxinv*aMain);
w = 4*Rxxinv * aMain * totalInv;

theta=linspace(-pi/2,pi/2,200);
f0  = zeros(1,length(theta));
for k = 1:length(theta)
    a = exp(1j*2*pi*sin(theta(k))*ULAmicArray.distanceVactor');
    f0(k) = w'*a;
end
% plot(theta*180/pi,20*log10(abs(f0)/max(max(abs(f0)))),'b');
yrho = 20*log10(abs(f0)/max(max(abs(f0))));
polarplot(theta,yrho,'b');
rlim([-100 0])
audioBFout = real(w' * audioDataArray);



