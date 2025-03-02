defmodule Melf.General.Class do
  use Melf.Schema

  schema "class" do
    field :index, :string
    field :name, :string
  end
end
