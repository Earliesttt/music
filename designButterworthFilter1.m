function generate_filter_coefficients(Fs, f1, f2, gain_options)
    % 1. 滤波器设计参数
    order = 2;  % 滤波器阶数
    
    % 2. 归一化截止频率
    Wn = [f1, f2] / (Fs / 2);
    
    % 3. 设计 Butterworth 带通滤波器
    [coeff_b, coeff_a] = butter(order/2, Wn, 'bandpass'); % 每个级联部分为 2 阶，总共 4 阶

    % 检查系数长度
    assert(length(coeff_b) == 3 && length(coeff_a) == 3, '滤波器系数数量不正确，应为3个系数');

    % 4. 定义缩放长度（用户定义）
    scale_a_length = 14;  % 分母系数缩放位宽
    scale_b_length = 14;  % 分子系数缩放位宽

    % 5. 定义输入和输出位宽
    DIN_WIDTH = 16;  % 输入位宽
    DOUT_WIDTH = DIN_WIDTH + scale_b_length - scale_a_length;  % 输出位宽

    % 6. 输出文件路径
    output_folder = './data/'; % 输出文件夹

    % 7. 检查并创建文件夹
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);  % 创建文件夹
    end

    % 8. 为每个增益选项生成定点系数文件
    for i = 1:length(gain_options)
        gain = gain_options(i);
        coeff_b_gain = coeff_b * gain; % 应用增益因子

        % 转换为定点表示
        coeff_a_fi = round(coeff_a * 2^(scale_a_length)); % 定点化分母系数
        coeff_b_fi = round(coeff_b_gain * 2^(scale_b_length)); % 定点化增益后的分子系数

        % 保存系数到文件
        coeff_a_file = [output_folder, sprintf('coeff_a_gain%d.dat', i)];
        coeff_b_file = [output_folder, sprintf('coeff_b_gain%d.dat', i)];

        fid_a = fopen(coeff_a_file, 'w'); %
