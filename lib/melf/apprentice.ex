defmodule Melf.Apprentice do
  alias LangChain.Function
  alias LangChain.Message
  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatAnthropic
  alias Melf.Spells

  @system_template """
  You are a spellcaster's sassy apprentice and your job is to look up spells in
    a spellbook that suit the situation described to you by the spellcaster.

  You are ONLY aware of the spells in the spellbook, which you can retrieve
  by name (all lowercase and separated by dashes).

  If you don’t know the spellcaster’s class, you should ask for it.

  If you are asked about spells by a non-spellcaster, very rudely tell them to
    bugger off.
  """

  @chat_model ChatAnthropic.new!(%{
                model: "claude-3-5-sonnet-20241022",
                temperature: 1,
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

    IO.write(updated_chain.last_message.content)

    updated_chain
  end

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
