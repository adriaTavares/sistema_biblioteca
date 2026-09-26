# Documento de Requisitos do Sistema de Biblioteca

## 1. Descrição do sistema

O sistema tem como objetivo gerenciar as operações de uma biblioteca, incluindo seu acervo, clientes, funcionários, reservas e empréstimos.

O sistema permite o gerenciamento de categorias, livros e exemplares físicos, além do controle de clientes, funcionários e gerentes. Também administra reservas e empréstimos, controlando a disponibilidade dos exemplares e evitando conflitos entre operações realizadas simultaneamente.

O sistema possui diferentes níveis de acesso, permitindo que funcionários, gerentes e administradores executem operações de acordo com suas respectivas permissões.

As principais regras operacionais da biblioteca podem ser configuradas pelo sistema, permitindo alterar prazos de reservas e empréstimos, limites de renovações, quantidade máxima de reservas e regras de aplicação de multas sem necessidade de modificar o código-fonte.

O sistema também mantém histórico das operações relevantes, permitindo identificar as ações realizadas, o usuário responsável e o momento em que cada operação ocorreu.

---

## 2. Usuários do sistema

### 2.1 Funcionário

Responsável pelas operações relacionadas ao atendimento e ao funcionamento cotidiano da biblioteca.

Pode realizar operações como:

- consultar livros e exemplares;
- cadastrar e gerenciar clientes;
- registrar reservas;
- registrar empréstimos;
- registrar devoluções;
- realizar renovações permitidas;
- consultar informações relacionadas às operações que possui permissão para acessar.

### 2.2 Gerente

Possui as permissões de um funcionário e permissões administrativas adicionais relacionadas à operação da biblioteca.

Pode:

- gerenciar funcionários;
- definir permissões de funcionários dentro dos limites estabelecidos;
- consultar informações administrativas;
- executar operações adicionais de acordo com suas permissões.

### 2.3 Administrador

Possui o maior nível de acesso do sistema.

Pode:

- gerenciar gerentes;
- gerenciar permissões administrativas;
- alterar configurações gerais do sistema;
- consultar informações administrativas e históricos;
- executar operações de gerenciamento geral da biblioteca.

---

# 3. Requisitos funcionais

## 3.1 Autenticação e controle de acesso

### RF01 — Autenticação

O sistema deve permitir que funcionários, gerentes e administradores cadastrados realizem autenticação.

### RF02 — Controle de acesso

O sistema deve restringir o acesso às funcionalidades de acordo com as permissões do usuário autenticado.

### RF03 — Gerenciamento de sessão

O sistema deve controlar as sessões dos usuários autenticados e impedir o acesso às funcionalidades protegidas após o encerramento ou expiração da sessão.

---

## 3.2 Categorias

### RF04 — Gerenciamento de categorias

O sistema deve permitir que usuários autorizados cadastrem, consultem, alterem e removam categorias.

### RF05 — Consulta de categorias

O sistema deve permitir consultar as categorias existentes e os livros associados a cada categoria.

---

## 3.3 Livros

### RF06 — Gerenciamento de livros

O sistema deve permitir que usuários autorizados cadastrem, consultem, alterem e removam livros.

### RF07 — Consulta de livros

O sistema deve permitir consultar os livros cadastrados e suas informações.

### RF08 — Associação entre livros e categorias

O sistema deve permitir associar livros às categorias cadastradas.

### RF09 — Consulta de exemplares

O sistema deve permitir consultar os exemplares físicos associados a cada livro.

---

## 3.4 Exemplares

### RF10 — Gerenciamento de exemplares

O sistema deve permitir que usuários autorizados cadastrem, consultem, alterem e removam exemplares.

### RF11 — Identificação única

Cada exemplar deve possuir uma identificação única dentro do sistema.

### RF12 — Controle da situação do exemplar

O sistema deve manter a situação atual de cada exemplar, permitindo identificar se ele está disponível, emprestado, reservado ou em outro estado definido pelo sistema.

### RF13 — Consulta de disponibilidade

O sistema deve permitir verificar a disponibilidade dos exemplares associados a determinado livro.

### RF14 — Histórico do exemplar

O sistema deve permitir consultar o histórico de operações realizadas sobre cada exemplar.

---

## 3.5 Clientes

### RF15 — Gerenciamento de clientes

O sistema deve permitir que usuários autorizados cadastrem, consultem, alterem e removam clientes.

### RF16 — Histórico do cliente

O sistema deve permitir consultar o histórico de operações de um cliente, incluindo reservas, empréstimos, devoluções e outras operações relevantes.

---

## 3.6 Funcionários

### RF17 — Gerenciamento de funcionários

