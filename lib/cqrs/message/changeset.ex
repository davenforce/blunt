defmodule Cqrs.Message.Changeset do
  @moduledoc false

  alias Ecto.Changeset
  alias Cqrs.Message.{Input, Metadata}
  alias Cqrs.Message.Changeset, as: MessageChangeset

  defmacro generate do
    quote do
      def changeset(message \\ %__MODULE__{}, values)

      def changeset(message, values) when is_struct(values),
        do: changeset(message, Map.from_struct(values))

      def changeset(%{__struct__: message}, values) when is_list(values) or is_map(values),
        do: changeset(message, values)

      def changeset(message, values) when is_list(values) or is_map(values),
        do: MessageChangeset.create(message, values)
    end
  end

  @type message :: atom()
  @type discarded_data :: map()
  @type changeset :: Ecto.Changeset.t()
  @type values :: maybe_improper_list | map | struct

  @spec create(message(), values()) :: {changeset, discarded_data}

  def create(message, values) do
    values =
      values
      |> Input.normalize(message)
      |> autogenerate_fields(message)

    required_fields = Metadata.required_fields(message)

    embeds = message.__schema__(:embeds)
    fields = message.__schema__(:fields)

    discarded_data =
      values
      |> Map.drop(Enum.map(fields, &to_string/1))
      |> Map.drop(Enum.map(embeds, &to_string/1))

    changeset =
      message
      |> struct()
      |> Changeset.cast(values, fields -- embeds)

    changeset =
      embeds
      |> Enum.reduce(changeset, &Changeset.cast_embed(&2, &1))
      |> Changeset.validate_required(required_fields)
      |> message.handle_validate()

    {changeset, discarded_data}
  end

  defp autogenerate_fields(values, message) do
    message
    |> Metadata.autogenerated_fields()
    |> Enum.into(%{}, &run_generator(&1, message))
    |> Map.merge(values)
  end

  defp run_generator({name, {m, f}}, message),
    do: run_generator({name, {m, f, []}}, message)

  defp run_generator({name, {m, f, a}}, message) do
    unless function_exported?(m, f, length(a)) do
      raise Cqrs.Message.Error,
        message: "#{inspect(message)}.#{name} autogenerate function '#{inspect(m)}.#{f}/#{length(a)}' not found."
    end

    {to_string(name), apply(m, f, a)}
  end

  def format_errors(changeset) do
    Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
