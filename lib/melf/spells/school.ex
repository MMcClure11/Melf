defmodule Melf.Spells.School do
  use Melf.Schema

  schema "school" do
    field :index, :string
    field :name, :string
  end
end
