# Skills e plugins

O que multiplica o Claude.

## Skill (habilidade)

Pacote de conhecimento e procedimento que ensina o Claude a executar uma tarefa **do seu jeito**: suas regras, seu padrão de qualidade, seu vocabulário.

Uma vez criada, a skill fica disponível. O Claude a consulta toda vez que a tarefa aparecer.

Analogia: o manual de treinamento de um funcionário novo. Você escreve uma vez, e todo “funcionário digital” que chegar depois já começa sabendo como a empresa trabalha.

Uma skill por tarefa. Cinco skills pequenas e precisas vencem uma gigante que tenta fazer tudo.

Como criar a primeira: [[04 Criar uma skill]].

## Plugin (extensão)

Extensão que adiciona ferramentas e skills prontas. Em vez de construir do zero, você instala um pacote.

Analogia: contratar um especialista já treinado.

Na imersão, a lista curta é:

- o plugin da imersão (`imersao@imersao-ia`);
- Superpowers (`/brainstorming`, `/writing-plans`, `/executing-plans`);
- Design OS (protótipo);
- Goal (refinamento do Dia 3);
- Chrome DevTools MCP (olhos no navegador).

Não instale dezenas de plugins aleatórios.

## Superpowers

Método de descoberta, planejamento e execução. Na imersão usamos os nomes reais:

| Comando | Dia | Função |
|---|---|---|
| `/brainstorming` | 1 | Três caminhos + PRD |
| `/writing-plans` | 2 | Plano do MVP |
| `/executing-plans` | 2 (e no 3, por baixo do Goal) | Construir em lotes |
| `/goal --plan` | 3 | Só o refinamento validado |

## Chrome DevTools MCP

Dá olhos ao Claude no navegador: ele abre o produto, testa as telas, tira fotos e confere o próprio trabalho.

Cole uma vez. Vale para sempre:

```bash
claude mcp add chrome-devtools --scope user -- npx chrome-devtools-mcp@latest
```

Ver: [[Claude e Claude Code]] · [[Design OS]]
