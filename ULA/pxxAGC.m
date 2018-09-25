function y = pxxAGC(audioNSoutFinal)
x = audioNSoutFinal;

N=size(x,1);
Px=zeros(N,1);
Py=zeros(N,1);
y=zeros(N,1);
g=zeros(N,1);
a=0.2;
mu=0.5;
Pref=0.4;
g(1,1)=1;
y(1,1)=x(1,1);
Py(1,1)=(1-a)*x(1,1)*x(1,1);
Px(1,1)=(1-a)*x(1,1)*x(1,1);
for n=2:N
    Px(n,1)=a*Px(n-1,1)+(1-a)*x(n,1)*x(n,1);              % 能量平滑
    g(n,1)=g(n-1,1)*(1+mu*Px(n,1)*(Pref-Py(n-1,1)));      % 计算增益
    y(n,1)=g(n,1)*x(n,1);                                 % 增益控制
    
    if y(n,1)>2                                             % 截幅控制
        y(n,1)=2;
    end
    
    if y(n,1)<-2                                            % 截幅控制
        y(n,1)=-2;
    end
    
    Py(n,1)=g(n,1)*g(n,1)*Px(n,1);                      % 对能量进行增益控制
end