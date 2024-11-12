function sendSliderData(app, sliderValue, sliderTag)
    % 滑动条标签到地址的映射
    tagToAddressMap = struct('1', '7', '2', '8', '3', '9', '4', '10', ...
                             '5', '11', '6', '12', '7', '13', '8', '14', ...
                             '9', '15', '10', '16');

    % 确定滑动条值对应的增益数值 (1, 2, 或 3)
    switch sliderValue
        case -6
            gainNum = 1;  % 对应 num1
        case 0
            gainNum = 2;  % 对应 num2
        case 6
            gainNum = 3;  % 对应 num3
        otherwise
            error('无效的滑动条值: %d', sliderValue);
    end

    % 获取当前滑动条的地址二进制表示
    if isfield(tagToAddressMap, sliderTag)
        addressBinary = dec2bin(str2double(tagToAddressMap.(sliderTag)), 6);
    else
        error('无效的滑动条标签: %s', sliderTag);
    end

    % 将增益数值转换为18位二进制表示
    valueBinary = dec2bin(gainNum, 18);

    % 合并地址和增益值，形成24位二进制字符串
    combinedBinary = strcat(addressBinary, valueBinary);

    % 转换为带空格的3字节HEX字符串
    hexData = sprintf('%02X %02X %02X', ...
                      bin2dec(combinedBinary(1:8)), ...
                      bin2dec(combinedBinary(9:16)), ...
                      bin2dec(combinedBinary(17:24)));

    % 将HEX数据转换为字节数组
    byteData = uint8(sscanf(hexData, '%2x').');

    try
        % 通过串口发送数据
        write(app.SerialObject, byteData, "uint8");

        % 在SerialSend控件上显示发送的HEX数据
        app.SerialSend.Value = hexData;
    catch
        errordlg('错误: 串口未连接！');
    end
end
