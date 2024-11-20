# Changelog

## [Unreleased]

## [1.1.0] - 2024-11-20

### Doc

- recommend using `@permute_args` over `permute_args` and `permute_args!`

### Feat

- `permute_args` now could take a single argument for Function and Method as input
- `permute_args` now support keywords
- improve argument names handling in `permute_args`

### Refactor

- consolidate function signature and cleanup codes
- refactor out `generate_permuted_methods` for `@permute_args`, `permute_args` and `permute_args!` function
- make `permute_args` and `permute_args!` more general

### Test

- add local scope test for `permute_args!`
- test throw correct method

### Chore

- deprecate permute_args_dynamic
- add benchmarks

## [1.0.0] - 2024-11-20

Initial release of PermuteArgs.jl: a Julia package for creating functions with permutable arguments

- `@permute_args`: Macro to define functions with permutable arguments
- `permute_args`: Function to create a new function with permutable arguments
- `permute_args!`: Function to add permuted methods to an existing function

[unreleased]: https://github.com/Beforerr/PermuteArgs.jl/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/Beforerr/PermuteArgs.jl/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Beforerr/PermuteArgs.jl/commits/v1.0.0