defmodule Melf.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
    end
  end
end
