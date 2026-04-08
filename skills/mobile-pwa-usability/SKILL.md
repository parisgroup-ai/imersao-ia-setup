---
name: mobile-pwa-usability
description: "Use when building or modifying React/Next.js components, pages, layouts, PWA configurations, or CSS/Tailwind files - enforces mobile usability standards with mandatory checks for critical issues (touch targets, viewport, safe areas, accessibility) and recommendations for PWA optimization (manifest, service worker, offline support)"
version: 1.0.0
author: gustavo
tags: [mobile, pwa, usability, ui]
---

# Mobile PWA Usability

Guia para criar interfaces mobile-first em PWAs React/Next.js com foco em usabilidade real.

## Quando Usar

**Triggers automáticos:**
- Componentes React (`.tsx`, `.jsx`)
- Layouts e páginas (`app/`, `pages/`)
- Configurações PWA (`manifest.json`, `manifest.ts`, `next.config.js`)
- CSS/Tailwind (`.css`, `.scss`, `tailwind.config.js`)
- Service workers

## Checklist Crítico (Bloqueante)

**PARE se qualquer item falhar. Corrija antes de continuar.**

| Item | Regra | Como Verificar |
|------|-------|----------------|
| Touch targets | Mínimo 44x44px | `min-h-[44px] min-w-[44px]` em buttons/links |
| Font size inputs | Mínimo 16px | `text-base` ou `text-[16px]` - previne zoom iOS |
| Viewport | `width=device-width, initial-scale=1` | Em `layout.tsx` ou `<head>` |
| Safe areas | Suporte a notch/islands | `pb-[env(safe-area-inset-bottom)]` |
| Contraste | WCAG AA (4.5:1 texto) | Verificar cores primárias |
| Tap delay | Sem delay 300ms | `touch-manipulation` em elementos interativos |
| Horizontal scroll | Não permitido | `overflow-x-hidden` no root |

### Viewport para Next.js 14+

```tsx
// app/layout.tsx
import { Viewport } from 'next';

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
  userScalable: true,
  viewportFit: 'cover', // Para safe areas
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#ffffff' },
    { media: '(prefers-color-scheme: dark)', color: '#0a0a0a' },
  ],
};
```

### Safe Areas (Notch/Dynamic Island)

```tsx
// Para elementos fixos no bottom
<nav className="fixed bottom-0 pb-[env(safe-area-inset-bottom)] ...">

// Para containers principais
<main className="pb-[env(safe-area-inset-bottom)] pt-[env(safe-area-inset-top)]">

// CSS puro
.safe-bottom {
  padding-bottom: max(1rem, env(safe-area-inset-bottom));
}
```

### Touch Targets Corretos

```tsx
// ❌ ERRADO - muito pequeno
<button className="p-1 text-sm">Save</button>

// ✅ CORRETO - 44px mínimo
<button className="min-h-[44px] min-w-[44px] p-3 touch-manipulation">
  Save
</button>

// ✅ Ícone com área de toque expandida
<button className="p-3 -m-3"> {/* padding expande, margin negativa compensa */}
  <Icon className="w-5 h-5" />
</button>
```

### Inputs sem Zoom iOS

```tsx
// ❌ ERRADO - iOS vai dar zoom
<input className="text-sm ..." />

// ✅ CORRETO - 16px mínimo
<input className="text-base ..." /> {/* 16px */}
```

## Recomendações (Não-bloqueantes)

### PWA Manifest (Next.js 14+)

```tsx
// app/manifest.ts
import { MetadataRoute } from 'next';

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'App Name',
    short_name: 'App',
    description: 'Descrição do app',
    start_url: '/',
    display: 'standalone',
    background_color: '#ffffff',
    theme_color: '#0a0a0a',
    icons: [
      { src: '/icon-192.png', sizes: '192x192', type: 'image/png' },
      { src: '/icon-512.png', sizes: '512x512', type: 'image/png' },
      { src: '/icon-maskable.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
    ],
  };
}
```

### Touch Feedback (Active States)

```tsx
// Sempre adicione feedback visual ao toque
<button className="
  active:scale-95 active:bg-opacity-80
  transition-transform duration-100
  touch-manipulation select-none
">
```

### Reduced Motion

```tsx
// Respeite preferências do usuário
<div className="
  motion-safe:animate-fade-in
  motion-reduce:animate-none
">

// CSS
@media (prefers-reduced-motion: reduce) {
  * { animation-duration: 0.01ms !important; }
}
```

### Bottom Navigation

```tsx
// Ações primárias no alcance do polegar
<nav className="
  fixed bottom-0 left-0 right-0
  pb-[env(safe-area-inset-bottom)]
  bg-white border-t
  flex justify-around
">
  <NavItem icon={<Home />} label="Início" />
  <NavItem icon={<Search />} label="Buscar" />
  <NavItem icon={<User />} label="Perfil" />
</nav>
```

### Skeleton Loaders

```tsx
// Prefira skeletons a spinners em mobile
<div className="animate-pulse">
  <div className="h-4 bg-gray-200 rounded w-3/4 mb-2" />
  <div className="h-4 bg-gray-200 rounded w-1/2" />
</div>
```

## Erros Comuns

| Erro | Problema | Correção |
|------|----------|----------|
| `text-sm` em inputs | Zoom no iOS Safari | Use `text-base` (16px) |
| FAB sem safe area | Fica atrás do home indicator | Adicione `bottom-[calc(1.5rem+env(safe-area-inset-bottom))]` |
| Apenas `:hover` | Não funciona em touch | Adicione `:active` states |
| Scroll horizontal | UX ruim, parece quebrado | `overflow-x-hidden` no root |
| Animações pesadas | Drena bateria, trava em devices fracos | Use `will-change`, reduza complexity |

## Validação Pós-Implementação

```bash
# Lighthouse PWA audit
npx lighthouse https://localhost:3000 --only-categories=pwa

# Verificar touch targets
# Chrome DevTools > More tools > Rendering > Show touch target sizes
```

## Quick Reference

```tsx
// Padrão para botão mobile-friendly
<button className="
  min-h-[44px] min-w-[44px]
  touch-manipulation select-none
  active:scale-95 active:opacity-80
  transition-transform duration-100
">

// Padrão para input mobile-friendly
<input className="
  text-base
  py-3 px-4
  rounded-lg
  focus:ring-2 focus:outline-none
"/>

// Padrão para container com safe areas
<main className="
  min-h-screen
  pb-[env(safe-area-inset-bottom)]
  pt-[env(safe-area-inset-top)]
">
```

## Integração com Outras Skills

| Skill | Quando Usar Junto |
|-------|-------------------|
| `frontend-design` | Para design system e estética visual |
| `testing-strategy` | Para testes E2E mobile com Playwright viewport |
| `clean-architecture` | Para estrutura de componentes reutilizáveis |
