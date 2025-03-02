defmodule MelfWeb.SpellsLive do
  use MelfWeb, :live_view
  alias Melf.Apprentice

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:messages, [])
     |> assign(:user_input, "")
     |> assign(:loading, false)
     |> assign(:conversation, nil)}
  end

  def handle_event("submit", %{"user_input" => user_input}, socket) do
    if String.trim(user_input) == "" do
      {:noreply, socket}
    else
      # Add user message to the conversation
      updated_messages = socket.assigns.messages ++ [%{role: "user", content: user_input}]

      # Start processing in a separate task to keep UI responsive
      send(self(), {:process_message, user_input})

      {:noreply,
       socket
       |> assign(:messages, updated_messages)
       |> assign(:user_input, "")
       |> assign(:loading, true)}
    end
  end

  def handle_info({:process_message, message}, %{assigns: %{conversation: nil}} = socket) do
    # First message - start a new conversation
    conversation = Apprentice.start_conversation(message)
    assistant_message = %{role: "assistant", content: conversation.last_message.content}
    updated_messages = socket.assigns.messages ++ [assistant_message]

    {:noreply,
     socket
     |> assign(:messages, updated_messages)
     |> assign(:loading, false)
     |> assign(:conversation, conversation)}
  end

  def handle_info({:process_message, message}, socket) do
    # Continue existing conversation
    updated_conversation = Apprentice.continue_conversation(socket.assigns.conversation, message)
    assistant_message = %{role: "assistant", content: updated_conversation.last_message.content}
    updated_messages = socket.assigns.messages ++ [assistant_message]

    {:noreply,
     socket
     |> assign(:messages, updated_messages)
     |> assign(:loading, false)
     |> assign(:conversation, updated_conversation)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-4">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold text-purple-800">Spellcaster's Apprentice</h1>
      </div>

      <div class="bg-gray-100 rounded-lg p-4 h-[500px] overflow-y-auto mb-4 border border-gray-300">
        <div id="message-container" phx-update="append" class="space-y-4">
          <%= if Enum.empty?(@messages) do %>
            <div class="text-center text-gray-500 italic py-8">
              Ask the apprentice about spells...
            </div>
          <% end %>

          <%= for {message, i} <- Enum.with_index(@messages) do %>
            <div id={"message-#{i}"} class={message_container_class(message.role)}>
              <div class={message_class(message.role)}>
                <%= raw(format_message(message.content)) %>
              </div>
            </div>
          <% end %>
        </div>

        <%= if @loading do %>
          <div class="flex items-center justify-center py-4">
            <div class="animate-pulse flex space-x-2">
              <div class="h-2 w-2 bg-purple-600 rounded-full"></div>
              <div class="h-2 w-2 bg-purple-600 rounded-full"></div>
              <div class="h-2 w-2 bg-purple-600 rounded-full"></div>
            </div>
          </div>
        <% end %>
      </div>

      <form phx-submit="submit" class="flex gap-2">
        <input
          type="text"
          name="user_input"
          value={@user_input}
          placeholder="Ask about spells..."
          class="flex-1 px-4 py-2 rounded-md border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500"
          phx-keyup="update_input"
          autocomplete="off"
          disabled={@loading}
        />
        <button
          type="submit"
          disabled={@loading}
          class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 transition disabled:opacity-50"
        >
          Send
        </button>
      </form>
    </div>
    """
  end

  def handle_event("update_input", %{"value" => value}, socket) do
    {:noreply, assign(socket, :user_input, value)}
  end

  defp message_container_class("user"), do: "flex justify-end"
  defp message_container_class("assistant"), do: "flex justify-start"

  defp message_class("user"), do: "bg-purple-600 text-white rounded-lg p-3 max-w-[80%]"
  defp message_class("assistant"), do: "bg-gray-200 text-gray-800 rounded-lg p-3 max-w-[80%]"

  defp format_message(content) do
    content
    |> String.replace("\n", "")
    # Add more formatting if needed for markdown, etc.
  end
end
