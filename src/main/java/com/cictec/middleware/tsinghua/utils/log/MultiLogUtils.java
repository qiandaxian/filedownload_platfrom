package com.cictec.middleware.tsinghua.utils.log;


import org.apache.log4j.*;

import java.io.File;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;


/**
 * 多日志文件输出类
 * 
 * @author Administrator
 *
 */
public class MultiLogUtils {


	private static ConcurrentMap<String, MultiLog> multiLog = new ConcurrentHashMap<String, MultiLog>();


	
	public static MultiLog getMultiLogNotime(String path,String loggerName,String loncontent) {

		if (multiLog.containsKey(loggerName)) {
			return multiLog.get(loggerName);
		}

		
		MultiLog multLog = new MultiLog();

		
		String [] logs = loncontent.split(",");
		for (String string : logs) {
			
			String []logdetail = loggerName.split(",");
			if(string.equals(logdetail[1])){
				
				Logger logger = getLoggerByNameNoTime(path,logdetail[0]);
				multLog.setLogger(logger);
			}
			
			multLog.setLoggerName(logdetail[0]);
			multiLog.put(loggerName, multLog);
		}
		

		return multLog;
	}
	
	public static Logger getLoggerByNameNoTime(String path, String name) {
		// 存在则返回现有
		Logger logger = Logger.getLogger(name);
		// 清空Appender。特別是不想使用現存实例时一定要初期化
		logger.removeAllAppenders();
		// 设定Logger级别。
		logger.setLevel(Level.DEBUG);
		// 默认为true。继承root輸出。
		// 设置false后将不输出root。
		logger.setAdditivity(false);
		// 生成新的Appender
		FileAppender appender = new RollingFileAppender();
		PatternLayout layout = new PatternLayout();
		// log的输出形式
		// String conversionPattern = "%m%n";
		String conversionPattern = "%d{yyyy-MM-dd HH:mm:ss SSS} %t  %-5p %c{1} %x - %m%n";
		conversionPattern = "%d{yyyy-MM-dd HH:mm:ss SSS} - %m%n";
//		layout.setConversionPattern(conversionPattern);
		appender.setLayout(layout);
		// log输出路径: zsmart_home 忠配置的"uploadFileDirectory"路径下
		// String logPath = PropertiesUtils.getString("logger.terminal.por");
		// appender.setFile("./log/position.log");
		appender.setFile( path + File.separator + name + ".log");
		// log的文字码
		appender.setEncoding("UTF-8");
		// true:在已存在log文件后面追加 false:新log覆盖以前的log
		appender.setAppend(true);
		// 使用当前配置
		appender.activateOptions();
		// 将新的Appender加到Logger中
		logger.addAppender(appender);
		return logger;
	}

}
