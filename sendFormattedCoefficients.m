function sendFormattedCoefficients(app, addresses, coeff_a_fi, coeff_b_fi)
    % 将 coeff_a 和 coeff_b 的数据合并
    coeff_data = [coeff_a_fi; coeff_b_fi];
    
    % 依次发送
    for i = 1:length(coeff_data)
        % 6位地址 + 18位数据 (24位)
        address = addresses(i);
        data = coeff_data(i);
        
        % 将数据组合为 24 位：6 位地址 + 18 位数据
        packet = bitshift(uint32(address), 18) + uint32(data); % 格式化为 uint32
        
        % 将数据作为 24 位发送
        app.sendData(packet);  % 假设 sendData 是已定义的串口发送函数
        
        % 发送间隔，避免发送过快
        pause(0.01); % 10ms 的间隔，可以根据需求调整
    end
end
