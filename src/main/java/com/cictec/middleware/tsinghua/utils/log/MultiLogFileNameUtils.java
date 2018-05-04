package com.cictec.middleware.tsinghua.utils.log;

import com.cictec.middleware.tsinghua.utils.DateUtils;

import java.io.File;

/**
 * 日志多文件输出文件名 辅助类
 * @author Administrator
 *
 */
public class MultiLogFileNameUtils {


	/**
	 * 进出站
	 * @param terminalId
	 * @return
	 */
	public static String getPositionEnterOutLogName(String lineName, String terminalId, String date){

		String logPath = "positionEnterOut" +File.separator + date + File.separator + terminalId+"-enterout";
		logPath += ",enterout";
		return logPath;
	}
	/**
	 * 位置信息判定过程 存储路径、日志文件名
	 * @return
	 */
	public static String getPositionJudgeLogName(String lineName, String busNumber){
		String cdate = DateUtils.getDate();
		String logPath = "positionJudge" + File.separator + cdate + File.separator + busNumber+"-judge";
		logPath += ",positionJudge";
		
		return logPath;
	}
	
	/**
	 * 位置信息，进出站 数据存储路径、日志文件名
	 * @param lineName
	 * @param busNumber
	 * @return
	 */
	public static String getPositionLogName(String lineName, String busNumber, String date){
		String logPath = "positionData" + File.separator + date + File.separator + busNumber+ "-position";
		logPath += ",positin";
		return logPath;
	}
	
	/**
	 * 获取终端指令 存储路径、日志文件名
	 * @return
	 */
	public static String getInstructionsLogName(String terminalId){
		String cdate = DateUtils.getDate();
		String logPath = "terminalInstruct" + File.separator + cdate + File.separator + terminalId+ "-instruct";
		logPath += ",terminalInstruct";
		
		return logPath;
	}
	/**
	 * mq推送数据日志 存储路径、日志文件名
	 * @return
	 */
	public static String getMqLogName(String busNumber){
		String cdate = DateUtils.getDate();
		String logPath = "mq" + File.separator + cdate + File.separator + busNumber+ "-mq";
		logPath += ",activemq";
		
		return logPath;
	}
	/**
	 * apollo推送数据日志  存储路径、日志文件名
	 * @return
	 */
	public static String getApolloLogName(String busNumber){
		String cdate = DateUtils.getDate();
		String logPath = "apollo"+ File.separator + cdate + File.separator + busNumber+ "-apollo";
		logPath += ",apollo";
		
		return logPath;
	}
	
	/**
	 * 里程计算
	 * @param busNumber
	 * @return
	 */
	public static String getBusMileageLogName(String date, String busNumber){
		String logPath = "busMileage"+ File.separator + date + "/" + busNumber+"-caculate";
		logPath += ",mileageCaculate";
		
		return logPath;
	}

	/**
	 * 原始数据
	 * @param date
	 * @param terminalId
	 * @return
	 */
	public static String getBinaryLogName(String date, String terminalId){
		String logPath = "binaryLog"+ File.separator + date + File.separator + terminalId+"-binaryLog";
		logPath += ",binaryLog";
		
		return logPath;
	}


}
