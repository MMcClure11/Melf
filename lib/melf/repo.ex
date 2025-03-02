defmodule Melf.Repo do
  use Ecto.Repo,
    otp_app: :melf,
    adapter: Mongo.Ecto
end