O sistema deve permitir que gerentes cadastrem, consultem, alterem e removam funcionários.

### RF18 — Gerenciamento de permissões de funcionários

O sistema deve permitir que gerentes gerenciem as permissões dos funcionários dentro dos limites estabelecidos pelo nível hierárquico.

---

## 3.7 Gerentes

### RF19 — Gerenciamento de gerentes

O sistema deve permitir que administradores cadastrem, consultem, alterem e removam gerentes.

### RF20 — Controle de hierarquia de permissões

O sistema deve impedir que funcionários ou gerentes concedam a si mesmos ou a outros usuários permissões superiores ao seu próprio nível de acesso.

---

## 3.8 Reservas

### RF21 — Registro de reservas

O sistema deve permitir que funcionários registrem reservas de livros para clientes.

### RF22 — Consulta de reservas

O sistema deve permitir que usuários autorizados consultem reservas de acordo com suas permissões.

### RF23 — Cancelamento de reservas

O sistema deve permitir o cancelamento de reservas de acordo com as regras definidas pela biblioteca.

### RF24 — Controle do ciclo de vida da reserva

O sistema deve controlar os estados de uma reserva, incluindo:

- ativa;
- processando;
- finalizada;
- expirada;
- cancelada.

### RF25 — Expiração automática de reservas

O sistema deve expirar automaticamente reservas em processamento após o período configurado pela biblioteca.

### RF26 — Renovação de reservas

O sistema deve permitir a renovação de reservas quando as regras da biblioteca permitirem, respeitando o limite máximo de renovações configurado.

---

## 3.9 Empréstimos

### RF27 — Registro de empréstimos

O sistema deve permitir que funcionários registrem empréstimos de exemplares disponíveis para clientes.

### RF28 — Consulta de empréstimos

O sistema deve permitir que usuários autorizados consultem os empréstimos existentes.

### RF29 — Registro de devolução

O sistema deve permitir registrar a devolução de um exemplar e finalizar o empréstimo correspondente.

### RF30 — Renovação de empréstimos

O sistema deve permitir a renovação de empréstimos quando as regras da biblioteca permitirem.

### RF31 — Controle do ciclo de vida do empréstimo

O sistema deve controlar os estados dos empréstimos, incluindo:

- ativo;
- finalizado;
- atrasado.

### RF32 — Cálculo do prazo do empréstimo

O sistema deve calcular a data de vencimento do empréstimo utilizando o período configurado para a biblioteca.

---

## 3.10 Controle de conflitos e concorrência

### RF33 — Exclusividade de empréstimo

O sistema deve impedir que um mesmo exemplar possua mais de um empréstimo ativo simultaneamente.

### RF34 — Prevenção de reservas incompatíveis

O sistema deve impedir reservas incompatíveis para o mesmo livro ou exemplar de acordo com as regras configuradas.

### RF35 — Validação de disponibilidade

O sistema deve verificar a disponibilidade do exemplar no momento da criação de um empréstimo ou reserva.

### RF36 — Controle de operações simultâneas

O sistema deve garantir que operações simultâneas envolvendo o mesmo exemplar sejam processadas de forma consistente, impedindo que duas operações confirmem simultaneamente a utilização do mesmo recurso.

### RF37 — Atomicidade das operações

Operações que alterem simultaneamente o estado de um exemplar e de um empréstimo ou reserva devem ser executadas de forma atômica, evitando estados parcialmente concluídos.

---

## 3.11 Multas

### RF38 — Cálculo de multas

O sistema deve calcular multas referentes a empréstimos que ultrapassarem o prazo de devolução, de acordo com a política de multas configurada.

### RF39 — Valor diário da multa

O sistema deve utilizar um valor de multa por dia definido nas configurações da biblioteca.

### RF40 — Consulta de multas

O sistema deve permitir que usuários autorizados consultem as multas associadas aos clientes e aos respectivos empréstimos.

### RF41 — Configuração da política de multas

O sistema deve permitir definir como o valor da multa será aplicado aos empréstimos.

A política deve possuir pelo menos os seguintes modos:

- `FIXA`;
- `POR_PERIODO`.

### RF42 — Política de multa fixa

Quando a política `FIXA` estiver configurada, o empréstimo deve utilizar permanentemente o valor diário da multa vigente no momento de sua criação.

Alterações posteriores no valor da multa não devem modificar o valor aplicado a esse empréstimo.

### RF43 — Política de multa por período

Quando a política `POR_PERIODO` estiver configurada, o sistema deve calcular a multa considerando o valor diário vigente durante cada período em que o empréstimo permaneceu em atraso.

### RF44 — Acumulação de multas por período

Na política `POR_PERIODO`, o sistema deve acumular os valores correspondentes aos diferentes períodos de configuração.

