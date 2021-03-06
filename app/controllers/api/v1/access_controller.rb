class Api::V1::AccessController < Api::V1::ApplicationController
  represents :json, entity: AuthObjectRepresenter,
                    collection: AuthObjectCollectionRepresenter

  swagger_controller :access, 'Manage and share auth_objects with other users.'

  swagger_api :show do
    summary 'Returns auth object if requested url is valid.'
    notes ''
    response :ok, 'Success', :AuthObjectRepresenter
    response :not_found, 'Url you requested was not found (i.e. not valid), or api_key wasn\'t valid'
  end

  swagger_api :create do
    summary 'Creates n number of objects where n is number of emails in \'to\''
    notes ''
    response :ok, 'Success', :AuthObjectCollectionRepresenter
    response :not_found, 'Either api_key, email, content_id, content_type or to isn\'t valid'
    response :not_acceptable, 'Could not create auth_objects, most likely provided emails and permissions are not valid'
  end

  def show
    @application = Application.find_by_api_key(params[:api_key])
    @auth_object = AuthObject.find_by_token(params[:id])

    if @application && @auth_object
      render json: @auth_object
    else
      render_error :not_found
    end
  end

  def create
    prerequisites
    @application && @user && @auth_object ? save_auth_objects_and_send_response : (render_error :not_found)
  end

  private

  def save_auth_objects_and_send_response
    @auth_objects = store_auth_objects(params[:to])
    if @auth_objects
      SendAccessEmailJob.perform_later(@auth_objects)
      render json: @auth_objects
    else
      render_error :not_acceptable
    end
  end

  def prerequisites
    @application = Application.find_by_api_key(params[:api_key])
    @user = User.find_by_email(params[:email])
    @auth_object = AuthObject.where(find_auth_object_params).first
  end

  def store_auth_objects(to)
    flag = true
    auth_objects ||= []
    AuthObject.transaction do
      to.each do |key_email, val_perm|
        user = find_or_create_new_user(key_email)
        auth_object = AuthObject.new(create_auth_object_params(user, val_perm))
        flag &&= auth_object.save
        auth_objects.push(auth_object)
      end
    end
    flag ? auth_objects : flag
  end

  def find_auth_object_params
    { content_id: params[:content_id],
      content_type: params[:content_type],
      application_id: @application.id,
      user_token: @user.token }
  end

  def create_auth_object_params(user, permission)
    { content_type: params[:content_type],
      content_id: params[:content_id],
      user_token: user.token,
      permissions: permission.strip,
      application_id: @application.id,
      token: SecureRandom.uuid }
  end

  def find_or_create_new_user(email)
    user = User.find_by_email(email)
    user ? user : User.create(email: email, token: SecureRandom.uuid)
  end
end
