#!/usr/bin/env ruby
#-*-coding:utf-8-*-

require './mongo_handler'
require './config'
require 'sinatra'

host = settings.mongo_host
db_config = settings.db_config
API_DB = MongoDB.new("api", host, db_config)

def insert_into_api(doc)
    API_DB.insert(doc)
end


def get_from_api_host(host, year, month, day, hour)
    year,month, day, hour = [year, month, day, hour].map(&:to_i)
    API_DB.get_by_host(host, year, month, day, hour)
end

def get_from_api_hour(year, month, day, hour)
    year,month, day, hour = [year, month, day, hour].map(&:to_i)
    API_DB.get_by_hour(year, month, day, hour)
end

def get_from_api_day_total(year, month, day)
    year,month, day = [year, month, day].map(&:to_i)
    API_DB.get_by_date_total(year, month, day)
end


def get_from_api_host_total(host, year, month, day)
    year,month, day = [year, month, day].map(&:to_i)
    API_DB.get_by_host_total(host, year, month, day)
end