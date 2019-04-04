#!/usr/bin/env ruby
#-*-coding:utf-8-*-

require 'mongo'

class MongoDB
    def initialize(collection, host, config)
        Mongo::Logger.level = Logger::INFO
        begin 
            client = Mongo::Client.new(host, config)
            @collection = client[collection]
        rescue => e
            puts e.message
        end
    end

    def insert(doc)
        @collection.insert_one(doc)
    end

    #单服务器按小时
    def get_by_host(host, year, month, day, hour)
        date = sprintf("%d-%02d-%02d", year, month, day)
        hour = sprintf("%02d", hour)
        @collection.find({host: host, date: date, hour: hour},
            {'projection': {"_id": 0}}).first
    end
    
    #总和按小时
    def get_by_hour(year, month, day, hour)
        date = sprintf("%d-%02d-%02d", year, month, day)
        hour = sprintf("%02d", hour)
        data = @collection.find({date: date, hour: hour})
        return if data == nil
        merge_hash = data.inject({total: 0, interface: Hash.new(0)}) do |result, element|
            result[:total] += element[:total]
            result[:interface].merge!(element[:interface]) do |key, v1, v2|
                v1 + v2
            end  
            result
        end
        merge_hash[:date] = sprintf("%d-%02d-%02d", year, month, day)
        merge_hash[:hour] = hour
        return merge_hash
    end

    #总按天统计
    def get_by_date_total(year, month, day)
        date = sprintf("%d-%02d-%02d", year, month, day)
        data = @collection.find({date: date})
        return if data == nil
        merge_hash = data.inject({total:0, interface:Hash.new(0)}) do |result, element|
            result[:total] += element[:total]
            result[:interface].merge!(element[:interface]) do |key, v1, v2|
                v1 + v2
            end
            result
        end
        merge_hash[:date] = sprintf("%d-%02d-%02d", year, month, day)
        return merge_hash
    end

    #单服务器按天
    def get_by_host_total(host, year, month, day)
        date = sprintf("%d-%02d-%02d", year, month, day)
        data = @collection.find({date: date, host: host})
        return if data == nil
        merge_hash = data.inject({total:0, interface:Hash.new(0)}) do |result, element|
            result[:total] += element[:total]
            result[:interface].merge!(element[:interface]) do |key, v1, v2|
                v1 + v2
            end
            result
        end
        merge_hash[:date] = sprintf("%d-%02d-%02d", year, month, day)
        return merge_hash
    end
end
