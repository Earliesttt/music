function designButterworthFilter(Fs, Fc)
    % 1. 检查输入参数
    if Fc <= 0 || Fc >= Fs / 2
        error('截止频率必须在 (0, Fs/2) 范围内。当前 Fc 值为： %f', Fc);
    end

    % 2. 归一化截止频率
    Wn = Fc / (Fs / 2);
    disp(['归一化截止频率 Wn: ', num2str(Wn)]);

    % 3. 设计 Butterworth 低通滤波器
    order = 2; % 固定阶数为2
    [coeff_b, coeff_a] = butter(order, Wn, 'low');

    % 4. 设定缩放长度（用户定义）
    scale_a_length = 16;
    scale_b_length = 16;

    % 5. 转换为定点表示
    coeff_a_fi = round(coeff_a * 2^(scale_a_length));
    coeff_b_fi = round(coeff_b * 2^(scale_b_length));

    % 6. 输出文件路径
    output_folder = './data/';
    coeff_a_file = [output_folder, 'coeff_a.dat'];
    coeff_b_file = [output_folder, 'coeff_b.dat'];

    % 7. 检查并创建文件夹
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % 8. 将系数保存为竖向的 .dat 文件（signed DEC 格式）
    fid_a = fopen(coeff_a_file, 'w');
    fid_b = fopen(coeff_b_file, 'w');
    fprintf(fid_a, '%d\n', coeff_a_fi);
    fprintf(fid_b, '%d\n', coeff_b_fi);
    fclose(fid_a);
    fclose(fid_b);

    disp('分子 (b) 和分母 (a) 系数已保存为竖向排列的 .dat 文件，格式为 signed DEC。');
end
