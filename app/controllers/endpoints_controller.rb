require 'timeout'
require 'socket'

class EndpointsController < ApplicationController
    def index
        @endpoints = Endpoint.all
    end

    def new
        @endpoint = Endpoint.new
    end

    def edit
        @endpoint = Endpoint.find(params[:id])
    end

    def create
        @endpoint = Endpoint.new(endpoint_params) 
        if @endpoint.save
            #event = Endpointed.new(data: @endpoint)
            #Rails.configuration.event_store.publish_event(event)
            #ActionCable.server.broadcast 'endpoint_check', data: @endpoint

            @check_info = CheckInfo.new
            @check_info.endpoint_id = @endpoint.id
            @check_info.unhealthy_count = 0
            @check_info.healthy_count = 0

            @check_info.save
            redirect_to @endpoint
        else
            render 'new'
        end
    end

    def update
        @endpoint = Endpoint.find(params[:id])
       
        if @endpoint.update(endpoint_params)
          redirect_to @endpoint
        else
          render 'edit'
        end
    end

    def show
        @endpoint = Endpoint.find(params[:id])
    end


    def destroy
        @endpoint = Endpoint.find(params[:id])
        @endpoint.destroy
        redirect_to endpoints_path
    end

    def ping
        @endpoint = Endpoint.find(params[:id])
        resp = {'code' => 0, 'msg' => 'check fail', 'data' => @endpoint}
        begin
            Timeout.timeout(@endpoint.response_timeout) do 
                s = TCPSocket.new(@endpoint.path, @endpoint.port)
                s.close 
                resp['code'] = 1
                resp['msg'] = 'check ok'
            end

            rescue Errno::ECONNREFUSED => e
                print e
                resp['code'] = 1
                resp['msg'] = 'check ok'
            rescue  => e
                print e
        end

        render json: resp
    end

    private
    def endpoint_params
        params.require(:endpoint).permit(
            :category_id,
            :name, 
            :description,
            :port,
            :path,
            :status,
            :check_status,
            :check_protocol,
            :response_timeout,
            :check_interval,
            :unhealthy_threshold,
            :healthy_threshold
        )
    end
end
