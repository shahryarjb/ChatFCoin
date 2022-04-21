install_docker:
	cd developer; docker-compose up -d;

install_elixir:
	mix deps.get
	mix deps.compile
	mix ecto.create
	mix ecto.migrate || true
	mix assets.deploy || true
	iex -S mix phx.server