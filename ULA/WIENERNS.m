function enhancement=WIENERNS(x,wind,inc,NIS,alpha)
% MS估计噪声功率谱, D-D法估计先验概率, 不需要估计纯净信号功率
% x：输入语音段
% wind：帧长
% inc：重叠帧长
% NIS：无语音段帧数
% alpha：抑制参数
% enhancement：增强后的语音

    Length=length(x);
    nwin=length(wind);           % 取窗长
    if (nwin == 1)              % 判断窗长是否为1，若为1，即表示没有设窗函数
       framesize= wind;               % 是，帧长=win
       wnd=hamming(framesize);                      % 设置窗函数
    else
       framesize = nwin;              % 否，帧长=窗长
       wnd=wind;
    end
    y=enframe(x,wnd,inc)';             % 分帧
    framenum=size(y,2);                           % 求帧数
    y_fft = fft(y);                         % FFT
    y_a = abs(y_fft);                       % 求取幅值
    y_phase=angle(y_fft);                   % 求取相位角
    y_fft2=y_a.^2;                            % 求能量
    noise=mean(y_fft2(:,1:NIS),2);               % 计算噪声段平均能量
   
    snr_x_q=0.96;                                    %前一帧先验信噪比，初始值设为0.96
    for i=1:framenum
         Mag_y=y_a(:,i);                          
         snr_h=y_fft2(:,i)./noise;%(:,i);                   %计算后验信噪比
         snr_x=alpha.*snr_x_q+(1-alpha).*max(snr_h-1,0);        %先验信噪比,利用"D-D"法  ,framesize*1
         Hw=snr_x./(1+snr_x);                             %维纳滤波
         M=Mag_y.*Hw;                                     %维纳后的幅度值
         Mn=M.*exp(1i.*y_phase(:,i));                           %插入相位
         snr_x_q=M.^2./noise;                                   %更新估计的前一帧先验信噪比
         signal(:,i)=real(ifft(Mn));
    end
enhancement=filpframe(signal',wnd,inc);


function frameout=enframe(x,win,inc)

nx=length(x(:));            % 取数据长度
nwin=length(win);           % 取窗长
if (nwin == 1)              % 判断窗长是否为1，若为1，即表示没有设窗函数
   len = win;               % 是，帧长=win
else
   len = nwin;              % 否，帧长=窗长
end
if (nargin < 3)             % 如果只有两个参数，设帧inc=帧长
   inc = len;
end
nf = fix((nx-len+inc)/inc); % 计算帧数
frameout=zeros(nf,len);            % 初始化
indf= inc*(0:(nf-1)).';     % 设置每帧在x中的位移量位置
inds = (1:len);             % 每帧数据对应1:len
frameout(:) = x(indf(:,ones(1,len))+inds(ones(nf,1),:));   % 对数据分帧
if (nwin > 1)               % 若参数中包括窗函数，把每帧乘以窗函数
    w = win(:)';            % 把win转成行数据
    frameout = frameout .* w(ones(nf,1),:);  % 乘窗函数
end


function frameout=filpframe(x,win,inc)

[nf,len]=size(x);
nx=(nf-1) *inc+len;                 %原信号长度
frameout=zeros(nx,1);
nwin=length(win);                   % 取窗长
if (nwin ~= 1)                           % 判断窗长是否为1，若为1，即表示没有设窗函数
    winx=repmat(win',nf,1);
    x=x./winx;                          % 除去加窗的影响
    x(find(isinf(x)))=0;                %去除除0得到的Inf
end

sig=zeros((nf-1)*inc+len,1);
for i=1:nf
    start=(i-1)*inc+1;    
    xn=x(i,:)';
    sig(start:start+len-1)=sig(start:start+len-1)+xn;
end
frameout=sig;