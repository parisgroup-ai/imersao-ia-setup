# Prompt 5 — construir o MVP integrado (onda 1)

Use na pasta `projeto/` ainda no Dia 2. Troque `NOME-DO-PLANO.md` pelo arquivo aprovado.

```text
/executing-plans

Execute SOMENTE a onda 1 do plano `docs/superpowers/plans/NOME-DO-PLANO.md`.
Entregue hoje um MVP integrado funcionando.

FONTES DA VERDADE
1. `docs/PRD.md` — requisitos da onda 1 e mapa de ondas;
2. `product-plan/` — interface, navegação, componentes e estados;
3. `docs/superpowers/plans/NOME-DO-PLANO.md` — ordem da implementação da onda 1.

ANTES DE COMEÇAR
- Leia o plano e as fontes por completo.
- Confira se o mapa de ondas está no plano. Se não estiver, pare e volte ao Prompt 4.
- Se o plano misturar tarefa de onda 2 no meio da onda 1, pare, separe e peça minha confirmação.
- Aponte arquivos ausentes, placeholders, contradições e dependências externas.
- Confirme comigo qualquer decisão que altere produto, escopo, arquitetura, custo ou serviço externo.
- Mostre os lotes da ONDA 1 e espere minha aprovação para iniciar.

CONCLUÍDO QUANDO (onda 1)
- o app abre sem erro e o fluxo principal funciona de ponta a ponta;
- os dados importantes persistem após atualizar a página ou repetir o fluxo;
- estados vazio, carregando, sucesso e erro foram verificados;
- cada integração obrigatória do PRD está configurada e testada com uma chamada ou ação real;
- nenhuma simulação aparece como integração real;
- testes, verificação de tipos e build passam;
- a implementação mantém o recorte e a linguagem visual aprovados;
- as evidências ficam registradas para a validação do Dia 3;
- as ondas 2+ continuam listadas em “Como continuar depois”, sem terem sido construídas.

NÃO FAZER
- não construir onda 2+ nesta sessão;
- não ampliar o MVP;
- não redesenhar telas aprovadas;
- não trocar a tecnologia definida no plano;
- não apagar arquivos ou histórico sem autorização;
- não inventar credencial, retorno de API ou prova;
- não publicar, fazer push, criar conta, contratar serviço ou executar outra ação externa sem autorização.

DURANTE A EXECUÇÃO
- trabalhe em lotes curtos, na ordem do plano da onda 1;
- faça o teste falhar antes da implementação quando houver código;
- após cada lote, informe resultado, comando de verificação e saída relevante;
- se uma verificação falhar, investigue a causa antes de tentar outra solução;
- depois de três tentativas sem causa confirmada, pare e peça ajuda;
- no final, faça regressão do fluxo principal, persistência e integrações;
- recorde, em uma frase: “onda 1 pronta; o resto do produto está no plano, na mesma pasta.”

Pare somente quando o MVP da onda 1 estiver demonstrável ou quando existir um bloqueio externo real, com responsável e próximo passo registrados.
```

Não use `/goal` neste passo. Goal é do Dia 3: [[Prompt 6 - Refinar]].
