defmodule Melf.Spells do
  alias __MODULE__.Spell
  alias Melf.Repo

  def get_spell!(index), do: Repo.get_by!(Spell, index: index)
end
