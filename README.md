# Payment Messenger (Work in Progress)

[![continuous integration](https://github.com/aleDsz/payment-messenger/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/aleDsz/payment-messenger/actions/workflows/elixir.yml)
[![codecov](https://codecov.io/gh/aleDsz/payment-messenger/branch/main/graph/badge.svg?token=5VU8NOU0YQ)](https://codecov.io/gh/aleDsz/payment-messenger)

Transfer data with [ISO-8583](https://wikipedia.org/wiki/ISO_8583) message pattern with Ecto schemas and validations
without any need to implement the message generation.

This library will return the string from given `Message` and vice-versa.

## Installation

```elixir
def deps do
  [
    {:payment_messenger, git: "aleDsz/payment-messenger"}
  ]
end
```
