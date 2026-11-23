# SFY

Aplicação de **comunicação, partilha de ficheiros multimédia e agendamento de tarefas**, em Node.js puro (sem dependências externas) com base de dados **SQLite**.

![SFY](public/assets/logo.png)

> A logo original anexa (`MEU-LOGO-SF.png`, 8142×8142) foi otimizada para web em `public/assets/logo.png` (2000×2000). Paleta extraída da marca: azul-marinho `#0A3668` / `#14477F`, ouro `#FFB31F` / `#F5A800`, transição oliva `#5E6A3A` e grafite `#5B6672`.

## Arranque rápido

```bash
npm start
```

Ou, no Windows, duplo clique em **`start.bat`**. Depois abre **https://localhost:3000**.

### HTTPS local

A app arranca com **HTTPS** sempre que existir `certs/sfy-local.pfx` (o `start.bat` gera-o automaticamente na primeira execução). O certificado é autoassinado e inclui `localhost`, `127.0.0.1` e o IP da rede local.

- No mesmo PC: **https://localhost:3000**
- Noutro dispositivo da mesma Wi-Fi: **https://<IP-deste-PC>:3000** (ex.: `https://192.168.0.120:3000`)

O browser pode apresentar um aviso de segurança no primeiro acesso. Clica em **Avançado → Continuar** ou confia no certificado uma vez:

```powershell
Import-Certificate -FilePath "certs\sfy-local.cer" -CertStoreLocation Cert:\CurrentUser\Root
```

Para voltar a HTTP (apenas para desenvolvimento), define `HTTPS=0`. O HTTPS é necessário para chamadas WebRTC a partir de outros dispositivos da rede.

### Link público para os utilizadores

Duplo clique em **`start-public.bat`**. O script arranca o servidor e cria um **Quick Tunnel** da Cloudflare, mostrando no terminal um endereço público HTTPS, por exemplo:

```
https://palavras-aleatorias.trycloudflare.com
```

Partilha esse endereço com os utilizadores: eles abrem a app, criam conta e entram normalmente. Não é preciso abrir portas no router nem configurar DNS.

> Atenção: é um túnel temporário — o endereço muda cada vez que o script é executado e deixa de funcionar quando a janela é fechada. A app não tem contas de demonstração: todos os acessos são feitos com contas reais criadas por registo.

### Link fixo gratuito com Serveo

Para um endereço curto e estável sem comprar domínio: **`https://sfywork.serveo.net`**.

Configuração única:

1. Abre `https://console.serveo.net` e cria uma conta gratuita.
2. Em **Keys → SSH keys**, adiciona o conteúdo de `certs\serveo_ed25519.pub` (a chave já foi gerada; a privada fica em `certs\serveo_ed25519`).
3. Em **Domains**, reserva o hostname `sfywork.serveo.net`.

Depois basta duplo clique em **`start-serveo.bat`**. O servidor SFY continua em `https://localhost:3000` e abre-se um portal HTTP interno em `127.0.0.1:3001` apenas para o túnel; o Serveo termina o TLS e entrega em HTTPS. A app gera os links de confirmação/recuperação com `https://sfywork.serveo.net` corretamente.

Notas: contas gratuitas mostram um aviso do Serveo na primeira visita (clicar em **Continue**); `TUNNEL_PORT` permite mudar a porta interna se 3001 estiver ocupada.

### Link fixo com a Cloudflare

Um endereço **fixo** da Cloudflare exige um domínio (não existe URL permanente gratuita sem ele). Podes usar um domínio próprio ou um subdomínio gratuito (ex.: DuckDNS), desde que o domínio esteja na tua conta Cloudflare.

1. Cria/configura o domínio na Cloudflare (plano gratuito chega).
2. Executa:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\setup-fixed-link.ps1 -Domain sfy.exemplo.com
```

O script abre o browser para autenticar na Cloudflare, cria o túnel nomeado `sfy`, cria o registo DNS e grava `certs\tunnel-config.yml`. Depois, arranca sempre com **`start-fixed.bat`** — o link `https://sfy.exemplo.com` mantém-se igual mesmo após reiniciar o PC.

