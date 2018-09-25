%% 处理数据
function [numberMax,sequence,angle] = MUSICDOA(audioDataArray,ULAmicArray,numberOfSource,frameLength)
angle = zeros(1,361);
audioDataArrayCovarianceArray = (audioDataArray*audioDataArray')/frameLength;
[EV,D] = eig(audioDataArrayCovarianceArray);
EVA = diag(D)';
[EVA,I] = sort(EVA);
EVA = fliplr(EVA);
EV = fliplr(EV(:,I));

for iang = 1:361
    angle(iang) = (iang - 181) / 2;
    phim = pi/180 * angle(iang);
    arrayOfArive = exp(-1j * 2*pi * ULAmicArray.distanceVactor * sin (phim))';       % 获取阵列流形
    En = EV(:,numberOfSource + 1:ULAmicArray.kelm);
    SP(iang) = (arrayOfArive'*arrayOfArive)/(arrayOfArive'*En*En'*arrayOfArive);
end
SPabs = abs(SP);
[numberMax,sequence] = max(SPabs);

% figure(2)
% plot(angle,SPabs)




