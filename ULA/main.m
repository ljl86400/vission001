clc
clear
close all

frameLength = 441;
twpi = 2*pi;
darad = pi/180;
ULAdata.sampleFrequency = 44100;


run D:\matlab\work\micArrayVision001\ULA\ULAmicInfo.m
run D:\matlab\work\micArrayVision001\ULA\constructionULAData.m;
run D:\matlab\work\micArrayVision001\ULA\vadStatusSet.m


%% 读取音频数据
load D:\matlab\work\micArrayVision001\ULA\mydata2.mat;
fs1 = ULAdata.sampleFrequency;
audioSource1 = dsp.SignalSource(arrayDataOut(1,:)',frameLength);
audioSource2 = dsp.SignalSource(arrayDataOut(2,:)',frameLength);
audioSource3 = dsp.SignalSource(arrayDataOut(3,:)',frameLength);
audioSource4 = dsp.SignalSource(arrayDataOut(4,:)',frameLength);
framesNumber = size(audioSource1.Signal,1)/160;
timeAxisOfAudiodata = 1/fs1:1/fs1:(1/fs1)*size(arrayDataOut(1,:),1);

%% 阵列数据处理
numTSteps = fix(framesNumber*160/frameLength);
SP = zeros(1,361);
audioDataArray = zeros(4,frameLength);
audioBFoutFinal = zeros(1,size(arrayDataOut(1,:),1));
audioAECoutFinal = zeros(1,size(arrayDataOut(1,:),1));
vadDecisionFinal = zeros(1,numTSteps);
DOAvector = zeros(1,numTSteps);
h = waitbar(0,'计算进度条');
steps = numTSteps;
signalNumberEstmation = zeros(2,numTSteps);
for iloop1 = 1:numTSteps
    audioDataArray(1,:) = audioSource1();
    audioDataArray(2,:) = audioSource2();
    audioDataArray(3,:) = audioSource3();
    audioDataArray(4,:) = audioSource4();
    
    % 声源数目估计
    [signalNumber,signalNumberRatio] = EigenDecomSSNE(audioDataArray,frameLength,ULAmicArray);
    signalNumberEstmation(:,iloop1) = [signalNumber;signalNumberRatio];
    
    % 波达方向判断
    [numberMax,sequence,angle] = MUSICDOA(audioDataArray,ULAmicArray,signalNumber,frameLength);
    DOAvector(iloop1) = angle(sequence);
    
    % 固定角度的波束形成处理
    [audioBFout] = MMSEBF(audioDataArray,ULAmicArray,ULAdata.theta(2));
    audioBFoutFinal((iloop1 - 1)*frameLength + 1:iloop1 * frameLength ) = audioBFout;
    
    % 回声消除处理
    refSignal = spkerSound((iloop1 - 1)*frameLength + 1:iloop1 * frameLength );
    [AECout] = LMSAEC(refSignal,audioBFout,frameLength);
    audioAECoutFinal((iloop1 - 1)*frameLength + 1:iloop1 * frameLength ) = AECout;
    
    % VAD判断
    [vadStatus] = ENVAD(AECout,frameLength,iloop1,vadStatus);
    vadDecisionFinal(iloop1) = vadStatus.status;
      
    waitbar(iloop1/steps);
end
close(h);

% 降噪处理
audioNSoutFinal = WIENERNS(audioAECoutFinal,frameLength,220,110,0.99);

% 自动增益控制
audioAGCoutFinal = pxxAGC(audioNSoutFinal);


%% 阵列算法处理结果输出
figure(2)
stem(DOAvector)

figure(3)
title('声源数目估计')
subplot(2,1,1)
plot(signalNumberEstmation(1,:))
subplot(2,1,2)
plot(signalNumberEstmation(2,:))

figure(4)
subplot(6,1,1)
plot(real(arrayDataOut(1,:)))
title('MIC输出信号曲线')
subplot(6,1,2)
plot(audioBFoutFinal)
title('波束形成输出曲线')
subplot(6,1,3)
plot(audioAECoutFinal)
title('回声消除输出曲线')
subplot(6,1,4)
stairs(vadDecisionFinal)
title('语音活动检测输出曲线')
ylim([-0.1 3.1])
subplot(6,1,5)
plot(audioNSoutFinal)
title('噪声抑制输出曲线')
subplot(6,1,6)
plot(audioAGCoutFinal)
title('自动增益控制输出曲线')


%% 播放声音
sound(real(arrayDataOut(1,:)),ULAdata.sampleFrequency)
pause(6)
sound(audioBFoutFinal,ULAdata.sampleFrequency)
pause(6)
sound(audioAECoutFinal,ULAdata.sampleFrequency)
pause(6)
sound(audioNSoutFinal,ULAdata.sampleFrequency)