Se o PC estiver atrás de uma rede que bloqueia QUIC, o script `start-fixed.bat` pode ser ajustado com `--protocol http2`.

### Conta SFY

A conta ativa desta instalação é `sfancony11@gmail.com` (perfil Individual). Não existem contas de demonstração nem botão de acesso demo. Novos utilizadores são criados apenas por registo legítimo e podem escolher **três métodos de confirmação**: **email**, **WhatsApp** ou **SMS**.

Se o fornecedor de email estiver indisponível (por exemplo, Brevo a devolver `SMTP account is not yet activated`), o registo continua a funcionar mas a conta fica pendente. O administrador pode ativar contas reais **apenas no PC do servidor**, depois de confirmar a identidade do utilizador por outro meio:

```bat
node tools\manage-users.js list
node tools\manage-users.js approve utilizador@exemplo.com
```

O comando `approve` apenas marca a conta como confirmada e envia uma notificação interna; não cria contas, não define senhas e não expõe links de confirmação na web. Consulta `node tools\manage-users.js pending` para ver contas à espera e `node tools\manage-users.js revoke <email>` para retirar a confirmação.

#### Confirmação por WhatsApp e SMS

No registo, o utilizador escolhe o método. Para WhatsApp/SMS é obrigatório indicar o número de telemóvel (o mesmo fica associado à conta para pesquisa por contacto).

- **Email:** a app envia o link de confirmação pelo fornecedor configurado (`data/mail.env`).
- **WhatsApp:** a app gera um código de 6 dígitos (10 minutos) e abre um link `wa.me` com mensagem pré-preenchida para o número SFY configurado. O utilizador envia a mensagem; o administrador vê o código com `node tools\manage-users.js codes` e marca a receção com `node tools\manage-users.js receive <email>`. Só depois o utilizador consegue confirmar o código no ecrã.
- **SMS:** a app envia o código por um gateway HTTP configurado em `data/sms.env` (Twilio ou gateway JSON genérico). O código só é aceite depois de o gateway confirmar o envio.

Configuração em `data/sms.env` (copiar de `data/sms.env.example`):

```bat
WHATSAPP_NUMBER=244923456789

SMS_PROVIDER=twilio
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_FROM=+244...
```

Para gateway genérico, usa `SMS_PROVIDER=generic`, `SMS_API_URL`, `SMS_API_TOKEN` e `SMS_FROM`; a app faz `POST` JSON com `{ to, from, text }`. O ecrã de registo mostra apenas os métodos configurados; o servidor volta a validar o método antes de enviar.

Os códigos e tentativas ficam em `verification_codes` e `verification_outbox`, com expiração de 10 minutos e limite de 5 tentativas. Nunca são devolvidos em respostas através de túnel/proxy; apenas em acesso direto ao PC (`devCode`), tal como os tokens de email.

### Ecrãs, telemóveis e instalação

A interface adapta-se a desktop, tablet e telemóvel (Android, iOS e outros sistemas). Em ecrãs estreitos o menu lateral fecha e abre pelo botão ☰, as colunas empilham-se e todo o conteúdo pode ser percorrido por scroll — incluindo os formulários de entrada e registo em ecrãs baixos.

A app é uma **PWA**: no Chrome/Edge, usa **Instalar aplicação** no menu do browser; no iPhone/iPad, **Partilhar → Adicionar ao ecrã inicial**. Abre em modo próprio, sem barras do browser. São respeitadas as áreas seguras (notch/barra de gestos) e os alvos de toque são amplos. Para chamadas WebRTC funciona melhor com HTTPS (ver acima).

## Funcionalidades

