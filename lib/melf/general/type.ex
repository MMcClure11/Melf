defmodule Melf.General.Type do
  use Melf.Schema

  schema "type" do
    field :index, :string
    field :name, :string
  end
end
