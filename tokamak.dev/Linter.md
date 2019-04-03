## Tokamak Linter

Tokamak Linter is module to check your Tokamak projects for known warning
and show them in xcode or in terminal.

## How to run

### Add to Xcode build phase

- build TokamakCLI with Xcode
- add path to TokamakCLI to build phase

or

### Run in terminal

- run `swift build --product TokamakCLI` in Tokamak directory
- run `{path to TokamakCLI}/TokamakCLI lint`

## Supported Rules

| Rule              | Description                                            |
| ----------------- | ------------------------------------------------------ |
| Props conformance | Props should be always conformance Equatable protocol. |
