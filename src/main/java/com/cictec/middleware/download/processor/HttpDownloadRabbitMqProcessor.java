package com.cictec.middleware.download.processor;

import com.alibaba.fastjson.JSONObject;
import com.cictec.middleware.download.entity.dto.download.HttpDownloadDTO;
import org.apache.camel.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


/**
 * 文件下载信息反馈处理类
 * @author qiandaxian
 */
@Component
public class HttpDownloadRabbitMqProcessor extends BaseProcessor {




    Logger logger = LoggerFactory.getLogger(HttpDownloadRabbitMqProcessor.class);



    @Override
    public void doProcess(Message message) throws Exception {
        byte[] bytes = (byte[]) message.getBody();

        logger.debug("收到消息：{}",new String(bytes,"UTF-8"));
        HttpDownloadDTO messageDTO = JSONObject.parseObject(bytes,HttpDownloadDTO.class);


    }


}
