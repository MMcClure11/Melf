defmodule Melf.General.SubClass do
  use Melf.Schema

  schema "sub_class" do
    field :index, :string
    field :name, :string
  end
end
