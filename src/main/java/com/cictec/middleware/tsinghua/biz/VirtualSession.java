package com.cictec.middleware.tsinghua.biz;

import com.cictec.middleware.tsinghua.entity.dto.Terminal.PositionMessageDTO;
import com.cictec.middleware.tsinghua.entity.po.elasticsearch.PositionInfo;
import com.cictec.middleware.tsinghua.entity.po.elasticsearch.WarnInfo;
import lombok.Data;

import java.util.Date;


/**
 * @author qiandaxian
 * 虚拟session,用于模拟session各种状态。
 */
@Data
public class VirtualSession {

    private String devCode;
    private Date createTime;
    private Date lastReceiveMessageTime;
    private PositionMessageDTO lastPosition;

}
