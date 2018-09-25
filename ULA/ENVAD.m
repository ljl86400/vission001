function [vadStatus]=ENVAD(x,framesLength,nic,vadStatus)
% x:��ǰ֡��Ƶ����
% framesLength:��ǰ֡����
% nic:��ǰ֡���
% vadStatus:vad״̬��־�ṹ��

%% ���㵱ǰ֡���ݶ�ʱ����
x2 = x.*x;
amp = sum(x2);         

%% ���㵱ǰ֡�Ķ�ʱ�������
delta=0.01;
ym = zeros(1,framesLength);
for k=1 : framesLength
    if x(k) >= delta
        ym(k) = x(k) - delta;
    elseif x(k) < -delta
        ym(k) = x(k) + delta;
    else
        ym(k) = 0;
    end
end
zcr=sum(ym(1:end-1).*ym(2:end)<0);             

%% ����ƽ��ֵ�Լ�������ֵ
if( nic <= 3)
    vadStatus.ampin = amp + vadStatus.ampin;                     % �����ʼ�޻������������͹����ʵ�ƽ��ֵ
    vadStatus.zcrin = zcr + vadStatus.zcrin;
    return;
end
ampth = vadStatus.ampin/3;
zcrth = vadStatus.zcrin/3;

amp2=2*ampth;
amp1=4*ampth;                                               % ���������͹����ʵ���ֵ
zcr2=2*zcrth;

%% ���ж˵���
xn=1;
switch vadStatus.status
    case {0,1}                                              % 0 = ����, 1 = ���ܿ�ʼ
        if amp > amp1                                       % ȷ�Ž���������
            vadStatus.x1 = max(vadStatus.count - 1 , 1);
            vadStatus.status  = 2;
            vadStatus.silence = 0;
            vadStatus.count   = vadStatus.count + 1;
        elseif amp > amp2 || ...                % ���ܴ���������
                zcr > zcr2
            vadStatus.status = 1;
            vadStatus.count  = vadStatus.count + 1;
        else                              % ����״̬
            vadStatus.status  = 0;
            vadStatus.count = 0;
            vadStatus.x1 = 0;
            x2 = 0;
        end
    case 2                              % 2 = ������
        if amp > amp2 && ...            % ������������
                zcr > zcr2
            vadStatus.count = vadStatus.count + 1;
        else                              % ����������
            vadStatus.silence = vadStatus.silence + 1;
            if vadStatus.silence < vadStatus.maxsilence    % ��������������������δ����
                vadStatus.count = vadStatus.count + 1;
            elseif vadStatus.count < vadStatus.minlen      % ��������̫�̣���Ϊ�Ǿ���������
                vadStatus.status  = 0;
                vadStatus.silence = 0;
                vadStatus.count   = 0;
            else                           % ��������
                vadStatus.status  = 3;
                x2 = vadStatus.x1 + vadStatus.count;
            end
        end
    case 3                              % ����������Ϊ��һ������׼��
        vadStatus.status  = 0;
        xn = xn + 1;
        vadStatus.count = 0;
        vadStatus.silence = 0;
        vadStatus.x1 = 0;
        x2 = 0;
end


