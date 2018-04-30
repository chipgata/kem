class SettingsController < ApplicationController
    def index
        @slack = Setting.where(name: 'slack').take
        @ding = Setting.where(name: 'ding').take
        @setting = Setting.new
    end

    def new
        @setting = Setting.new
    end

    def edit
        @setting = Setting.find(params[:id])
    end

    def create
        @setting = Setting.create_with(setting_params).find_or_create_by(name: setting_params['name'])
        @setting.value = setting_params['value']

        if @setting.save
            redirect_to settings_path
        else
            render 'new'
        end
    end

    def update
        @setting = Setting.find(params[:id])
       
        if @setting.update(setting_params)
          redirect_to settings_path
        else
          render 'edit'
        end
    end

    def show
        @setting = Setting.find(params[:id])
    end


    def destroy
        @setting = Setting.find(params[:id])
        @setting.destroy
   
        redirect_to settings_path
    end

    private
    def setting_params
        value_params = (params[:setting] || {})[:value].keys
        params.require(:setting).permit(:name, value: value_params)
    end
end
