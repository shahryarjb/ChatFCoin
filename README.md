# ChatFCoin

This is a training project to build chatbot for Facebook with elixir and phoenix. `Genserver`, `DynamicSupervisor`, `Protocol` are used, and this project shows you how you can implement [`mishka_installer`](https://github.com/mishka-group/mishka_installer) and make a project plugin-based.

> In this project, I tried to use at least ready library. For this reason, there is a lot of room for optimization in this project. Please see my CMS [MishkaCms an open source and real time API base CMS Powered by Elixir and Phoenix](https://github.com/mishka-group/mishka-cms)

---

## Quick View


https://user-images.githubusercontent.com/8413604/164182681-21d48b84-3c19-4758-8061-1bd34b194045.mp4



### Installation

It is a normal Phoenix project, and you can deploy it on your system, but I prepared a simple docker for you. If you want to install this project as a regular Phoenix project, I implemented a Makefile, but `export` these parameters as env.

#### Do not forget to put it into your OS variables

```elixir
FACEBOOK_CHAT_ACCSESS_TOKEN
FACEBOOK_CHAT_PAGE_ID
FACEBOOK_CHAT_APP_ID
FACEBOOK_CHAT_SECRET
DB_USERNAME
DB_PASSWORD
DB_HOSTNAME
DB_NAME
```

> how to config Facebook Messenger Bot: https://www.youtube.com/watch?v=5wPrfMxvrgo and the document: https://developers.facebook.com/docs/messenger-platform/getting-started


#### Testing

It should be noted that if you have custom settings for your database, please create this `DATABASE_URL` OS variable and put your config into it. For example, we configured it for two different conditions, the first one is for local testing that you do not need to set anything, and it loads it like this: `ecto://postgres:postgres@localhost/chat_f_coin_test`, and the other is for GitHub CI and we config it like this: `postgresql://postgres:postgres@localhost:${{job.services.postgres.ports[5432]}}/chat_f_coin_test` it depends on your situation.

