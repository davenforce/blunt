if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.Factories do
    defmacro __using__(opts) do
      quote do
        use Blunt.Data.Factories, unquote(opts)
        use Blunt.Testing.Factories.DispatchStrategy

        fake_provider Blunt.Testing.Factories.FakeProvider
        builder Blunt.Testing.Factories.Builder.BluntMessageBuilder
      end
    end
  end
end
