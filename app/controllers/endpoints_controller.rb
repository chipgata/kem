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

    private
    def endpoint_params
        params.require(:endpoint).permit(
            :category_id,
            :name, 
            :description,
            :port,
            :path,
            :status,
            :check_protocol,
            :response_timeout,
            :check_interval,
            :unhealthy_threshold,
            :healthy_threshold
        )
    end
end
