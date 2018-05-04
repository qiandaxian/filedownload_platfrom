package com.cictec.middleware.tsinghua.service.impl;

import com.cictec.middleware.tsinghua.dao.TWarnMediaMapper;
import com.cictec.middleware.tsinghua.entity.po.TWarnMedia;
import com.cictec.middleware.tsinghua.service.TWarnMediaService;
import com.cictec.middleware.tsinghua.config.AbstractService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;


/**
 * Created by daxian on 2018/05/03.
 */
@Service
@Transactional
public class TWarnMediaServiceImpl extends AbstractService<TWarnMedia> implements TWarnMediaService {
    @Resource
    private TWarnMediaMapper tWarnMediaMapper;

}
