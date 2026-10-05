# Language and infrastructure tooling

One owner per responsibility: LSP for code intelligence/most diagnostics,
Conform for formatting, nvim-lint only where there is no chosen LSP diagnostic
provider. No LSP formatting fallback is enabled, so a save never runs two competing
formatters. No blanket Ruff fix-all or Terraform apply on save.

| Language | LSP | Formatter | Lint/diagnostics |
|---|---|---|---|
| Python | basedpyright + Ruff native server | Ruff organize imports, then Ruff format | basedpyright types; Ruff style/imports |
| TypeScript / JavaScript | typescript-language-server; ESLint when config found | Prettier | ts_ls types; ESLint LSP for project rules |
| JSON / JSONC | vscode-json-language-server | Prettier | JSON LS |
| YAML | yaml-language-server, SchemaStore | Prettier | YAML LS + declared schema |
| Bash / sh | bash-language-server | shfmt | ShellCheck via Bash LS |
| Lua | lua-language-server | StyLua | Lua LS |
| Terraform / tfvars | terraform-ls | terraform fmt | Terraform LS; manual tflint |
| Dockerfile | dockerfile-language-server | None; keep manual layout | Docker LS + hadolint on save |
| Markdown | Marksman | Prettier | markdownlint-cli2 on save |

Mason is disabled: language servers and command-line tools are installed by
Homebrew, uv, and pnpm, and should be on PATH before opening Neovim.
`:checkhealth vim.lsp` and `:ConformInfo` diagnose missing tools. LazyVim supplies native `gc`
commenting, Treesitter highlighting/folds, and mini.ai text objects.

## Python: uv projects

```sh
cd ~/code/project-a
uv init                       # only for a new project
uv add --dev ruff basedpyright
uv sync
uv run pytest                 # after adding pytest to this project
uv run ruff check .
uv run ruff format --check .
uv run basedpyright
```

For an existing project, use its `uv sync` / `uv.lock`, not a global environment.
basedpyright selects `<LSP root>/.venv/bin/python` when present. An activated
`VIRTUAL_ENV` also works with the server's normal environment discovery; restart
the LSP after changing environments (`:lsp restart` on current Neovim).
The Python interpreter, installed stubs/dependencies, and type-checker version
must agree between your editor and CI. Choose a type-checking mode in pyproject;
the baseline is `standard`, not basedpyright's noisier recommended strict policy.

Conform and the Ruff language server prefer `.venv/bin/ruff`; the Homebrew Ruff
binary is the fallback. basedpyright uses `.venv/bin/python` when available.
Ruff owns imports and style;
basedpyright owns hover/navigation/types (its import-organize feature is disabled).

Example project-owned settings, only if they match the team's policy:

```toml
[tool.ruff]
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B"]

[tool.basedpyright]
typeCheckingMode = "standard"
venvPath = "."
venv = ".venv"
```

Do not suppress all type diagnostics simply to remove Ruff duplicates; the two
servers intentionally have distinct jobs. Ruff formatting also sorts imports,
but does not auto-apply every potentially semantic lint fix.

## JavaScript / TypeScript: pnpm

```sh
pnpm install --frozen-lockfile
pnpm add -D typescript@6 typescript-language-server prettier eslint
pnpm exec prettier --check .
pnpm exec eslint .
pnpm exec tsc --noEmit
```

Use the existing lockfile/version policy, not these package-add commands blindly
in an established repo. The LSP config's ts_ls definition prefers a local
`node_modules/.bin/typescript-language-server`, and its upstream resolver uses
the workspace TypeScript version. The locked dotfiles TypeScript/Prettier are fallbacks;
Conform prefers local Prettier. ESLint's language server comes from
`vscode-langservers-extracted`, and uses the project's ESLint/config rather than
adding a second global ESLint policy. Its upstream root markers require an ESLint
config; projects without one are not forced into linting. Use `eslint.config.*`
or the repository's supported config. ESLint fixes are code actions/explicit CLI
commands, not an additional formatter on every save.

For pnpm monorepos, open Neovim at the workspace root. Keep TypeScript compatible
with the chosen server; current ts_ls requires the JavaScript TypeScript line <7.
Do not auto-replace this with experimental language servers just because newer
packages exist. Deno/Biome are project-specific alternatives, not parallel defaults.

## YAML / Kubernetes / DevOps

LazyVim's YAML extra uses SchemaStore plus the YAML server's catalog. Automatic
Kubernetes association is limited to `k8s*.yaml/yml`; do **not** label every YAML
file as Kubernetes (that breaks workflows, Compose, CI, and Helm values). For
other paths, use a file-level modeline or project-specific schema associations:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json
apiVersion: apps/v1
kind: Deployment
```

Schemas may require network access. Pin a schema matching your cluster version
in a real project. Helm templates are templated YAML, not always valid plain YAML;
use `helm lint`/`helm template` and adjust associations rather than trusting editor
diagnostics alone. Use task windows for `kubectl`, `k9s`, logs, port-forwards, and
`helm`. `kubectx`/`kubens` switch explicitly; run `kubectl config current-context`
and verify namespace before changes. Never auto-run infrastructure operations.

## Terraform

Use repository-required Terraform/provider versions. `terraform init` installs
the provider schemas needed for strong completion/validation; `tflint --init`
installs project-declared tflint rules. Both can download code and should be run
explicitly in a trusted repo, not by an editor autocmd.

```sh
terraform init
terraform fmt -check -recursive
terraform validate
tflint --init
tflint
terraform plan
```

Only formatting is automatic. `Space cL` runs tflint in the selected project root
on demand; in a monorepo, use a module's lockfile/.tflint.hcl or run tflint in the
module task window. No `apply`/`destroy` shortcuts; review plans and target workspace.
Terraform is installed from HashiCorp's tap for the current official distribution,
not an outdated license-frozen core formula. OpenTofu is a legitimate alternative,
but choose one deliberately and update formatter/LSP/version policy together.

## Markdown / shell / Docker

Keep `.markdownlint-cli2.*`, Prettier, `.shellcheckrc`, and `.hadolint.yaml` policy
in each repository. Prettier wrapping and markdownlint line length may disagree;
configure MD013 appropriately for your team. Native LSP diagnostics are displayed
alongside nvim-lint diagnostics; no second lint plugin runs Ruff/ESLint/ShellCheck.
Dockerfiles are highlighted, validated, and linted but not automatically rewritten
by an arbitrary formatter. Docker/Compose execution stays in tmux task windows.
