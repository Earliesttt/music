% 1. 滤波器设计参数
Fs = 48000;          % 采样率 48 kHz
f1 = 20;             % 带通滤波器起始频率
f2 = 40;             % 带通滤波器结束频率
order = 4;           % 滤波器阶数

% 2. 归一化截止频率
Wn = [f1, f2] / (Fs / 2);

% 3. 设计 Butterworth 带通滤波器
[coeff_b, coeff_a] = butter(order/2, Wn, 'bandpass');

% 4. 绘制频率响应
fvtool(coeff_b, coeff_a); % 使用 fvtool 显示滤波器频率响应
