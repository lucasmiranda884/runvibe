# RunVibe Mobile

Aplicativo Flutter feature-first, offline-first, integrado à API Spring Boot do RunVibe.

## Preparação

Instale Flutter 3.x com Dart 3.6+ e execute, na raiz `mobile`:

```powershell
flutter create --platforms=android,ios --org com.runvibe .
flutter pub get
flutter test
flutter run
```

Por padrão, o aplicativo usa a API pública:
`https://runvibe-api.onrender.com/api/v1/`.

Para desenvolvimento local no emulador Android, sobrescreva o endereço:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1/
```
Android e iOS bloqueiam HTTP puro por padrão. Libere tráfego local somente no build de
desenvolvimento ou, preferencialmente, exponha a API por HTTPS.

## Permissões nativas obrigatórias

Após `flutter create`, adicione ao AndroidManifest permissões de localização fina,
background, internet, foreground service e notificações. No iOS, adicione as chaves
de localização em uso/sempre e o background mode `location`. Os arquivos de exemplo
estão em `platform_config/`.

O uso contínuo do GPS consome bateria. A interface deve explicar claramente ao usuário
por que a permissão “Sempre” é necessária e permitir interromper o rastreamento.
