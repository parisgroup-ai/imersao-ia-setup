---
name: mobile-native-bestpractices
description: Use when building or reviewing React Native or Expo code for architecture, UX, performance, or native best practices.
---

# Mobile Native Best Practices

Production-grade React Native/Expo guide focused on real-device performance, native UX, and maintainability.

## When to Use

- React Native screen/component files (`.tsx`, `.jsx`)
- Expo configuration (`app.json`, `app.config.ts`)
- Navigation setup (React Navigation stacks, tabs)
- Native module integration (`expo-*` packages)
- Hooks, context providers, StyleSheet, push/voice/sensor code

## 1. Architecture

### Folder Structure

```
src/
  screens/          # Full-page components (1 per route)
  components/       # Reusable UI (stateless when possible)
  hooks/            # Custom hooks (data fetching, behavior, sensors)
  context/          # React Context providers (thin — delegate to hooks)
  lib/
    api.ts          # HTTP client (single entry point)
    config.ts       # App config + AsyncStorage persistence
    domain/         # Pure business logic (zero React imports)
  navigation/       # Type-safe route definitions
  types/            # Shared TypeScript contracts
```

### Principles

- **Screens orchestrate**: compose hooks + components, never own business logic
- **Hooks own data**: fetching, caching, state transforms live in hooks
- **Domain is pure**: `lib/domain/` = plain TypeScript, no React
- **Context is thin**: providers wire hooks, never implement logic

| Anti-pattern | Fix |
|---|---|
| Business logic in screens | Extract to `lib/domain/` |
| API calls inside components | Extract to `lib/api.ts` + hook |
| Fat context providers | Split by update frequency |
| Types inlined in components | Centralize in `types/` |

## 2. Performance

### Render Optimization

Re-renders cross the JS-native bridge. Every one matters on real devices.

```tsx
const ProcessCard = React.memo(({ process }: Props) => { /* ... */ });

const handlePress = useCallback(() => {
  navigation.navigate('Detail', { id: item.id });
}, [item.id]);

const sortedItems = useMemo(
  () => items.sort((a, b) => b.updatedAt - a.updatedAt),
  [items]
);
```

### FlatList

```tsx
<FlatList
  data={items}
  keyExtractor={(item) => item.id}
  renderItem={renderItem}          // useCallback
  getItemLayout={getItemLayout}    // fixed-height items
  windowSize={5}
  maxToRenderPerBatch={10}
  removeClippedSubviews={true}     // Android
  initialNumToRender={10}
/>
```

### Images

Use `expo-image` (not `Image` from react-native) — it handles caching, blurhash placeholders, and transitions natively.

### Animations

```tsx
Animated.spring(animatedValue, {
  toValue: 1,
  useNativeDriver: true,   // runs on UI thread
  bounciness: 6,
  speed: 18,
}).start();
```

- `useNativeDriver: true` for transform/opacity (not layout props)
- Spring > timing for interactive elements
- iOS favors spring physics, Android favors ease curves
- For gesture+animation combos, prefer `react-native-reanimated`

### StyleSheet

Always at module scope — sends styles to native once at startup:

```tsx
const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0b1020' },
});
```

## 3. Navigation

### Type-safe Routes

```tsx
export type RootStackParamList = {
  Home: undefined;
  Detail: { id: string };
  Settings: undefined;
};

// In screens
type Props = NativeStackScreenProps<RootStackParamList, 'Detail'>;
export default function DetailScreen({ route, navigation }: Props) {
  const { id } = route.params; // fully typed
}
```

- Use `createNativeStackNavigator` for native transitions
- Nest navigators: Tabs contain Stacks
- Deep linking: configure `scheme` in `app.json` + `linking` in NavigationContainer

## 4. State Management

| Scope | Tool | Example |
|-------|------|---------|
| Component-local | `useState` | Form input, collapsed state |
| Cross-component | React Context | Auth, theme, config |
| Server state | Custom hook + fetch | API data, polling |
| Persisted | AsyncStorage | Preferences, tokens |
| Complex global | Zustand (if needed) | Frequent cross-tree updates |

### Thin Context Pattern

```tsx
export function AppProvider({ children }: { children: ReactNode }) {
  const config = useConfig();          // hook does the work
  const health = useHealth(config);    // hook does the work
  return (
    <AppContext.Provider value={{ ...config, health }}>
      {children}
    </AppContext.Provider>
  );
}
```

### AsyncStorage

- Versioned keys: `app.config.v1`
- Graceful fallback on read/write errors (keep in memory)
- Never store tokens in AsyncStorage — use `expo-secure-store`

## 5. Networking

### HTTP Client

