package com.cictec.middleware.download.entity.dto.download;


import lombok.Data;
import java.util.Date;

@Data
public class HttpDownloadResponseDTO {
    private String downloadUrl;
    private Integer downloadStatus;
    private Date downloadTime;
    private String mediaUuid;
}
