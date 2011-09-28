#:nodoc:
module Users
  #:nodoc:
  module Controller
    ##
    # Controller for managing users.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    class Users < Zen::Controller::AdminController
      helper :users, :layout
      map    '/admin/users'

      before_all do
        csrf_protection(:save, :delete) do
          respond(lang('zen_general.errors.csrf'), 403)
        end
      end

      serve(:javascript, ['/admin/js/users/permissions'], :minify => false)
      serve(:css, ['/admin/css/users/permissions.css'], :minify => false)

      load_asset_group(:tabs)

      set_layout :admin => [:index, :edit, :new]
      set_layout :login => [:login]

      ##
      # Creates a new instance of the controller.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def initialize
        super

        @page_title  = lang("users.titles.#{action.method}") rescue nil
        @status_hash = {
          'open'   => lang('users.special.status_hash.open'),
          'closed' => lang('users.special.status_hash.closed')
        }
      end

      ##
      # Show an overview of all users and allow the current user
      # to manage these users.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def index
        authorize_user!(:show_user)

        set_breadcrumbs(lang('users.titles.index'))

        @users = paginate(::Users::Model::User)
      end

      ##
      # Edit an existing user based on the ID.
      #
      # @author Yorick Peterse
      # @param  [Fixnum] id The ID of the user to edit.
      # @since  0.1
      #
      def edit(id)
        authorize_user!(:edit_user)

        set_breadcrumbs(
          Users.a(lang('users.titles.index'), :index),
          lang('users.titles.edit')
        )

        if flash[:form_data]
          @user = flash[:form_data]
        else
          @user = validate_user(id)
        end

        @user_group_pks = ::Users::Model::UserGroup.pk_hash(:name).invert
        @permissions    = @user.permissions.map { |p| p.permission.to_sym }

        render_view(:form)
      end

      ##
      # Create a new user.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def new
        authorize_user!(:new_user)

        set_breadcrumbs(
          Users.a(lang('users.titles.index'), :index),
          lang('users.titles.new')
        )

        @user           = ::Users::Model::User.new
        @user_group_pks = ::Users::Model::UserGroup.pk_hash(:name).invert

        render_view(:form)
      end

      ##
      # Show a form that allows a user to log in.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def login
        if request.post?
          # Let's see if we can authenticate
          if user_login(request.subset(:email, :password))
            # Update the last time the user logged in
            ::Users::Model::User[:email => request.params['email']].update(
              :last_login => Time.new
            )

            message(:success, lang('users.success.login'))
            redirect(::Sections::Controller::Sections.r(:index))
          else
            message(:error, lang('users.errors.login'))
          end
        end
      end

      ##
      # Logout and destroy the user's session.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def logout
        user_logout
        session.clear

        message(:success, lang('users.success.logout'))
        redirect(Users.r(:login))
      end

      ##
      # Saves or creates a new user based on the POST data.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def save
        post = request.subset(
          :id,
          :email,
          :name,
          :website,
          :password,
          :confirm_password,
          :status,
          :language,
          :frontend_language,
          :date_format,
          :user_group_pks
        )

        if post['id'] and !post['id'].empty?
          authorize_user!(:edit_user)

          user        = validate_user(post['id'])
          save_action = :save
          hook_name   = :edit_user
        else
          authorize_user!(:new_user)

          user        = ::Users::Model::User.new
          save_action = :new
          hook_name   = :new_user
        end

        if post['password'] != post['confirm_password']
          message(:error, lang('users.errors.no_password_match'))
          redirect_referrer
        end

        post.delete('confirm_password')
        post.delete('id')

        post['user_group_pks'] ||= []
        flash_success            = lang("users.success.#{save_action}")
        flash_error              = lang("users.errors.#{save_action}")

        begin
          user.update(post)
          message(:success, flash_success)

          user.user_group_pks = post['user_group_pks'] if save_action === :new
        rescue => e
          Ramaze::Log.error(e.inspect)
          message(:error, flash_error)

          flash[:form_data]   = user
          flash[:form_errors] = user.errors

          redirect_referrer
        end

        # Add or update the permissions if the user is allowed to do so.
        if user_authorized?(:edit_permission)
          update_permissions(
            :user_id,
            user.id,
            request.params['permissions'] || [],
            user.permissions.map { |p| p.permission }
          )
        end

        Zen::Event.call(hook_name, user)

        if user.id
          redirect(Users.r(:edit, user.id))
        else
          redirect_referrer
        end
      end

      ##
      # Delete all specified users.
      #
      # @author Yorick Peterse
      # @since  0.1
      #
      def delete
        authorize_user!(:delete_user)

        if !request.params['user_ids'] or request.params['user_ids'].empty?
          message(:error, lang('users.errors.no_delete'))
          redirect_referrer
        end

        request.params['user_ids'].each do |id|
          begin
            u                = ::Users::Model::User[id]
            u.user_group_pks = []

            u.destroy
            message(:success, lang('users.success.delete'))
          rescue => e
            Ramaze::Log.error(e.inspect)
            message(:error, lang('users.errors.delete') % id)

            redirect_referrer
          end
        end

        redirect_referrer
      end
    end # Users
  end # Controller
end # Users
