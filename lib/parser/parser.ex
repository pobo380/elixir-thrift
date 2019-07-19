defmodule Thrift.Parser do
  @moduledoc """
  This module provides functions for parsing `.thrift` files.
  """

  @type path_element :: String.t() | atom

  alias Thrift.Parser.Models
  alias Thrift.Parser.Models.Schema

  @doc """
  Parses a Thrift document and returns the schema that it represents.
  """
  @spec parse(String.t()) :: %Schema{}
  def parse(doc) do
    doc = String.to_char_list(doc)

    {:ok, tokens, _} = :thrift_lexer.string(doc)
    {:ok, schema} = :thrift_parser.parse(tokens)

    schema
  end

  @doc """
  Parses a Thrift document and returns a component to the caller.

  The part of the Thrift document that's returned is determined by
  the `path` parameter. It works a lot like the `find_in` function,
  which takes a map and can pull out nested pieces.

  For example, this makes it easy to get to a service definition:

      parse(doc, [:services, :MyService])

  Will return the "MyService" service.
  """
  @spec parse(String.t(), [path_element]) :: Models.all()
  def parse(doc, path) do
    schema = parse(doc)

    Enum.reduce(path, schema, fn
      _part, nil ->
        nil

      part, %{} = next ->
        Map.get(next, part)
    end)
  end
end
