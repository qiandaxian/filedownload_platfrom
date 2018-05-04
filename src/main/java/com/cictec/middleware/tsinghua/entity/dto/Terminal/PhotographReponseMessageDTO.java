package com.cictec.middleware.tsinghua.entity.dto.Terminal;

import com.cictec.middleware.tsinghua.entity.dto.TsinghuaDeviceMessageDTO;
import lombok.Data;

/**
 * @author qiandaxian
 * 摄像头抓拍结果上报
 */
@Data
public class PhotographReponseMessageDTO extends TsinghuaDeviceMessageDTO {
    private Integer mediaCount;
    private String[] mediaIdArr;
    private String replyHexFlowNo;
    private Integer resultCode;
}
