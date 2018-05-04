package com.cictec.middleware.tsinghua.biz;

import com.aliyun.oss.OSSClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * 单例的ossclient客户端
 */
@Component
public class OSSClientManage {

    @Value("${media.alibaba.endpoint}")
    private String endPoint;
    @Value("${media.alibaba.access-id}")
    private String accessId;
    @Value("${media.alibaba.access-key}")
    private String accessKey;

    private OSSClient ossClient = null;

    public OSSClient getOssClient(){
        if(ossClient == null){
            ossClient =  new OSSClient(endPoint, accessId, accessKey);
        }
        return ossClient;
    }
}
