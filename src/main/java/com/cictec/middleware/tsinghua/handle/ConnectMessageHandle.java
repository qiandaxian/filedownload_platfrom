package com.cictec.middleware.tsinghua.handle;

import com.alibaba.fastjson.JSONObject;
import com.cictec.middleware.tsinghua.entity.dto.Terminal.ConnectMessageDTO;
import com.cictec.middleware.tsinghua.handle.state.MessageState;
import com.cictec.middleware.tsinghua.biz.VirtualSessionManage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


/**
 * @author qiandaxian
 * 连接信息处理
 */
@Component("0102")
public class ConnectMessageHandle implements MessageState {

    Logger logger = LoggerFactory.getLogger(ConnectMessageHandle.class);

    @Autowired
    private VirtualSessionManage sessionManage;

    @Override
    public void messageHandle(byte[] bytes) {
        ConnectMessageDTO connectMessage = JSONObject.parseObject(bytes,ConnectMessageDTO.class);

        sessionManage.createSession(connectMessage);

        logger.info("收到设备【{}】鉴权消息，消息内容：{}",connectMessage.getHexDevIdno(),connectMessage.toString());
        logger.info("设备设备【{}】状态为在线。",connectMessage.getHexDevIdno());



    }
}
