# Prompt 6 — refinar o MVP validado com Goal

Use no Dia 3, **somente** depois do teste com usuário e da aprovação de um plano curto. Troque `PLANO-DE-REFINAMENTO.md` pelo arquivo real.

```text
/goal --plan docs/superpowers/plans/PLANO-DE-REFINAMENTO.md

CONTEXTO
O MVP já existe e funciona. O plano informado contém somente os reajustes priorizados depois da validação de hoje.

OBJETIVO
Refinar o MVP sem ampliar o escopo, preservar o que já funciona e preparar uma apresentação verificável da solução.

CONCLUÍDO QUANDO
- cada reajuste aprovado foi implementado ou registrado como bloqueado;
- o fluxo principal continua funcionando de ponta a ponta;
- persistência e integrações obrigatórias continuam aprovadas na regressão;
- os problemas bloqueantes observados na validação foram corrigidos;
- testes, verificação de tipos e build passam;
- `docs/o-que-e-real.md` corresponde ao estado atual;
- a demonstração final apresenta problema, solução, fluxo, prova e próximo passo.

NÃO FAZER
- não repetir brainstorming, PRD, Design OS ou a construção inicial do MVP;
- não incluir sugestão que não esteja no plano curto aprovado;
- não trocar arquitetura, tecnologia ou serviço externo sem me perguntar;
- não esconder falha com dado simulado;
- não publicar, fazer push, criar recurso externo ou executar ação irreversível sem autorização.

DURANTE A EXECUÇÃO
- use `executing-plans` para seguir o plano curto na ordem;
- verifique cada reajuste e depois rode a regressão completa;
- informe em uma linha o resultado e a prova de cada tarefa;
- pare diante de mudança material, credencial ausente, custo ou autorização externa;
- invoque `verification-before-completion` antes de afirmar que terminou.

No final, entregue um resumo das mudanças, das verificações e do roteiro de apresentação. Espere minha autorização antes de publicar.
```

Se o Goal tentar reconstruir o MVP: pare e volte ao plano curto.
