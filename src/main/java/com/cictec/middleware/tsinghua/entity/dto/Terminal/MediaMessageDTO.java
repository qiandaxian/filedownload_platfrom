package com.cictec.middleware.tsinghua.entity.dto.Terminal;

import com.cictec.middleware.tsinghua.entity.dto.TsinghuaDeviceMessageDTO;
import lombok.Data;

/**
 * @author qiandaxian
 * 媒体信息传输对象
 */
@Data
public class MediaMessageDTO extends TsinghuaDeviceMessageDTO {
    private String[] alarmSet;
    private Integer altitude;
    private Integer angle;
    private Integer channelId;
    private String hexLocationBuf;
    private String hexMediaId;
    private Integer itemEncoding;
    private String mediaEncoding;
    private Integer mediaType;
    private String mediaUrl;
    private String lat;
    private String lng;
    private Integer mile;
    private Integer speed;
    private String[] statusSet;
    private String yyMMddHHmmss;
}
