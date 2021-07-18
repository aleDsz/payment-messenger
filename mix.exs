defmodule PaymentMessenger.MixProject do
  use Mix.Project

  def project do
    [
      app: :payment_messenger,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.6", optional: true},
      {:temporary_env, "~> 2.0", only: [:test]}
    ]
  end
end