- **Cadastro com email e senha**, com confirmação por **email, WhatsApp ou SMS** (código de 6 dígitos) e **recuperação de senha** por token (24 h).
- **Três tipos de perfil**: Individual, Comercial e Empresarial. Ao escolher Comercial ou Empresarial no registo abrem-se os campos de nome comercial/empresa e NIF; depois podes completar localidade e site em *Perfil*.
- **Foto de perfil**: clica na avatar em *Perfil* ou em **Editar perfil** para carregar PNG, JPG, WEBP ou GIF até 2 MB, com pré-visualização e opção de remover. A imagem fica em `data/avatars` (fora da base de dados, sem expiração) e aparece em mensagens, tarefas e contactos. Se não houver foto, mostram-se as iniciais com a cor escolhida.
- **Pesquisa de contactos em duas vias** (estilo WhatsApp): pela barra de pesquisa procuras simultaneamente por **email** e **contacto telefónico** associado à conta; o resultado indica qual dos dois correspondeu.
- **Ficheiros até 20 MB** (imagens, vídeos, áudio e documentos) com **validade de 1 mês**: expirados são removidos da base e do disco automaticamente ao arrancar e de hora em hora. Nunca ficam guardados na memória do dispositivo cliente.
- **Mensagens em tempo real** (SSE) com histórico, anexos e indicadores de leitura.
- **Grupos** com criação, administrador, adição/remoção de membros, edição e eliminação.
- **Chamadas de voz e vídeo** entre membros (WebRTC + sinalização no servidor), com histórico de chamadas, silenciar, câmara e chamadas perdidas.
- **Agendamento de tarefas** com prazo, prioridade, responsável, lembretes e quadro Kanban.
- **Calendário mensal**, painel com estatísticas e notificações em tempo real.

### Privacidade das conversas

Cada conta vê **apenas as suas conversas e ficheiros**. As mensagens diretas são privadas entre os dois participantes; os grupos de trabalho só são visíveis para membros e partilhas de ficheiros feitas num grupo são revogadas automaticamente quando o membro sai ou o grupo é eliminado. O directório de utilizadores e a pesquisa por nome mostram apenas contactos e pessoas com quem já existe conversa; a pesquisa por email/telefone exige correspondência exata. Dados pessoais (email, telefone, NIF, localização) nunca aparecem em payloads de terceiros, e fotos de perfil só podem ser vistas por contactos. Ao trocar de conta, todo o estado em memória é limpo.

### Chamadas entre redes diferentes

As chamadas usam WebRTC com sinalização no servidor. Para funcionar em NAT simétrico, redes móveis ou com UDP bloqueado é necessário um servidor **TURN**. Configura-o no ambiente antes de arrancar:

```
TURN_URLS=turn:turn.exemplo.com:3478?transport=udp,turn:turn.exemplo.com:3478?transport=tcp
TURN_USERNAME=utilizador
TURN_CREDENTIAL=senha
```

Sem TURN, as chamadas podem falhar entre redes distintas mesmo com a sinalização correta. O cliente obtém esta configuração por `/api/config`.

### Caixa local e envio de emails

Em acesso direto ao próprio PC (`localhost`), os emails de confirmação/recuperação estão sempre disponíveis na **caixa de correio de teste**, mesmo que um fornecedor externo esteja configurado ou tenha falhado. No ecrã de login, *Esqueci-me da senha* tem o botão **Caixa local de emails (teste)**: introduz o email da conta e vês o assunto, o token e o link de redefinição. A API correspondente é `/api/mail/local?email=...` (sem sessão); com sessão, `/api/mail/outbox` mostra só as mensagens do utilizador autenticado. Por segurança, ambos os endpoints e os tokens/link só funcionam em acesso direto ao PC — nunca através do link público/túnel.

Para envio real, copia `data/mail.env.example` para `data/mail.env` e preenche. O servidor lê esse ficheiro ao arrancar (fora da pasta pública). O fornecedor é detetado automaticamente: `BREVO_API_KEY` → Brevo, `RESEND_API_KEY` → Resend, senão SMTP. Podes forçar com `MAIL_PROVIDER=brevo|resend|smtp`.