Exemplo:

- primeiros 5 dias de atraso: R$ 1,00 por dia;
- próximos 5 dias: R$ 2,00 por dia.

A multa total será:

`5 × R$ 1,00 + 5 × R$ 2,00 = R$ 15,00`

### RF45 — Preservação do histórico da multa

O sistema deve manter informações suficientes para identificar qual valor de multa estava vigente em cada período utilizado no cálculo.

Alterações posteriores nas configurações não devem apagar ou modificar indevidamente os valores históricos já considerados no cálculo.

---

## 3.12 Configurações do sistema

### RF46 — Gerenciamento das configurações

O sistema deve permitir que administradores consultem e alterem as configurações gerais da biblioteca.

### RF47 — Configuração da expiração de reservas

O sistema deve permitir configurar o período de validade de uma reserva em processamento.

### RF48 — Configuração da renovação de reservas

O sistema deve permitir configurar:

- o tempo adicionado a uma reserva durante uma renovação;
- o número máximo de renovações permitidas.

### RF49 — Configuração do limite de reservas

O sistema deve permitir configurar a quantidade máxima de reservas do mesmo livro que um cliente pode possuir simultaneamente.

### RF50 — Configuração da duração dos empréstimos

O sistema deve permitir configurar o período padrão de duração dos empréstimos.

### RF51 — Configuração da renovação de empréstimos

O sistema deve permitir configurar:

- o tempo adicionado ao prazo durante uma renovação;
- o número máximo de renovações permitidas.

### RF52 — Configuração do valor da multa

O sistema deve permitir configurar o valor diário da multa.

### RF53 — Configuração da política de multas

O sistema deve permitir selecionar a política de aplicação das multas entre os modos disponíveis.

### RF54 — Aplicação das configurações

O sistema deve utilizar as configurações vigentes nas operações correspondentes, respeitando as regras de preservação de informações históricas.

### RF55 — Flexibilidade das regras

O sistema deve permitir alterar as principais regras operacionais por meio das configurações administrativas, sem necessidade de modificar o código-fonte.

---

## 3.13 Histórico e auditoria

### RF56 — Registro de operações

O sistema deve registrar operações relevantes realizadas sobre livros, exemplares, reservas, empréstimos, clientes, funcionários e configurações.

### RF57 — Consulta do histórico

O sistema deve permitir que usuários autorizados consultem o histórico das operações registradas.

### RF58 — Identificação das operações

Cada registro de histórico deve identificar, quando aplicável:

- usuário responsável;
- operação realizada;
- entidade afetada;
- data e hora da operação.

---

# 4. Requisitos não funcionais

### RNF01 — Segurança

As credenciais dos usuários devem ser armazenadas de forma segura, utilizando mecanismos apropriados de proteção.

### RNF02 — Controle de acesso

O sistema deve garantir que cada usuário tenha acesso somente às funcionalidades permitidas pelo seu nível de acesso.

### RNF03 — Integridade dos dados

O sistema deve garantir a integridade dos dados armazenados, evitando estados inválidos e relacionamentos inconsistentes.

### RNF04 — Consistência em operações simultâneas

O sistema deve manter a consistência dos dados mesmo quando operações conflitantes forem realizadas simultaneamente.

### RNF05 — Atomicidade

Operações compostas que dependam umas das outras devem ser executadas de forma atômica.

### RNF06 — Controle de concorrência

O sistema deve possuir mecanismos capazes de evitar conflitos na utilização simultânea de exemplares e outros recursos compartilhados.

### RNF07 — Desempenho

O sistema deve apresentar tempo de resposta adequado para as operações comuns de gerenciamento e consulta.

### RNF08 — Disponibilidade

O sistema deve permanecer disponível durante o período de funcionamento da biblioteca, exceto durante manutenções programadas ou falhas.

### RNF09 — Usabilidade

As funcionalidades devem possuir comportamento consistente e permitir que os usuários executem as operações de forma clara.

### RNF10 — Manutenibilidade

O sistema deve possuir uma estrutura que facilite a manutenção, correção de erros e evolução das funcionalidades.

### RNF11 — Flexibilidade

As principais regras operacionais da biblioteca devem poder ser alteradas por meio das configurações disponíveis, sem necessidade de alterações no código-fonte.

### RNF12 — Compatibilidade

A interface do sistema deve ser compatível com navegadores modernos.

### RNF13 — Escalabilidade

A estrutura do sistema deve permitir o crescimento da quantidade de clientes, livros, exemplares, reservas e empréstimos sem exigir alterações fundamentais em seu funcionamento.

---

# 5. Regras de negócio

### RN01 — Hierarquia de acesso

