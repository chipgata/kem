
class OttSentJob < ApplicationJob
  queue_as :default
  self.queue_adapter = :resque

  def perform(endpoint, check_info)
    #slack(endpoint, check_info)
    ding_talk(endpoint, check_info)
  end

  def slack(endpoint, check_info)
    begin
      notifier = Slack::Notifier.new "https://hooks.slack.com/services/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" do
        defaults channel: "#random",
                username: "KEM_notifier"
      end

      a_ok_note = {
        pretext: "The endpoint " + endpoint.name + " was down",
        text: "",
        color: check_info['check_status']=='FAIL' ? "danger" : 'good',
        fields: [
            {
                "title" => "Host",
                "value" => "abc.xyz",
                "short" => false
            },
            {
              "title" => "Port",
              "value" => 8080,
              "short" => false
            },
            {
              "title" => "Last status",
              "value" => 'can not resolve host',
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
      DingBot.endpoint = 'https://oapi.dingtalk.com/robot/send'
      DingBot.access_token = 'eaec67742727896c52e3407d8425d483db2510d0ac30afba7d4d7c3f70c8be55'
      msg = "### The endpoint #{endpoint.name} was down\n > **Host**: [#{endpoint.check_protocol}://#{endpoint.path}](#{endpoint.check_protocol}://#{endpoint.path})\n\n > **Port**: #{endpoint.port}\n\n > **Status**: #{check_info['check_status']} \n\n > **Last response**: can not resolve host"
      DingBot.send_markdown("The endpoint #{endpoint.name} was down", msg)
    rescue => e
      puts e
    end
    
  end

  private :slack, :ding_talk

end
