defmodule Melf.Apprentice do
  alias LangChain.Function
  alias LangChain.Message
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatAnthropic
  alias Melf.Spells
  alias Melf.Repo
  import Ecto.Query

  @system_template """
  You are a spellcaster's apprentice whose ONLY knowledge comes from the spellbook database.

  IMPORTANT RULES:
  1. You have NO prior knowledge about any spells, magic, or fantasy worlds
  2. If asked about a spell not in the database, say "That spell isn't in my spellbook"
  3. If asked about general magic knowledge, say "I only know what's in the spellbook"
  4. Never make up or infer details not present in the spell data

  When recommending spells by class:
  - Organize spells by level (cantrips first, then level 1, 2, etc.)
  - Highlight particularly useful or powerful spells
  """

  @chat_model ChatAnthropic.new!(%{
                model: "claude-3-5-sonnet-20241022",
                temperature: 0.2,
                stream: false
              })

  def start_conversation(message, context \\ %{}) do
    {:ok, chain} =
      %{llm: @chat_model, custom_context: context, verbose: false}
      |> LLMChain.new!()
      |> LLMChain.add_messages([
        Message.new_system!(@system_template),
        Message.new_user!(message)
      ])
      |> LLMChain.add_tools([custom_function()])
      |> LLMChain.run(mode: :while_needs_response)

    chain
  end

  def continue_conversation(chain, message) do
    {:ok, updated_chain} =
      chain
      |> LLMChain.add_messages([Message.new_user!(message)])
      |> LLMChain.run(mode: :while_needs_response)

    # Get the latest assistant message
    assistant_message = updated_chain.last_message.content
    put_content(updated_chain.last_message.content)

    updated_chain
  end

  defp put_content(str), do: [:blue_background, :black, str] |> IO.ANSI.format() |> IO.puts()

  defp custom_function do
    Function.new!(%{
      name: "get_spell",
      description: "Get JSON spell object by name.",
      function: fn %{"name" => name}, _context ->
        response =
          name
          |> Spells.get_spell!()
          |> Jason.encode!()

        {:ok, response}
      end
    })
  end
end
