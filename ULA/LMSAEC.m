function [e] = LMSAEC(refSignal,expSignal,frameLength)
n = frameLength;
L=frameLength;      % �˲������������ǵ������ź�֮��û����ʱ��������ֻ����������������x�źţ�
                    % ��������Ҫ����˲���Ҫ����̫�ߵĽ���
u=0.022;            % ���泣��

if exist('D:\matlab\work\micArrayVision001\ULA\LMSAECdata.mat','file')
    load D:\matlab\work\micArrayVision001\ULA\LMSAECdata.mat;   
else
    refSignalPre  = zeros(1,frameLength);
    wL=zeros(L,1)';                     % ����һ��Ȩϵ������������
end
    
y = zeros(1,frameLength);               % ���ڴ�Ź��ƻ����źţ��´�����źŷ����ں�frameLength����Ԫ��
                                        % ǰframeLength����Ԫ���ڴ����һ֡�Ļ�������
e = zeros(1,frameLength) ;              % ��Ż���������Ľ����Ҳ�Ƿ���ֵ                          

x = zeros(1,2*frameLength);             % ���ڴ�ο��źţ��´�����źŷ����ں�frameLength����Ԫ��
                                        % ǰframeLength����Ԫ���ڴ����һ֡�Ļ�����
x(frameLength + 1:2*frameLength) = refSignal;
x(1:frameLength) = refSignalPre;

for i=1:n                           % ����Ȩ���������е�����Ȩ���������һ��Ȩ������صı���������x��e=x-y����һ��y,û��d��n��
    X = x(i:i + frameLength -1);    % �����˲����Ĳο�ʸ��X��n��
    y(i) = X*wL';                   % ����x����iʱ������ź�
    e(i) = expSignal(i) - y(i);     % ����iʱ������ź�
    wL = wL+2*u*e(i)*X;             % ����iʱ���˲�����Ȩ����
end

refSignalPre = refSignal;
save D:\matlab\work\micArrayVision001\ULA\LMSAECdata.mat refSignalPre wL