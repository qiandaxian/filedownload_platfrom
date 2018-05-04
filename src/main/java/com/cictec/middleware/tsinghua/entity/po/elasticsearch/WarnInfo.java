package com.cictec.middleware.tsinghua.entity.po.elasticsearch;


import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;

@Data
@Document(indexName = "tsinghua_warn",type = "WARN")
public class WarnInfo {
    @Id
    private String uuid;

    private String mediaUrl;

    private String hexLocationBuf;

    private String hexMediaId;

    private String channelId;

    private String deviceId;

    private String itemEncoding;

    private String mediaEncoding;

    private String mediaType;

    private String ceateTime;

    private String saveTime;

    private String savePath;

    private String downloadType;

    private String downloadTime;

    private String downloadUrl;

}
