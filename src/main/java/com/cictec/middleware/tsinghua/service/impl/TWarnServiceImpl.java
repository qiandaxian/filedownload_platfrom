package com.cictec.middleware.tsinghua.service.impl;

import com.cictec.middleware.tsinghua.dao.TWarnMapper;
import com.cictec.middleware.tsinghua.entity.po.TWarn;
import com.cictec.middleware.tsinghua.service.TWarnService;
import com.cictec.middleware.tsinghua.config.AbstractService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;


/**
 * Created by daxian on 2018/04/24.
 */
@Service
@Transactional
public class TWarnServiceImpl extends AbstractService<TWarn> implements TWarnService {
    @Resource
    private TWarnMapper tWarnMapper;

}
