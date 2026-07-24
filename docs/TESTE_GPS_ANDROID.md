# Validação do RunVibe em um aparelho Android

Este roteiro valida o que não pode ser certificado apenas pelo computador:
GPS real, tela bloqueada e restrições de bateria do fabricante.

## Preparação

1. Instale o APK de produção no aparelho.
2. Abra o RunVibe e faça cadastro ou login com acesso à internet.
3. Conceda localização precisa.
4. Nas configurações do Android, defina a localização do RunVibe como
   **Permitir o tempo todo**.
5. No Android 13 ou superior, permita notificações.
6. Em Bateria, escolha **Sem restrições** para o RunVibe. Em aparelhos Samsung,
   Xiaomi, Motorola, Oppo ou similares, remova também o app das listas de
   suspensão/otimização automática.

## Teste principal

1. Inicie uma corrida ao ar livre e confirme que a notificação persistente
   aparece.
2. Caminhe ou corra por pelo menos 15 minutos.
3. Bloqueie a tela por 5 minutos durante o percurso.
4. Desbloqueie e confirme que tempo, distância e linha no mapa continuaram.
5. Pause por 1 minuto; o tempo decorrido deve continuar, mas o tempo em
   movimento não deve aumentar.
6. Retome, percorra mais alguns metros e finalize.
7. Confirme o resumo e a atividade no feed.

## Teste offline

1. Inicie outra corrida com internet.
2. Antes de finalizar, ative o modo avião.
3. Finalize a corrida. Ela deve permanecer salva como pendente de
   sincronização.
4. Desative o modo avião e aguarde a reconexão.
5. Confirme que a atividade foi enviada apenas uma vez e aparece no feed.

## Critérios de aprovação

- O serviço permanece ativo com a tela bloqueada.
- A rota não apresenta saltos grandes incompatíveis com o percurso.
- Pausa e retomada não duplicam pontos nem tempo em movimento.
- Nenhuma corrida finalizada é perdida sem rede.
- Ao voltar a conexão, a sincronização acontece sem duplicar a atividade.

## Observações do plano gratuito

O backend usa o plano gratuito do Render e pode dormir após ficar sem tráfego.
A primeira chamada depois desse período pode levar cerca de um minuto. Isso não
apaga a corrida: o aplicativo mantém a atividade local e tenta sincronizar
novamente quando a API estiver disponível.

Forçar a parada do aplicativo nas configurações do Android encerra serviços em
segundo plano por decisão do sistema. Nenhum aplicativo pode contornar essa ação.
