package com.cictec.middleware.tsinghua.entity.dto.Terminal;

import com.cictec.middleware.tsinghua.entity.dto.TsinghuaDeviceMessageDTO;
import lombok.Data;

/**
 * @author qiandaxian
 * 位置信息传输对象
 */
@Data
public class PositionMessageDTO extends TsinghuaDeviceMessageDTO {
    private String[] alarmSet;
    private Integer altitude;
    private Integer angle;
    private String hexLocationBuf;
    private String lat;
    private String lng;
    private Integer mile;
    private Integer speed;
    private String[] statusSet;
    private String yyMMddHHmmss;
}
