defmodule Melf.General.DifficultyClass do
  use Melf.Schema

  schema "difficulty_class" do
    field :success, :string, source: :dc_success

    embeds_one :dc_type, Melf.General.Type
  end
end