Centralize in `lib/api.ts`. See `api-design` skill for full patterns. Key mobile specifics:

- Bearer token from config in every request
- Error class with `code` + `status` for domain-level mapping
- Handle 204 (no content) explicitly

### WebSocket

- Auto-reconnect with exponential backoff (max 30s, max 12 attempts)
- Ping every 30s to keep alive
- Auth diagnostics after 3 failed reconnects
- Base64 decode binary data with TextDecoder

### Deduplication

Track handled IDs in `useRef(new Set())` with max cache size to prevent memory leaks from overlapping REST + WebSocket data.

## 6. Accessibility

```tsx
<Pressable
  accessible={true}
  accessibilityLabel="Dismiss notification"
  accessibilityRole="button"
  accessibilityHint="Swipe right to dismiss"
  accessibilityState={{ disabled: isLoading }}
  onPress={handleDismiss}
/>
```

- Touch targets: **44x44pt minimum** (Apple HIG, non-negotiable)
- Expand icon hit areas with `padding: 12, margin: -12`
- `accessibilityLiveRegion="polite"` for dynamic content
- `accessibilityElementsHidden` for decorative images
- Color contrast: 4.5:1 text, 3:1 large text/interactive
- Never use color alone as indicator (add icon or text)

## 7. Platform-Specific Code

```tsx
const shadowStyle = Platform.select({
  ios: { shadowColor: '#000', shadowOffset: {width:0,height:2}, shadowOpacity: 0.1, shadowRadius: 4 },
  android: { elevation: 4 },
});
```

- Use `useSafeAreaInsets()` on every screen for notch/home indicator
- Platform-specific files: `Component.ios.tsx` / `Component.android.tsx`
- Guard native modules with try/catch on dynamic import:

```tsx
async function loadSpeechModule() {
  try { return (await import('expo-speech-recognition')).default; }
  catch { return null; }
}
```

## 8. Offline-First

| Layer | What | Tool |
|-------|------|------|
| Config | Preferences, tokens | AsyncStorage / SecureStore |
| API cache | Last-known data | AsyncStorage or MMKV |
| In-memory | Live feed, session | useRef / useState |
| Queue | Pending offline actions | AsyncStorage queue |

- Queue actions when offline, replay sequentially when connected (stop on first failure)
- Monitor connectivity with `@react-native-community/netinfo`
- Show clear offline indicator in UI
- Deduplication refs with max cache to prevent memory leaks

## 9. Security

- **Tokens**: `expo-secure-store` (not AsyncStorage)
- **Log redaction**: `token.slice(0,4)...token.slice(-2)`
- **Input validation**: trim + max length before API calls
- **URL validation**: check protocol before navigation
- **Permissions**: request at point of use, not startup
- **Graceful degradation**: if permission denied, show explanation + fallback

See `security-practices` skill for auth flows and broader patterns.

## 10. UX Patterns

### Loading
- Skeleton screens for lists (not spinners)
- Spinners for actions — always pair with `disabled` + `opacity: 0.55`

### Gestures
- Swipe: `react-native-gesture-handler` with `activeOffsetX` threshold
- Long press: `delayLongPress={400}` for secondary actions
- Pull to refresh: `RefreshControl` with themed `tintColor`

### Haptics
```tsx
import * as Haptics from 'expo-haptics';
Haptics.selectionAsync();                                    // selection, toggle
Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);     // confirm
Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning); // destructive
```

### Errors
- Map technical codes to user-friendly strings in `lib/domain/errors.ts`
- Show inline banners with retry button (never alerts)

## 11. Testing

- **Domain logic**: Jest pure function tests (no React needed)
- **Hooks**: `renderHook` from `@testing-library/react-native`
- **Components**: query by accessibility role/label (mirrors screen reader)
- **E2E**: Maestro or Detox for device flows

See `testing-strategy` skill for structure and coverage goals.

## Checklist

Before submitting mobile native code:

- [ ] `StyleSheet.create()` at module scope
- [ ] `useNativeDriver: true` on compatible animations
- [ ] Touch targets >= 44x44pt
- [ ] Safe area insets on screens
- [ ] Accessibility labels on interactive elements
- [ ] Native module imports guarded with try/catch
- [ ] Tokens in SecureStore (not AsyncStorage)
- [ ] Errors shown inline (not alerts)
- [ ] FlatList with keyExtractor + windowing
- [ ] Network reconnection with exponential backoff

## Related Skills

| Skill | When |
|-------|------|
| `clean-architecture` | Domain layer organization |
| `testing-strategy` | Test structure, coverage goals |
| `api-design` | HTTP client patterns |
| `security-practices` | Auth flows, data protection |
| `mobile-pwa-usability` | Web/PWA companion app |
