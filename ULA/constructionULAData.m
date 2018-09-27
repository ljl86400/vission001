% 构造采样频率 16K，长度 5s，其中有效信号区间为[2s,4s]，的音频数据，
% 阵列排布为均匀线阵 ，声源角度theta度。


ULAdata.audioTime = 5;
ULAdata.effectivTime  = 3;
ULAdata.samplesNumber = ULAdata.sampleFrequency * ULAdata.audioTime;


ULAdata.signalNumber = 2;
ULAdata.theta = [-45 0 30];            % 声源入射角度,第一个元素是干扰信号角度，第二个元素是主信号角度
                                            % 第三个元素是回放信号的角度

% 产生干扰信号
ULAdata.effectiveSignalData(1,:)  = randn(1,ULAdata.sampleFrequency * ULAdata.audioTime)/5;

% 产生主信号
time = 1/ULAdata.sampleFrequency:1/ULAdata.sampleFrequency:ULAdata.effectivTime;
ULAdata.effectiveSignalData(2,ULAdata.sampleFrequency*1:ULAdata.sampleFrequency*4-1)  =0.1 * sin(2*pi*1000*time);

% 产生一个回放信号，并让回放信号经过回声系统
[spkerSound,fsSpk] = audioread('D:\matlab\work\micArrayVision001\ULA\Shostakovich.mp3');
spkerSound = spkerSound(ULAdata.sampleFrequency * 5 + 1:ULAdata.sampleFrequency * (ULAdata.audioTime + 5));
ULAdata.effectiveSignalData(3,:) = EchoGenerate(spkerSound)*20;

% 产生阵列输出信号
ULAdata.arrayOfArive = exp(-1j * twpi * ULAmicArray.distanceVactor' * sin(ULAdata.theta * darad));       % 获取阵列流形
ULAdata.arrayEffectiveDataOut = ULAdata.arrayOfArive*ULAdata.effectiveSignalData;

% 为阵列输出信号添加白噪声
ULAdata.snr = 40;                   % 有效声音段的信噪比
ULAdata.signalData = zeros(ULAmicArray.kelm,ULAdata.samplesNumber);
ULAdata.signalData(:,:) = ULAdata.arrayEffectiveDataOut;
arrayDataOut = awgn(ULAdata.signalData,ULAdata.snr,'measured');

audiowrite('D:\matlab\work\micArrayVision001\ULA\ULAchannel1.wav',real(arrayDataOut(1,:)),16000);
audiowrite('D:\matlab\work\micArrayVision001\ULA\ULAchannel2.wav',real(arrayDataOut(2,:)),16000);
audiowrite('D:\matlab\work\micArrayVision001\ULA\ULAchannel3.wav',real(arrayDataOut(3,:)),16000);
audiowrite('D:\matlab\work\micArrayVision001\ULA\ULAchannel4.wav',real(arrayDataOut(4,:)),16000);

save D:\matlab\work\micArrayVision001\ULA\mydata2.mat arrayDataOut

disp('ULAdata');
disp(ULAdata);
% figure(1)
% plot(ULAdata.signalData(1,:))