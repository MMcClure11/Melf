defmodule Melf.Spells.Spell do
  use Melf.Schema

  alias Melf.Spells.{School}
  alias Melf.General.{Class, Damage, DifficultyClass, SubClass}

  schema "spells" do
    field :index, :string
    field :name, :string
    field :description, {:array, :string}
    field :range, :string
    field :components, {:array, :string}
    field :ritual, :boolean
    field :duration, :string
    field :concentration, :boolean
    field :level, :integer
    field :casting_time, :string

    embeds_one :damage, Damage
    embeds_one :dc, DifficultyClass
    embeds_one :school, School
    embeds_many :classes, Class
    embeds_many :sub_classes, SubClass
  end
end
