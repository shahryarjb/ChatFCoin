  # @facebook_url "https://graph.facebook.com/v2.6/me/messages"
  # def send_message(psid, message) do
  #   url = "#{@facebook_url}?access_token=#{ChatFCoin.get_config(:facebook_chat_accsess_token)}"
  #   body = %{recipient: %{id: psid}, message: %{text: message}}
  #   headers = [{"Content-type", "application/json"}]
  #   HTTPoison.post(url, Poison.encode!(body), headers)
  # end


  # def send_card(psid, entry) do
  #   url = "#{@facebook_url}?access_token=#{Application.get_env(:rent_bot_web, RentBotWeb.BotController)[:facebook_messenger_access_token]}"
  #   body = %{
  #     recipient: %{id: psid},
  #     message: %{
  #       attachment: %{
  #         type: "template",
  #         payload: %{
  #           template_type: "generic",
  #           elements: [
  #             %{
  #               title: entry.title,
  #               image_url: entry.image,
  #               subtitle: entry.price,
  #               default_action: %{
  #                 type: "web_url",
  #                 url: entry.url,
  #                 messenger_extensions: false,
  #                 webview_height_ratio: "full"
  #               }
  #             }
  #           ]
  #         }
  #       }
  #     }
  #   }
  #   headers = [{"Content-type", "application/json"}]
  #   HTTPoison.post(url, Poison.encode!(body), headers)
  # end
