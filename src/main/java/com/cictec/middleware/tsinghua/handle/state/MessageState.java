package com.cictec.middleware.tsinghua.handle.state;

import com.cictec.middleware.tsinghua.entity.dto.TsinghuaDeviceMessageDTO;

/**
 * @author qiandaxian
 * 状态模式
 * 根据消息类型，抽象出状态，不同状态使用不同messageHandle
 */
public interface MessageState {
    /**
     * 消息的处理方法
     * @param bytes
     */
    void messageHandle(byte[] bytes);
}
