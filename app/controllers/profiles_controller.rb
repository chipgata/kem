class ProfilesController < ApplicationController

    def index
        if !current_user.profile
          Profile.create(:first_name => '', :last_name => '', :avatar => '', :user_id => current_user.id)
        end
        @profile = current_user.profile
    end
    
    def create
        @profile = current_user.profile
      
        respond_to do |format|
          if @profile.save(profile_params)
            format.html { redirect_to @profile, notice: 'Profile was
    successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "index" }
            format.json { render json: @profile.errors, status:
    :unprocessable_entity }
          end
        end
    end

    def update
      @profile = current_user.profile

      if profile_params[:picture]
        uploaded_io = profile_params[:picture]
        File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
          file.write(uploaded_io.read)
        end
        @profile.avatar = "/uploads/#{uploaded_io.original_filename}"
      end
      
      @profile.first_name = profile_params[:first_name]
      @profile.last_name = profile_params[:last_name]
      if @profile.save
        redirect_to profiles_path
      else
        render 'index'
      end
    end

    private
    def profile_params
        params.require(:profile).permit(:first_name, :last_name, :picture)
    end
    
end
