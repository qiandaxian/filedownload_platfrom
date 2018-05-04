package com.cictec.middleware.tsinghua.dao.elasticsearch;

import com.cictec.middleware.tsinghua.entity.po.elasticsearch.PositionInfo;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.Optional;

import static org.junit.Assert.*;

@SpringBootTest
@RunWith(SpringRunner.class)
public class PositionInfoReponsitoryTest {

    @Autowired
    private PositionInfoReponsitory positionInfoReponsitory;

    @Test
    public void saveTest(){
        PositionInfo positionInfo = new PositionInfo();
        positionInfo.setUuid("123123");
        positionInfo.setLat("11111");
        positionInfo.setLng("2222");
        positionInfoReponsitory.save(positionInfo);
    }

    @Test
    public void queryTest(){
        PositionInfo positionInfo = positionInfoReponsitory.findOne("123123");
        System.out.println(positionInfo.toString());
    }

    @Test
    public void delTest(){
        PositionInfo positionInfo = new PositionInfo();
        positionInfo.setUuid("123123");
        positionInfoReponsitory.delete(positionInfo);
    }
}