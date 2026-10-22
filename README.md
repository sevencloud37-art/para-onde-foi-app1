# Para onde foi — app de iPhone

O app abre a página `ParaOndeFoi/index.html` dentro de um app nativo.
O GitHub Actions gera o `.ipa` sem assinatura; o Sideloadly assina com seu Apple ID e instala.

## Gerar o .ipa
1. Envie estes arquivos para um repositório no GitHub (branch `main`).
2. Abra a aba **Actions** → **Gerar IPA**. Cada envio para `main` gera um novo build (ou use **Run workflow**).
3. Quando ficar verde, baixe o artefato **ParaOndeFoi-ipa** e descompacte: dentro está `ParaOndeFoi.ipa`.

## Instalar com o Sideloadly
1. Conecte o iPhone no computador e abra o Sideloadly.
2. Arraste o `ParaOndeFoi.ipa`, escolha o iPhone e digite seu Apple ID. Clique em **Start**.
3. No iPhone: Ajustes → Geral → VPN e Gerenciamento de Dispositivo → confie no seu Apple ID.
4. Com Apple ID gratuito o app vale 7 dias; reinstale pelo Sideloadly para renovar (os dados ficam salvos se você não apagar o app).

## Atualizar o app
Troque o `ParaOndeFoi/index.html` pela versão nova, envie para `main`, baixe o novo `.ipa` e instale por cima.
