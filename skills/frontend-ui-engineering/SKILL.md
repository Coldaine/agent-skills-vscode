---
name: frontend-ui-engineering
description: Engineers frontend UIs and component systems. Use when building web interfaces, React/Vue/Svelte components, or design systems. Use when evaluating frontend architecture, accessibility, or performance. Use for CSS layout, state management, and browser API patterns.
user-invocable: true
---

# Frontend UI Engineering

## Overview

Frontend engineering sits at the intersection of software engineering, design, and user experience. It's responsible for everything the user directly interacts with: the visual interface, interaction patterns, accessibility, and performance characteristics that determine whether a product feels fast and reliable.

Modern frontend has significant complexity: component architecture, state management, browser compatibility, accessibility, performance optimization, build tooling, and type safety. This skill covers the engineering patterns and principles that make frontend codebases maintainable and performant.

## Core Philosophy

### Progressive Enhancement

Build for the lowest common denominator first, then enhance. HTML that works without JavaScript, CSS that works without custom properties, JavaScript that degrades gracefully. This approach produces more resilient applications and naturally prioritizes accessibility.

### Semantic HTML First

The right HTML element conveys meaning to browsers, search engines, and assistive technologies. A `<button>` is focusable, keyboard-activatable, and announces itself as a button to screen readers. A `<div>` with click handler is none of those things without significant extra work.

Start with semantic HTML before adding CSS or JavaScript. Most accessibility problems are easier to prevent than to retrofit.

### Component Architecture Principles

- **Single responsibility**: Each component does one thing well
- **Composable**: Components combine to produce complex UIs
- **Encapsulated**: Internal implementation details are hidden; public API is explicit
- **Testable**: Components can be rendered and tested in isolation

## Component Design

### Component API Design

Components are APIs. Apply API design principles:

```tsx
// Avoid: vague props that require knowing implementation details
<Modal type="1" config={{ x: true, y: false }} />

// Prefer: props that express intent
<Modal variant="confirmation" dismissible onClose={handleClose}>
  {children}
</Modal>
```

Principles:
- Name props for what they mean, not how they're implemented
- Boolean props for binary states (`disabled`, `loading`, `required`)
- Enum/union types for multi-state variants (`variant: 'primary' | 'secondary' | 'danger'`)
- Children for content composition rather than content props where possible
- Callbacks named `on{Event}` (not `handle{Event}` — that's the consumer's job)

### Controlled vs. Uncontrolled Components

**Controlled**: Parent owns the state; component receives value and onChange.
```tsx
<Input value={name} onChange={setName} />
```

**Uncontrolled**: Component owns the state internally; parent uses refs or event handlers.
```tsx
<Input defaultValue="initial" ref={inputRef} />
```

Default to uncontrolled for simple cases; use controlled when the parent needs to react to or control the value. Form libraries (React Hook Form, Formik) generally prefer uncontrolled.

### Compound Components

For complex components with multiple parts, compound component pattern makes the API flexible:

```tsx
<Select>
  <Select.Trigger>Choose an option</Select.Trigger>
  <Select.Content>
    <Select.Item value="a">Option A</Select.Item>
    <Select.Item value="b">Option B</Select.Item>
  </Select.Content>
</Select>
```

Shared state between parts lives in context. Each part can be styled and extended independently.

## State Management

### Collocate State

State should live as close to where it's needed as possible. Before reaching for global state, ask:
- Does this state need to be shared across distant components?
- Would lifting state up work?
- Is this actually UI state that belongs in the component?

```
Local component state → Context → External store (Zustand, Redux, Jotai)
```

Each step up the hierarchy has higher coordination cost. Use the minimum necessary scope.

### URL as State

For state that should survive page refresh or be shareable in a URL — search filters, pagination, active tab, modal visibility — put it in the URL. This is often neglected but provides significant UX benefits: back button works, links can be shared, refreshing preserves context.

### Server State vs. UI State

