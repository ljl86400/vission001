vadStatus.ampin = 0;
vadStatus.zcrin = 0;
vadStatus.status = 0;
vadStatus.maxsilence = 15;                        % 语音结束端点阈值，如果静音帧长大于此数值认为语音结束
vadStatus.minlen  = 5;                            % 语音段开始点的阈值，如果语音长度小于此数值认为语音尚未开始
vadStatus.count   = 0;                            % 记录当前语音段的帧长
vadStatus.silence = 0;                            % 记录当前静音段帧长
vadStatus.x1 = 0;
disp('vadStatus');
disp(vadStatus);