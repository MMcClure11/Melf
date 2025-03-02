defmodule Melf.General.Damage do
  use Melf.Schema

  schema "damage" do
    embeds_one :damage_type, Melf.General.DamageType do
      field :index, :string
      field :name, :string
    end

    embeds_one :damage_at_character_level, Melf.General.DamageAtCharacterLevel do
      field :"1", :string
      field :"5", :string
    end
  end
end
