function [e] = LMSAEC(refSignal,expSignal,frameLength)
n = frameLength;
L=frameLength;      % 滤波器阶数，考虑到两个信号之间没有延时，且这里只是用来分离出输入的x信号，
                    % 而且误差不做要求，因此不需要设置太高的阶数
u=0.022;            % 增益常数

if exist('D:\matlab\work\micArrayVision001\ULA\LMSAECdata.mat','file')
    load D:\matlab\work\micArrayVision001\ULA\LMSAECdata.mat;   
else
    refSignalPre  = zeros(1,frameLength);
    wL=zeros(L,1)';                     % 产生一个权系数列向量矩阵
end
    
y = zeros(1,frameLength);               % 用于存放估计回声信号，新传入的信号放置在后frameLength个单元中
                                        % 前frameLength个单元用于存放上一帧的回声估计
e = zeros(1,frameLength) ;              % 存放回声消除后的结果，也是返回值                          

x = zeros(1,2*frameLength);             % 用于存参考信号，新传入的信号放置在后frameLength个单元中
                                        % 前frameLength个单元用于存放上一帧的回声估
x(frameLength + 1:2*frameLength) = refSignal;
x(1:frameLength) = refSignalPre;

for i=1:n                           % 计算权向量矩阵中第三组权向量到最后一组权向量相关的变量，根据x和e=x-y求下一个y,没有d（n）
    X = x(i:i + frameLength -1);    % 更新滤波器的参考矢量X（n）
    y(i) = X*wL';                   % 根据x计算i时刻输出信号
    e(i) = expSignal(i) - y(i);     % 计算i时刻误差信号
    wL = wL+2*u*e(i)*X;             % 更新i时刻滤波器的权向量
end

refSignalPre = refSignal;
save D:\matlab\work\micArrayVision001\ULA\LMSAECdata.mat refSignalPre wL