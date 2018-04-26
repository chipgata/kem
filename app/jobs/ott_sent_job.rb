
class OttSentJob < ApplicationJob
  queue_as :default
  self.queue_adapter = :resque

  def perform(endpoint, check_info)
    slack(endpoint, check_info)
    ding_talk(endpoint, check_info)
  end

  def slack(endpoint, check_info)
    begin
      config = get_slack_config(endpoint)
      notifier = Slack::Notifier.new config['hook'] do
        defaults channel: config['channel'],
                username: config['username']
      end

      a_ok_note = {
        pretext: "The endpoint #{endpoint.name} was #{check_info['check_status']=='OK' ? 'up' : 'down'}",
        text: "",
        color: check_info['check_status']=='FAIL' ? "danger" : 'good',
        fields: [
            {
                "title" => "Host",
                "value" => "#{endpoint.path}",
                "short" => false
            },
            {
              "title" => "Port",
              "value" => "#{endpoint.port}",
              "short" => false
            },
            {
              "title" => "Last status",
              "value" => "#{check_info['last_msg']}",
              "short" => false
            }
          ],
      }
      
      notifier.post attachments: [a_ok_note]
    rescue => e
      puts e
    end
  end

  def ding_talk(endpoint, check_info)
    begin
      config = get_dingtalk_config(endpoint)
      DingBot.endpoint = config['endpoint']
      DingBot.access_token = config['access_token']
      msg = "### The endpoint #{endpoint.name} was down\n > **Host**: [#{endpoint.check_protocol}://#{endpoint.path}](#{endpoint.check_protocol}://#{endpoint.path})\n\n > **Port**: #{endpoint.port}\n\n > **Status**: #{check_info['check_status']} \n\n > **Last response**: #{check_info['last_msg']}"
      DingBot.send_markdown("The endpoint #{endpoint.name} was " + check_info['check_status']=='OK' ? "up" : 'down', msg)
    rescue => e
      puts e
    end
    
  end

  def get_slack_config(endpoint)
    slack_settings = endpoint.creater.settings.where(name: 'slack').first
    slack_settings.value
  end

  def get_dingtalk_config(endpoint)
    ding_settings = endpoint.creater.settings.where(name: 'ding').first
    ding_settings.value
  end

  private :slack, :ding_talk, :get_dingtalk_config, :get_slack_config

end
