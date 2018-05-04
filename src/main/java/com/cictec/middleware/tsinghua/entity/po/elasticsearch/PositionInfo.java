package com.cictec.middleware.tsinghua.entity.po.elasticsearch;


import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;

@Data
@Document(indexName = "tsinghua_position",type = "POSITION")
public class PositionInfo {
    @Id
    private String uuid;

    private String lat;

    private String lng;

    private String speed;

    private String hexLocationBuf;

    private String angle;

    private String alarmSetStr;

    private String statusSetStr;

    private String deviceCode;

    private String createTime;

    private String mile;

    private String altitude;
}
