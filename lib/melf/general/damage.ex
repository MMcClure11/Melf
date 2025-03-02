defmodule Melf.General.Damage do
  use Melf.Schema

  defmodule DamageAtCharacterLevel do
    use Melf.Schema

    schema "damage_at_character_level" do
      field :"1", :string
      field :"5", :string
      field :"11", :string
      field :"17", :string
    end
  end

  schema "damage" do
    embeds_one :damage_type, Melf.General.Type
    embeds_one :damage_at_character_level, DamageAtCharacterLevel
  end
end
