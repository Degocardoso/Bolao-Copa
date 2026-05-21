# 🏆 Bolão da Copa do Mundo — Guia de Instalação

Site de bolão com login pelo Google, palpites de placar exato e ranking automático.
Tudo roda de graça no **Supabase** (banco + login) + **Vercel** (hospedagem).

**Regra de pontuação:** cravou o placar exato = **3 pontos**. Errou o placar = 0.
**Trava:** cada palpite fecha sozinho no horário de início do jogo. Sem volta.

Você vai seguir 5 etapas. Reserve uns 30–40 minutos. Não precisa saber programar —
é tudo copiar, colar e clicar. Vá com calma.

---

## ✅ Antes de começar

Crie (se ainda não tiver) uma conta em:
- https://supabase.com  (pode entrar com o Google)
- https://vercel.com    (pode entrar com o Google)
- https://github.com    (a Vercel puxa o código daqui)

---

## 1️⃣ Criar o banco de dados no Supabase

1. Entre em https://supabase.com e clique em **New project**.
2. Dê um nome (ex: `bolao-copa`), crie uma senha de banco (guarde-a) e escolha a
   região mais perto (ex: *South America (São Paulo)*). Clique em **Create**.
3. Espere ~2 min até o projeto ficar pronto.
4. No menu lateral, abra **SQL Editor** → **New query**.
5. Abra o arquivo `supabase/schema.sql` deste projeto, copie **tudo**, cole no editor
   e clique em **Run** (canto inferior direito). Deve aparecer "Success".
   ✔️ Isso cria todas as tabelas, o ranking e as regras de segurança.

---

## 2️⃣ Ativar o login com Google

### a) Criar as credenciais no Google
1. Acesse https://console.cloud.google.com → crie um projeto (qualquer nome).
2. Menu → **APIs e serviços** → **Tela de consentimento OAuth**.
   - Tipo: **Externo** → Criar.
   - Preencha nome do app e seu email. Salve e avance até concluir.
   - Em "Usuários de teste" não precisa adicionar ninguém se você publicar o app,
     mas para começar pode adicionar os emails da galera.
3. Menu → **Credenciais** → **Criar credenciais** → **ID do cliente OAuth**.
   - Tipo: **Aplicativo da Web**.
   - Em **URIs de redirecionamento autorizados**, adicione esta URL (troque pelo
     seu projeto Supabase):
     ```
     https://SEU-PROJETO.supabase.co/auth/v1/callback
     ```
     (o endereço exato aparece no próximo passo, no Supabase.)
   - Clique em **Criar**. Guarde o **Client ID** e o **Client Secret**.

### b) Ligar no Supabase
1. No Supabase: **Authentication** → **Providers** → **Google**.
2. Cole o **Client ID** e o **Client Secret**, ative e **Save**.
3. Logo acima aparece a "Callback URL (for OAuth)". Confira que é a mesma que você
   colou no Google. Se for diferente, ajuste lá no Google.

---

## 3️⃣ Pegar as chaves do Supabase

No Supabase: **Project Settings** (engrenagem) → **API**. Anote três coisas:

| Onde | O que copiar |
|------|--------------|
| Project URL | `https://SEU-PROJETO.supabase.co` |
| Project API keys → `anon` `public` | chave longa pública |
| Project API keys → `service_role` `secret` | chave longa secreta ⚠️ |

⚠️ A `service_role` é uma chave de **administrador total**. Nunca a poste em lugar
público nem mande por mensagem. Ela só vai no painel da Vercel (passo 5).

---

## 4️⃣ Subir o código no GitHub

1. Crie um repositório novo (privado) em https://github.com/new (ex: `bolao-copa`).
2. Suba os arquivos deste projeto. Se você não usa terminal, dá pra arrastar os
   arquivos na opção **"uploading an existing file"** do GitHub. Suba a pasta
   inteira **menos** `node_modules` e `.env.local` (esses não vão).

> Dica: o arquivo `.gitignore` já impede o envio do `.env.local` por segurança.

---

## 5️⃣ Publicar na Vercel

1. Entre em https://vercel.com → **Add New** → **Project**.
2. Importe o repositório do GitHub que você acabou de criar.
3. Antes de clicar em Deploy, abra **Environment Variables** e adicione estas quatro
   (uma por uma):

   | Nome | Valor |
   |------|-------|
   | `NEXT_PUBLIC_SUPABASE_URL` | a Project URL do passo 3 |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | a chave `anon public` |
   | `SUPABASE_SERVICE_ROLE_KEY` | a chave `service_role secret` |
   | `NEXT_PUBLIC_ADMIN_EMAILS` | **seu** email do Google (você será o admin) |

   > Pode pôr mais de um admin separando por vírgula:
   > `voce@gmail.com,outro@gmail.com`

4. Clique em **Deploy** e espere ~1 min. A Vercel te dá um endereço tipo
   `https://bolao-copa.vercel.app`. Esse é o link do seu site! 🎉

### Último ajuste (importante)
Depois do deploy, volte no **Supabase → Authentication → URL Configuration** e em
**Site URL** coloque o endereço da Vercel (`https://bolao-copa.vercel.app`).
Em **Redirect URLs** adicione `https://bolao-copa.vercel.app/**`.
Isso garante que o login do Google volte para o seu site certo.

---

## 🎮 Como usar

- **Você (admin):** entre no site, vá na aba **Admin**. Cadastre os times (com emoji
  da bandeira e grupo), depois os jogos (com data e hora de início). Conforme os
  jogos acontecem, lance o placar oficial — o ranking se atualiza sozinho.
- **A galera:** manda o link pra todo mundo. Cada um entra com o Google, vai em
  **Jogos**, define o placar de cada partida e salva. Pode editar até o jogo começar.
  Depois disso, trava. Acompanham tudo em **Ranking** e **Meus Palpites**.

---

## ❓ Dúvidas comuns

- **"Esqueci de cadastrar um time / errei a data."** Tudo é editável no painel Admin
  enquanto o jogo não começou. Dá pra apagar e refazer.
- **"O bandeirão não aparece."** Use o emoji da bandeira no campo "bandeira"
  (ex: 🇧🇷 🇦🇷 🇫🇷). No celular dá pra pegar no teclado de emojis.
- **"Não consigo entrar como admin."** Confirme que o email em `NEXT_PUBLIC_ADMIN_EMAILS`
  é exatamente o mesmo do Google com que você logou (sem espaços).
- **"Mudei uma variável na Vercel."** Depois de alterar variáveis, clique em
  **Redeploy** no painel da Vercel para valer.

Bom bolão! ⚽🏆
