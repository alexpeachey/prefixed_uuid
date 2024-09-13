# PrefixedUUID

A while back I read a wonderfully useful [blog post](https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto) by @danschultzer

I've used a modified version of his code from the post in a few projects and
as I copy/pasted the code into yet another project today, I decided to turn it into a small library. It may not be useful for anyone else, but it will make adding it to my new projects a lot easier.

Under the hood it relies on [Ecto](https://github.com/elixir-ecto/ecto) and [Uniq](https://github.com/bitwalker/uniq)

As Dan explains in his post, it opts to use the newer UUIDv7 instead of UUIDv4 which allow for nicieties like ordering. It also makes the UUIDs more friendly by encoding them in base62 and allowing a prefix to be assigned per schema. This allows for ids that look like `user_3TUIKuXX5mNO2jSA41bsDx` instead of `7232b37d-fc13-44c0-8e1b-9a5a07e24921`. At a glance you know the id belongs to a user schema and while not a lot shorter, it is shorter and more compact.

## Installation

The package can be installed by adding `prefixed_uuid` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prefixed_uuid, "~> 1.0.0"}
  ]
end
```

## Usage

In your schema files, instead of `use Ecto.Schema` instead do `use PrefixedUUID.Schema, prefix: "user"`

This precludes the need for specifying `@primary_key` and `@foreign_key_type` in your schema file. If you would like to be more explicit and continue using `Ecto.Schema`, then you may instead opt to specify these directly.

```
@primary_key {:id, PrefixedUUID, prefix: "user", autogenerate: true}
@foreign_key_type PrefixedUUID
```

If you chose to use `PrefixedUUID.Schema` then you also get a type automatically set and a couple of helper functions:

* `prefix/0` returns the prefix you set which allows progromatic access to the prefix.
* `generate_id/0` returns a freshly generated prefixed UUID that uses the set prefix.


See the [docs](https://hexdocs.pm/prefixed_uuid) for the full set of functions available.
