package com.cictec.middleware.download.utils;

import org.apache.commons.lang3.StringUtils;

import java.util.stream.Stream;


/**
 * @author daxian
 */
public class DaxianStringUtils extends StringUtils {
    /**
     * 字符串去重方法
     */
    public static String distinctStringWithSplit(String strArray,String regex){
        return  StringUtils.join(Stream.of(strArray.split(regex)).distinct().toArray(String[]::new),regex);
    }

    public static String distinctStringWithSplit(String strArray){
        if (strArray==null||strArray.length()==0){
            return "";
        }
        return  distinctStringWithSplit(strArray,",");
    }


    /**
     * 数字转指定长度字符串,不足的位数补0
     * @param num
     * @param length
     * @return
     */
    public static String getIntegerStringByLength(Integer num,Integer length){

        String format = "%0"+length+"d";

        return String.format(format, num);

    }

    /**
     * 将本地文件的路径，按照web访问地址的根路径，转换成web的访问地址
     * @param filePath
     * @param webRootPath
     * @param webRootPath
     * @return
     */
    public static String convertFilePathToWebPath(String filePath,String webRootPath,String webRootUrl){

        String relativePath =  removeFirst(filePath,webRootPath);

        return webRootUrl + relativePath;
    }



    public static void main(String[] args) {

        String filePath = "/Users/qiandaxian/Documents/work/media/package/1111112222222/239f4910bd47433dba9e.zip";

        String webRootPath = "/Users/qiandaxian/Documents/work/media";

        String webRootUrl = "http://192.168.10.166:9090/media";

        System.out.println(
                //convertFilePathToWebPath(filePath,webRootPath,webRootUrl)
                removeEnd(webRootPath,"/media")
        );

    }


}
