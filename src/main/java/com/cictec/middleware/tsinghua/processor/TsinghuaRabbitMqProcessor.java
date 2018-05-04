package com.cictec.middleware.tsinghua.processor;

import com.alibaba.fastjson.JSONObject;
import com.cictec.middleware.tsinghua.entity.dto.TsinghuaDeviceMessageDTO;
import com.cictec.middleware.tsinghua.handle.state.MessageStateContext;
import com.cictec.middleware.tsinghua.utils.DateUtils;
import com.cictec.middleware.tsinghua.utils.log.MultiLog;
import com.cictec.middleware.tsinghua.utils.log.MultiLogFileNameUtils;
import com.cictec.middleware.tsinghua.utils.log.MultiLogUtils;
import org.apache.camel.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.UnsupportedEncodingException;


/**
 * 清研设备消息的处理类
 * @author qiandaxian
 */
@Component
public class TsinghuaRabbitMqProcessor extends BaseProcessor {

    @Value("${tcpMessage.save}")
    private boolean messageSave;

    @Value("${tcpMessage.address}")
    private String messageAddress;

    @Value("${tcpMessage.content}")
    private String logContent;

    Logger logger = LoggerFactory.getLogger(TsinghuaRabbitMqProcessor.class);

    @Autowired
    private MessageStateContext messageStateContext;

    @Override
    public void doProcess(Message message) throws Exception {
        byte[] bytes = (byte[]) message.getBody();

        logger.debug("收到消息：{}",new String(bytes,"UTF-8"));
        TsinghuaDeviceMessageDTO messageDTO = JSONObject.parseObject(bytes,TsinghuaDeviceMessageDTO.class);
        saveLogToFile(messageDTO,bytes);
        messageStateContext.messageHandle(messageDTO,bytes);

    }

    /**
     * 保存接收消息到文件
     * @param messageDTO
     * @param bytes
     * @throws Exception
     */
    private void saveLogToFile(TsinghuaDeviceMessageDTO messageDTO,byte[] bytes)throws Exception{
        if(messageSave) {
            String logPath = MultiLogFileNameUtils.getBinaryLogName(DateUtils.getDate(), messageDTO.getHexDevIdno());
            MultiLog log = MultiLogUtils.getMultiLogNotime(messageAddress, logPath, logContent);
            log.debug(new String(bytes, "UTF-8"));
        }
    }

}
