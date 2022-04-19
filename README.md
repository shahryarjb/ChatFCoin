# ChatFCoin

This is a training project to build chatbot for Facebook with elixir and phoenix. `Genserver`, `DynamicSupervisor`, `Protocol` are used, and this project shows you how you can implement `mishka_installer` and make a project plugin-based.

> In this project, I tried to use at least ready library. For this reason, there is a lot of room for optimization for this project.

---

## Quick View


https://user-images.githubusercontent.com/8413604/163977114-e0ce62e6-5ca7-4926-9218-cedcdc02487c.mp4



### Installation

It is a normal Phoenix project, and you can deploy on your system, but I prepared a simple docker for you.

#### Do not forget to put it into your OS variables

* FACEBOOK_CHAT_ACCSESS_TOKEN
* FACEBOOK_CHAT_PAGE_ID
* FACEBOOK_CHAT_APP_ID
* FACEBOOK_CHAT_SECRET
* DB_USERNAME
* DB_PASSWORD
* DB_HOSTNAME
* DB_NAME

> how to config Facebook Messenger Bot: https://www.youtube.com/watch?v=5wPrfMxvrgo and the document: https://developers.facebook.com/docs/messenger-platform/getting-started
