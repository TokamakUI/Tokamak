## Tokamak Linter

Tokamak Linter is a module to check your Tokamak projects for known warnings
and show them in Xcode or in terminal.

## How to run

### Add to Xcode build phase

- build TokamakCLI with Xcode
- add path to TokamakCLI to build phase

```bash
{path to TokamakCLI}/TokamakCLI lint {path to folder or file}
```

or

### Run in terminal

- run `swift build --product TokamakCLI` in Tokamak directory
- run `swift run TokamakCLI lint "{path to lint folder or file}"` in Tokamak directory

## Supported Rules

| Rule              | Description                                            |
| ----------------- | ------------------------------------------------------ |
| Props conformance | Props should be always conformance Equatable protocol. |