Usuários somente podem executar operações compatíveis com seu nível de acesso.

### RN02 — Gerenciamento de gerentes

Somente administradores podem criar, alterar ou remover gerentes.

### RN03 — Gerenciamento de funcionários

Somente gerentes ou usuários com permissão equivalente podem criar, alterar ou remover funcionários.

### RN04 — Alteração das configurações

Somente administradores podem alterar as configurações gerais do sistema.

### RN05 — Identificação dos exemplares

Cada exemplar deve possuir uma identificação única.

### RN06 — Empréstimo exclusivo

Um exemplar não pode possuir mais de um empréstimo ativo simultaneamente.

### RN07 — Conflitos simultâneos

Operações simultâneas que tentem utilizar o mesmo exemplar de maneira incompatível não podem ser confirmadas simultaneamente.

### RN08 — Disponibilidade para empréstimo

Um exemplar somente pode ser emprestado quando estiver em uma situação que permita empréstimos.

### RN09 — Prioridade de reservas

As regras de prioridade definidas pela biblioteca devem ser respeitadas durante o processamento de reservas e empréstimos.

### RN10 — Limite de reservas

Um cliente não pode ultrapassar a quantidade máxima configurada de reservas do mesmo livro.

### RN11 — Expiração de reserva

Uma reserva em processamento deve expirar após o período configurado, caso não seja finalizada dentro do prazo.

### RN12 — Limite de renovação de reserva

Uma reserva não pode ser renovada após atingir o número máximo de renovações configurado.

### RN13 — Prazo inicial do empréstimo

O prazo inicial de um empréstimo deve ser determinado pela configuração vigente no momento da criação do empréstimo.

### RN14 — Limite de renovação de empréstimo

Um empréstimo não pode ser renovado após atingir o número máximo de renovações configurado.

### RN15 — Aplicação de multas

A multa deve ser calculada de acordo com a política de multas configurada.

### RN16 — Multa fixa

Na política `FIXA`, o valor diário da multa utilizado pelo empréstimo deve ser definido a partir da configuração vigente no momento da criação do empréstimo.

Alterações posteriores no valor da multa não devem modificar esse valor para o empréstimo.

### RN17 — Multa por período

Na política `POR_PERIODO`, cada período de atraso deve utilizar o valor diário de multa vigente durante aquele período.

### RN18 — Histórico dos valores de multa

O sistema deve preservar o histórico necessário para determinar os valores de multa vigentes em períodos anteriores.

### RN19 — Preservação dos valores acumulados

Alterações no valor da multa não devem apagar ou modificar retroativamente valores de multa que já tenham sido acumulados em períodos anteriores.

### RN20 — Alteração da política de multas

Somente administradores podem alterar a política de aplicação das multas.

### RN21 — Configurações históricas

Alterações em configurações que afetem operações já existentes devem respeitar as regras específicas de cada operação, evitando alterações retroativas indevidas.

### RN22 — Integridade das operações

Uma operação que dependa da alteração de múltiplos registros deve ser concluída integralmente ou não produzir nenhuma alteração parcial.

### RN23 — Permissões hierárquicas

Nenhum usuário pode conceder a outro usuário um nível de acesso superior ao permitido pelo próprio nível hierárquico.

---

# 6. Configurações do sistema

O sistema deve possuir uma estrutura centralizada para armazenar as principais configurações operacionais da biblioteca.

As configurações devem incluir, no mínimo:

- tempo de expiração de reservas;
- tempo adicionado durante a renovação de reservas;
- quantidade máxima de reservas do mesmo livro;
- quantidade máxima de renovações por reserva;
- duração padrão dos empréstimos;
- tempo adicionado durante a renovação de empréstimos;
- quantidade máxima de renovações por empréstimo;
- valor da multa por dia;
- política de aplicação da multa.

## 6.1 Políticas de multa

A política de multa deve possuir os seguintes modos:

### FIXA

O empréstimo utiliza o valor diário vigente no momento de sua criação durante todo o período de atraso.

Exemplo:

```text
Valor no momento da criação: R$ 1,00/dia

Empréstimo:
10 dias de atraso

Multa:
10 × R$ 1,00 = R$ 10,00
```

Mesmo que a biblioteca altere posteriormente a multa para R$ 2,00 por dia, esse empréstimo continuará utilizando R$ 1,00 por dia.

### POR_PERIODO

O empréstimo utiliza o valor correspondente a cada período em que permaneceu em atraso.

Exemplo:

```text
Dias 1–5:  R$ 1,00/dia
Dias 6–10: R$ 2,00/dia

Multa:
5 × R$ 1,00 = R$ 5,00
5 × R$ 2,00 = R$ 10,00

Total = R$ 15,00
```