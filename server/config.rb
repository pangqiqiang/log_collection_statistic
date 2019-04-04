require "sinatra"
#配置信息
configure do
    set :bind, '0.0.0.0'
    set :port, 4567
    #工程部署脚本目录
    set :mongo_host, ['127.0.0.1:27017']
    set :db_config, {
        database: 'nginx_logs',
        connect_timeout: 3,
        max_idle_time: 1800,
        max_pool_size: 30,
        max_read_retries: 5,
        min_pool_size: 3
    }
end
