## Tokamak Linter

Tokamak Linter is module to check your Tokamak projects for known warning
and show them in Xcode or in terminal.

## How to run

### Add to Xcode build phase

- build TokamakCLI with Xcode
- add path to TokamakCLI to build phase

```bash
{path to TokamakCLI}/TokamakCLI
```

or

### Run in terminal

- run `swift build --product TokamakCLI` in Tokamak directory
- run `{path to Tokamak}/.build/debug/TokamakCLI "{path to lint folder}"`

## Supported Rules

| Rule              | Description                                            |
| ----------------- | ------------------------------------------------------ |
| Props conformance | Props should be always conformance Equatable protocol. |