**Brevo (API HTTP, sem App Password):** cria uma chave em *SMTP & API → API Keys* e verifica o remetente em *Senders*:

```
MAIL_PROVIDER=brevo
SMTP_FROM=teu-email-verificado@gmail.com
BREVO_API_KEY=xkeysib-...
```

**Resend (API HTTP):** usa um domínio verificado ou o remetente de teste `onboarding@resend.dev`:

```
MAIL_PROVIDER=resend
SMTP_FROM=SFY <onboarding@resend.dev>
RESEND_API_KEY=re_...
```

**SMTP (Gmail/Outlook):** suporta STARTTLS e TLS implícito.

**Gmail:** ativa a verificação em dois passos e cria uma *App Password* em `myaccount.google.com/apppasswords`. Usa:

```
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_STARTTLS=1
SMTP_SECURE=0
SMTP_FROM=teu-email@gmail.com
SMTP_USER=teu-email@gmail.com
SMTP_PASS=senha-de-aplicacao-16-caracteres-sem-espacos
```

**Outlook/Hotmail:** em `account.microsoft.com/security` cria uma *App password* (ou usa a senha normal se a conta ainda permitir autenticação básica):

```
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_STARTTLS=1
SMTP_SECURE=0
SMTP_FROM=teu-email@outlook.com
SMTP_USER=teu-email@outlook.com
SMTP_PASS=...
```

Servidor próprio com SSL implícito: `SMTP_PORT=465`, `SMTP_SECURE=1`, `SMTP_STARTTLS=0`.

Ao arrancar, o banner indica `Emails SMTP ...`, `Emails brevo (API) ...` ou `caixa local (sem fornecedor)`. A caixa local passa a mostrar `Enviado` nos emails entregues; se o envio falhar, a mensagem fica guardada localmente e o erro é registado no console. Testa com `node tools/check-mail.js o-teu-email@exemplo.com`.

> **Brevo em conta gratuita:** se a API devolver `HTTP 403 permission_denied — Your SMTP account is not yet activated`, a conta precisa de ativação manual de envio transacional. Abre um ticket em *Brevo → Ajuda/Suporte* a pedir a ativação da plataforma de envio. Enquanto isso, usa `node tools\manage-users.js approve <email>` (ver *Conta SFY*) para ativar contas reais sem depender do email.

> O link incluído no email usa o endereço com que a página foi aberta. Com o túnel temporário, o link aponta para o `trycloudflare.com` ativo; com domínio próprio, aponta para esse domínio.

## Base de dados e migrações

`data/sfy.db` é criada automaticamente. Ao arrancar, `src/migrate.js` aplica migrações **incrementais, transacionais e idempotentes** registadas em `schema_migrations`: adiciona colunas e tabelas novas sem apagar nem reescrever dados existentes. Contas antigas são marcadas como já confirmadas; não são criados dados de demonstração.

## Estrutura

```
web_sfy/
├─ src/
│  ├─ server.js     servidor HTTP e ficheiros estáticos
│  ├─ api.js        rotas REST
│  ├─ db.js         esquema inicial + seed + limpeza
│  ├─ migrate.js    migrações automáticas sem perda de dados
│  ├─ auth.js       senhas scrypt, sessões e cookies
│  ├─ mailer.js     tokens e entrega de email (caixa local ou SMTP)
│  ├─ calls.js      sinalização e histórico de chamadas
│  ├─ events.js     hub SSE
│  ├─ http.js       auxiliares HTTP e multipart
│  └─ constants.js  limites (20 MB / 1 mês) e regras da marca
├─ public/          interface (index.html, css, js, logo)
├─ data/            base SQLite (gerada)
├─ uploads/         ficheiros enviados (gerida automaticamente)
└─ start.bat
```

## Requisitos

- Node.js **22.5+** (módulo nativo `node:sqlite`).
- Navegador com suporte a `getUserMedia` / `RTCPeerConnection` para chamadas (idealmente HTTPS ou `localhost`).

Não há build nem instalação de pacotes: `npm start` é suficiente.
