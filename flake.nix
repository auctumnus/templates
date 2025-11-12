{
  description = "Autumn's flake templates";

  outputs =
    { ... }:
    {
      templates = {
        rust = {
          path = ./rust;
          description = "A template for generic Rust development.";
        };

        rust-web = {
          path = ./rust-web;
          description = "A template for Rust web application development.";
        };
      };
    };
}
