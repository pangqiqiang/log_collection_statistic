#!/usr/bin/env ruby
#-*-encoding:utf-8-*-
require 'net/http'
require 'json'
require 'rest-client'
require 'uri'

LOG_DIR = "/data/httplogs/api" #nginx日志存放目录
IGNORE_LINE = %r'$A127.0.0.1'  #排除本地监控调用
CURRENT_DIR = File.dirname(File.expand_path(__FILE__))
SINCE_FILE = File.join(CURRENT_DIR, "since.txt")   #存储上次读取位置
LOG_PATH = File.join(CURRENT_DIR, "info.log")      #本程序记录日志路径
REMOTE_URL = "db03.ecloudsign.com:4567/upload"
API_FILTER = ["/ecs/account/applyCert_jspa", "/ecs/signInfo/createSeal_jspa", "/ecs/signApiPage/signPage_jspa",
    "/ecs/signInfo/createSign_jspa", "/ecs/template/addHtmlTemplate_jspa", "/ecs/template/createContractByTemplate_jspa",
    "/ecs/contract/getContractDetail_jspa", "/ecs/contract/autoSign_jspa", "/ecs/contract/downloadContract_jspa",
    "/ecs/contract/launchContractAutoSignAndSendSms_jspa"]


#得到需要分析的日志文件
def get_origin_logfile
    today = (Time.now-3600).strftime("%Y-%m-%d")  #统计的是一小时前的数据,防止最后一个小时数据丢失
    Dir.glob("#{LOG_DIR}/*.#{today}.log")[0]      #此处未做循环数组处理,日志应该按天切割
end

def deal_each_line(filename)
    total_requests = 0
    interface_requests = Hash.new(0)
    now_hour = Time.now.hour
    flag = true            #用于标记一小时以内
    last_lineno = get_last_lineno
    open(filename) do |file|
        file.each_line do |line|
            next if file.lineno <= last_lineno.to_i       #跳过之前的行
            next if  Regexp.new(IGNORE_LINE) =~ line  #跳过本地监控调用
            ip, time, method, path = analyse_log_info(line)
            break if time.split(':')[1].to_i >= now_hour.to_i  #如果超过当前小时则停止统计
            total_requests += 1
            next unless API_FILTER.include?(path)        #过滤路径
            interface_requests[path] +=1
        end
        store_curr_lineno(file.lineno)
    end
    log_time = Time.now - 60 * 60    #记录统计的十几件
    hostname = ENV["HOSTNAME"]
    data = {host: hostname, date: log_time.strftime("%Y-%m-%d"),
            hour: log_time.strftime("%H"), total: total_requests, interface: interface_requests}
    post_static_data(REMOTE_URL, data.to_json, get_last_lineno)
end

#从文件中得到上次读取到行数
def get_last_lineno
    today = Time.now.strftime("%Y-%m-%d")
    lineno = 0
    read_date = ""
    open(SINCE_FILE) do |file|
        read_date, lineno = file.read.chomp.split
    end
    lineno = 0 if read_date != today
    return lineno
end

#保存操作结束后的文件行数
def store_curr_lineno(lineno)
    file_date = (Time.now-3600).strftime("%Y-%m-%d")
    open(SINCE_FILE, 'w') do |fobj|
        fobj << file_date << "\t" + lineno.to_s
    end
end

#将统计结果post给服务器存为数据库
def post_static_data(url, data, lineno)
    response = RestClient.post(url, data)
    if response.code == 200
        log_info(sprintf("info: success last static lineno is:%d", lineno))
    else
        log_info(response.body)
    end
end


def analyse_log_info(line)
    data_arr = line.split
    ip, time, method, path = data_arr.values_at(0, 3, 5, 6)
    time = time[1..time.size]
    method = method[1..method.size]
    path = URI.parse(path).path.gsub(/\./, '_') #去除query参数,注意mongo的key不支持"."和"$"
    return ip, time, method, path
end

def log_info(msg)
    open(LOG_PATH, 'w') do |fobj|
        fobj.write(msg)
    end
end 

def main()
    filename = get_origin_logfile
    deal_each_line(filename)
end  

if __FILE__ == $0
  main()
end
