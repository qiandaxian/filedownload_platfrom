package com.cictec.middleware.tsinghua.dao.elasticsearch;

import com.cictec.middleware.tsinghua.entity.po.elasticsearch.PositionInfo;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

/**
 * 位置信息存储ES
 */
public interface PositionInfoReponsitory extends ElasticsearchRepository<PositionInfo,String> {

}
