# Checklist QA do playbook

Confirme três coisas antes de chamar o playbook de validado:

1. o texto é fiel ao processo real;
2. um terceiro entende como executar;
3. o escopo cabe no trabalho de uma pessoa.

O revisor procura lacunas. O autor confirma os fatos. Ninguém inventa etapa para tapar buraco.

Somente a **dupla** marca `VALIDADO`. Uma revisão do agente não substitui o teste humano.

## Como revisar em 30 minutos

1. **5 min — autor:** explica o gatilho e a saída sem ler o documento.
2. **10 min — revisor:** lê e tenta repetir o processo em voz alta.
3. **10 min — dupla:** marca o checklist e corrige lacunas confirmadas.
4. **5 min — autor:** leitura final e fidelidade.

## A. Fidelidade — bloqueante

- [ ] Usa uma execução recente como referência.
- [ ] A ordem dos passos é a que o autor realmente faz.
- [ ] Ferramentas, arquivos e responsáveis citados existem.
- [ ] Decisões importantes estão em **SE / ENTÃO / PORQUE**.
- [ ] Exceções frequentes têm uma ação segura.
- [ ] O texto separa fato de hipótese ou melhoria futura.
- [ ] O autor rejeitou ou corrigiu qualquer trecho inventado pelo agente.

Pergunta do revisor: “Qual trecho mudaria se eu observasse você executar isso hoje?”

## B. Clareza para um terceiro — bloqueante

- [ ] Está claro quando o processo começa.
- [ ] As entradas dizem origem, formato ou local.
- [ ] Cada passo começa com uma ação e tem um fim verificável.
- [ ] Siglas que só o autor conheceria estão explicadas.
- [ ] Um terceiro sabe onde pedir ajuda numa exceção.
- [ ] A saída final e o destino estão claros.
- [ ] O critério de conclusão pode ser conferido sem adivinhar.
- [ ] As provas são localizáveis.

Teste: o revisor explica o processo de volta. Se o autor precisar completar uma etapa essencial oralmente, o texto ainda não está pronto.

## C. Escopo individual — bloqueante

- [ ] Começo e fim reconhecíveis.
- [ ] A execução principal pertence a uma pessoa ou função.
- [ ] O documento não tenta explicar uma área inteira.
- [ ] Dependências de outras pessoas aparecem como entrada, aprovação ou exceção.
- [ ] Dá para revisar durante a imersão sem mapear a empresa toda.

Pergunta: “Qual parte deste processo o autor executa do começo ao fim?”

## D. Segurança — bloqueante

- [ ] Sem senha, token ou chave.
- [ ] Sem documento pessoal.
- [ ] Dados de cliente removidos ou anonimizados.
- [ ] Exemplos fictícios ou anonimizados.

Ver: [[Seguranca dos dados]] · [[Modelo de playbook]]
