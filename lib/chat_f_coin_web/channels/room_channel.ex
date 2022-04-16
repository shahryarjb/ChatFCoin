defmodule ChatFCoinWeb.RoomChannel do
  use Phoenix.Channel
  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:1", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    if body == "id" do
      broadcast!(socket, "new_msg", %{body: "this is specific user"})
    else
      broadcast!(socket, "new_msg", %{body: body})
    end
    {:noreply, socket}
  end
end

### FaceBook Token
# EAANIf4UhbEABAGOnEQmQgUaww2CZCD96q9Kp1frQPaiQaMntjpf6RaXmnJTZCxuxRqD7KGQznfVXWNffaazFRo61EwZBDILCRjVUJROZB2GDRseNCGIPvy7omv462visdG6ZCmTNIMPwZAahcrtf2I7i9DzwZAKbYZA3RtdnPQvTVZA3SJ4V8J0Bg

## Facebook Page id: 111373678212299

## FaceBook app id: 924137461738560

## FaceBook App secret: b0f177385b321248920ab74f27268814

## qFYY51KCGZt91zm7B8YrNUj1BcE=sT

### ws://mishka.group/chatbot/socket/websocket
