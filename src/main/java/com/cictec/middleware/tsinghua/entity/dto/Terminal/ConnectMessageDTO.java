package com.cictec.middleware.tsinghua.entity.dto.Terminal;

import com.cictec.middleware.tsinghua.entity.dto.TsinghuaDeviceMessageDTO;
import lombok.Data;

/**
 * @author qiandaxian
 * 鉴权信息传输对象
 */
@Data
public class ConnectMessageDTO extends TsinghuaDeviceMessageDTO {
    private String authenticationCode;
}
