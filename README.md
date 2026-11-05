# EB da Residência - Sistema de Patentes e Divisões

Scripts em Luau para Roblox Studio que permitem dar qualquer patente personalizada a um jogador e colocá-lo em qualquer divisão no jogo **EB da Residência**. O sistema inclui comandos de chat para administradores, salvamento automático das patentes e divisões, e interface visual para os jogadores.

## Instalação

1. No **Explorer** do Roblox Studio, crie dois **ModuleScripts** em `ServerScriptService` chamados `PatenteService` e `DivisaoService`.
2. Cole o conteúdo de `src/PatenteService.lua` no ModuleScript `PatenteService`.
3. Cole o conteúdo de `src/DivisaoService.lua` no ModuleScript `DivisaoService`.
4. Crie um **Script** em `ServerScriptService` chamado `ComandosAdmin` e cole o conteúdo de `src/ComandosAdmin.server.lua`.
5. Crie um **LocalScript** em `StarterPlayer > StarterPlayerScripts` chamado `InterfacePatente` e cole o conteúdo de `src/InterfacePatente.client.lua`.
6. Crie um **LocalScript** em `StarterPlayer > StarterPlayerScripts` chamado `InterfaceDivisao` e cole o conteúdo de `src/InterfaceDivisao.client.lua`.

## Configuração dos administradores

Abra o script `ComandosAdmin` e edite a tabela `ADMIN_IDS` no topo do código, colocando o **UserId** de cada administrador autorizado:

```lua
local ADMIN_IDS = {
	[112233445] = true,  -- Nome do admin
	[556677889] = true,  -- Outro admin
}
```

O dono da place (`game.CreatorId`) é automaticamente considerado admin.

## Uso

Digite no chat com o prefixo `!`:

| Comando | Descrição | Exemplo |
|---------|-----------|---------|
| `!patente <nome> <patente>` | Dá uma patente personalizada | `!patente Joao Coronel-Comandante` |
| `!divisao <nome> <divisao>` | Coloca o jogador numa divisão | `!divisao Joao Forca Aerea` |
| `!remover-patente <nome>` | Remove a patente do jogador | `!remover-patente Joao` |
| `!remover-divisao <nome>` | Remove a divisão do jogador | `!remover-divisao Joao` |
| `!minha-patente` | Mostra sua própria patente e divisão (todos os jogadores) | `!minha-patente` |

O `<nome>` pode ser o **nome de usuário** ou o **nome de exibição** do jogador.

### Exemplos de patentes personalizadas

- `!patente Joao Cel. Comandante Geral`
- `!patente Maria Sgt. Intendente`
- `!patente Pedro Ten. Espacial`
- `!patente Ana Sd. Recruta`

### Exemplos de divisões

- `!divisao Joao Exercito`
- `!divisao Maria Marinha`
- `!divisao Pedro Forca Aerea`
- `!divisao Ana Policia da Residencia`

## Características

- **Patentes ilimitadas e personalizadas**: qualquer texto pode servir como patente.
- **Divisões ilimitadas e personalizadas**: qualquer texto pode ser a divisão.
- **Salvamento automático**: usa `DataStoreService` para persistência.
- **Interface visual**: painéis mostram patente e divisão do jogador.
- **Permissões**: apenas admins definidos podem atribuir/remover patentes.

## Observações

- Em modo Studio (teste), os dados não persistem entre reinícios.
- No jogo publicado, os dados são salvos de verdade via DataStoreService.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/d301aa52-4449-44a7-9894-6ad6ee6ca1ab?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=d301aa52-4449-44a7-9894-6ad6ee6ca1ab
