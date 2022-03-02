if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.Factories do
    alias Blunt.Testing.Factories.Factory

    defmacro __using__(opts) do
      repo = Keyword.get(opts, :repo)

      quote do
        use Blunt.Testing.Factories.DispatchStrategy

        if unquote(repo) do
          use ExMachina.Ecto, repo: unquote(repo)
        else
          use ExMachina
        end

        import Blunt.Testing.Factories, only: :macros
        import Blunt.Testing.Factories.Values, only: :macros

        Module.put_attribute(__MODULE__, :desc, nil)
      end
    end

    defmacro factory(message) do
      create_factory(message, [], [])
    end

    defmacro factory(message, do: body) do
      values = extract_values(body)
      create_factory(message, values, [])
    end

    defmacro factory(message, opts) do
      create_factory(message, [], opts)
    end

    defmacro factory(message, opts, do: body) do
      values = extract_values(body)
      create_factory(message, values, opts)
    end

    defp extract_values({:__block__, _meta, elements}), do: elements
    defp extract_values(nil), do: []
    defp extract_values(list) when is_list(list), do: list
    defp extract_values(element), do: [element]

    defp create_factory(message, values, opts) do
      {name, opts} = factory_name(message, opts)

      {name, message} =
        case name do
          {:map_factory, name} -> {name, Map}
          _ -> {name, message}
        end

      quote do
        def unquote(name)(attrs) do
          Factory.new(unquote(name), unquote(message), unquote(values))
          |> Factory.build(attrs, unquote(opts))
        end
      end
    end

    defp factory_name(message, opts) when is_atom(message) do
      name = String.to_atom("#{message}_factory")
      {{:map_factory, name}, opts}
    end

    defp factory_name({:__aliases__, _meta, message}, opts) do
      case Keyword.pop(opts, :as, nil) do
        {name, opts} when is_atom(name) and not is_nil(name) ->
          factory_name = String.to_atom(to_string(name) <> "_factory")
          {factory_name, opts}

        {_, opts} ->
          factory_name =
            message
            |> List.last()
            |> to_string()
            |> Macro.underscore()
            |> Kernel.<>("_factory")
            |> String.to_atom()

          {factory_name, opts}
      end
    end
  end
end
