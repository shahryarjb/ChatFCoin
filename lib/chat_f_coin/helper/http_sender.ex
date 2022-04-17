defmodule ChatFCoin.Helper.HttpSender do
  @url "https://graph.facebook.com/v2.6/me/messages"
  @request_name MyHttpClient

  @spec send_message(any, binary | URI.t()) :: {:error, Exception.t} | {:ok, Finch.Response.t()}
  def send_message(body, url \\ @url) do
    access_token = ChatFCoin.get_config(:facebook_chat_accsess_token)

    headers = [
      {"Content-type", "application/json"},
      {"Accept", "application/json"}
    ]

    Finch.build(:post, url <> "?access_token=#{access_token}", headers, body |> Jason.encode!())
    |> Finch.request(@request_name)
  end

  @spec message_body(:shor, integer(), String.t()) :: %{message: %{text: any}, recipient: %{id: any}}
  def message_body(:shor, psid, message), do: %{recipient: %{id: psid}, message: %{text: message}}

  # Ref: https://developers.facebook.com/docs/graph-api/reference/v2.6/user
  # curl -X GET -G \
  # -d 'access_token=<ACCESS_TOKEN>' \
  # https://graph.facebook.com/v13.0/{person-id}/

  @spec get_user_info(integer(), String.t()) :: {:error, Exception.t} | {:ok, Finch.Response.t()}
  def get_user_info(person_id, access_token \\ ChatFCoin.get_config(:facebook_chat_accsess_token)) do
    url = "https://graph.facebook.com/v13.0/#{person_id}?access_token=#{access_token}"
    Finch.build(:get, url)
    |> Finch.request(@request_name)
    |> handle_user_info
  end

  defp handle_user_info({:ok, %{body: body, headers: _headers, status: 200}}), do: Jason.decode!(body)
  # I should pass nil or error as atom, but the message can be sent with Dear client and make him/her smile With our respect
  defp handle_user_info(_), do: %{"first_name" => "Dear client", "last_name" => "", "profile_pic" => "", "id" => ""}
end

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
