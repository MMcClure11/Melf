defmodule Melf.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @derive {Jason.Encoder, except: [:__meta__]}
    end
  end
end
