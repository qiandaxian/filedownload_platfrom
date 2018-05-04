package com.cictec.middleware.tsinghua.service.impl;

import com.cictec.middleware.tsinghua.entity.po.TDevice;
import com.cictec.middleware.tsinghua.entity.po.TWarn;
import com.cictec.middleware.tsinghua.entity.po.TWarnMedia;
import com.cictec.middleware.tsinghua.service.TDeviceService;
import com.cictec.middleware.tsinghua.service.TWarnMediaService;
import com.cictec.middleware.tsinghua.service.TWarnService;
import com.cictec.middleware.tsinghua.utils.DateUtils;
import com.cictec.middleware.tsinghua.utils.DownloadUtils;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.Date;
import java.util.List;

@SpringBootTest
@RunWith(SpringRunner.class)
public class TDeviceServiceImplTest {
    @Autowired
    private TDeviceService tDeviceService;
    @Autowired
    private TWarnService tWarnService;
    @Autowired
    private TWarnMediaService tWarnMediaService;

    @Test
    public void test1(){
        List<TDevice> deviceList = tDeviceService.findAll();
        System.out.println(deviceList.size());
    }
    @Test
    public void warn_test(){

        for (int i = 0; i < 1; i++) {

            TWarn a = new TWarn();
            a.setWarnUuid(i+"AAAAAA");
            a.setWarnTime(new Date());
            tWarnService.save(a);

            TWarn b = new TWarn();
            b.setWarnUuid(i+"BBBB");
            b.setWarnTime(DateUtils.parseDateTime("2018-03-11 11:11:11"));
            tWarnService.save(b);

            TWarn c = new TWarn();
            c.setWarnUuid(i+"CCC");
            c.setWarnTime(DateUtils.parseDateTime("2018-05-11 11:11:11"));
            tWarnService.save(c);

            TWarn d = new TWarn();
            d.setWarnUuid(i+"DDD");
            d.setWarnTime(DateUtils.parseDateTime("2018-06-11 11:11:11"));
            tWarnService.save(d);

            TWarn e = new TWarn();
            e.setWarnUuid(i+"EEE");
            e.setWarnTime(DateUtils.parseDateTime("2018-07-11 11:11:11"));
            tWarnService.save(e);

            TWarn f = new TWarn();
            f.setWarnUuid(i+"FFF");
            f.setWarnTime(DateUtils.parseDateTime("2018-08-11 11:11:11"));
            tWarnService.save(f);


        }

    }
    @Test
    public void warn_query_test(){
        List list = tWarnService.findAll();
        System.out.println(list.size());
    }
    @Test
    public void warnMediatest(){


            TWarnMedia f = new TWarnMedia();
            f.setMediaUuid("test1211");
            f.setCreateTime(DateUtils.parseDateTime("2018-08-11 11:11:11"));
            tWarnMediaService.save(f);

    }

    @Test
    public void httpDownloadtest(){
//        String url = "https://qyws123.oss-cn-hangzhou.aliyuncs.com/180101/001709270034_20180101_102907.h264?Expires=1524876063&OSSAccessKeyId=TMP.AQEm3wh2XJktatOGL_gHdHciseYjTtj5H_yTmWmo4y4-nR8VKpKIHJiLmZrPAAAwLAIUJoq30dozfw4SBrmOPg3SOwWtKFACFEpKAhtZWWXKNY31cXv2QQniuK96&Signature=AX1Q4oclBquWO%2FCXtrKo2gWYmm4%3D";
//        String url = "https://qyws123.oss-cn-hangzhou.aliyuncs.com/180101/001709270034_20180101_103436.jpg?Expires=1524876096&OSSAccessKeyId=TMP.AQEm3wh2XJktatOGL_gHdHciseYjTtj5H_yTmWmo4y4-nR8VKpKIHJiLmZrPAAAwLAIUJoq30dozfw4SBrmOPg3SOwWtKFACFEpKAhtZWWXKNY31cXv2QQniuK96&Signature=rZhIfIv5haiEz8dv2fsYdfZeuyg%3D";
        String url="http://qyws123.oss-cn-hangzhou.aliyuncs.com/180418/211712230085_20180418_105011.h264?Expires=1524020418&OSSAccessKeyId=LTAIrw8Otq3F04oo&Signature=Avx3fLxVhcxkFAM9ZZ5zvn0jQB0%3D";
        String savePath = "/Users/qiandaxian/Desktop/22222.h264";

    }
}