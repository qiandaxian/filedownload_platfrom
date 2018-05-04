package com.cictec.middleware.tsinghua.processor;

import com.alibaba.fastjson.JSONObject;
import com.cictec.middleware.tsinghua.entity.dto.download.HttpDownloadResponseDTO;
import com.cictec.middleware.tsinghua.entity.po.TWarnMedia;
import com.cictec.middleware.tsinghua.handle.state.MessageStateContext;
import com.cictec.middleware.tsinghua.service.TWarnMediaService;
import org.apache.camel.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;


/**
 * 文件下载信息反馈处理类
 * @author qiandaxian
 */
@Component
public class HttpDownloadResponseRabbitMqProcessor extends BaseProcessor {


    @Autowired
    private TWarnMediaService tWarnMediaService;

    Logger logger = LoggerFactory.getLogger(HttpDownloadResponseRabbitMqProcessor.class);

    @Autowired
    private MessageStateContext messageStateContext;

    @Override
    public void doProcess(Message message) throws Exception {
        byte[] bytes = (byte[]) message.getBody();

        logger.debug("收到消息：{}",new String(bytes,"UTF-8"));
        HttpDownloadResponseDTO messageDTO = JSONObject.parseObject(bytes,HttpDownloadResponseDTO.class);

        TWarnMedia warnMedia = converHttpDownloadResponseDTOToWarnMedia(messageDTO);

        tWarnMediaService.update(warnMedia);

    }

    private TWarnMedia converHttpDownloadResponseDTOToWarnMedia(HttpDownloadResponseDTO responseDTO){
        TWarnMedia tWarnMedia = new TWarnMedia();
        tWarnMedia.setDownloadStatus(responseDTO.getDownloadStatus());
        tWarnMedia.setDownloadTime(responseDTO.getDownloadTime());
        tWarnMedia.setMediaUuid(responseDTO.getMediaUuid());
        tWarnMedia.setDownloadUrl(responseDTO.getDownloadUrl());
        return tWarnMedia;
    }

}
