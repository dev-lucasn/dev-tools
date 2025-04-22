#!/bin/bash

# Nome do repositório no formato usuario/repositorio
REPO="dev-lucasn/CredereApi"

# Verifica se o repositório existe e se você tem acesso
gh repo view "$REPO" &>/dev/null || { echo "❌ Repositório não encontrado ou sem permissão."; exit 1; }

echo "🧹 Limpando labels existentes no repositório: $REPO"

# Obtém todas as labels e apaga uma por uma
gh label list --repo "$REPO" --limit 1000 | cut -f1 | while read -r LABEL_NAME; do
  if [ -n "$LABEL_NAME" ]; then
    gh label delete "$LABEL_NAME" --repo "$REPO" --yes &>/dev/null \
      && echo "🗑️  Label removida: $LABEL_NAME"
  fi
done

echo "📌 Criando novas labels padronizadas..."

declare -A LABELS=(
  ["feature"]="#1D76DB|Nova funcionalidade"
  ["bug"]="#D73A49|Erro ou comportamento inesperado"
  ["refactor"]="#8A2BE2|Melhoria interna sem alteração funcional"
  ["tech-debt"]="#B60205|Dívida técnica a ser resolvida"
  ["docs"]="#0075CA|Documentação"
  ["test"]="#5319E7|Cobertura de testes"
  ["infra"]="#C2E0C6|Infraestrutura, CI/CD, DevOps"
  ["urgent"]="#FF0000|Alta prioridade"
  ["low-priority"]="#D4C5F9|Baixa prioridade"
)

for LABEL in "${!LABELS[@]}"; do
  IFS='|' read -r COLOR DESC <<< "${LABELS[$LABEL]}"
  gh label create "$LABEL" --color "${COLOR/#\#}" --description "$DESC" --repo "$REPO" &>/dev/null \
    && echo "✅ Label criada: $LABEL" \
    || echo "⚠️  Falha ao criar: $LABEL"
done

echo "🏁 Labels redefinidas com sucesso!"
