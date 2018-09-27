% �������Ƶ�� 16K������ 5s��������Ч�ź�����Ϊ[2s,4s]������Ƶ���ݣ�
% �����Ų�Ϊ�������� ����Դ�Ƕ�theta�ȡ�


ULAdata.audioTime = 5;
ULAdata.effectivTime  = 3;
ULAdata.samplesNumber = ULAdata.sampleFrequency * ULAdata.audioTime;


ULAdata.signalNumber = 2;
ULAdata.theta = [-45 0 30];            % ��Դ����Ƕ�,��һ��Ԫ���Ǹ����źŽǶȣ��ڶ���Ԫ�������źŽǶ�
                                            % ������Ԫ���ǻط��źŵĽǶ�

% ���������ź�
ULAdata.effectiveSignalData(1,:)  = randn(1,ULAdata.sampleFrequency * ULAdata.audioTime)/5;

% �������ź�
time = 1/ULAdata.sampleFrequency:1/ULAdata.sampleFrequency:ULAdata.effectivTime;
ULAdata.effectiveSignalData(2,ULAdata.sampleFrequency*1:ULAdata.sampleFrequency*4-1)  =0.1 * sin(2*pi*1000*time);

% ����һ���ط��źţ����ûط��źž�������ϵͳ
[spkerSound,fsSpk] = audioread('D:\matlab\work\micArrayVision001\ULA\Shostakovich.mp3');
spkerSound = spkerSound(ULAdata.sampleFrequency * 5 + 1:ULAdata.sampleFrequency * (ULAdata.audioTime + 5));
ULAdata.effectiveSignalData(3,:) = EchoGenerate(spkerSound)*20;

% ������������ź�
ULAdata.arrayOfArive = exp(-1j * twpi * ULAmicArray.distanceVactor' * sin(ULAdata.theta * darad));       % ��ȡ��������
ULAdata.arrayEffectiveDataOut = ULAdata.arrayOfArive*ULAdata.effectiveSignalData;

% Ϊ��������ź���Ӱ�����
ULAdata.snr = 40;                   % ��Ч�����ε������
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