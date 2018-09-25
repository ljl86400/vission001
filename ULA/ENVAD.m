function [vadStatus]=ENVAD(x,framesLength,nic,vadStatus)
% x:当前帧音频数据
% framesLength:当前帧长度
% nic:当前帧序号
% vadStatus:vad状态标志结构体

%% 计算当前帧数据短时能量
x2 = x.*x;
amp = sum(x2);         

%% 计算当前帧的短时过零点数
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

%% 计算平均值以及设置阈值
if( nic <= 3)
    vadStatus.ampin = amp + vadStatus.ampin;                     % 计算初始无话段区间能量和过零率的平均值
    vadStatus.zcrin = zcr + vadStatus.zcrin;
    return;
end
ampth = vadStatus.ampin/3;
zcrth = vadStatus.zcrin/3;

amp2=2*ampth;
amp1=4*ampth;                                               % 设置能量和过零率的阈值
zcr2=2*zcrth;

%% 进行端点检测
xn=1;
switch vadStatus.status
    case {0,1}                                              % 0 = 静音, 1 = 可能开始
        if amp > amp1                                       % 确信进入语音段
            vadStatus.x1 = max(vadStatus.count - 1 , 1);
            vadStatus.status  = 2;
            vadStatus.silence = 0;
            vadStatus.count   = vadStatus.count + 1;
        elseif amp > amp2 || ...                % 可能处于语音段
                zcr > zcr2
            vadStatus.status = 1;
            vadStatus.count  = vadStatus.count + 1;
        else                              % 静音状态
            vadStatus.status  = 0;
            vadStatus.count = 0;
            vadStatus.x1 = 0;
            x2 = 0;
        end
    case 2                              % 2 = 语音段
        if amp > amp2 && ...            % 保持在语音段
                zcr > zcr2
            vadStatus.count = vadStatus.count + 1;
        else                              % 语音将结束
            vadStatus.silence = vadStatus.silence + 1;
            if vadStatus.silence < vadStatus.maxsilence    % 静音还不够长，语音尚未结束
                vadStatus.count = vadStatus.count + 1;
            elseif vadStatus.count < vadStatus.minlen      % 语音长度太短，认为是静音或噪声
                vadStatus.status  = 0;
                vadStatus.silence = 0;
                vadStatus.count   = 0;
            else                           % 语音结束
                vadStatus.status  = 3;
                x2 = vadStatus.x1 + vadStatus.count;
            end
        end
    case 3                              % 语音结束，为下一个语音准备
        vadStatus.status  = 0;
        xn = xn + 1;
        vadStatus.count = 0;
        vadStatus.silence = 0;
        vadStatus.x1 = 0;
        x2 = 0;
end


