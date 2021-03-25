defmodule Sup do
  require Logger
  @moduledoc """
  Documentation for `Sup`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Sup.hello()
      :world

  """
  def hello do
    Logger.info("start")
    for _ <- 0..1_000_000, do: Sup.Session.Manager.add(nil)
    Logger.info("ended")
  end
end
