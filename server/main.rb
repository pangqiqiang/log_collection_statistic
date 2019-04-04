#!/usr/bin/env ruby
#-*-coding:utf-8-*-
require 'sinatra'
require 'sinatra/json'
require './libs'

before do
    content_type :json
end


post '/upload' do
    data = JSON.parse(request.body.read)
    insert_into_api(data)
end

get '/get_by_host/:host/:year/:month/:day/:hour' do
    domain = ".ecloudsign.com"
    host = params[:host] 
    year = params[:year] 
    month = params[:month]
    day = params[:day]
    hour = params[:hour]
    host += domain
    data = get_from_api_host(host, year, month, day, hour)
    json data
end

get '/get_by_hour/:year/:month/:day/:hour' do
    year = params[:year] 
    month = params[:month]
    day = params[:day]
    hour = params[:hour]
    data = get_from_api_hour(year, month, day, hour)
    json data
end

get '/get_total_day/:year/:month/:day' do
    year = params[:year] 
    month = params[:month]
    day = params[:day]
    data = get_from_api_day_total(year, month, day)
    json data
end

get '/get_total_day_host/:host/:year/:month/:day' do
    domain = ".ecloudsign.com"
    host = params[:host] 
    year = params[:year] 
    month = params[:month]
    day = params[:day]
    host += domain
    data = get_from_api_host_total(host, year, month, day)
    json data
end

get '/*' do
    "Your router or request parameters is not correct"
end