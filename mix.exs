defmodule PaymentMessenger.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo "https://github.com/aledsz/payment-messenger"

  def project do
    [
      app: :payment_messenger,
      name: "Payment Messenger",
      description: "ISO-8583 TLV messages with Ecto validation",
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "PaymentMessenger",
      source_ref: "v#{@version}",
      source_url: @repo,
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      links: %{github: @repo}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.6", optional: true},
      {:temporary_env, "~> 2.0", only: :test},
      {:credo, "~> 1.5.0", optional: true, only: :test, runtime: false},
      {:excoveralls, "~> 0.10", optional: true, only: :test},
      {:git_hooks, "~> 0.5.0", optional: true, only: :test, runtime: false}
    ]
  end
end