Distinguish between:
- **Server state**: Data that lives on the server, needs fetching, caching, and synchronization (use React Query, SWR, or similar)
- **UI state**: Ephemeral state that only exists in the client (is this dropdown open? what's in this text field?)

Treating server state as UI state leads to complex manual caching logic. Dedicated server state libraries handle refetching, cache invalidation, optimistic updates, and background synchronization.

### Derived State

Don't store state that can be computed from other state:

```tsx
// Avoid: storing derived state
const [items, setItems] = useState([]);
const [itemCount, setItemCount] = useState(0); // redundant

// Prefer: compute from source of truth
const [items, setItems] = useState([]);
const itemCount = items.length; // derived
```

Derived state means one state update instead of two, no risk of inconsistency, no extra re-render.

## CSS Architecture

### Layout Primitives

Master CSS layout fundamentals before reaching for utility frameworks:

**Flexbox**: One-dimensional layout (row or column). Good for component-level layout, alignment, distribution.
```css
.toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
}
```

**Grid**: Two-dimensional layout (rows and columns). Good for page-level layout, complex arrangements.
```css
.dashboard {
  display: grid;
  grid-template-columns: 240px 1fr;
  grid-template-rows: 64px 1fr;
  min-height: 100vh;
}
```

**Container Queries**: Apply styles based on the parent container's size, not the viewport. More useful than media queries for reusable components.
```css
.card-grid {
  container-type: inline-size;
}
@container (min-width: 600px) {
  .card { grid-column: span 2; }
}
```

### CSS Custom Properties for Design Tokens

Define design decisions as variables; apply consistently:

```css
:root {
  --color-primary: #0066cc;
  --color-primary-hover: #0052a3;
  --spacing-base: 8px;
  --radius-md: 6px;
  --font-size-sm: 0.875rem;
  --shadow-card: 0 1px 3px rgba(0,0,0,0.12);
}
```

Theme variants (dark mode, brand themes) just override the variables at the appropriate scope.

### CSS Methodologies

**Utility-first (Tailwind)**: Compose styles from small utility classes. High consistency, low cognitive overhead, verbose HTML. Well-suited for teams.

**CSS Modules**: Locally-scoped CSS files. Good balance of expressiveness and encapsulation. No runtime overhead.

**CSS-in-JS (styled-components, Emotion)**: Co-locate styles with components. Dynamic styles based on props. Runtime overhead; zero-runtime alternatives (vanilla-extract, Linaria) avoid this.

**BEM**: Block-Element-Modifier naming convention for plain CSS. Explicit, verbose, but predictable.

No single right answer; pick the approach that fits the team and toolchain.

## Performance

### Core Web Vitals

Google's metrics for user-centric performance:

- **LCP (Largest Contentful Paint)**: Loading performance. Time until the largest visible element is rendered. Target: < 2.5s
- **FID/INP (Interaction to Next Paint)**: Interactivity. Time from user input to next paint. Target: < 200ms
- **CLS (Cumulative Layout Shift)**: Visual stability. Unexpected layout shifts during load. Target: < 0.1

### Rendering Performance

**Avoid unnecessary renders**: Use `memo`, `useMemo`, `useCallback` when renders are expensive, but profile first — premature optimization adds complexity without benefit.

**Virtualize long lists**: Rendering 1000 DOM nodes when only 20 are visible is wasteful. Use `react-virtual`, `@tanstack/virtual`, or similar for long lists.

**Code splitting**: Split bundles by route. Load only the code needed for the current page.
```tsx
const HeavyComponent = lazy(() => import('./HeavyComponent'));
```

**Image optimization**: Serve appropriately sized images, use modern formats (WebP, AVIF), include width/height to prevent layout shift, lazy-load below-the-fold images.

### Bundle Size

Keep JavaScript bundles small:
- Import only what you use (tree shaking requires ES modules)
- Audit bundle size with bundlephobia, webpack-bundle-analyzer, or similar
- Prefer smaller alternatives when functionality is equivalent
- Lazy load non-critical features

## Accessibility

### The Four WCAG Principles (POUR)

- **Perceivable**: Content can be perceived by users regardless of sensory ability
- **Operable**: Interface can be operated without a mouse, with assistive tech
- **Understandable**: Content is readable and UI behavior is predictable
- **Robust**: Content works with current and future assistive technologies

### Practical Accessibility Patterns

**Keyboard navigation**: Every interactive element must be keyboard accessible. Test by tabbing through your UI. Manage focus when content changes (modal opens, route changes).

**Color contrast**: Text must have sufficient contrast against its background. Use tooling (Colour Contrast Analyser, browser devtools) to verify. Never use color alone to convey information.

**Alternative text**: Images need descriptive alt text. Decorative images get `alt=""`. Complex images (charts, diagrams) need extended descriptions.

**Forms**: Every input needs a visible label (not just placeholder). Error messages must be programmatically associated with the field. Group related inputs with `<fieldset>` and `<legend>`.

**ARIA**: Use ARIA roles and attributes to supplement semantic HTML when native elements aren't sufficient. First rule of ARIA: don't use ARIA if a native HTML element provides the semantics. Wrong ARIA is worse than no ARIA.

### Testing Accessibility

- **Automated**: axe-core, eslint-plugin-jsx-a11y (catches ~30% of issues)
- **Manual keyboard testing**: Navigate with Tab, Shift+Tab, Enter, Space, Arrow keys
- **Screen reader testing**: NVDA+Firefox (Windows), VoiceOver+Safari (Mac), TalkBack (Android)
- **Browser devtools**: Accessibility inspector, contrast checker

## Forms

### Controlled Forms with Validation

For complex forms, use a form library rather than managing state manually:

```tsx
// React Hook Form example
const { register, handleSubmit, formState: { errors } } = useForm<FormValues>();

// Validation schema (Zod)
const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'At least 8 characters'),
});
```

### UX Principles for Forms

- Validate on blur (not on every keystroke), and after the first submit attempt
- Show errors at the field level, not just at the top
- Preserve user input on error — don't reset the form
- Clearly distinguish required from optional fields
- Provide inline help text for non-obvious requirements
- After success, provide clear confirmation

## Testing Frontend Code

### Testing Pyramid for Frontend

- **Unit tests**: Individual functions and utilities — fast, isolated
- **Component tests**: Render a component, interact with it, assert on output (React Testing Library)
- **Integration tests**: Multiple components together, including data fetching (Mock Service Worker for API mocking)
- **E2E tests**: Full user flows in a real browser (Playwright, Cypress) — slow but highest confidence

### React Testing Library Philosophy

Test behavior, not implementation:

```tsx
// Avoid: testing implementation details
expect(component.state.isOpen).toBe(true);

// Prefer: testing what the user sees
expect(screen.getByRole('dialog')).toBeInTheDocument();
```

Query by accessibility role > text content > test ID. If you need test IDs for everything, the component may have accessibility issues.

## Common Patterns

### Error Boundaries

Catch JavaScript errors in component subtrees and display fallback UI:

```tsx
class ErrorBoundary extends React.Component {
  state = { hasError: false };
  static getDerivedStateFromError() { return { hasError: true }; }
  render() {
    return this.state.hasError
      ? <ErrorFallback />
      : this.props.children;
  }
}
```

### Optimistic Updates

Update the UI immediately on user action, then confirm with the server. Revert on error:

```tsx
// Using React Query mutation
const mutation = useMutation(updateTodo, {
  onMutate: async (newTodo) => {
    await queryClient.cancelQueries(['todos']);
    const previous = queryClient.getQueryData(['todos']);
    queryClient.setQueryData(['todos'], old => [...old, newTodo]); // optimistic
    return { previous };
  },
  onError: (err, newTodo, context) => {
    queryClient.setQueryData(['todos'], context.previous); // revert
  },
});
```

### Portal Pattern

Render content outside the component's DOM position (modals, tooltips, dropdowns):

```tsx
function Modal({ children }) {
  return createPortal(
    <div className="modal-overlay">{children}</div>,
    document.getElementById('modal-root')
  );
}
```

## Checklist

### Component Design

- [ ] Does the component have a single, clear responsibility?
- [ ] Is the public API (props) clear and intention-revealing?
- [ ] Are implementation details encapsulated?
- [ ] Can it be used without knowing how it's implemented?

### Accessibility

- [ ] Semantic HTML used as the base layer?
- [ ] All interactive elements keyboard-accessible?
- [ ] Sufficient color contrast (4.5:1 for normal text, 3:1 for large text)?
- [ ] Images have appropriate alt text?
- [ ] Forms have properly associated labels?
- [ ] Focus management handled for dynamic content changes?

### Performance

- [ ] Images sized appropriately and using modern formats?
- [ ] Long lists virtualized?
- [ ] Routes code-split?
- [ ] Core Web Vitals measured?

### Testing

- [ ] Components tested via user-facing behavior, not implementation?
- [ ] Key user flows covered by integration or E2E tests?
- [ ] Accessibility tested with axe or keyboard navigation?
