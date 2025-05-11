defmodule JumpTickets.NotionDonePoller do
  use GenServer
  require Logger

  @poll_interval :timer.seconds(60)
  @table :notion_done_poller

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    schedule_poll()
    {:ok, state}
  end

  def handle_info(:poll, state) do
    poll_notion()
    schedule_poll()
    {:noreply, state}
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp poll_notion do
    case JumpTickets.External.Notion.query_db() do
      {:ok, tickets} ->
        Enum.each(tickets, fn ticket ->
          if ticket_done?(ticket) && !already_notified?(ticket) do
            Logger.info("Notifying Slack for done ticket: #{ticket.ticket_id}")
            case JumpTickets.Ticket.DoneNotifier.notify_ticket_done(ticket) do
              :ok ->
                mark_notified(ticket)
              error ->
                Logger.error("Failed to notify Slack for ticket #{ticket.ticket_id}: #{inspect(error)}")
            end
          end
        end)
      error ->
        Logger.error("Failed to poll Notion: #{inspect(error)}")
    end
  end

  defp ticket_done?(ticket) do
    # The Notion parser should set a field for done status, but if not, check the summary or another field
    Map.get(ticket, :done, false) || Map.get(ticket, "done", false)
  end

  defp already_notified?(ticket) do
    :ets.member(@table, ticket.notion_id)
  end

  defp mark_notified(ticket) do
    :ets.insert(@table, {ticket.notion_id, true})
  end
end 