function enhancement=WIENERNS(x,wind,inc,NIS,alpha)
% MS��������������, D-D�������������, ����Ҫ���ƴ����źŹ���
% x������������
% wind��֡��
% inc���ص�֡��
% NIS����������֡��
% alpha�����Ʋ���
% enhancement����ǿ�������

    Length=length(x);
    nwin=length(wind);           % ȡ����
    if (nwin == 1)              % �жϴ����Ƿ�Ϊ1����Ϊ1������ʾû���贰����
       framesize= wind;               % �ǣ�֡��=win
       wnd=hamming(framesize);                      % ���ô�����
    else
       framesize = nwin;              % ��֡��=����
       wnd=wind;
    end
    y=enframe(x,wnd,inc)';             % ��֡
    framenum=size(y,2);                           % ��֡��
    y_fft = fft(y);                         % FFT
    y_a = abs(y_fft);                       % ��ȡ��ֵ
    y_phase=angle(y_fft);                   % ��ȡ��λ��
    y_fft2=y_a.^2;                            % ������
    noise=mean(y_fft2(:,1:NIS),2);               % ����������ƽ������
   
    snr_x_q=0.96;                                    %ǰһ֡��������ȣ���ʼֵ��Ϊ0.96
    for i=1:framenum
         Mag_y=y_a(:,i);                          
         snr_h=y_fft2(:,i)./noise;%(:,i);                   %������������
         snr_x=alpha.*snr_x_q+(1-alpha).*max(snr_h-1,0);        %���������,����"D-D"��  ,framesize*1
         Hw=snr_x./(1+snr_x);                             %ά���˲�
         M=Mag_y.*Hw;                                     %ά�ɺ�ķ���ֵ
         Mn=M.*exp(1i.*y_phase(:,i));                           %������λ
         snr_x_q=M.^2./noise;                                   %���¹��Ƶ�ǰһ֡���������
         signal(:,i)=real(ifft(Mn));
    end
enhancement=filpframe(signal',wnd,inc);


function frameout=enframe(x,win,inc)

nx=length(x(:));            % ȡ���ݳ���
nwin=length(win);           % ȡ����
if (nwin == 1)              % �жϴ����Ƿ�Ϊ1����Ϊ1������ʾû���贰����
   len = win;               % �ǣ�֡��=win
else
   len = nwin;              % ��֡��=����
end
if (nargin < 3)             % ���ֻ��������������֡inc=֡��
   inc = len;
end
nf = fix((nx-len+inc)/inc); % ����֡��
frameout=zeros(nf,len);            % ��ʼ��
indf= inc*(0:(nf-1)).';     % ����ÿ֡��x�е�λ����λ��
inds = (1:len);             % ÿ֡���ݶ�Ӧ1:len
frameout(:) = x(indf(:,ones(1,len))+inds(ones(nf,1),:));   % �����ݷ�֡
if (nwin > 1)               % �������а�������������ÿ֡���Դ�����
    w = win(:)';            % ��winת��������
    frameout = frameout .* w(ones(nf,1),:);  % �˴�����
end


function frameout=filpframe(x,win,inc)

[nf,len]=size(x);
nx=(nf-1) *inc+len;                 %ԭ�źų���
frameout=zeros(nx,1);
nwin=length(win);                   % ȡ����
if (nwin ~= 1)                           % �жϴ����Ƿ�Ϊ1����Ϊ1������ʾû���贰����
    winx=repmat(win',nf,1);
    x=x./winx;                          % ��ȥ�Ӵ���Ӱ��
    x(find(isinf(x)))=0;                %ȥ����0�õ���Inf
end

sig=zeros((nf-1)*inc+len,1);
for i=1:nf
    start=(i-1)*inc+1;    
    xn=x(i,:)';
    sig(start:start+len-1)=sig(start:start+len-1)+xn;
end
frameout=sig;