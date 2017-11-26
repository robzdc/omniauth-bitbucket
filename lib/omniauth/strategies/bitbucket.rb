require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Bitbucket < OmniAuth::Strategies::OAuth2
      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site => 'https://bitbucket.org',
        :authorize_url     => 'https://bitbucket.org/site/oauth2/authorize',
        :token_url  => 'https://bitbucket.org/site/oauth2/access_token'
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['username'] }

      info do
        {
          :name => "#{raw_info['first_name']} #{raw_info['last_name']}",
          :avatar => raw_info['avatar'],
          :email => raw_info['email']
        }
      end

      def raw_info
        @raw_info ||= begin
                        ri = MultiJson.decode(access_token.get('/api/1.0/user').body)['user']
                        emails = MultiJson.decode(access_token.get('/api/1.0/emails').body)
                        email_hash = emails.find { |email| email['primary'] } || emails.first || {}
                        ri.merge('email' => email_hash['email'])
                      end
      end

      private

      def callback_url
        options.redirect_url || (full_host + script_name + callback_path)
      end
    end
  end
end
