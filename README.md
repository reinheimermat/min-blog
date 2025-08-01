# Min Blog - Monorepo

Este é um monorepo que contém tanto o frontend quanto o backend do projeto Min Blog.

## Estrutura do Projeto

```
min-blog/
├── api/          # Backend API (Ruby on Rails)
└── web/          # Frontend (Astro)
```

## Projetos

### 🚀 Web (Frontend)

- **Tecnologia**: Astro + TypeScript
- **Localização**: `./web/`
- **Descrição**: Interface web do blog construída com Astro

### 🔧 API (Backend)

- **Tecnologia**: Ruby on Rails
- **Localização**: `./api/`
- **Descrição**: API REST para gerenciar posts e comentários

## Comandos Úteis

### Para o Frontend (Web)

```bash
cd web
pnpm install    # Instalar dependências
pnpm dev        # Executar em desenvolvimento
pnpm build      # Build para produção
```

### Para o Backend (API)

```bash
cd api
bundle install  # Instalar dependências
bin/dev         # Executar em desenvolvimento
bundle exec rspec # Executar testes
```

## Desenvolvimento

Cada projeto mantém seus próprios arquivos de configuração e dependências. Para trabalhar em ambos simultaneamente, abra dois terminais separados, um para cada projeto.

## Estrutura Git

Este é um monorepo unificado. Ambos os projetos estão sob o mesmo repositório Git, facilitando o gerenciamento de versões e deploy conjunto.
